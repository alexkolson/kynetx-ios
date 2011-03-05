//
//  MainViewController.h
//  kynetx-iOS
//
//  Created by Alex  on 1/4/11.
//  Copyright 2011 Kynetx. All rights reserved.
//

#import "kynetx.h"
@interface MainViewController : UIViewController <UITextFieldDelegate, KynetxDelegate, CLLocationManagerDelegate> {
	@private
	CLLocationManager* KNSLocationManager_;
	UILabel* devModeSwitchLabel_;
	UIButton* saveAppButton_;
	UIButton* deleteAllAppsButton_;
	UISwitch* devModeSwitch_;
	UITextField* inputField_;
	UITextView* appIDList_;
	NSString* message_;
	Kynetx* app_;
}

@property (nonatomic, retain) CLLocationManager *KNSLocationManager;
@property (nonatomic, retain) IBOutlet UILabel *devModeSwitchLabel;
@property (nonatomic, retain) IBOutlet UITextField *inputField;
@property (nonatomic, retain) IBOutlet UITextView *appIDList;
@property (nonatomic, retain) IBOutlet UIButton *saveAppButton;
@property (nonatomic, retain) IBOutlet UIButton	*deleteAllAppsButton;
@property (nonatomic, retain) IBOutlet UISwitch *devModeSwitch;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) Kynetx *app;

- (IBAction) saveAppID:(id)sender;
- (IBAction) deleteAllAppIDs:(id)sender;
- (void) notify:(NSString*)text andBadgeNumber:(NSString*)badgeNumber url:(NSString*)url;

@end
