# DPFlickr

---------------------------------------

This open source iOS library allows you to integrate Flickr into your iOS application on the iPhone, iPad and iPod touch.

## Integration
* First clone or download DPFlickr from GitHub
* Open the Example Project (Photo Uploader)
* Drag the group "DPFlickr Files" from the files pane in Xcode to your own Xcode Project (This will add the DPFlickrFiles, ASIHTTPRequest, MBProgressHUD, and the SFHKeychainUtils files to your project)
* Add the following frameworks (Your project name Build Phases > Link Binary With Libraries in Xcode 4)
  * `System Configuration.framework`
  * `MobileCoreServices.framework`
  * `CFNetwork.framework`
  * `Security.framework`
  * `Libz.1.2.3.dylib`
  * `libxml2.dylib`
    * Also add `UIKit.Framework`, `Foundation.Framework`, and `CoreGraphics.framework` (if you've removed it)
* Now add a Header Search Path of `$(SDKROOT)/usr/include/libxml2` (This is under your project > Build Settings > Search Paths> Header Search Paths in Xcode 4) 
* You're done! Now just add your APIKey and APISecret (More on this below) to DPFlickrManager.h and you're ready to start using DPFlickr. 

## Setting up your APIKeys
Start with getting your APIKey and APISecret from [http://www.flickr.com/services/apps/create/apply/](http://www.flickr.com/services/apps/create/apply/ "http://www.flickr.com/services/apps/create/apply/")

Enter the information Flickr asks about your app and click edit auth flow for this app.

Set your app type to "Web Application". Set your callback url to: FlickrAPI:// and hit save changes. 

Copy and paste your APIKey & APISecret to the corresponding values at the top of DPFlickrManager.h

## Using DPFlickr

Note: Most if not all features of DPFlickrManager are previewed in the example app (Photo Uploader) included.

You can refer to it if you ever get stuck or need help.

In header of file where you will be using DPFlickrManager, import it.
    `#import "DPFlickrManager.h"`

DPFlickr Manager is composed of three very important calls:
1. Checking if your user is logged into and authorized into Flickr or not
2. Showing a authorization view, that needs to be showed for your user to log in
3. Uploading a photo to Flickr
4. Logging out of Flickr

Let's examine each of these separate calls more closely:

Checking if your user is logged in or not is a simple call of:

    if ([DPFlickrManager isAuthorized]) {
    
    //The user is logged in
    }
    else {
    
    //The user isn't logged in
    }

Start with checking if the user is authorized (has already logged in) to Flickr

If the user hasen't logged into Flickr you should probably show the login screen so the user can authenticate.

This would be an example of a login button's method:

    - (IBAction)loginPressed:(id)sender {
        [DPFlickrManager setDelegate:self];
        if (![DPFlickrManager isAuthorized]) {
            [[DPFlickrManager sharedInstance] showloginScreenIn:self];
        }
        else {
        
        }
    }
Remember DPFlickr has a delegate to tell you about the current status about the users photo upload or authorization process!

Just remember to set DPFlickrManager's delegate to your .m or else you won't receive any of these delegate calls! You can set the delegate of DPFlickrManager with a simple call of

    [DPFlickrManager setDelegate:self];
    
These are the possible delegate calls that you can implement:

`- (void)loginSucceeded;`
`- (void)loginFailed;`
`- (void)imageUploadStarted;`
`- (void)imageUploadFailed;`
`- (void)imagePublished;`

Now after the user has logged in, you can use a method like the one below to post a image to facebook.

    - (IBAction)postPhotoPressed:(id)sender {
        if ([DPFlickrManager isAuthorized]) {
            //Two ways to upload a photo
            [[DPFlickrManager sharedInstance] uploadImage:[UIImage imageNamed:@"me-gusta.png"]]; //This is a quick way
        }
    }
    
Lastly logging out of Flickr is the call below. This removes the Flickr token from the keychain, logging the user out.

    [[DPFlickrManager sharedInstance] logout];

Remember, if you want updates about errors or when the photo get finished uploaded remember to use DPFlickrManager's Delegate (Methods Above)

Also, there are two different methods you can use to upload photos. One of them is a quick method and dosen't supply a title & description while the other one does.

These two methods are:
`- (void)uploadImage:(UIImage *)image;`
`- (void)uploadImage:(UIImage *)image withTitle:(NSString *)title withDescription:(NSString *)description;`

So you're postPhotoMethod could also look something like this:

    - (IBAction)postPhotoPressed:(id)sender {
        if ([DPFlickrManager isAuthorized]) {
          [[DPFlickrManager sharedInstance] uploadImage:[UIImage imageNamed:@"me-gusta.png"] withTitle:@"Me Gusta" withDescription:@"F7U12 Rage Face"]; //This is a way with a title + description  
        }
        else {
    	  //The user isn't authorized. The user should log in!
        }
    }

Lastly, I've tested DPFlickr on 3.2>, so feel free to set your deployment target to 3.2. It should also work on <3.2, but I haven't tested it.

Credits & Thanks
---------------------------------------
DPFlickr is created by David Porter [@bobbypage](http://twitter.com/bobbypage)

I would also like to thank pokeb for his awesome library [ASIHTTPRequest](https://github.com/pokeb/asi-http-request), jdg for [MBProgressHUD](https://github.com/jdg/MBProgressHUD) and Buzz Andersen & Justin Williams for [SFHFKeychainUtils](https://github.com/ldandersen/scifihifi-iphone).

License
---------------------------------------
Copyright (C) 2011, David Porter (David Porter Apps

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

tl;dr: You can do whatever the hell you want with this code. If it blows up I'm not responsible, you are. Also, I'd be nice if you can show some appreciation by tweeting me on [twitter](http://twitter.com/bobbypage) or crediting me in your app.

Thanks!