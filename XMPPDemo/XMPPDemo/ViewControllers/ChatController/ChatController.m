//
//  ChatController.m
//  XMPPDemo
//
//  Created by Saheb Roy on 24/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#define OFFSET_For_MSGSCROLl (self.tblView.bounds.size.height + OFFSET_for_ScrollMsg)
#define OFFSET_for_ScrollMsg 150

#import "ChatController.h"
#import "CommonUtil.h"
#import "ChatCell.h"
#import "AttachmentView.h"

@interface ChatController()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UIImageView *iv_avatarUser;
@property (nonatomic,weak) IBOutlet UILabel *lbl_nickName;
@property (nonatomic,weak) IBOutlet UILabel *lbl_currentStatus;


@property (nonatomic,weak) IBOutlet UITableView *tblView;
@property (nonatomic,weak) IBOutlet UIImageView *backGroundPic;
@property (nonatomic,weak) IBOutlet UITextView *txt_Chat;
@property (nonatomic,weak) IBOutlet UIView *topView;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *lc_tblbottom;
@property (nonatomic,strong) NSMutableArray *allChat;
@property (nonatomic,strong) UITapGestureRecognizer *tapToDismiss;

@property (nonatomic,strong) NSTimer *typingTimer;

@end


@implementation ChatController

#pragma mark -- Life Cycle

-(void)viewDidLoad{
    [self setupChatController];
    self.allChat = [[Chat fetchAllChatForjid:Common_Manager.chattingWithjid] mutableCopy];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(otherUservCardDidChange) name:SRXMPP_OtherUservCardUpdated object:nil];
    
    if (self.allChat.count > 0)
        [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    if (self.allChat.count > 0)
        [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}



-(void)setupChatController{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(messageRecieved:) name:SRXMPP_MessageReceivedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(typingStatus:) name:SRXMPP_StatusOfOtherUserNotification object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    self.tblView.estimatedRowHeight = 50.0;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    [self.navigationController setNavigationBarHidden:YES];
    self.lbl_nickName.text = [self getUserTalkingTo].nickname;
    self.iv_avatarUser.image = [self getUserTalkingTo].photo;
    
    if([self getUserTalkingTo].isOnline){
        self.lbl_currentStatus.text = @"Online";
    }
    else {
        self.lbl_currentStatus.text = @"Last Seen";
    }
}


-(XMPPUserCoreDataStorageObject *)getUserTalkingTo{
    
    
    return [[SRXMPP_Manager xmppRosterStorage]
            userForJID:[XMPPJID jidWithString:Common_Manager.chattingWithjid]
            xmppStream:[SRXMPP_Manager xmppStream]
            managedObjectContext:[SRXMPP_Manager managedObjectContext_roster]];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SRXMPP_OtherUservCardUpdated object:nil];
}

#pragma mark -- IBActions ---

-(IBAction)attachmentAction:(id)sender{
    
    NSLog(@"%f",self.tblView.contentOffset.y);
    NSLog(@"%f",self.tblView.contentSize.height);
    
    
    float yPos = self.topView.frame.size.height + self.topView.frame.origin.y;
    AttachmentView *attachMntView = [[AttachmentView alloc]initwithStartingPosition:yPos andFrame:self.view.frame];
    [self.topView addSubview:attachMntView];
    [self.view addSubview:attachMntView];
    [self.view bringSubviewToFront:attachMntView];
}

-(IBAction)settingsAction:(id)sender{
    
}

-(IBAction)goBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark --- Tableview Delegate n Datasource---

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *meChatMessage = @"mineMessageCellReuseID";
    static NSString *otherChatMessage = @"otherMessageCellReuseID";
    
    NSManagedObjectContext *dic = self.allChat[indexPath.row];
    ChatCell *cell;
    UIImage *image;
    
    
    if([[dic valueForKey:@"sender"]isEqualToString:[SRXMPP_Manager.xmppStream.myJID bare]]){
        cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:meChatMessage];
        
        image =  [[UIImage imageNamed:@"chatMyChat"] resizableImageWithCapInsets:UIEdgeInsetsMake(27.0f,15.0f,5.0f,13.0f) resizingMode:UIImageResizingModeStretch];
    }
    else {
        cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:otherChatMessage];
        image =  [[UIImage imageNamed:@"chatOtherChat"] resizableImageWithCapInsets:UIEdgeInsetsMake(27.0f,15.0f,5.0f,13.0f) resizingMode:UIImageResizingModeStretch];
    }
    cell.chatBubble.image = image;
    cell.lbl_msg.text = [dic valueForKey:@"msg"];
    cell.lbl_time.text = [dic valueForKey:@"time"];
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allChat.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}



#pragma mark -- TextView delegate ---

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    else {
        [SRXMPP_Manager sendTypingStatusToJid:Common_Manager.chattingWithjid andStatus:kChatTyping];
        return YES;
    }
}

-(void)keyboardDidChange:(NSNotification *)notification{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.lc_tblbottom.constant = self.view.bounds.size.height -  keyboardFrameBeginRect.origin.y ;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if(self.allChat.count > 1){
        [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.allChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(!self.tapToDismiss){
        self.tapToDismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    }
    [self.view addGestureRecognizer:self.tapToDismiss];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    [self.view removeGestureRecognizer:self.tapToDismiss];
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}


#pragma mark -- Messege sent and recieve --

-(IBAction)sendMessageAction:(id)sender{
    
    
    NSDictionary *dict = [SRXMPP_Manager sendMessageTo:Common_Manager.chattingWithjid andText:self.txt_Chat.text];
    [Chat insertIntoDB:dict];
    [self.allChat addObject:dict];
    
    [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0  ]] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    self.txt_Chat.text = @"";
}

-(void)messageRecieved:(NSNotification *)notification{
    NSLog(@"%@",[notification userInfo]);
    [self.allChat addObject:[notification userInfo]];
    
    NSLog(@"%f",self.tblView.contentOffset.y);
    NSLog(@"%f",self.tblView.contentSize.height);
    
    if(self.tblView.contentOffset.y < (self.tblView.contentSize.height-OFFSET_For_MSGSCROLl)){
        // user is scrolling up !
        [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0  ]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0  ]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allChat.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }

}

-(NSMutableArray *)allChat{
    if(_allChat == nil){
        _allChat = [NSMutableArray array];
    }
    return _allChat;
}

#pragma mark -- Change Notification of Status ---




-(void)typingStatus:(NSNotification *)notification{
    NSString *str = [[notification userInfo]objectForKey:@"status"];
    
    if([str isEqualToString:@"typing"]){
        //do typing
        [self setTypingStatus];
    }
    else if ([str isEqualToString:@"online"] || [str isEqualToString:@"available"]){
        //do online
        self.lbl_currentStatus.text = @"Online";
    }
    else {
        self.lbl_currentStatus.text = @"Last Seen...";
    }
    
}

-(void)setTypingStatus{
    if(self.typingTimer){
        [self.typingTimer invalidate];
        self.lbl_currentStatus.text = @"Online";
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(changeTypingStatusToOnline) userInfo:nil repeats:NO];
    self.lbl_currentStatus.text = @"Typing...";
}

-(void)changeTypingStatusToOnline{
    [self.typingTimer invalidate];
    self.lbl_currentStatus.text = @"Online";
}


#pragma mark -- vCard Other User updated -- 

-(void)otherUservCardDidChange{
    self.iv_avatarUser.image = [self getUserTalkingTo].photo;
}



@end
