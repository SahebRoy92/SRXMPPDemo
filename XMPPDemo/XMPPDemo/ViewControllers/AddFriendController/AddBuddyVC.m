//
//  AddBuddyVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 19/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "AddBuddyVC.h"
#import "CommonUtil.h"
#import "AddBuddyPopup.h"

@interface AddBuddyVC()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AddbuddyProtocol>

@property (nonatomic,weak) IBOutlet UITableView *tbl_results;
@property (nonatomic,weak) IBOutlet UITextField *txt_userName;
@property (nonatomic,strong) UITapGestureRecognizer *ges_tap;
@end


@implementation AddBuddyVC{
    NSMutableArray *searchResults;
    NSDictionary *friendSelected;
}


#pragma mark - Life Cycle and Setup ---

-(void)viewDidLoad{
    [self setupVC];
}

-(void)setupVC{
    [self.txt_userName addTarget:self action:@selector(textfieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchUserFound:) name:SRXMPP_SearchUserNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark --- Tableview Delegate and Datasource---

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuse = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuse];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    
    cell.textLabel.text = [searchResults [indexPath.row] objectForKey:@"email"];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    friendSelected = searchResults[indexPath.row];
    [self openInterfaceForAddingBuddy];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchResults.count;
}

#pragma mark -- TextFields Delegate ----

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(!self.ges_tap){
        self.ges_tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endAllEditing)];
    }
    [self.view addGestureRecognizer:self.ges_tap];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:self.ges_tap];
}

-(void)endAllEditing{
    [self.view endEditing:YES];
}

-(void)textfieldDidChange:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    [SRXMPP_Manager searchRegisteredWithUserName:textField.text];
}


#pragma mark --- XMPP delegate --- 

-(void)searchUserFound:(NSNotification *)notification{
    
    NSDictionary *allusers = [notification userInfo];
    [searchResults removeAllObjects];
    searchResults = [[allusers objectForKey:@"item"] mutableCopy];
    [self removeSelfFromArray];
    [self.tbl_results reloadData];
}

-(void)removeSelfFromArray{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"_jid MATCHES %@", userDef_get(SRXMPP_jid)];
    NSArray *result = [searchResults filteredArrayUsingPredicate:pred];
    if(result.count >0){
        [searchResults removeObjectIdenticalTo:[result firstObject]];
    }
}


-(void)openInterfaceForAddingBuddy{
    
    AddBuddyPopup *popup = [[AddBuddyPopup alloc]initWithFrame:self.view.frame];
    [self.view addSubview:popup];
    popup.delegate = self;
    
}

#pragma mark - Add Buddy pop up delegate--- 

-(void)didClickOkWithNickname:(NSString *)nickName{
    [SRXMPP_Manager addBuddyWithJid:[friendSelected objectForKey:@"_jid"] andNickname:nickName];
    [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:@"Your buddy request has been sent!" andCompletionBlock:^NSArray *{
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:nil];
        return @[action];
        
    } andViewController:self andStyle:UIAlertControllerStyleAlert];
}

@end
