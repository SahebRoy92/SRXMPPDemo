//
//  AddBuddyPopup.m
//  XMPPDemo
//
//  Created by Saheb Roy on 23/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#define Width_Pop   300
#define Height_Pop  150


#import "AddBuddyPopup.h"


@interface AddBuddyPopup()<UITextFieldDelegate>

@property (nonatomic,strong) UIView *popBackground;
@property (nonatomic,strong) UITextField *txt_nickName;
@property (nonatomic,strong) UIButton *btn_accept;
@property (nonatomic,strong) UIButton *btn_reject;
@property (nonatomic,strong) UITapGestureRecognizer *tapToDismiss;
@end

@implementation AddBuddyPopup



-(instancetype)init{
    if([super init]){
        [self setupBuddyPopup];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        [self setupBuddyPopup];
    }
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if([super initWithCoder:aDecoder]){
        [self setupBuddyPopup];
    }
    return self;
}


#pragma mark -- Setup Methods---

-(void)setupBuddyPopup{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    [self.popBackground addSubview:self.txt_nickName];
    [self.popBackground addSubview:self.btn_reject];
    [self.popBackground addSubview:self.btn_accept];
    self.tapToDismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditingAndRemove)];
    [self addGestureRecognizer:self.tapToDismiss];
    [self addSubview:self.popBackground];
}

-(UIView *)popBackground{
    if(_popBackground == nil){
        _popBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width_Pop, Height_Pop)];
        _popBackground.backgroundColor = [UIColor whiteColor];
        _popBackground.center = self.center;
    }
    return _popBackground;
}

-(UITextField *)txt_nickName{
    if(_txt_nickName == nil){
        _txt_nickName = [[UITextField alloc]initWithFrame:CGRectMake(25, 50, Width_Pop-50, 35)];
        _txt_nickName.placeholder = @"Nickname";
        _txt_nickName.delegate = self;
        _txt_nickName.layer.borderColor = [UIColor blackColor].CGColor;
        _txt_nickName.layer.borderWidth = 2;
        _txt_nickName.clipsToBounds = YES;
        
    }
    return _txt_nickName;
}

-(UIButton *)btn_accept{
    if(_btn_accept == nil){
        _btn_accept = [[UIButton alloc]initWithFrame:CGRectMake(35, 90, 80, 40)];
        [_btn_accept setTitle:@"Accept" forState:UIControlStateNormal];
        [_btn_accept setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
         [_btn_accept addTarget:self action:@selector(acceptBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_accept;
}

-(UIButton *)btn_reject{
    if(_btn_reject == nil){
        _btn_reject = [[UIButton alloc]initWithFrame:CGRectMake(200, 90, 80, 40)];
        [_btn_reject setTitle:@"Cancel" forState:UIControlStateNormal];
        [_btn_reject setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_btn_reject addTarget:self action:@selector(endEditingAndRemove) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_reject;
}

-(void)acceptBtnAction{
    [self.delegate didClickOkWithNickname:self.txt_nickName.text];
    [self endEditingAndRemove];
}

-(void)endEditingAndRemove{
    [self endEditing];
    [self removeFromSuperview];
    
}

-(void)endEditing{
    [self endEditing:YES];
}


#pragma mark --- Textfield delegate ---

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -- Delegate gesture recog --- 

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.view == self.popBackground){
        return NO;
    }
    else
        return YES;
}

@end
