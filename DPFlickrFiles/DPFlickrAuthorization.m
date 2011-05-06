//
//  DPFlickrAuthorization.m
//
//  Created by David Porter on 4/9/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//

#import "DPFlickrAuthorization.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SFHFKeychainUtils.h"
#import "DPFlickrManager.h"
@implementation DPFlickrAuthorization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
- (NSURL *)url {
    //set up the authorization url that will be loaded
    NSString *APISig =  [self md5HexDigest:[NSString stringWithFormat:@"%@api_key%@permswrite",APISecret, APIKey]];
    NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/auth/?api_key=%@&perms=write&api_sig=%@", APIKey, APISig];
    NSURL *url = [NSURL URLWithString:urlString];

    //NSLog(@"%@", urlString);
    return  url;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (NSString *) convertFrobToToken:(NSString *)frob {
    NSString *signatureString = [NSString stringWithFormat:@"%@api_key%@frob%@methodflickr.auth.getToken", APISecret, APIKey, frob];
    NSString *finalToken;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.auth.getToken&api_key=%@&frob=%@&api_sig=%@", APIKey, frob, [self md5HexDigest:signatureString]]; 
    
    //set up the request
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error = [request error];
    NSString *response;
    
    [request startSynchronous];
    
    if (!error) {
        response = [request responseString];
        //NSLog(@"Response: %@", response);
    }
      
    finalToken = [self scanXMLElement:@"<token>" fromSource:response];
//    NSLog(@"Final Token: %@", finalToken);
    [self setToken:finalToken];
    
    [self hideHUD];
    
    return finalToken;
    
}
- (NSString *)scanXMLElement:(NSString *)element fromSource:(NSString *)fromSource {
    NSString *finalValue;
    if (element != nil) {
    NSScanner *scanner = [NSScanner scannerWithString:fromSource];
	[scanner scanUpToString:element intoString:nil];
	[scanner scanString:element intoString:nil];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<"] intoString:&finalValue];
    return finalValue;
    }
    else {
        return nil;
    }

}
- (void)setToken:(NSString *)token {
    NSString *signatureString = [NSString stringWithFormat:@"%@api_key%@auth_token%@methodflickr.auth.checkToken", APISecret, APIKey, token];
	NSString *urlString = [NSString stringWithFormat:
                           @"http://api.flickr.com/services/rest/?method=flickr.auth.checkToken&api_key=%@&auth_token=%@&api_sig=%@", 
                           APIKey, token, [self md5HexDigest:signatureString]];
    
    NSString *response;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error = [request error];
    [request startSynchronous];
    
    if (!error) {
        response = [request responseString];
    }
    
    NSString *returnedToken = [self scanXMLElement:@"<token>" fromSource:response];
    NSError *keychainError = nil;
    
    [SFHFKeychainUtils storeUsername:@"DPFlickrToken" andPassword:returnedToken forServiceName:@"DPFlicker" updateExisting:YES error:&keychainError]; 
    if (!keychainError && !error && returnedToken!=nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DPFlickr_tokenExists"];
    }
  
}
- (BOOL)isTokenValid:(NSString *)token {
    NSString *signatureString = [NSString stringWithFormat:@"%@api_key%@auth_token%@methodflickr.auth.checkToken", APISecret, APIKey, token];
	NSString *urlString = [NSString stringWithFormat:
                           @"http://api.flickr.com/services/rest/?method=flickr.auth.checkToken&api_key=%@&auth_token=%@&api_sig=%@", 
                           APIKey, token, [self md5HexDigest:signatureString]];

    NSString *response;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error = [request error];
    [request startSynchronous];
    
    if (!error) {
        response = [request responseString];
       // NSLog(@"%@" , response);
    }
    
    NSString *returnedToken = [self scanXMLElement:@"<rsp stat=" fromSource:response];    
    if (![returnedToken isEqualToString:@"\"fail\">\n\t"]) {
        return YES;
 
    }
    else {
        return NO;  
    }
}
- (NSString *)retrieveToken {
    NSError *error;
    return [SFHFKeychainUtils getPasswordForUsername:@"DPFlickrToken" andServiceName:@"DPFlicker" error:&error];
}
#pragma mark - View lifecycle
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *currentURL = [[request URL] absoluteString];
    //NSLog(@"%@",currentURL);
    
    //a bit hacky, but we are looking if the webview's url length is is more than 18 characters. This should only happen when the url is the flickr site url + frob + our api callback (should be set to FlickrAPI://) 
    
    //This solution is great because we don't have to open safari for the user to autheticante - they can do it in the app
    //But, if Flickr ever changes their url scheme, this may stop working
    
    NSUInteger characterCount = [currentURL length];
    if (characterCount >= 18) {
        if ([currentURL isEqualToString:@"http://m.flickr.com/#/home"] || [currentURL isEqualToString:@"http://www.flickr.com/"] ||  [currentURL isEqualToString:@"http://m.flickr.com/#/home"]) {
            //the user has not allowed the app to use it's account
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailedNotification" object:nil];
            [self dismissModalViewControllerAnimated:YES];
        }
        else {
    
    NSString *frob = [currentURL substringFromIndex:18];
    float frobFloat = [frob floatValue];
    
    if (frobFloat != 0) {
        //We have auntheticated  
        NSString *finalToken = [[[NSString alloc] init] autorelease];
        finalToken = [self convertFrobToToken:frob];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceededNotification" object:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoginStatus_DPFLickr"];
        [self dismissModalViewControllerAnimated:YES];
    }
        }
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self displayActivity:@""];

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHUD];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailedNotification" object:nil];

}
- (NSString *) md5HexDigest: (NSString *) str {
	
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}
- (void)viewDidLoad
{
    webView.delegate = self;
    webView.bounds = self.view.bounds;
    webView.frame = self.view.frame;

    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[self url]];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];  
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)postImage:(UIImage *)image withTitle:(NSString *)title withDescription:(NSString *)description {
    BOOL canUpload = [self isTokenValid:[NSString stringWithFormat:@"%@", [self retrieveToken]]];
    if (canUpload) {
        NSMutableArray *array;  
        array = [[NSMutableArray alloc] init];  
        //add all the possible upload attributions to an array 
        if (image != nil) {
            [array addObject:image];
        }
        if (title != nil) {
            [array addObject:title];
        }
        if (description != nil) {
            [array addObject:description];
        }
        [self performSelectorInBackground:@selector(uploadImage:) withObject:array]; //do the whole upload process in the background and send the array
        [array release];
    }
    else {
//        NSLog(@"User is not logged in, you are trying to upload a photo so please try to check if the user is logged in before uploading");
    }
}
- (BOOL)doesTokenExist {
    NSError *error;
    if ([SFHFKeychainUtils getPasswordForUsername:@"DPFlickrToken" andServiceName:@"DPFlicker" error:&error] != nil) {
        return YES;
    }
    else {
        return NO;
    }
}
- (void)uploadImage:(NSArray *)array {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    float items = [array count];
    
    UIImage *imagetoPost = nil;
    NSString *title = nil;
    NSString *description = nil;
    
    if (items > 0) {
        imagetoPost = [array objectAtIndex:0];
    }
    if (items > 1) {
        title = [array objectAtIndex:1];
    }
    if (items > 2) {
        description = [array objectAtIndex:2];
    }
    
    NSData *imageData = UIImagePNGRepresentation(imagetoPost);
	
	NSURL *URL = [NSURL URLWithString: @"http://api.flickr.com/services/upload/"] ;
	
	ASIFormDataRequest *post = [ASIFormDataRequest requestWithURL: URL] ;
	[post setRequestMethod:@"POST"] ;
	[post addPostValue:APIKey forKey: @"api_key"] ;
	[post addPostValue:[self retrieveToken] forKey: @"auth_token"] ;
	
	NSString *sigString = [NSString stringWithFormat: @"%@api_key%@auth_token%@", APISecret, APIKey, [self retrieveToken]];
    
    if (description && [description length])
    {
        [post addPostValue:description forKey: @"description"] ;
        sigString = [sigString stringByAppendingFormat: @"description%@", description] ;
    }
    
    if (title && [title length])
    {
        [post addPostValue: title forKey: @"title"] ;
        sigString = [sigString stringByAppendingFormat: @"title%@", title] ;
    }
    
    
    
    [post addPostValue:[self md5HexDigest:sigString] forKey: @"api_sig"] ;
    [post setData:imageData forKey:@"photo"];	
    [post setDidStartSelector: @selector(uploadStarted:)];
    [post setDidFinishSelector: @selector(uploadFinished:)];
    [post setDidFailSelector: @selector(uploadFailed:)];
    [post setDelegate:self] ;
    [post startSynchronous];
    [pool release];


}
- (void)uploadStarted:(ASIFormDataRequest *)post {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imageUploadStartedNotification" object:nil];
}
- (void)uploadFailed:(ASIFormDataRequest *)post {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imageUploadFailedNotification" object:nil];
}
- (void)uploadFinished:(ASIFormDataRequest *)post {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"imagePublishedNotification" object:nil];
}
- (void)displayActivity:(NSString *)labelText {
    [self createHUD];
    HUD.labelText = labelText;
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
}

- (void)hideHUD {
    [HUD hide:YES];
    [HUD removeFromSuperview];
}

- (void)createHUD {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:window];
	    HUD.userInteractionEnabled = NO;
        HUD.animationType = MBProgressHUDAnimationZoom;
        HUD.minShowTime = HUDMinShowTime;
    }
    if (HUD.superview != window) {
        if (HUD.superview) {
            [window removeFromSuperview];
        }
        [window addSubview:HUD];
    }
     
  }

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
