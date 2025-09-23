#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void nk_clear_tmp_files(void);
FOUNDATION_EXPORT NSString* nk_device_description();
FOUNDATION_EXPORT void nk_imsg_kill(void);
FOUNDATION_EXPORT void nk_kill_process(NSString *processName);

// mad
FOUNDATION_EXPORT NSString* nk_get_path_from_container(NSString *recPath);
FOUNDATION_EXPORT void nk_clear_activation_records();
FOUNDATION_EXPORT void nk_mad_kill();
// keychain
FOUNDATION_EXPORT void kc_clear_apsd(void);
FOUNDATION_EXPORT int kc_clear_imsg(void);
FOUNDATION_EXPORT NSString* kc_auth_uuid(void);

// pem
FOUNDATION_EXPORT NSData* decode_pem_data(NSData *data, NSString *typeName);
