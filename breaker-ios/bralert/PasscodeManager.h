#import <Foundation/Foundation.h>
#import "x/passcode.h"
#import "../src/Account.h"

@interface PasscodeManager : NSObject

@property (retain, nonatomic) Account *account;
@property (retain, nonatomic) RUIPasscodeView *passcodeView;

+ (instancetype)shared;

- (void)startWork;

- (BOOL)shouldPasscode;

@end