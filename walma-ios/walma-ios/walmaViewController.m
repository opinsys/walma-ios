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
@synthesize imageView, popoverController, toolbar, send, camera, galley;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *servername = [defaults stringForKey:@"walmaserver_preference"];
    NSLog(@"name before is %@", servername);
     if(servername == nil||servername.length <1){
        NSLog(@"servername %@", servername);
        servername = @"http://walmademo.opinsys.fi";
        [defaults setObject:servername forKey:@"walmaserver_preference"];
         NSLog(@"servername %@",[defaults stringForKey:@"walmaserver_preference"]);
    }

    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Camera"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(useCamera:)];
    UIBarButtonItem *cameraRollButton = [[UIBarButtonItem alloc] 
                                         initWithTitle:@"Camera Roll"
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(useCameraRoll:)];
    UIBarButtonItem *sendImageButton = [[UIBarButtonItem alloc] 
                                        initWithTitle:@"Send Image"
                                        style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(sendImage:)];
    NSArray *items = [NSArray arrayWithObjects: cameraButton,
                      cameraRollButton,sendImageButton, nil];
    
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

    /*
	 turning the image into a NSData object
	 getting the image back out of the UIImageView
	 setting the quality to 90
     */
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
  	NSData *imageData = UIImageJPEGRepresentation(imageView.image, 1.0);
	// setting up the URL to post to
    NSURL *url = [NSURL URLWithString:serverurl];
	
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    // Upload a file on disk
    
    // Upload an NSData instance
    //TODO we need json support for response string
    [request setPostValue:remotekey forKey:@"remotekey"];
    [request setData:imageData withFileName:@"myphoto.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response;
        response = [request responseString];
        NSArray *components = [response componentsSeparatedByString:@"\""];
        NSString *afterOpenBracket = [components objectAtIndex:3];
        
        NSLog(@"after %@",afterOpenBracket);
        NSLog(@"%@",[request responseString]);
        NSString * uri = [NSString stringWithFormat:@"http://walmademo.opinsys.fi%@",afterOpenBracket];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
//        [uri release];
//        [response release];
        imageData = nil;
        imageView.image = nil;
//        [imageData release];
//        [url release];
//        [request release];
        
    }  

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
            [popoverController release];
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
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)info
{
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"devicetype= %@",deviceType);
        if([deviceType isEqualToString:@"iPhone Simulator"] || [deviceType isEqualToString:@"iPhone"]){
        imageView.image = image;
        [picker dismissModalViewControllerAnimated:YES];
        }
    
       if([deviceType isEqualToString:@"iPad Simulator"]||[deviceType isEqualToString:@"iPad"]){
    [self.popoverController dismissPopoverAnimated:true];
    [popoverController release];
    
//    NSString *mediaType = [info
//                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    //    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
    //        UIImage *image = [info
    //                          objectForKey:UIImagePickerControllerOriginalImage];
    //        
    imageView.image = image;

      
    //        if (newMedia)
    //            UIImageWriteToSavedPhotosAlbum(image,
    //                                           self,  
    //                                           @selector(image:finishedSavingWithError:contextInfo:),
    //                                           nil);
    //    }
    //    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    //    {
    //        // Code here to support video if enabled
    //    }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
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
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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