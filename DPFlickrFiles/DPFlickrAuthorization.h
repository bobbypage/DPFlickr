//
//  DPFlickrAuthorization.h
//
//  Created by David Porter on 4/9/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h" 
static const NSTimeInterval HUDMinShowTime = 1.0;
@interface DPFlickrAuthorization : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    BOOL hasAuthorized;
    MBProgressHUD *HUD;
}
- (NSString *) md5HexDigest: (NSString *) str;
- (NSString *) convertFrobToToken:(NSString *)frob;
- (BOOL)isTokenValid:(NSString *)token;
- (NSString *)scanXMLElement:(NSString *)element fromSource:(NSString *)fromSource;
- (void)postImage:(UIImage *)image withTitle:(NSString *)title withDescription:(NSString *)description;
- (NSString *)retrieveToken;
- (BOOL)doesTokenExist;
- (void)setToken:(NSString *)token;

#pragma mark -
#pragma mark HUD Activity Messaging

- (void)displayActivity:(NSString *)labelText;
- (void)hideHUD;
- (void)createHUD;
@end
