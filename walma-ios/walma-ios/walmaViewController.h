//
//  walmaViewController.h
//  walma-ios
//
//  Created by Mikko Jokinen on 4.6.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface walmaViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    UIButton *takePictureButton;
    UIImageView *imageView;
}
@property (nonatomic,retain)IBOutlet UIImageView *imageView;
@property (nonatomic,retain)IBOutlet UIButton *takePictureButton;
-(IBAction)getCameraPicture:(id)sender;
@end
