//
//  HomeVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "HomeVC.h"
#import "CommonUtil.h"
#import "FirstVC.h"
#import "ChatController.h"
#import "RoasterCells.h"


@interface HomeVC()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) IBOutlet UITableView *tblView;
@end

@implementation HomeVC{
    // For inband roaster fetch NSArray *allBuddies;
    NSMutableArray *buddiesAndLastMsgs;
}

-(void)viewDidLoad{
    [self setupHomeUI];
}

-(void)loadLastMessageForRoaster{
    
   buddiesAndLastMsgs = [Chat fetchLastMessageForAllRoaster:[self fetchedResultsController].fetchedObjects];
    [self.tblView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    /*
     // For inband Fetch Roster!
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(roasterFetched:) name:SRXMPP_RoasterFetchedNotification object:nil];
     [SRXMPP_Manager loadRoaster];*/
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadLastMessageForRoaster) name:SRXMPP_MessageReceivedNotification object:nil];
    [self loadLastMessageForRoaster];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[SRXMPP_Manager xmppvCardTempModule] removeDelegate:self];
}


-(void)setupHomeUI{
    //Logout
    self.navigationItem.hidesBackButton = YES;
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    
    //Edit profile
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithCustomView:logoutBtn];
    UIBarButtonItem *log = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
    
    [self.navigationItem setRightBarButtonItems:@[edit,log] animated:YES];
    
    //Add Buddy
    UIButton *addBuddy = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [addBuddy setTitle:@"Add Friend" forState:UIControlStateNormal];
    [addBuddy addTarget:self action:@selector(addBuddySentController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBuddy];
    

}

-(void)editAction{
    [self performSegueWithIdentifier:kFromHomeToEditProfileSegue sender:self];
}


-(void)logoutAction{
    [Common_Manager resetUDfromapplication];
    [SRXMPP_Manager disconnect];
    FirstVC *FstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"firstVCstoryboardID"];
    [self.navigationController setViewControllers:@[FstVC]];
}

-(void)addBuddySentController{
    [self performSegueWithIdentifier:kFromHomeToAddFriendSegue sender:self];
}
/*
 For Inband Roster Fetch
 
 -(void)roasterFetched:(NSNotification *)notification{
 NSDictionary *dic = [notification userInfo];
 allBuddies = [dic objectForKey:@"roaster"];
 [self.tblView reloadData];
 }*/

#pragma mark -- Tableview Delegate and Datasource---

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuse = @"cell";
    
    /*
     for inband roster fetch
     RoasterCells *cell = (RoasterCells *)[tableView dequeueReusableCellWithIdentifier:reuse];
     cell.lbl_roasterName.text = [allBuddies objectAtIndex:indexPath.row];
     return cell;*/
    
    NSMutableDictionary *dic = [buddiesAndLastMsgs objectAtIndex:indexPath.row];
    RoasterCells *cell = (RoasterCells *)[tableView dequeueReusableCellWithIdentifier:reuse];
    
    cell.lbl_roasterName.text = [dic valueForKey:@"jid"];
    cell.lbl_lastText.text = [dic valueForKey:@"msg"];
    cell.lbl_lastTextTime.text = [dic valueForKey:@"time"];
    
    NSData *imgData = [self imgForJid:[XMPPJID jidWithString:[dic valueForKey:@"jid"]]];
    if(imgData){
        cell.iv_roasterAvatar.image = [UIImage imageWithData:imgData];
    }
    else
        cell.iv_roasterAvatar.image = [UIImage imageNamed:@"avatarTemp"];
    
    cell.iv_roasterAvatar.clipsToBounds = YES;
    cell.iv_roasterAvatar.layer.masksToBounds = YES;
    cell.iv_roasterAvatar.layer.cornerRadius = 30;
    
    cell.lbl_numberOFUnread.hidden = YES;
    
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:kFromHomeToChatSegue sender:self];

    
    NSMutableDictionary *selectedUser = [buddiesAndLastMsgs objectAtIndex:indexPath.row];
    Common_Manager.chattingWithjid = [selectedUser objectForKey:@"jid"];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return buddiesAndLastMsgs.count;
}

#pragma mark -- Using Fetch request get Roaster ---

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [SRXMPP_Manager managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            NSLog(@"Error");
        }
        
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self loadLastMessageForRoaster];
}


#pragma mark -- Get image from JID --- 

-(NSData *)imgForJid:(XMPPJID *)jid{
    return [SRXMPP_Manager.xmppvCardAvatarModule photoDataForJID:jid];
}


@end
