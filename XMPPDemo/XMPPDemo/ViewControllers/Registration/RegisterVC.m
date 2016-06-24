//
//  RegisterVC.m
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#define kOFFSET_FOR_KEYBOARD 200.0
#define TEXTFIELD_TAG 200

#import "RegisterVC.h"
#import "CommonUtil.h"


@interface RegisterVC()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *lc_tbvBottom;
@property (nonatomic,strong) UITapGestureRecognizer *imagePickerTap;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,weak) IBOutlet UITableView *tblView;

@end

@implementation RegisterVC{
    UIImage *avatarPic;
    NSData *avatarData;
}


#pragma mark -- Life Cycles---

-(void)viewWillAppear:(BOOL)animated{
    [self setupViewController];
}



-(void)setupViewController{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishRegistration:) name:SRXMPP_RegisterNotification object:nil];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



#pragma mark -- Tableview Datasource and Delegate --- 

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *avatarReuse = @"cellAvatarReuseIdentifier";
    static NSString *txtFieldReuse = @"cellTextFieldReuseIdentifier";
    static NSString *btnReuse = @"cellBtnReuseIdentifier";
    
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:avatarReuse];
            UIImageView *imgV = (UIImageView *)[cell.contentView viewWithTag:100];
            imgV.backgroundColor = [UIColor blackColor];
            imgV.image = avatarPic;
            imgV.userInteractionEnabled = YES;
            imgV.layer.cornerRadius = 64;
            imgV.layer.masksToBounds = YES;
            imgV.clipsToBounds = YES;
            
            
            [self.imagePickerTap addTarget:self action:@selector(actionForImagePicker)];
            [imgV addGestureRecognizer:self.imagePickerTap];
            break;
        }
        case 1:{
            
            cell = [tableView dequeueReusableCellWithIdentifier:txtFieldReuse];
            
            UITextField *txtF = (UITextField *)[cell.contentView viewWithTag:200];
            if(txtF){
                 txtF.tag = TEXTFIELD_TAG+indexPath.row;
            }
            else {
                txtF = (UITextField *)[cell.contentView viewWithTag:TEXTFIELD_TAG+indexPath.row];
            }
            txtF.delegate = self;
            
            switch (indexPath.row) {
                case 0:
                    txtF.placeholder = @"Username";
                    break;
                case 1:{
                    txtF.placeholder = @"Password";
                    txtF.secureTextEntry = YES;
                }
                    break;
                case 2:
                    txtF.placeholder = @"Email";
                    break;
                case 3:
                    txtF.placeholder = @"Nickname";
                    break;
                case 4:
                    txtF.placeholder = @"Full Name";
                    break;
                    
                    default:
                    break;
            }
            break;
        }
        case 2:{
            cell = [tableView dequeueReusableCellWithIdentifier:btnReuse];
            UIButton *btn = (UIButton *)[cell.contentView viewWithTag:300];
            [btn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 158;
            break;
        
        default:
            return 51;
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        return 5;
    }
    else {
        return 1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}




#pragma mark -- ImagePicker actions --- 

-(UITapGestureRecognizer *)imagePickerTap{
    if(_imagePickerTap == nil){
        _imagePickerTap = [[UITapGestureRecognizer alloc]init];
    }
    return _imagePickerTap;
}


-(void)actionForImagePicker{
   [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:@"Please select an image to choose for your avatar" andCompletionBlock:^NSArray *{
       
       UIAlertAction *actionGallery = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           [self openCameraOrGallery:kGallery];
       }];
       
       UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           [self openCameraOrGallery:kCamera];
       }];
       
       UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
       
       return @[actionGallery,actionCamera,actionCancel];
       
   } andViewController:self andStyle:UIAlertControllerStyleActionSheet];
}


-(void)openCameraOrGallery:(UploadPhotoFrom)from{
    
    UIImagePickerController *controller = [[UIImagePickerController alloc]init];
    controller.delegate = self;
    
    if(from == kCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
         controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:controller animated:YES completion:nil];
}



