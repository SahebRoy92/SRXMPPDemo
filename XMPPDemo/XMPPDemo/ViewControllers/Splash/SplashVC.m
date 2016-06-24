//
//  SplashVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "SplashVC.h"
#import "CommonUtil.h"
#import "FirstVC.h"

@implementation SplashVC

-(void)viewDidLoad{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    if([userDef_get(UDKEY_userFound) boolValue]){
       //user found
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAuthenticate:) name:SRXMPP_AuthenticateNotification object:nil];
        
        NSError *error;
        NSString *pass = userDef_get(SRXMPP_pass);
        [SRXMPP_Manager.xmppStream authenticateWithPassword:pass error:&error];
        
    }
    else {
        [self performSegueWithIdentifier:kFromSplashToLoginSegue sender:self];
    }
}


-(void)didAuthenticate:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    if([[dict objectForKey:@"success"]isEqualToString:@"1"]){
        [self performSegueWithIdentifier:kFromSplashToHomeSegue sender:self];
    }
    else {
        [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:@"Something went wrong!" andCompletionBlock:^NSArray *{
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [Common_Manager resetUDfromapplication];
                
                FirstVC *fstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"firstVCstoryboardID"];
                [self.navigationController setViewControllers:@[fstVC]];
                
            }];
            
            return @[action];

        } andViewController:self andStyle:UIAlertControllerStyleAlert];

    }
}


@end
