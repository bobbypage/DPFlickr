//
//  PhotoUploaderViewController.m
//  PhotoUploader
//
//  Created by David Porter on 5/3/11.
//  Copyright 2011 David Porter Apps. All rights reserved.
//

#import "PhotoUploaderViewController.h"

@implementation PhotoUploaderViewController

- (void)dealloc
{
    [label release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [DPFlickrManager setDelegate:self];

    if ([DPFlickrManager isAuthorized]) {
        label.text = @"You are logged into Flickr";
    }
    else {
        label.text = @"You are not logged into Flickr";
    }
    [super viewDidLoad];
}
- (void)loginSucceeded {
    label.text = @"You are logged into Flickr";
}
- (void)imageUploadStarted {
    label.text = @"Loading...";
}
- (void)imagePublished {
    label.text = @"Uploaded!";
}
- (void)viewDidUnload
{
    [label release];
    label = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loginPressed:(id)sender {
    if (![DPFlickrManager isAuthorized]) {
        [[DPFlickrManager sharedInstance] showloginScreenIn:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, you can't do that because you're already logged into Flickr!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release]; 
    }
}
- (IBAction)logoutPressed:(id)sender {
    [[DPFlickrManager sharedInstance] logout];
    label.text = @"You are not logged into Flickr";
}
- (IBAction)postPhotoPressed:(id)sender {
    if ([DPFlickrManager isAuthorized]) {
        //Two ways to upload a photo:
        
      //  [[DPFlickrManager sharedInstance] uploadImage:[UIImage imageNamed:@"me-gusta.png"]]; //This is a quick way
        
      [[DPFlickrManager sharedInstance] uploadImage:[UIImage imageNamed:@"me-gusta.png"] withTitle:@"Me Gusta" withDescription:@"F7U12"]; //This is a way with a title + description  
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, you can't do that because you aren't logged into Flickr!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];   
    }
}

@end