#pragma mark -- ImagePickerController delegate -- 

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    if(img){
        avatarPic = img;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            avatarData = UIImagePNGRepresentation(img);
        });
    }
    [picker dismissViewControllerAnimated:YES completion:^{[self.tblView reloadData];}];
}






#pragma mark --- Register Action ---

-(IBAction)registerAction:(id)sender{
    
    UITextField *txtUsername = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG];
    UITextField *txtPass = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+1];
    UITextField *txtEmail = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+2];
    UITextField *txtNick = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+3];
    UITextField *txtFullName = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+4];
    
    if(![Common_Manager checkForBlankStringsinAll:@[txtUsername.text,txtPass.text,txtEmail.text,txtFullName.text,txtNick.text]]){
        //register xmpp code inband
        
        [SRXMPP_Manager registerWithDetailsUserName:txtUsername.text andPassword:txtPass.text andEmail:txtEmail.text andFullName:txtFullName.text];
        
    }
    else {
        [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:@"Please provide all information" andCompletionBlock:^NSArray *{
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:nil];
            return @[action];
            
        } andViewController:self andStyle:UIAlertControllerStyleAlert];
    }
}

#pragma mark ---- Textfield Delegate ---- 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(!self.tapGesture){
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditingAllTextFields)];
        [self.view addGestureRecognizer:self.tapGesture];
    }
    
}
#pragma mark ---- Move view up and down for keyboard appearence---

-(void)keyboardWillShow:(NSNotification*)notification {
    // Animate the current view out of the way
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.lc_tbvBottom.constant = keyboardFrameBeginRect.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

-(void)keyboardWillHide:(NSNotification *)notification {
    self.lc_tbvBottom.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)endEditingAllTextFields{
    [self.view endEditing:YES];
}


#pragma mark -- Register XMPP Notification Methods ----


-(void)didFinishRegistration:(NSNotification *)notification{
    NSDictionary *dic = [notification userInfo];
    
    UITextField *txtUsername = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG];
    UITextField *txtPass = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+1];
    
    
    if([[dic objectForKey:@"success"]isEqualToString:@"1"]){

        // success
        [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:[dic objectForKey:@"message"] andCompletionBlock:^NSArray *{
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [SRXMPP_Manager.xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",txtUsername.text,SRXMPP_Hostname]]];
                NSError *error;
                [userDef setObject:[NSString stringWithFormat:@"%@",txtPass.text] forKey:SRXMPP_pass];
                [SRXMPP_Manager.xmppStream authenticateWithPassword:txtPass.text error:&error];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishAuthenticateAfterRegistering:) name:SRXMPP_AuthenticateNotification object:nil];
            }];
            return @[action];
            
        } andViewController:self andStyle:UIAlertControllerStyleAlert];
    }
    else {
        // not done
        [Common_Manager showAlertWithTitle:@"XMPP DEMO" andMessege:[dic objectForKey:@"message"] andCompletionBlock:^NSArray *{
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:nil];
            return @[action];
        } andViewController:self andStyle:UIAlertControllerStyleAlert];
    }
    
}


#pragma mark --- Authenticate XMPP Notification Methods ----

-(void)didFinishAuthenticateAfterRegistering:(NSNotification *)notification{
    NSDictionary *dic = [notification userInfo];
    if([[dic objectForKey:@"success"]isEqualToString:@"1"]){
        
        UITextField *txtNick = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+3];
        UITextField *txtFullName = (UITextField *)[self.tblView viewWithTag:TEXTFIELD_TAG+4];
        
        
        [SRXMPP_Manager updateVCard:@{@"avatar":avatarData,@"nick":txtNick.text,@"fullname":txtFullName.text}];
        [self performSegueWithIdentifier:kFromRegisterToHomeSegue sender:self];
    }
    else {
        [Common_Manager resetUDfromapplication];
    }
}


@end
