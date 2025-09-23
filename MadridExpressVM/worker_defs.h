//
//  stage.h
//  BlackTrain
//
//  Created by boss on 24/07/2019.
//  Copyright © 2019 Fenda Casarinwa. All rights reserved.
//

#ifndef worker_defs_h
#define worker_defs_h

// args keys
#define MASTER_PORT_ARG_KEY     @"me_port"
#define CERT_BOX_DATA_ARG_KEY   @"me_cert"
#define QUERY_RESULTS_ARG_KEY   @"me_qret"
#define TARGETS_ARG_KEY         @"me_tgs"
#define TEXT_MESSAGE_ARG_KEY    @"me_text"
#define EMU_ID_ARG_KEY          @"me_emu_id"
#define SEND_INTERVAL_ARG_KEY   @"me_send_interval"
#define FINISH_WAIT_ARG_KEY     @"me_finish_wait"


// worker stage
#define WORKER_STAGE_READY         (uint8_t)0x10
#define WORKER_STAGE_SENT          (uint8_t)0x20
#define WORKER_STAGE_BLOCK         (uint8_t)0x30

#define WORKER_STAGE_GAME_OVER     (uint8_t)0x44


#endif /* worker_defs_h */
