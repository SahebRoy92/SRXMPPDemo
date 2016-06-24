//
//  SRCoreData.h
//  XMPPDemo
//
//  Created by Saheb Roy on 27/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chat+CoreDataProperties.h"


@interface SRCoreData : NSObject

+(instancetype)sharedInstance;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
