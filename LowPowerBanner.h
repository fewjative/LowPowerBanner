@interface BBBulletin : NSObject <NSCopying, NSCoding>
@property(copy, nonatomic) NSSet *alertSuppressionAppIDs_deprecated; // @synthesize alertSuppressionAppIDs_deprecated;
@property(nonatomic) unsigned int realertCount_deprecated; // @synthesize realertCount_deprecated;
@property(retain, nonatomic) NSDate *lastInterruptDate; // @synthesize lastInterruptDate=_lastInterruptDate;
@property(copy, nonatomic) NSString *bulletinID; // @synthesize bulletinID=_bulletinID;
@property(retain, nonatomic) NSDate *expirationDate; // @synthesize expirationDate=_expirationDate;
@property(retain, nonatomic) NSDictionary *context; // @synthesize context=_context;
@property(nonatomic) BOOL expiresOnPublisherDeath; // @synthesize expiresOnPublisherDeath=_expiresOnPublisherDeath;
@property(copy, nonatomic) NSArray *buttons; // @synthesize buttons=_buttons;
@property(retain, nonatomic) NSMutableDictionary *actions; // @synthesize actions=_actions;
@property(copy, nonatomic) NSString *unlockActionLabelOverride; // @synthesize unlockActionLabelOverride=_unlockActionLabelOverride;
@property(nonatomic) BOOL clearable; // @synthesize clearable=_clearable;
@property(nonatomic) int accessoryStyle; // @synthesize accessoryStyle=_accessoryStyle;
@property(retain, nonatomic) NSTimeZone *timeZone; // @synthesize timeZone=_timeZone;
@property(nonatomic) BOOL dateIsAllDay; // @synthesize dateIsAllDay=_dateIsAllDay;
@property(nonatomic) int dateFormatStyle; // @synthesize dateFormatStyle=_dateFormatStyle;
@property(retain, nonatomic) NSDate *recencyDate; // @synthesize recencyDate=_recencyDate;
@property(retain, nonatomic) NSDate *endDate; // @synthesize endDate=_endDate;
@property(retain, nonatomic) NSDate *date; // @synthesize date=_date;
@property(nonatomic) int sectionSubtype; // @synthesize sectionSubtype=_sectionSubtype;
@property(nonatomic) int addressBookRecordID; // @synthesize addressBookRecordID=_addressBookRecordID;
@property(copy, nonatomic) NSString *publisherBulletinID; // @synthesize publisherBulletinID=_publisherBulletinID;
@property(copy, nonatomic) NSString *recordID; // @synthesize recordID=_publisherRecordID;
@property(copy, nonatomic) NSString *sectionID; // @synthesize sectionID=_sectionID;
@property(readonly, nonatomic) int primaryAttachmentType;
@property(copy, nonatomic) NSString *section;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *subtitle;
@property(copy, nonatomic) NSString *title;
@end

@interface NSObject ()
@property (assign,nonatomic) UIEdgeInsets clippingInsets;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *subtitle;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *sectionID;
@property (copy, nonatomic) id defaultAction;
+ (id)action;
+ (id)sharedInstance;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(NSInteger)arg3;
- (void)_replaceIntervalElapsed;
- (void)_dismissIntervalElapsed;
- (BOOL)containsAttachments;
- (void)setSecondaryText:(id)arg1 italicized:(BOOL)arg2;
- (int)_ui_resolvedTextAlignment;

- (UILabel *)tb_titleLabel;
- (void)tb_setTitleLabel:(UILabel *)label;
- (void)tb_setSecondaryLabel:(UILabel *)label;

@end

