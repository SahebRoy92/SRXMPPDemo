//
//  CommonUtil.m
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil



+(instancetype)sharedInstance{
    static CommonUtil *utilManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utilManager = [[CommonUtil alloc]init];
    });
    return utilManager;
}

-(void)showAlertWithTitle:(NSString *)title andMessege:(NSString *)messege andCompletionBlock:(NSArray *(^)(void))alertActions andViewController:(UIViewController *)vc andStyle:(UIAlertControllerStyle)style{
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:messege preferredStyle:style];
    NSArray *arrayOfActions = alertActions();
    for (int i= 0; i<arrayOfActions.count;i++) {
        
        UIAlertAction *action = arrayOfActions[i];
        [controller addAction:action];
    }
    
    [vc presentViewController:controller animated:YES completion:nil];
}


-(BOOL)checkForBlankStringsinAll:(NSArray *)array{
    
    BOOL itemReturn = YES;
    
    for (id item in array) {
        if([item isKindOfClass:[UITextField class]]){
            UITextField *castedItem = (UITextField *)item;
            if(![castedItem.text isEqualToString:@""]){
                itemReturn = NO;
            }
            else
                itemReturn = YES;
            break;
        }
        else if ([item isKindOfClass:[NSString class]]){
            NSString *castedItem = (NSString *)item;
            if(![castedItem isEqualToString:@""]){
                itemReturn = NO;
            }
            else
                itemReturn = YES;
            break;
        }
        else
            return YES;
            break;
    }
    return itemReturn;
}

-(NSString *)convertDateToformat{
    return [self.dateFormatter stringFromDate:[NSDate date]];
}


-(void)resetUDfromapplication{
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"nameless@%@",SRXMPP_Hostname] forKey:SRXMPP_jid];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:UDKEY_userFound];
    [[NSUserDefaults standardUserDefaults]setObject:@"pass" forKey:SRXMPP_pass];
}

-(NSDateFormatter *)dateFormatter{
    if(_dateFormatter == nil){
        _dateFormatter = [[NSDateFormatter alloc]init];
        if(self.currentChatDateFormat == k24Hour){
            [_dateFormatter setDateFormat:k24HourTimeFormat];
        }
        else {
            [_dateFormatter setDateFormat:k12HourTimeFormat];
        }
    }
    return _dateFormatter;
}


- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

-(BOOL)saveChatBackgroundImageToPath:(UIImage *)image{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kChatBackgroundImageName];
    
    // Save image.
    if([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES])
        return YES;
    else
        return NO;
}

-(UIImage *)retrieveChatBackgroundImage{

    NSString *imgPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kChatBackgroundImageName];

    NSData *data = [NSData dataWithContentsOfFile:imgPath];
    return [UIImage imageWithData:data];
    
}


@end
