//
//  RoasterCells.h
//  XMPPDemo
//
//  Created by Saheb Roy on 25/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoasterCells : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lbl_roasterName;
@property (nonatomic,weak) IBOutlet UILabel *lbl_lastText;
@property (nonatomic,weak) IBOutlet UILabel *lbl_lastTextTime;
@property (nonatomic,weak) IBOutlet UILabel *lbl_numberOFUnread;
@property (nonatomic,weak) IBOutlet UIImageView *iv_roasterAvatar;

@end
