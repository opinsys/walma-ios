//
//  walmaViewController.m
//  walma-ios
//
//  Created by Mikko Jokinen on 4.6.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "walmaViewController.h"

@implementation walmaViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
#pragma mark -

-(IBAction)getCameraPicture:(id)sender{
    UIImagePickerController *picker =
    [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = (sender == takePictureButton) ?
    UIImagePickerControllerSourceTypeCamera :
    UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

-(IBAction)selectImage{
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
}

#pragma mark -

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    imageView.image = image;
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];   
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
