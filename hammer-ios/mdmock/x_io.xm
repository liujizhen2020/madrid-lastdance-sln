#import <CoreFoundation/CoreFoundation.h>
#import <CydiaSubstrate.h>
#import "../src/Device.h"
#import "../src/NSData+FastHex.h"
#import "IOKit/IOKitLib.h"

static CFTypeRef (*origin_IORegistryEntryCreateCFProperty)(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);
CFTypeRef my_IORegistryEntryCreateCFProperty(int entry, CFStringRef key, CFAllocatorRef allocator, int options){
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... my_IORegistryEntryCreateCFProperty");
        return origin_IORegistryEntryCreateCFProperty(entry, key, allocator, options);
    }
	NSLog(@"my_IORegistryEntryCreateCFProperty key *%@*", key);
 
 	// key: IOPlatformSerialNumber
	if (CFEqual(key, CFSTR("IOPlatformSerialNumber"))){
		NSString *v = [[Device shared] SN];
        if (v){
            NSLog(@" _IORegistryEntryCreateCFProperty ~~~ SN %@", v);
		    return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
	}

	if (CFEqual(key, CFSTR("IOPlatformUUID"))){
		NSString *v = [[Device shared] UDID];
		if (v){
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~ UDID %@", v);
			return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);	
		}
    }

	if (CFEqual(key, CFSTR("IOMACAddress"))){
		NSString *v = [[Device shared] WIFI];
        if (v){
            NSString *vs = [[v stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
			NSData *hexData = [NSData dataWithHexString:vs];
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~ IOMACAddress %@", hexData);
		    return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexData);
        }
	}

	// // key: mac-address-wifi0
	if (CFEqual(key, CFSTR("mac-address-wifi0"))){
        NSString *wifi = [[Device shared] WIFI];
        wifi = [wifi stringByReplacingOccurrencesOfString:@":" withString:@""];
		NSData *v = [NSData dataWithHexString:wifi];
		if (v){
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~ WIFI %@", v);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)v);
		}
	}	

	// key: mac-address-bluetooth0
	if (CFEqual(key, CFSTR("mac-address-bluetooth0"))){
        NSString *bt = [[Device shared] BT];
        bt = [bt stringByReplacingOccurrencesOfString:@":" withString:@""];
		NSData *v = [NSData dataWithHexString:bt];
		if (v){
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~ BT %@", v);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)v);
		}
	}	

	// key: unique-chip-id
	if (CFEqual(key, CFSTR("unique-chip-id"))){
		NSData *v = [[Device shared] ECIDData];
		if (v){
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~ ECID %@", v);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)v);	
		}
	}

	// key: model
	if (CFEqual(key, CFSTR("model"))){
		NSString *v = [[Device shared] PT];
		NSLog(@" _IORegistryEntryCreateCFProperty ~~~ PT %@", v);
		NSData *data = [v dataUsingEncoding:NSUTF8StringEncoding];
		return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)data);
	}
	
	if (CFEqual(key, CFSTR("device-imei"))){
		NSString *v = [[Device shared] IMEI];
		if (v){
			NSData *vd = [v dataUsingEncoding:NSUTF8StringEncoding];
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~~ device-imei %@",vd);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)vd);
		}
    }

    if (CFEqual(key, CFSTR("die-id"))){
		NSData *v = [[Device shared] ECIDData];
		if (v){
			NSLog(@" _IORegistryEntryCreateCFProperty ~~~ die-id %@", v);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)v);	
		}
    }
		
	return origin_IORegistryEntryCreateCFProperty(entry, key, allocator, options);
}


