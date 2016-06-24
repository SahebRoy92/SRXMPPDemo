//
//  FirstVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "CommonUtil.h"
#import "FirstVC.h"

@implementation FirstVC

-(void)viewWillDisappear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidLoad{
    if(![SRXMPP_Manager.xmppStream isConnected]){
        [SRXMPP_Manager connect];
    }
       
}

@end
