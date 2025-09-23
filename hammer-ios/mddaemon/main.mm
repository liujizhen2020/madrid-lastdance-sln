#import <Foundation/Foundation.h>
#import "Daemon.h"

static void _forever_loop();

int main(int argc, char **argv, char **envp) {
	Daemon *d = [Daemon new];
	[d start];
	
	_forever_loop();
	return 0;
}

void _forever_loop() 
{
	NSRunLoop *rl = [NSRunLoop currentRunLoop];
    BOOL ok = YES;
    while (ok){
        ok = [rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
