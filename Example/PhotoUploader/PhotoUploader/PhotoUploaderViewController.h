//
//  PhotoUploaderViewController.h
//  PhotoUploader
//
//  Created by David Porter on 5/3/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPFlickrManager.h"
@interface PhotoUploaderViewController : UIViewController <DPFlickrDelegate> {
    UILabel *label;
}
- (IBAction)loginPressed:(id)sender;
- (IBAction)postPhotoPressed:(id)sender;
- (IBAction)logoutPressed:(id)sender;
@end
