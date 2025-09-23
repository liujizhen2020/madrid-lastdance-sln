#import "hfs.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/sysctl.h>
#include <sys/resource.h>
#include <sys/vmmeter.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/disk.h>
#include <sys/loadable_fs.h>
#include <sys/attr.h>
#include <hfs/hfs_format.h>
#include <hfs/hfs_mount.h>
#include <err.h>

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <syslog.h>

/*
 * CommonCrypto provides a more stable API than OpenSSL guarantees;
 * the #define causes it to use the same API for MD5 and SHA1, so the rest of
 * the code need not change.
 */
#define COMMON_DIGEST_FOR_OPENSSL
#include <CommonCrypto/CommonDigest.h>

#include <libkern/OSByteOrder.h>

#include <CoreFoundation/CFString.h>

#include <uuid/uuid.h>

#define    HFS_BLOCK_SIZE            512


typedef struct FinderAttrBuf {
    u_int32_t info_length;
    u_int32_t finderinfo[8];
} FinderAttrBuf_t;


/* HFS+ internal representation of UUID */
typedef struct hfs_UUID {
    uint32_t high;
    uint32_t low;
} hfs_UUID_t;


void GenerateHFSVolumeUUID(hfs_UUID_t *hfsuu);
static int    SetVolumeUUIDRaw(const char *deviceNamePtr, hfs_UUID_t *hfsuu);
static int    SetVolumeUUIDAttr(const char *path, hfs_UUID_t *hfsuu);
static int    SetVolumeUUID(const char *deviceNamePtr, hfs_UUID_t *hfsuu);
static int    GetHFSMountPoint(const char *deviceNamePtr, char **pathPtr);

static int    GetEmbeddedHFSPlusVol(HFSMasterDirectoryBlock * hfsMasterDirectoryBlockPtr, off_t * startOffsetPtr);
static int    ReadHeaderBlock(int fd, void *bufptr, off_t *startOffset, hfs_UUID_t **finderInfoUUIDPtr);
static ssize_t    readAt( int fd, void * buf, off_t offset, ssize_t length );
static ssize_t    writeAt( int fd, void * buf, off_t offset, ssize_t length );



/* *************************************** DoChangeUUIDKey ******************************************
Purpose -
    This routine will change the UUID on the specified block device.
Input -
    theDeviceNamePtr - pointer to the device name (full path, like /dev/disk0s2).
Output -
    returns FSUR_IO_SUCCESS or else one of the FSUR_xyz error codes.
*************************************************************************************************** */
static int
DoChangeUUIDKey( const char * theDeviceNamePtr ) {
    int result;
    hfs_UUID_t newVolumeUUID;
    
    GenerateHFSVolumeUUID(&newVolumeUUID);

    result = SetVolumeUUID(theDeviceNamePtr, &newVolumeUUID);
    
    fprintf(stderr, "device %s has new UUID , ret = %d \n", theDeviceNamePtr, result);

    return result;
}




