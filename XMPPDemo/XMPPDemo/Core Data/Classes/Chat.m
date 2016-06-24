//
//  Chat.m
//  XMPPDemo
//
//  Created by Saheb Roy on 27/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import "Chat.h"
#import "CommonUtil.h"

@implementation Chat

// Insert code here to add functionality to your managed object subclass

+(void)insertIntoDB:(NSDictionary *)dic{
    
    NSString *msgId = [dic objectForKey:@"msgid"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:SRCoreDataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"msgid == %@", msgId];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
   
    
    NSError *error = nil;
    NSArray *fetchedObjects = [SRCoreDataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count == 0) {
        Chat *eachChat = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:SRCoreDataManager.managedObjectContext];
        
        eachChat.receiver       =        [dic valueForKey:@"receiver"];
        eachChat.msg            =        [dic valueForKey:@"msg"];
        eachChat.time           =        [dic valueForKey:@"time"];
        eachChat.sender         =        [dic valueForKey:@"sender"];
        eachChat.msgid          =        [dic valueForKey:@"msgid"];
        
        NSError *err;
        [SRCoreDataManager.managedObjectContext save:&err];
        if(err){
            NSLog(@"Saving issue!");
        }
    }
    
}

+(NSArray *)fetchAllChatForjid:(NSString *)jid{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:SRCoreDataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sender == %@) OR (receiver == %@)) AND ((sender == %@) OR (receiver == %@))",[SRXMPP_Manager.xmppStream.myJID bare],[SRXMPP_Manager.xmppStream.myJID bare] ,jid,jid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    NSError *error = nil;
    NSArray *fetchedObjects = [SRCoreDataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return nil;
    }
    else
        return fetchedObjects;
}

+(NSMutableArray *)fetchLastMessageForAllRoaster:(NSArray *)arrayOfRoster{
    NSMutableArray *lastMSgArray = [NSMutableArray array];
    for (int i=0; i<arrayOfRoster.count; i++) {
        XMPPUserCoreDataStorageObject *user = [arrayOfRoster objectAtIndex:i];
        Chat *c = [[Chat fetchAllChatForjid:user.jidStr] lastObject];
        
        NSMutableDictionary *userAndTheirLastmsg = [NSMutableDictionary dictionary];
        [userAndTheirLastmsg setObject:user.jidStr forKey:@"jid"];
        
       // [userAndTheirLastmsg setObject:user.nickname forKey:@"nick"];
        
        if(c){
            [userAndTheirLastmsg setObject:c.msg forKey:@"msg"];
            [userAndTheirLastmsg setObject:c.time forKey:@"time"];
        }

        [lastMSgArray addObject:userAndTheirLastmsg];
    }
    return lastMSgArray;
}


@end
