//
//  WCViewController.m
//  WCActionSheet
//
//  Created by Wojciech Czekalski on 27.02.2014.
//  Copyright (c) 2014 Wojciech Czekalski. All rights reserved.
//

#import "WCViewController.h"
#import "WCActionSheet.h"

@interface WCViewController () <WCActionSheetDelegate>

@end

@implementation WCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentActionSheet:(id)sender {
    WCActionSheet *actionSheet = [[WCActionSheet alloc] initWithDelegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
    [actionSheet addButtonWithTitle:@"Hi!" actionBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hi!" message:@"My name is Wojtek and I made it" delegate:nil cancelButtonTitle:@"okay" otherButtonTitles: nil];
        [alert show];
    }];
    [actionSheet addButtonWithTitle:@"Bye"];
    [actionSheet show];
}

- (void)actionSheetCancel:(WCActionSheet *)actionSheet {

}

- (void)actionSheet:(WCActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    ;
}

- (void)actionSheet:(WCActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    ;
}

- (void)actionSheet:(WCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    ;
}

- (void)willPresentActionSheet:(WCActionSheet *)actionSheet {
    ;
}

- (void)didPresentActionSheet:(WCActionSheet *)actionSheet {
    ;
}

@end