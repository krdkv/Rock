//
//  KRPhotoPickerVC.m
//  Rock
//
//  Created by Anton Chebotov on 05/04/14.
//  Copyright (c) 2014 Kusto. All rights reserved.
//

#import "KRPhotoPickerVC.h"
#import "DebugViewController.h"

@interface KRPhotoPickerVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	UIImagePickerController * _pickerController;
}

@property (weak) IBOutlet UIButton * takePhotoButton;
@property (weak) IBOutlet UIButton * usePhotoButton;

- (IBAction) takePhoto;
- (IBAction) usePhoto;
- (IBAction) skip;
@end

@implementation KRPhotoPickerVC


- (void)viewDidLoad
{
    [super viewDidLoad];

	_pickerController = [UIImagePickerController new];
	_pickerController.delegate = self;
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
		_takePhotoButton.hidden = YES;
	}
}

- (IBAction)takePhoto{
	_pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentViewController:_pickerController animated:YES completion:^{}];
}

- (IBAction) usePhoto{
	_pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	[self presentViewController:_pickerController animated:YES completion:^{}];
}

- (IBAction) skip{
	[self moveForwardWithImage:nil];
}

- (void) moveForwardWithImage:(UIImage *)image{
	[self dismissViewControllerAnimated:YES completion:^{}];
	DebugViewController * viewController = [[DebugViewController alloc] initWithNibName:@"DebugViewController" bundle:nil];
	[viewController setupWithImage:image];
	UINavigationController * navController = self.navigationController;
	[navController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	UIImage * image = info[UIImagePickerControllerOriginalImage];
	[self moveForwardWithImage:image];
}
@end
