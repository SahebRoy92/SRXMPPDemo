//
//  CommonUtil.h
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Header.h"

@interface CommonUtil : NSObject


@property (nonatomic,strong) UIAlertController *alertController;
@property (nonatomic,strong) NSString *chattingWithjid;
@property (nonatomic,assign) SRXMPPMode currentCode;
@property (nonatomic,assign) ChatDateFormat currentChatDateFormat;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

+(instancetype)sharedInstance;

-(void)showAlertWithTitle:(NSString *)title andMessege:(NSString *)messege andCompletionBlock:(NSArray *(^)(void))alertActions andViewController:(UIViewController *)vc andStyle:(UIAlertControllerStyle)style;


-(BOOL)checkForBlankStringsinAll:(NSArray *)array;
-(void)resetUDfromapplication;
-(NSString *)convertDateToformat;
-(NSString *)timeStamp;
-(BOOL)saveChatBackgroundImageToPath:(UIImage *)image;
-(UIImage *)retrieveChatBackgroundImage;

@end
