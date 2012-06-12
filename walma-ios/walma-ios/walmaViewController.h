//
//  walmaViewController.h
//  walma-ios
//
//  Created by Mikko Jokinen on 4.6.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface walmaViewController :  UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate>
{
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    UIImageView *imageView;
    UIButton *send;
    UIButton *gallery;
    UIButton *camera;
    BOOL newMedia;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *send;
@property (nonatomic, retain) IBOutlet UIButton *camera;
@property (nonatomic, retain) IBOutlet UIButton *galley;

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;
- (IBAction)sendImage:(id)sender;

@end
