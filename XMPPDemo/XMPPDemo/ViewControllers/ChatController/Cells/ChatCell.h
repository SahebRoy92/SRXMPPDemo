//
//  ChatCell.h
//  XMPPDemo
//
//  Created by Saheb Roy on 24/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lbl_msg;
@property (nonatomic,weak) IBOutlet UILabel *lbl_time;
@property (nonatomic,weak) IBOutlet UIImageView *chatBubble;

@end
