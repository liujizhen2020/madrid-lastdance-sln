#import <Foundation/Foundation.h>

@interface PSPasscodeField:NSObject
- (void)setStringValue:(id)arg1;
@end

@interface RUIPasscodeView:NSObject
- (void)viewDidAppear:(bool)arg1;
- (id)passcodeField;
- (id)footerView;
- (void)footerView:(id)arg1 activatedLinkWithURL:(id)arg2;
@end