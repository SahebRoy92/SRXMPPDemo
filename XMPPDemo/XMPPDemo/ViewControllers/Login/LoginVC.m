//
//  LoginVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//


#import "LoginVC.h"
#import "CommonUtil.h"


@interface LoginVC()<UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UITextField *txt_username;
@property (nonatomic,weak) IBOutlet UITextField *txt_pass;

@end

@implementation LoginVC


-(void)viewDidLoad{
   
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAuthenticate:) name:SRXMPP_AuthenticateNotification object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark --- Textfield Delegate --- 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



#pragma mark -- Actions --

-(IBAction)loginAction:(id)sender{
    if(![Common_Manager checkForBlankStringsinAll:@[_txt_username,_txt_pass]]){
        //login
        [self setJidAndPass];
        
        if(!SRXMPP_Manager.xmppStream.isConnected){
            [SRXMPP_Manager connect];
        }else {
            NSError *error;
            [SRXMPP_Manager.xmppStream authenticateWithPassword:_txt_pass.text error:&error];
        }
    }else {
        
    }
}

-(void)didAuthenticate:(NSNotification *)notification{
    NSDictionary *dic = [notification userInfo];
    if([[dic objectForKey:@"success"]isEqualToString:@"1"]){
        //authenticate successfull
        [self performSegueWithIdentifier:kFromLoginToHomeSegue sender:self];
    }
    else {
        //something went wrong
        [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:@"Wrong username or pass" andCompletionBlock:^NSArray *{
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:nil];
            return @[action];
        } andViewController:self andStyle:UIAlertControllerStyleAlert];
    }
        
}




-(void)setJidAndPass{
    NSString *jid = [NSString stringWithFormat:@"%@@%@",_txt_username.text,SRXMPP_Hostname];
    [userDef setObject:[NSString stringWithFormat:@"%@",_txt_pass.text] forKey:SRXMPP_pass];
    [SRXMPP_Manager.xmppStream setMyJID:[XMPPJID jidWithString:jid]];
   
}



@end
