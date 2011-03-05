//
//  MainViewController.m
//  kynetx-iOS
//
//  Created by Alex  on 1/4/11.
//  Copyright 2011 Kynetx. All rights reserved.
//

#import "MainViewController.h"
#import "kynetx.h"


@implementation MainViewController
@synthesize devModeSwitchLabel = devModeSwitchLabel_,
			devModeSwitch = devModeSwitch_,
			inputField = inputField_, 
			appIDList = appIDList_,
			saveAppButton = saveAppButton_,
			deleteAllAppsButton = deleteAllAppsButton_,
			message = message_, 
			app = app_, 
			KNSLocationManager = KNSLocationManager_;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewDidLoad {
	// set inputField delegate, no appIDList delegate
	// because it is readonly
	self.inputField.delegate = self;
	self.KNSLocationManager = [[CLLocationManager alloc] init];
	self.KNSLocationManager.delegate = self;
	
	///////////////////////////////////////////////////////////
	// BETTER BATTERY LIFE
	///////////////////////////////////////////////////////////
	self.KNSLocationManager.distanceFilter = 1000; // measured in meters, lateral distance filter
	self.KNSLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // The friggity boo bop
	
	NSDictionary* appDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"apps"];
	[self setApp:[[Kynetx alloc] initWithApps:appDict eventDomain:@"mobile" delegate:self]];
	
	// optionally issue new session here...
	// [self.app setIssueNewSession:YES];
	
	[self.KNSLocationManager startUpdatingLocation];
	// we do not neccisarily have to check for non-nilness here
	// but it saves processing, because we dont bother to even
	// run the for loop if there are no storedAppID's
	NSArray* appIDs = [appDict allKeys];
	int count = [appIDs count];
	for (int i = 0; i < count; i++) {
		self.appIDList.text = [NSString stringWithFormat:@"%@\n%@", self.appIDList.text, [appIDs objectAtIndex:i]]; 
	}
	
	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// if touches occur outside textfield, kill first responder status
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.inputField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark Button Actions
- (IBAction) saveAppID:(id)sender {
	NSDictionary* existingStoredApps = [[NSUserDefaults standardUserDefaults] objectForKey:@"apps"];
	NSMutableDictionary* storedAppsAppended = [NSMutableDictionary dictionaryWithDictionary:existingStoredApps];
	NSString* devOrProd = [self.devModeSwitch isOn] ? @"dev":@"prod";
	[storedAppsAppended setObject:devOrProd forKey:self.inputField.text];
	
	// save it to defaults
	[[NSUserDefaults standardUserDefaults] setObject:storedAppsAppended forKey:@"apps"];
	UIAlertView* successAlert = [[[UIAlertView alloc] initWithTitle:@"Kynetx for iOS" 
												  message:@"Succesfully saved app information"
												  delegate:self 
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil] autorelease];
	[successAlert show];
	[self.app setApps:[[NSUserDefaults standardUserDefaults] objectForKey:@"apps"]];
}

- (IBAction) deleteAllAppIDs:(id)sender {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"apps"];
	UIAlertView* successAlert = [[[UIAlertView alloc] initWithTitle:@"Kynetx for iOS" 
												 message:@"Succesfully deleted stored app information"
												 delegate:self 
												 cancelButtonTitle:@"Ok" 
												 otherButtonTitles:nil] autorelease];
	[successAlert show];
}

#pragma mark -
#pragma mark Kynetx Delegate methods

- (void) didReceiveKNSDirectives:(NSArray *)KNSDirectives {
	for (NSDictionary* directive in KNSDirectives) {
		if ([[directive objectForKey:@"action"] isEqualToString:@"notify"]) {
			[self notify:[directive valueForKeyPath:@"options.text"] andBadgeNumber:[directive valueForKeyPath:@"options.badgeNumber"] url:[directive valueForKeyPath:@"options.url"]];
		}
	}
	NSLog(@"%@", KNSDirectives);
}

- (void) KNSRequestDidFailWithError:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark CoreLocation delegate methods 

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	UIDevice* thisDevice = [UIDevice currentDevice];
	
	NSString* oldLocationString = [NSString stringWithFormat:@"%f, %f", 
								   oldLocation.coordinate.latitude, 
								   oldLocation.coordinate.longitude];
	NSString* newLocationString = [NSString stringWithFormat:@"%f, %f",
								   newLocation.coordinate.latitude,
								   newLocation.coordinate.longitude];
	NSLog(@"%@", [newLocation.timestamp descriptionWithLocale:[NSLocale currentLocale]]);
	
	[self.app signal:@"location_updated" params:[NSDictionary dictionaryWithObjectsAndKeys:oldLocationString, @"oldLocation",
												 newLocationString, @"newLocation",
												 [thisDevice name], @"deviceName",
												 [thisDevice model], @"deviceModel",
												 [thisDevice systemVersion], @"iOSVersion",
												 [self.app sessionID], @"KNSSessionID",
												 [newLocation.timestamp descriptionWithLocale:[NSLocale currentLocale]], @"deviceTimestamp", nil]];
}

#pragma mark -
#pragma mark custom methods
- (void) notify:(NSString *)text andBadgeNumber:(NSString*)badgeNumber url:(NSString*)url {
	NSLog(@"Notifiying! %@", [badgeNumber class]);
	UILocalNotification* aNotification = [[[UILocalNotification alloc] init] autorelease];
	
	if (url != nil) {
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:url, @"url", nil];
		[aNotification setUserInfo:userInfo];
	}
	
	NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber* badgeNumberAsNumber = [formatter numberFromString:badgeNumber];
	[aNotification setAlertBody:text];
	[aNotification setAlertAction:@"View"];
	[aNotification setApplicationIconBadgeNumber:[badgeNumberAsNumber integerValue]];
	[[UIApplication sharedApplication] presentLocalNotificationNow:aNotification];
}

#pragma mark -
#pragma mark destructor


- (void) dealloc {
	[self.KNSLocationManager stopUpdatingLocation];
	[self.devModeSwitchLabel release];
	[self.inputField release];
	[self.appIDList release];
	[self.saveAppButton release];
	[self.deleteAllAppsButton release];
	[self.message release];
	[self.app release];
	[self.KNSLocationManager release];
    [super dealloc];
}


@end
