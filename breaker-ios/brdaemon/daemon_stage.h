#ifndef _breaker_daemon_stage_h
#define _breaker_daemon_stage_h

#define STAGE_RESET					0
#define STAGE_DEVICE_INFO           1
#define STAGE_FAKE_DEVICE           2
#define STAGE_ACCOUNT        	    3
#define STAGE_IMS_REGISTER          4
#define STAGE_SWEEP_UP              5
#define STAGE_BREAK_IT              6
#define STAGE_UPLOAD_RESULT         7

// timeouts for stage
#define TIMEOUT_STAGE_SERVER_API      		30
#define TIMEOUT_STAGE_ACTIVATE_DEVICE       60
#define TIMEOUT_STAGE_OTHER_STEP            30
#define	TIMEOUT_STAGE_IMS_REGISTER          100      

#endif //_breaker_daemon_stage_h