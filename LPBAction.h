@interface LPBAction : NSObject {
}
- (void)actionOfKind:(NSString *)kind atBatteryLevel:(NSInteger)batteryLevel;
- (void)actionOfKind:(NSString *)kind atBatteryLevel:(NSInteger)batteryLevel fix:(BOOL)enabled;
@end

static BOOL enableTweak __unused= NO;
static BOOL enableFix = NO;