void GenerateHFSVolumeUUID(hfs_UUID_t *newuuid) {
    CC_SHA1_CTX context;
    char randomInputBuffer[26];
    unsigned char digest[20];
    time_t now;
    clock_t uptime;
    int mib[2];
    int sysdata;
    char sysctlstring[128];
    size_t datalen;
    double sysloadavg[3];
    struct vmtotal sysvmtotal;
    hfs_UUID_t hfsuuid;

    memset (&hfsuuid, 0, sizeof(hfsuuid));

    do {
        /* Initialize the SHA-1 context for processing: */
        CC_SHA1_Init(&context);
        
        /* Now process successive bits of "random" input to seed the process: */
        
        /* The current system's uptime: */
        uptime = clock();
        CC_SHA1_Update(&context, &uptime, sizeof(uptime));
        
        /* The kernel's boot time: */
        mib[0] = CTL_KERN;
        mib[1] = KERN_BOOTTIME;
        datalen = sizeof(sysdata);
        sysctl(mib, 2, &sysdata, &datalen, NULL, 0);
        CC_SHA1_Update(&context, &sysdata, datalen);
        
        /* The system's host id: */
        mib[0] = CTL_KERN;
        mib[1] = KERN_HOSTID;
        datalen = sizeof(sysdata);
        sysctl(mib, 2, &sysdata, &datalen, NULL, 0);
        CC_SHA1_Update(&context, &sysdata, datalen);

        /* The system's host name: */
        mib[0] = CTL_KERN;
        mib[1] = KERN_HOSTNAME;
        datalen = sizeof(sysctlstring);
        sysctl(mib, 2, sysctlstring, &datalen, NULL, 0);
        CC_SHA1_Update(&context, sysctlstring, datalen);

        /* The running kernel's OS release string: */
        mib[0] = CTL_KERN;
        mib[1] = KERN_OSRELEASE;
        datalen = sizeof(sysctlstring);
        sysctl(mib, 2, sysctlstring, &datalen, NULL, 0);
        CC_SHA1_Update(&context, sysctlstring, datalen);

        /* The running kernel's version string: */
        mib[0] = CTL_KERN;
        mib[1] = KERN_VERSION;
        datalen = sizeof(sysctlstring);
        sysctl(mib, 2, sysctlstring, &datalen, NULL, 0);
        CC_SHA1_Update(&context, sysctlstring, datalen);

        /* The system's load average: */
        datalen = sizeof(sysloadavg);
        getloadavg(sysloadavg, 3);
        CC_SHA1_Update(&context, &sysloadavg, datalen);

        /* The system's VM statistics: */
        mib[0] = CTL_VM;
        mib[1] = VM_METER;
        datalen = sizeof(sysvmtotal);
        sysctl(mib, 2, &sysvmtotal, &datalen, NULL, 0);
        CC_SHA1_Update(&context, &sysvmtotal, datalen);

        /* The current GMT (26 ASCII characters): */
        time(&now);
        strncpy(randomInputBuffer, asctime(gmtime(&now)), 26);    /* "Mon Mar 27 13:46:26 2000" */
        CC_SHA1_Update(&context, randomInputBuffer, 26);
        
        /* Pad the accumulated input and extract the final digest hash: */
        CC_SHA1_Final(digest, &context);
    
        memcpy(&hfsuuid, digest, sizeof(hfsuuid));
    } while ((hfsuuid.high == 0) || (hfsuuid.low == 0));

    /* now copy out the hfs uuid */
    memcpy (newuuid, &hfsuuid, sizeof (hfsuuid));

    return;
}


/*
    SetVolumeUUIDRaw
    
    Write a previously generated UUID to an unmounted volume, by doing direct
    access to the device.  Assumes the caller has already determined that a
    volume is not mounted on the device.

    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL, FSUR_UNRECOGNIZED
*/
static int
SetVolumeUUIDRaw(const char *deviceNamePtr, hfs_UUID_t *volumeUUIDPtr)
{
    int fd = 0;
    char * bufPtr;
    off_t startOffset;
    hfs_UUID_t *finderInfoUUIDPtr;
    int result;

    bufPtr = (char *)malloc(HFS_BLOCK_SIZE);
    if ( ! bufPtr ) {
        result = FSUR_UNRECOGNIZED;
        goto Err_Exit;
    }

    fd = open( deviceNamePtr, O_RDWR, 0);
    if (fd <= 0) {
#if TRACE_HFS_UTIL
        fprintf(stderr, "hfs.util: SetVolumeUUIDRaw: device open failed (errno = %d).\n", errno);
#endif
        result = FSUR_IO_FAIL;
        goto Err_Exit;
    }

    /*
     * Get the pointer to the volume UUID in the Finder Info
     */
    result = ReadHeaderBlock(fd, bufPtr, &startOffset, &finderInfoUUIDPtr);
    if (result != FSUR_IO_SUCCESS)
        goto Err_Exit;

    /*
     * Update the UUID in the Finder Info. Make sure to write out big endian.
     */
    finderInfoUUIDPtr->high = OSSwapHostToBigInt32(volumeUUIDPtr->high);
    finderInfoUUIDPtr->low = OSSwapHostToBigInt32(volumeUUIDPtr->low);

    /*
     * Write the modified MDB or VHB back to disk
     */
    result = writeAt(fd, bufPtr, startOffset + (off_t)(2*HFS_BLOCK_SIZE), HFS_BLOCK_SIZE);

Err_Exit:
    if (fd > 0) close(fd);
    if (bufPtr) free(bufPtr);
    
#if TRACE_HFS_UTIL
    if (result != FSUR_IO_SUCCESS) fprintf(stderr, "hfs.util: SetVolumeUUIDRaw: result = %d...\n", result);
#endif
    return (result == FSUR_IO_SUCCESS) ? FSUR_IO_SUCCESS : FSUR_IO_FAIL;
}