CFTypeRef (*origin_IORegistryEntrySearchCFProperty)(io_registry_entry_t entry, const io_name_t  plane, CFStringRef  key, CFAllocatorRef allocator, IOOptionBits options);
static CFTypeRef my_IORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options) {
    CFTypeRef result = origin_IORegistryEntrySearchCFProperty(entry, plane, key, allocator, options);

	if (CFEqual(key, CFSTR("IOPlatformSerialNumber"))){
		NSString *v = [[Device shared] SN];
        if (v){
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ IOPlatformSerialNumber %@", v);
		    return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
	}

	if (CFEqual(key, CFSTR("IOPlatformUUID"))){
		NSString *v = [[Device shared] UDID];
		if (v){
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ UDID %@", v);
			return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);	
		}
    }

	if (CFEqual(key, CFSTR("IOMACAddress"))){
		NSString *v = [[Device shared] WIFI];
        if (v){
            NSString *vs = [[v stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
			NSData *hexData = [NSData dataWithHexString:vs];
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ IOMACAddress %@", hexData);
		    return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexData);
        }
	}
    
    if (CFEqual(key, CFSTR("serial-number"))){
		NSString *v = [[Device shared] SN];
		if (v){
			NSData *hexData = [v dataUsingEncoding:NSUTF8StringEncoding];
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ serial-number %@", hexData);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexData);
		}
    }

    if (CFEqual(key, CFSTR("mlb-serial-number"))){
		NSString *v = [[Device shared] MLBSN];
		if (v){
			NSData *vd = [v dataUsingEncoding:NSUTF8StringEncoding];
        	NSMutableData *paddedData = [NSMutableData dataWithLength:32];
        	[paddedData replaceBytesInRange:NSMakeRange(0, vd.length) withBytes:vd.bytes];
        	NSData *finalData = [paddedData copy];
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ mlb-serial-number %@", finalData);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)finalData);
		}
    }

    if (CFEqual(key, CFSTR("local-mac-address"))) {
		NSString *v = [[Device shared] WIFI];
		if (v){
			NSString *vs = [[v stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
			NSData *hexData = [NSData dataWithHexString:vs];
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ local-mac-address %@", hexData);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexData);;
		}
    }

    if (CFEqual(key,CFSTR("mac-address-wifi0"))){
		NSString *v = [[Device shared] WIFI];
		if (v){
			NSString *vs = [[v stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
			NSData *hexData = [NSData dataWithHexString:vs];
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ local-mac-address %@", hexData);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexData);
		}
    }
    
    if (CFEqual(key, CFSTR("device-imei"))){
		NSString *v = [[Device shared] IMEI];
		if (v){
			NSData *vd = [v dataUsingEncoding:NSUTF8StringEncoding];
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~~ device-imei %@",vd);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)vd);
		}
    }

    if (CFEqual(key, CFSTR("unique-chip-id"))){
		NSData *v = [[Device shared] ECIDData];
		if (v){
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ unique-chip-id %@", v);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)v);	
		}
    }

    if (CFEqual(key, CFSTR("die-id"))){
		NSData *v = [[Device shared] ECIDData];
		if (v){
			NSLog(@" _IORegistryEntrySearchCFProperty ~~~ die-id %@", v);
			return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)v);	
		}
    }
 
    if (CFEqual(key, CFSTR("model"))){
		NSString *v = [[Device shared] PT];
		NSLog(@" _IORegistryEntrySearchCFProperty ~~~ model %@", v);
		NSData *data = [v dataUsingEncoding:NSUTF8StringEncoding];
		return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)data);
	}
    return result;
}

%ctor{
	MSImageRef image;
    image = MSGetImageByName("/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit");
    NSLog(@"io image %p", image);

	void *ptr_IORegistryEntryCreateCFProperty =  MSFindSymbol(image, "_IORegistryEntryCreateCFProperty"); 
	if (ptr_IORegistryEntryCreateCFProperty != NULL){
		NSLog(@"found _IORegistryEntryCreateCFProperty");
	    MSHookFunction((void*)ptr_IORegistryEntryCreateCFProperty, (void*)my_IORegistryEntryCreateCFProperty, (void**)&origin_IORegistryEntryCreateCFProperty);
	}

	void *ptr_IORegistryEntrySearchCFProperty =  MSFindSymbol(image, "_IORegistryEntrySearchCFProperty"); 
	if (ptr_IORegistryEntrySearchCFProperty != NULL){
		NSLog(@"found _IORegistryEntrySearchCFProperty");
	    MSHookFunction((void*)ptr_IORegistryEntrySearchCFProperty, (void*)my_IORegistryEntrySearchCFProperty, (void**)&origin_IORegistryEntrySearchCFProperty);
	}
}