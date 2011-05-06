//
//  DPFlickrManager.m
//
//  Created by David Porter on 5/3/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89	
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "DPFlickrManager.h"
#import "DPFlickrAuthorization.h"
#import "SFHFKeychainUtils.h"
static DPFlickrManager *_instance;
static __weak id<DPFlickrDelegate> _delegate;

@implementation DPFlickrManager
#pragma mark -
#pragma mark Singleton Methods

+ (DPFlickrManager*)sharedInstance
{
	@synchronized(self) {
		
        if (_instance == nil) {
			
            _instance = [[self alloc] init];
            
            // Allocate/initialize any member variables of the singleton class here
            // example
			//_instance.member = @"";
            
            
        }
    }
    return _instance;
}

- (id)init {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSucceededNotification) 
                                                 name:@"loginSucceededNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginFailedNotification) 
                                                 name:@"loginFailedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageUploadStartedNotification) 
                                                 name:@"imageUploadStartedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageUploadFailedNotification) 
                                                 name:@"imageUploadFailedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imagePublishedNotification) 
                                                 name:@"imagePublishedNotification"
                                               object:nil];
    
    return self;
}
+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_instance == nil) {
			
            _instance = [super allocWithZone:zone];			
            return _instance;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}

#pragma mark -
#pragma mark Custom Methods


+ (BOOL)isAuthorized
{
    DPFlickrAuthorization *dp = [DPFlickrAuthorization alloc];
    BOOL isTokenOk;
    if ([dp doesTokenExist]) {
        NSString *token = [dp retrieveToken];
        isTokenOk = [dp isTokenValid:token];
    }
    else {
        isTokenOk = NO;
    }
    return isTokenOk;
}
- (void)showloginScreenIn:(UIViewController *)view {
    DPFlickrAuthorization *loginView = [[DPFlickrAuthorization alloc]initWithNibName:@"DPFlickrAuthorization" bundle:nil];
    
    if ([self isiPad]) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30200
        loginView.modalPresentationStyle =  UIModalPresentationFormSheet;
#endif
    }
    else {
        loginView.modalPresentationStyle =  UIModalTransitionStyleCoverVertical;
    }
    
    [view presentModalViewController:loginView animated:YES];
    [loginView release];
}
- (void)uploadImage:(UIImage *)image withTitle:(NSString *)title withDescription:(NSString *)description {
    DPFlickrAuthorization *uploadRequestClass = [DPFlickrAuthorization alloc];
    [uploadRequestClass postImage:image withTitle:title withDescription:description];
    [uploadRequestClass release];
}
- (void)logout {
     [SFHFKeychainUtils deleteItemForUsername:@"DPFlickrToken" andServiceName:@"DPFlicker" error:nil];
}
- (void)uploadImage:(UIImage *)image {
    [self uploadImage:image withTitle:nil withDescription:nil];
}

#pragma mark -
#pragma mark Helpers
- (BOOL)isiPad {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30200
    BOOL deviceIsPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    return deviceIsPad;
#endif
    return NO;
}


#pragma mark -
#pragma mark Delegates
+ (id)delegate {
    
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
    
    _delegate = newDelegate;	
}
#pragma mark -
#pragma mark Listeners
- (void)loginSucceededNotification {
    if([_delegate respondsToSelector:@selector(loginSucceeded)])
		[_delegate loginSucceeded];
}
- (void)loginFailedNotification {
    if([_delegate respondsToSelector:@selector(loginFailed)])
		[_delegate loginFailed];
}
- (void)imageUploadStartedNotification {
    if([_delegate respondsToSelector:@selector(imageUploadStarted)])
		[_delegate imageUploadStarted];
}
- (void)imageUploadFailedNotification {
    if([_delegate respondsToSelector:@selector(imageUploadFailed)])
		[_delegate imageUploadFailed];
}
- (void)imagePublishedNotification {
    if([_delegate respondsToSelector:@selector(imagePublished)])
		[_delegate imagePublished];
}
@end
