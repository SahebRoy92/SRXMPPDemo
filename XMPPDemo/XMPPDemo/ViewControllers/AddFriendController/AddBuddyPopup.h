//
//  AddBuddyPopup.h
//  XMPPDemo
//
//  Created by Saheb Roy on 23/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AddbuddyProtocol <NSObject>

-(void)didClickOkWithNickname:(NSString *)nickName;

@end


@interface AddBuddyPopup : UIView

@property (nonatomic,weak) id <AddbuddyProtocol>delegate;

@end
