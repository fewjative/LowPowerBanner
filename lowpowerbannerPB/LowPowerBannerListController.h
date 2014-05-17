#import "PSViewController.h"
@interface LowPowerBannerListController: PSViewController <UITableViewDelegate, UIApplicationDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
	UITableView *tbView;
}
- (int)numberOfRows;
- (NSMutableArray *)levels;
@end

/*
@interface PSListController : PSViewController <UITableViewDelegate, UIApplicationDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
NSArray* _specifiers;
}
-(NSArray*)loadSpecifiersFromPlistName:(NSString*)plistName target:(id)target;
@end

@interface LowPowerBannerListController: PSListController{
	UITableView *tbView;
}
- (int)numberOfRows;
- (NSMutableArray *)levels;
@end
*/