@interface SBAlert : UIViewController
+ (void)registerForAlerts;
- (BOOL)_isLockAlert;
- (void)_removeFromImpersonatedAppIfNecessary;
- (id)_impersonatesApplicationWithBundleID;
- (void)removeFromView;
- (void)alertViewIsReadyToDismiss:(id)dismiss;
- (void)setDisplay:(id)display;
- (void)setAlertDelegate:(id)delegate;
- (id)alertDelegate;
- (BOOL)_shouldDismissSwitcherOnActivation;
- (BOOL)suppressesControlCenter;
- (BOOL)suppressesNotificationCenter;
- (BOOL)suppressesBanners;
- (void)handleAutoLock;
- (BOOL)handleHeadsetButtonPressed:(BOOL)pressed;
- (BOOL)handleVolumeDownButtonPressed;
- (BOOL)handleVolumeUpButtonPressed;
- (BOOL)handleLockButtonPressed;
- (BOOL)hasTranslucentBackground;
- (BOOL)shouldPendAlertItemsWhileActive;
- (void)handleSlideshowHardwareButton;
- (BOOL)handleMenuButtonHeld;
- (BOOL)handleMenuButtonDoubleTap;
- (BOOL)handleMenuButtonTap;
- (void)animateDeactivation;
- (BOOL)currentlyAnimatingDeactivation;
- (void)didFinishAnimatingOut;
- (void)didFinishAnimatingIn;
- (void)didAnimateLockKeypadOut;
- (void)didAnimateLockKeypadIn;
- (id)legibilitySettings;
- (id)effectiveStatusBarStyleRequest;
- (int)effectiveStatusBarStyle;
- (id)statusBarStyleRequest;
- (int)starkStatusBarStyle;
- (int)statusBarStyle;
- (double)autoLockTime;
- (BOOL)managesOwnStatusBarAtActivation;
- (double)autoDimTime;
- (BOOL)allowsEventOnlySuspension;
- (BOOL)expectsFaceContactInLandscape;
- (BOOL)expectsFaceContact;
- (void)setExpectsFaceContact:(BOOL)contact inLandscape:(BOOL)landscape;
- (void)setExpectsFaceContact:(BOOL)contact;
- (double)accelerometerSampleInterval;
- (void)setAccelerometerSampleInterval:(double)interval;
- (BOOL)orientationChangedEventsEnabled;
- (void)setOrientationChangedEventsEnabled:(BOOL)enabled;
- (id)description;
- (void)deactivate;
- (int)interfaceOrientationForActivation;
- (void)activate;
- (int)statusBarStyleOverridesToCancel;
- (void)displayDidDisappear;
- (float)finalAlpha;
- (BOOL)showsSpringBoardStatusBar;
- (BOOL)undimsDisplay;
- (BOOL)allowsStackingOfAlert:(id)alert;
- (void)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (id)alertDisplayViewWithSize:(CGSize)size;
- (id)deactivationValue:(unsigned)value;
- (BOOL)deactivationFlag:(unsigned)flag;
- (void)setDeactivationSetting:(unsigned)setting value:(id)value;
- (void)setDeactivationSetting:(unsigned)setting flag:(BOOL)flag;
- (void)clearDeactivationSettings;
- (id)activationValue:(unsigned)value;
- (BOOL)activationFlag:(unsigned)flag;
- (void)setActivationSetting:(unsigned)setting value:(id)value;
- (void)setActivationSetting:(unsigned)setting flag:(BOOL)flag;
- (void)clearActivationSettings;
- (void)removeBackgroundStyleWithAnimationFactory:(id)animationFactory;
- (void)setBackgroundStyle:(int)style withAnimationFactory:(id)animationFactory;
- (int)customBackgroundStyle;
- (BOOL)wantsCustomBackgroundStyle;
- (BOOL)isWallpaperTunnelActive;
- (void)setWallpaperTunnelActive:(BOOL)active;
- (BOOL)displayFlag:(unsigned)flag;
- (id)displayValue:(unsigned)value;
- (void)setDisplaySetting:(unsigned)setting value:(id)value;
- (void)setDisplaySetting:(unsigned)setting flag:(BOOL)flag;
- (void)clearDisplaySettings;
- (void)dismissAlert;
- (void)clearDisplay;
- (void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
- (void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
- (void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
- (BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
- (void)didMoveToParentViewController:(id)parentViewController;
- (void)viewDidDisappear:(BOOL)view;
- (void)viewWillDisappear:(BOOL)view;
- (void)viewDidAppear:(BOOL)view;
- (void)viewWillAppear:(BOOL)view;
- (void)loadView;
- (BOOL)wantsFullScreenLayout;
- (id)_screen;
- (void)_setTargetScreen:(id)screen;
- (void)dealloc;
- (id)init;
- (BOOL)isRemote;
- (BOOL)matchesRemoteAlertService:(id)service options:(id)options;
- (id)effectiveViewController;
@end

@interface SBAlertView : UIView
- (void)alertWindowViewControllerResizedFromContentFrame:(CGRect)contentFrame toContentFrame:(CGRect)contentFrame2;
- (void)setAlert:(id)alert;
- (BOOL)shouldAddClippingViewDuringRotation;
- (void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
- (void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
- (void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
- (BOOL)isSupportedInterfaceOrientation:(int)orientation;
- (void)layoutForInterfaceOrientation:(int)interfaceOrientation;
- (BOOL)isAnimatingOut;
- (BOOL)shouldAnimateIn;
- (void)setShouldAnimateIn:(BOOL)animateIn;
- (BOOL)isReadyToBeRemovedFromView;
- (void)alertDisplayBecameVisible;
- (void)alertDisplayWillBecomeVisible;
- (void)dismiss;
- (id)alert;
- (id)initWithFrame:(CGRect)frame;
@end

@interface SBAwayBulletinListItem : NSObject
- (BBBulletin *)bulletinWithID:(NSString *)bulletinID;
@end

@interface SBLockScreenNotificationListController : NSObject
- (SBAwayBulletinListItem *)_listItemContainingBulletinID:(NSString *)bulletinID;
@end

@interface SBLockScreenView : SBAlertView
@end

@interface SBLockScreenViewController : SBAlert
- (SBLockScreenNotificationListController *)_notificationController;
- (void)setPasscodeLockVisible:(BOOL)visible animated:(BOOL)animated completion:(id)completion;
- (void)lockScreenView:(SBLockScreenView *)view didEndScrollingOnPage:(NSInteger)page;
@end

@interface SBLockScreenManager : NSObject
@property(readonly, assign, nonatomic) SBLockScreenViewController *lockScreenViewController;
+ (id)sharedInstance;
- (BOOL)isUILocked;
- (void)unlockUIFromSource:(NSInteger)source withOptions:(id)options;
- (void)_finishUIUnlockFromSource:(NSInteger)source withOptions:(id)options;
@end

@interface SBBulletinBannerController : NSObject
+ (id)sharedInstance;
- (id)newBannerViewForItem:(id)item;
- (void)_presentBannerForItem:(id)item;
- (void)_presentBannerView:(id)view;
@end

@interface SBBulletinBannerItem : NSObject
+ (id)itemWithBulletin:(id)bulletin;
+ (id)itemWithBulletin:(id)bulletin andObserver:(id)observer;
@end

typedef	struct {
	BOOL itemIsEnabled[23];
	BOOL timeString[64];
	int gsmSignalStrengthRaw;
	int gsmSignalStrengthBars;
	BOOL serviceString[100];
	BOOL serviceCrossfadeString[100];
	BOOL serviceImages[3][100];
	BOOL operatorDirectory[1024];
	unsigned serviceContentType;
	int wifiSignalStrengthRaw;
	int wifiSignalStrengthBars;
	unsigned dataNetworkType;
	int batteryCapacity;
	unsigned batteryState;
	BOOL notChargingString[150];
	int bluetoothBatteryCapacity;
	int thermalColor;
	unsigned thermalSunlightMode : 1;
	unsigned slowActivity : 1;
	unsigned syncActivity : 1;
	BOOL activityDisplayId[256];
	unsigned bluetoothConnected : 1;
	unsigned displayRawGSMSignal : 1;
	unsigned displayRawWifiSignal : 1;
	unsigned locationIconType : 1;
} _data;

@interface SBLowPowerAlertItem : NSObject
@end

@interface BBBulletinRequest : BBBulletin
@property(nonatomic) BOOL tentative;
@property(nonatomic) BOOL showsUnreadIndicator;
@property(nonatomic) unsigned int realertCount;
@property(nonatomic) int primaryAttachmentType; // @dynamic primaryAttachmentType;
@end

@interface SBAwayController : NSObject
+ (id)sharedAwayController;
- (BOOL)isLocked;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (BOOL)isBatteryCharging;
- (BOOL)isOnAC;
- (void)ACPowerChanged;
- (int)batteryCapacityAsPercentage;
- (float)batteryCapacity;
- (int)displayBatteryCapacityAsPercentage;
- (int)curvedBatteryCapacityAsPercentage;
@end

@interface SBBannerController : NSObject
+ (id)sharedInstance;
- (void)_presentBannerView:(id)view;
@end

typedef struct {
	int batteryCapacity;
} XXStruct_dUflDB;

@interface SBStatusBarDataManager : NSObject {
	XXStruct_dUflDB _data;
}
+ (id)sharedDataManager;
-(const XXStruct_dUflDB*)currentData;
@end

