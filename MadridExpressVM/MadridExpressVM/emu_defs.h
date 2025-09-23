//
//  emu_defs.h
//  AppleEmulator
//
//  Created by boss on 12/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#ifndef emu_defs_h
#define emu_defs_h


// progress
#define EMU_PROGRESS_SLEEPING       0
#define EMU_PROGRESS_QUERYING       1
#define EMU_PROGRESS_CONNECTING     2
#define EMU_PROGRESS_SENDING        3
#define EMU_PROGRESS_CONFIRMING     4
#define EMU_PROGRESS_WILL_RESET     11
#define EMU_PROGRESS_QUERY_FAIL     12



// send retry
#define MAX_RETRY_SEND_MESSAGE      2

#endif /* emu_defs_h */
