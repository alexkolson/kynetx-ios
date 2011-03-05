//
//  kynetx_iOSAppDelegate.h
//  kynetx-iOS
//
//  Created by Alex  on 1/4/11.
//  Copyright 2011 Kynetx. All rights reserved.
//

@class MainViewController; // tell compiler to chill. It will be defined elsewhere.

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	@private
    UIWindow *window_;
}

@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