/*
    SetVolumeUUIDAttr
    
    Write a UUID to a mounted volume, by calling setattrlist().
    Assumes the path is the mount point of an HFS volume.

    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL
*/
static int
SetVolumeUUIDAttr(const char *path, hfs_UUID_t *volumeUUIDPtr)
{
    struct attrlist alist;
    struct FinderAttrBuf volFinderInfo;
    hfs_UUID_t *finderInfoUUIDPtr;
    int result;

    /* Set up the attrlist structure to get the volume's Finder Info */
    memset (&alist, 0, sizeof(alist));
    alist.bitmapcount = ATTR_BIT_MAP_COUNT;
    alist.reserved = 0;
    alist.commonattr = ATTR_CMN_FNDRINFO;
    alist.volattr = ATTR_VOL_INFO;
    alist.dirattr = 0;
    alist.fileattr = 0;
    alist.forkattr = 0;

    /* Get the Finder Info */
    result = getattrlist(path, &alist, &volFinderInfo, sizeof(volFinderInfo), 0);
    if (result) {
        result = FSUR_IO_FAIL;
        goto Err_Exit;
    }

    /* Update the UUID in the Finder Info. Make sure to swap back to big endian */
    finderInfoUUIDPtr = (hfs_UUID_t *)(&volFinderInfo.finderinfo[6]);
    finderInfoUUIDPtr->high = OSSwapHostToBigInt32(volumeUUIDPtr->high);
    finderInfoUUIDPtr->low = OSSwapHostToBigInt32(volumeUUIDPtr->low);

    /* Write the Finder Info back to the volume */
    result = setattrlist(path, &alist, &volFinderInfo.finderinfo, sizeof(volFinderInfo.finderinfo), 0);
    if (result) {
        result = FSUR_IO_FAIL;
        goto Err_Exit;
    }

    result = FSUR_IO_SUCCESS;

Err_Exit:
    return result;
}


/*
    SetVolumeUUID
    
    Write a UUID to an HFS, HFS Plus or HFSX volume.
    
    Determine whether an HFS volume is mounted on the given device.  If so, we
    need to use SetVolumeUUIDAttr to access the UUID through the filesystem.
    If there is no mounted volume, then do direct device access SetVolumeUUIDRaw.
    
    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL, FSUR_UNRECOGNIZED
 */
static int
SetVolumeUUID(const char *deviceNamePtr, hfs_UUID_t *volumeUUIDPtr) {
    int result;
    char *path = NULL;
    
    /*
     * Determine whether a volume is mounted on this device.  If it is HFS, then
     * get the mount point's path.  If it is non-HFS, then we can exit immediately
     * with FSUR_UNRECOGNIZED.
     */
    result = GetHFSMountPoint(deviceNamePtr, &path);
    if (result != FSUR_IO_SUCCESS)
        goto Err_Exit;
    
    fprintf(stderr, "GetHFSMountPoint path = %s \n", path);

    /*
     * Update the UUID.
     */
    if (path){
        fprintf(stderr, "SetVolumeUUIDAttr path = %s \n", path);
        result = SetVolumeUUIDAttr(path, volumeUUIDPtr);
    }else{
        fprintf(stderr, "SetVolumeUUIDRaw device name = %s \n", deviceNamePtr);
        result = SetVolumeUUIDRaw(deviceNamePtr, volumeUUIDPtr);
    }

Err_Exit:
    return result;
}


/*
    GetHFSMountPoint
    
    Given a path to a device, determine if a volume is mounted on that
    device.  If there is an HFS volume, return its path and FSUR_IO_SUCCESS.
    If there is a non-HFS volume, return FSUR_UNRECOGNIZED.  If there is
    no volume mounted on the device, set *pathPtr to NULL and return
    FSUR_IO_SUCCESS.

    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL, FSUR_UNRECOGNIZED
*/
static int
GetHFSMountPoint(const char *deviceNamePtr, char **pathPtr)
{
    int result;
    int i, numMounts;
    struct statfs *buf;
    
    /* Assume no mounted volume found */
    *pathPtr = NULL;
    result = FSUR_IO_SUCCESS;
    
    numMounts = getmntinfo(&buf, MNT_NOWAIT);
    if (numMounts == 0)
        return FSUR_IO_FAIL;
    
    for (i=0; i<numMounts; ++i) {
        if (!strcmp(deviceNamePtr, buf[i].f_mntfromname)) {
            /* Found a mounted volume; check the type */
            if (!strcmp(buf[i].f_fstypename, "hfs")) {
                *pathPtr = buf[i].f_mntonname;
                /* result = FSUR_IO_SUCCESS, above */
            } else {
                result = FSUR_UNRECOGNIZED;
            }
            break;
        }
    }
    
    return result;
}


/*
 --    GetEmbeddedHFSPlusVol
 --
 --    In: hfsMasterDirectoryBlockPtr
 --    Out: startOffsetPtr - the disk offset at which the HFS+ volume starts
                 (that is, 2 blocks before the volume header)
 --
 */

