//
//  EditProfileVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 31/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#define TXTFIELD_TAG 2500

#import "EditProfileVC.h"
#import "CommonUtil.h"


@interface EditProfileVC ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,weak) IBOutlet UITableView *tblView;
@property (nonatomic,strong) UIImagePickerController *imageController;
@property (nonatomic,strong) UITapGestureRecognizer *tapGes;
@property (nonatomic,strong) UIImage *avatarPic;

@end

@implementation EditProfileVC{
    
    NSArray *allPlaceHolderName;
    NSString *ownFullname;
    NSString *ownNickName;
    
    XMPPvCardTemp *tempOwnVCard;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    allPlaceHolderName = @[@"Nickname",@"Full Name"];
    self.tblView.estimatedRowHeight = 300;
    [self autoFillData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)autoFillData{
    
    tempOwnVCard = SRXMPP_Manager.xmppvCardTempModule.myvCardTemp;
    ownNickName = tempOwnVCard.nickname;
    ownFullname = tempOwnVCard.formattedName;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [SRXMPP_Manager.xmppvCardAvatarModule photoDataForJID:[SRXMPP_Manager.xmppStream myJID]];
        self.avatarPic = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblView reloadData];
        });
    });
}



#pragma mark -- Tableview Datasource -- delegate -

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *avatarCell = @"reuseCellUpdateAvatar";
    static NSString *txtCells = @"reuseCellUpdatetxt";
    static NSString *doneBtnCells = @"reuseCellUpdateBtn";
    switch (indexPath.row) {
        case 0:{
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:avatarCell];
            UIImageView *imgV = [cell.contentView viewWithTag:100];
            imgV.backgroundColor = [UIColor blackColor];
            imgV.image = self.avatarPic;
            imgV.layer.cornerRadius = 60;
            imgV.layer.masksToBounds = YES;
            imgV.clipsToBounds = YES;
            imgV.userInteractionEnabled = YES;
            
            
            self.tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionForUpdatePicture)];
            [imgV addGestureRecognizer:self.tapGes];
            
            return cell;
            //image
            break;
        }
        case 3:{
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:doneBtnCells];
            UIButton *btn = [cell.contentView viewWithTag:200];
            [btn addTarget:self action:@selector(updateProfile) forControlEvents:UIControlEventTouchUpInside];
            return cell;
            // btn
        }
        default:{
            //textfields
            
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:txtCells];
            UITextField *txtF = [cell.contentView viewWithTag:1];
            if(!txtF){
                txtF = [cell.contentView viewWithTag:TXTFIELD_TAG+indexPath.row];
            }
            txtF.tag = TXTFIELD_TAG+indexPath.row;
            
            txtF.placeholder = allPlaceHolderName[indexPath.row - 1];
            
            if([txtF.placeholder isEqualToString:@"Nickname"]){
                if(ownNickName)
                    txtF.text = ownNickName;
            }
            else {
                if(ownFullname)
                    txtF.text = ownFullname;
            }

            return cell;
            break;
        }
    }
    return nil;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            return 160;
            break;
        }
        default:{
            return 51;
            break;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allPlaceHolderName.count + 2;
}

#pragma mark --- Get Photo from Gallery --


-(void)actionForUpdatePicture{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"XMPP DEMO" message:@"Please select your Image" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openGalleryOrCamera:kCamera];
        
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openGalleryOrCamera:kGallery];
        
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)openGalleryOrCamera:(UploadPhotoFrom)enumFor{
    
    self.imageController = [[UIImagePickerController alloc]init];
    self.imageController.delegate = self;
    if(enumFor == kCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imageController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        self.imageController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.imageController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if(info[UIImagePickerControllerOriginalImage]){
        self.avatarPic = info[UIImagePickerControllerOriginalImage];
        [self.tblView reloadData];
    }
    [self.imageController dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imageController dismissViewControllerAnimated:YES completion:nil];
}


-(void)updateProfile{
    
    UITextField *newNick = [self.tblView viewWithTag:TXTFIELD_TAG+1];
    UITextField *newFullname = [self.tblView viewWithTag:TXTFIELD_TAG+2];
    NSData *pictureData = UIImagePNGRepresentation(self.avatarPic);
    NSDictionary *dictVcardUpdate = @{@"nick":newNick.text,@"fullname":newFullname.text,@"avatar":pictureData};
    [SRXMPP_Manager updateVCard:dictVcardUpdate];
    
}

@end
