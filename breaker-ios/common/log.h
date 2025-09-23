#ifndef _my_log_h
#define _my_log_h

#define I(fmt,...)	NSLog(@"x-<I> %@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])
#define E(fmt,...)	NSLog(@"x-<E> %@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__])

#define I0(msg)	NSLog(@"x-<I> %@", msg)
#define E0(msg)	NSLog(@"x-<E> %@", msg)

#endif // _my_log_h