static int
GetEmbeddedHFSPlusVol (HFSMasterDirectoryBlock * hfsMasterDirectoryBlockPtr, off_t * startOffsetPtr)
{
    int        result = FSUR_IO_SUCCESS;
    u_int32_t    allocationBlockSize, firstAllocationBlock, startBlock, blockCount;

    if (OSSwapBigToHostInt16(hfsMasterDirectoryBlockPtr->drSigWord) != kHFSSigWord) {
        result = FSUR_UNRECOGNIZED;
        goto Return;
    }

    allocationBlockSize = OSSwapBigToHostInt32(hfsMasterDirectoryBlockPtr->drAlBlkSiz);
    firstAllocationBlock = OSSwapBigToHostInt16(hfsMasterDirectoryBlockPtr->drAlBlSt);

    if (OSSwapBigToHostInt16(hfsMasterDirectoryBlockPtr->drEmbedSigWord) != kHFSPlusSigWord) {
        result = FSUR_UNRECOGNIZED;
        goto Return;
    }

    startBlock = OSSwapBigToHostInt16(hfsMasterDirectoryBlockPtr->drEmbedExtent.startBlock);
    blockCount = OSSwapBigToHostInt16(hfsMasterDirectoryBlockPtr->drEmbedExtent.blockCount);

    if ( startOffsetPtr )
        *startOffsetPtr = ((u_int64_t)startBlock * (u_int64_t)allocationBlockSize) +
            ((u_int64_t)firstAllocationBlock * (u_int64_t)HFS_BLOCK_SIZE);

Return:
        return result;

}


/*
    ReadHeaderBlock
    
    Read the Master Directory Block or Volume Header Block from an HFS,
    HFS Plus, or HFSX volume into a caller-supplied buffer.  Return the
    offset of an embedded HFS Plus volume (or 0 if not embedded HFS Plus).
    Return a pointer to the volume UUID in the Finder Info.

    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL, FSUR_UNRECOGNIZED
*/
static int
ReadHeaderBlock(int fd, void *bufPtr, off_t *startOffset, hfs_UUID_t **finderInfoUUIDPtr)
{
    int result;
    HFSMasterDirectoryBlock * mdbPtr;
    HFSPlusVolumeHeader * volHdrPtr;

    mdbPtr = bufPtr;
    volHdrPtr = bufPtr;

    /*
     * Read the HFS Master Directory Block or Volume Header from sector 2
     */
    *startOffset = 0;
    result = readAt(fd, bufPtr, (off_t)(2 * HFS_BLOCK_SIZE), HFS_BLOCK_SIZE);
    if (result != FSUR_IO_SUCCESS)
        goto Err_Exit;

    /*
     * If this is a wrapped HFS Plus volume, read the Volume Header from
     * sector 2 of the embedded volume.
     */
    if (OSSwapBigToHostInt16(mdbPtr->drSigWord) == kHFSSigWord &&
        OSSwapBigToHostInt16(mdbPtr->drEmbedSigWord) == kHFSPlusSigWord) {
        result = GetEmbeddedHFSPlusVol(mdbPtr, startOffset);
        if (result != FSUR_IO_SUCCESS)
            goto Err_Exit;
        result = readAt(fd, bufPtr, *startOffset + (off_t)(2*HFS_BLOCK_SIZE), HFS_BLOCK_SIZE);
        if (result != FSUR_IO_SUCCESS)
            goto Err_Exit;
    }
    
    /*
     * At this point, we have the MDB for plain HFS, or VHB for HFS Plus and HFSX
     * volumes (including wrapped HFS Plus).  Verify the signature and grab the
     * UUID from the Finder Info.
     */
    if (OSSwapBigToHostInt16(mdbPtr->drSigWord) == kHFSSigWord) {
        *finderInfoUUIDPtr = (hfs_UUID_t *)(&mdbPtr->drFndrInfo[6]);
    } else if (OSSwapBigToHostInt16(volHdrPtr->signature) == kHFSPlusSigWord ||
                OSSwapBigToHostInt16(volHdrPtr->signature) == kHFSXSigWord) {
        *finderInfoUUIDPtr = (hfs_UUID_t *)&volHdrPtr->finderInfo[24];
    } else {
        result = FSUR_UNRECOGNIZED;
    }

Err_Exit:
    return result;
}

/*
 --    readAt = lseek() + read()
 --
 --    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL
 --
 */

