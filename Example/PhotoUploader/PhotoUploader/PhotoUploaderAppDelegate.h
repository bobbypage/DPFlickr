//
//  PhotoUploaderAppDelegate.h
//  PhotoUploader
//
//  Created by David Porter on 5/3/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoUploaderViewController;

@interface PhotoUploaderAppDelegate : NSObject <UIApplicationDelegate> {
   
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PhotoUploaderViewController *viewController;

@end
