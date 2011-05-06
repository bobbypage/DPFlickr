//
//  DPFlickrManager.h
//
//  Created by David Porter on 5/3/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>
#define APIKey @"enter your api key here"
#define APISecret @"enter your api secret here"
@protocol DPFlickrDelegate <NSObject>
@optional
- (void)loginSucceeded;
- (void)loginFailed;
- (void)imageUploadStarted;
- (void)imageUploadFailed;
- (void)imagePublished;
@end

@interface DPFlickrManager : NSObject {
    
}

+ (DPFlickrManager*) sharedInstance;

//Public Properties/Methods
+ (BOOL)isAuthorized;
- (void)showloginScreenIn:(UIViewController *)view;
- (void)uploadImage:(UIImage *)image;
- (void)uploadImage:(UIImage *)image withTitle:(NSString *)title withDescription:(NSString *)description;
- (void)logout;
//Private Properties/Methods
- (BOOL)isiPad;
+(id)delegate;	
+(void)setDelegate:(id)newDelegate;
@end