static ssize_t
readAt( int fd, void * bufPtr, off_t offset, ssize_t length )
{
    int            blocksize;
    off_t        lseekResult;
    ssize_t        readResult;
    void *        rawData = NULL;
    off_t        rawOffset;
    ssize_t        rawLength;
    ssize_t        dataOffset = 0;
    int            result = FSUR_IO_SUCCESS;

    if (ioctl(fd, DKIOCGETBLOCKSIZE, &blocksize) < 0) {
#if TRACE_HFS_UTIL
        fprintf(stderr, "hfs.util: readAt: couldn't determine block size of device.\n");
#endif
        result = FSUR_IO_FAIL;
        goto Return;
    }
    /* put offset and length in terms of device blocksize */
    rawOffset = offset / blocksize * blocksize;
    dataOffset = offset - rawOffset;
    rawLength = ((length + dataOffset + blocksize - 1) / blocksize) * blocksize;
    rawData = malloc(rawLength);
    if (rawData == NULL) {
        result = FSUR_IO_FAIL;
        goto Return;
    }

    lseekResult = lseek( fd, rawOffset, SEEK_SET );
    if ( lseekResult != rawOffset ) {
        result = FSUR_IO_FAIL;
        goto Return;
    }

    readResult = read(fd, rawData, rawLength);
    if ( readResult != rawLength ) {
#if TRACE_HFS_UTIL
            fprintf(stderr, "hfs.util: readAt: attempt to read data from device failed (errno = %d)?\n", errno);
#endif
        result = FSUR_IO_FAIL;
        goto Return;
    }
    bcopy(rawData + dataOffset, bufPtr, length);

Return:
    if (rawData) {
        free(rawData);
    }
    return result;

} /* readAt */


/*
 --    writeAt = lseek() + write()
 --
 --    Returns: FSUR_IO_SUCCESS, FSUR_IO_FAIL
 --
 */

static ssize_t
writeAt( int fd, void * bufPtr, off_t offset, ssize_t length )
{
    int            blocksize;
    off_t        deviceoffset;
    ssize_t        bytestransferred;
    void *        rawData = NULL;
    off_t        rawOffset;
    ssize_t        rawLength;
    ssize_t        dataOffset = 0;
    int            result = FSUR_IO_SUCCESS;

    if (ioctl(fd, DKIOCGETBLOCKSIZE, &blocksize) < 0) {
#if TRACE_HFS_UTIL
        fprintf(stderr, "hfs.util: couldn't determine block size of device.\n");
#endif
        result = FSUR_IO_FAIL;
        goto Return;
    }
    /* put offset and length in terms of device blocksize */
    rawOffset = offset / blocksize * blocksize;
    dataOffset = offset - rawOffset;
    rawLength = ((length + dataOffset + blocksize - 1) / blocksize) * blocksize;
    rawData = malloc(rawLength);
    if (rawData == NULL) {
        result = FSUR_IO_FAIL;
        goto Return;
    }

    deviceoffset = lseek( fd, rawOffset, SEEK_SET );
    if ( deviceoffset != rawOffset ) {
        result = FSUR_IO_FAIL;
        goto Return;
    }

    /* If the write isn't block-aligned, read the existing data before writing the new data: */
    if (((rawOffset % blocksize) != 0) || ((rawLength % blocksize) != 0)) {
        bytestransferred = read(fd, rawData, rawLength);
        if ( bytestransferred != rawLength ) {
#if TRACE_HFS_UTIL
            fprintf(stderr, "writeAt: attempt to pre-read data from device failed (errno = %d)\n", errno);
#endif
            result = FSUR_IO_FAIL;
            goto Return;
        }
    }
    
    bcopy(bufPtr, rawData + dataOffset, length);    /* Copy in the new data */
    
    deviceoffset = lseek( fd, rawOffset, SEEK_SET );
    if ( deviceoffset != rawOffset ) {
        result = FSUR_IO_FAIL;
        goto Return;
    }

    bytestransferred = write(fd, rawData, rawLength);
    if ( bytestransferred != rawLength ) {
#if TRACE_HFS_UTIL
            fprintf(stderr, "writeAt: attempt to write data to device failed?!");
#endif
        result = FSUR_IO_FAIL;
        goto Return;
    }

Return:
    if (rawData) free(rawData);

    return result;

} /* writeAt */





int
hfs_change_disk_volume_uuid(const char *deviceNamePtr) {
    int ret = DoChangeUUIDKey(deviceNamePtr);
    NSLog(@"DoChangeUUIDKey ret = %d", ret);
    if (ret == FSUR_IO_SUCCESS){
        return 0;
    }
    return -1;
}
