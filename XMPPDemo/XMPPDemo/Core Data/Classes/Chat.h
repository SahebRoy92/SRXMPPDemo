//
//  Chat.h
//  XMPPDemo
//
//  Created by Saheb Roy on 27/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Chat : NSManagedObject

// Insert code here to declare functionality of your managed object subclass


+(void)insertIntoDB:(NSDictionary *)dic;
+(NSArray *)fetchAllChatForjid:(NSString *)jid;
+(NSMutableArray *)fetchLastMessageForAllRoaster:(NSArray *)arrayOfRoster;
@end

NS_ASSUME_NONNULL_END

#import "Chat+CoreDataProperties.h"
