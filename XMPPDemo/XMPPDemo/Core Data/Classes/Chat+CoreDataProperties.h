//
//  Chat+CoreDataProperties.h
//  XMPPDemo
//
//  Created by Saheb Roy on 27/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

@interface Chat (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *receiver;
@property (nullable, nonatomic, retain) NSString *time;
@property (nullable, nonatomic, retain) NSString *msg;
@property (nullable, nonatomic, retain) NSString *sender;
@property (nullable, nonatomic, retain) NSString *msgid;

@end

NS_ASSUME_NONNULL_END
