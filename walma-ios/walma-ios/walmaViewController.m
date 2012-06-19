//
//  walmaViewController.m
//  walma-ios
//
//  Created by Mikko Jokinen on 4.6.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "walmaViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation walmaViewController
@synthesize imageView, popoverController, toolbar, send, camera, galley,activityIndicator,sendLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"ruutu latautui");
    sendLabel.hidden = YES;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *servername = [defaults stringForKey:@"walmaserver_preference"];
    NSString *cameraString = NSLocalizedString(@"CAMERA", nil);
    NSLog(@"name before is %@", servername);
     if(servername == nil||servername.length <1){
        NSLog(@"servername %@", servername);
        servername = @"http://walmademo.opinsys.fi";
        [defaults setObject:servername forKey:@"walmaserver_preference"];
         NSLog(@"servername %@",[defaults stringForKey:@"walmaserver_preference"]);
    }


    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:cameraString
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(useCamera:)];
    UIBarButtonItem *cameraRollButton = [[UIBarButtonItem alloc] 
                                         initWithTitle:NSLocalizedString(@"ROLL", nil)
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(useCameraRoll:)];
    UIBarButtonItem *sendImageButton = [[UIBarButtonItem alloc] 
                                        initWithTitle:@"Send Image"
                                        style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(sendImage:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [NSArray arrayWithObjects: cameraButton,
                      cameraRollButton,flexibleSpace,sendImageButton, nil];
    cameraRollButton.title = NSLocalizedString(@"ROLL", nil);
    
    [toolbar setItems:items animated:NO];

    [cameraButton release];
    [cameraRollButton release];
    [sendImageButton release];
    [super viewDidLoad];
}

- (void)viewDidUnload {
    self.imageView = nil;
    self.popoverController = nil;
    self.toolbar = nil;
}
- (void)dealloc
{
    [toolbar release];
    [popoverController release];
    [imageView release];
    [super dealloc];
    
    
}
-(IBAction)sendImage:(id)sender
{
    [self imageSending];

}
- (IBAction)useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        //imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker
                                animated:YES];
        [imagePicker release];
    
        newMedia = YES;
    }
    
    
    
    
}


- (IBAction) useCameraRoll: (id)sender
{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]||[deviceType isEqualToString:@"iPad Simulator"] ){
        NSLog(@"devicetype= %@",deviceType);
        
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        } else {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *picker =
                [[UIImagePickerController alloc] init];
                
                picker.delegate = self;
//                picker.allowsEditing = YES;
                picker.sourceType = (sender == camera) ?
                UIImagePickerControllerSourceTypeCamera :
                UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                self.popoverController = [[UIPopoverController alloc]
                                          initWithContentViewController:picker];
                
                popoverController.delegate = self;
                
                [self.popoverController 
                 presentPopoverFromBarButtonItem:sender
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                 animated:YES];
                [picker release];
               
             
            }
        }
    }
    if([deviceType isEqualToString:@"iPhone Simulator"]||[deviceType isEqualToString:@"iPhone"]){
        if([UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary]){
            UIImagePickerController *picker =
            [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:picker animated:YES];
            [picker release];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"error accessing gallery"
                                  message:@"devicedoes not support gallery"
                                  delegate:nil
                                  cancelButtonTitle:@"Dismis"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        } 
        
        
        NSLog(@"devicetype= %@",deviceType);
    }
     NSLog(@"tee jotain");
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)info
{
    
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"devicetype picker= %@",deviceType);
    if([deviceType isEqualToString:@"iPhone Simulator"] || [deviceType isEqualToString:@"iPhone"]){
        imageView.image = image;
        [picker dismissModalViewControllerAnimated:YES];
        [self performSelectorOnMainThread:@selector(imageSending) withObject:nil waitUntilDone:YES];
    }
    
    if([deviceType isEqualToString:@"iPad Simulator"]||[deviceType isEqualToString:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:true];
        [popoverController release];
        imageView.image = image;
        [self dismissModalViewControllerAnimated:YES];
        [self performSelectorOnMainThread:@selector(imageSending) withObject:nil waitUntilDone:YES];
    }
    [deviceType release];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)imageSending{
    

    //here we load servername from preferences
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *servername = [[NSUserDefaults standardUserDefaults] stringForKey:@"walmaserver_preference"];
    if(servername == nil||servername ==@""){
        NSLog(@"servername %@", servername);
        servername = @"http://walmademo.opinsys.fi";
        [defaults setObject:servername forKey:@"walmaserver_preference"];
        
    }
    NSString *serverurl = [NSString stringWithFormat:@"%@/api/create_multipart",servername];
    NSString *remotekey = [[NSUserDefaults standardUserDefaults] stringForKey:@"remotekey_preference"];
    /*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
	 setting the quality to 100
     */
    NSData *imageData = UIImageJPEGRepresentation(imageView.image, 1.0);
	// setting up the URL to post to
    NSURL *url = [NSURL URLWithString:serverurl];
    //Form request with AsiFormDataRequest library
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    // Upload an NSData instance
    //TODO we need json support for response string
    //we set remote key for walma watcher program
    [request setPostValue:remotekey forKey:@"remotekey"];
    //imageData is set for form
    [request setData:imageData withFileName:@"myphoto.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    //request is made
//    [request startSynchronous];
    [request startAsynchronous];
    [activityIndicator startAnimating];
    self.sendLabel.text = NSLocalizedString(@"SENDING", nil);
    sendLabel.hidden = NO;
    activityIndicator.hidden = NO;
       //        [uri release];
        //        [response release];
        //        [imageData release];
        //        [url release];
        //   
        
    
    //would be nice to set error handling and return errors for users
    
}

- (void)requestDone:(ASIHTTPRequest *)request
{
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    sendLabel.hidden = YES;
    NSError *error = [request error];
    if (!error) {
        NSString *response;
        response = [request responseString];
        NSArray *components = [response componentsSeparatedByString:@"\""];
        NSString *walmaUrl = [components objectAtIndex:3];
        
        NSLog(@"after %@",response);
        NSLog(@"%@",[request responseString]);
        imageView.image = nil;
        
        NSString * uri = [NSString stringWithFormat:@"http://walmademo.opinsys.fi%@",walmaUrl];
  
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
        
    NSLog(@"latautuminen valmistui");
    }
    }

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"testi");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"testi2");
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end