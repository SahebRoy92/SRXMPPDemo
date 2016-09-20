//
//  SRXMPP.h
//  XMPPDemo
//
//  Created by Saheb Roy on 17/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"
#import "Header.h"

extern NSString* const SRXMPP_RegisterNotification;
extern NSString* const SRXMPP_ConnectNotification;
extern NSString* const SRXMPP_AuthenticateNotification;
extern NSString* const SRXMPP_SearchUserNotification;
extern NSString* const SRXMPP_BuddyAddedNotification;
extern NSString* const SRXMPP_RoasterFetchedNotification;
extern NSString* const SRXMPP_MessageReceivedNotification;
extern NSString* const SRXMPP_StatusOfOtherUserNotification;
extern NSString* const SRXMPP_OtherUservCardUpdated;


extern NSString* const SRXMPP_jid;
extern NSString* const SRXMPP_pass;
extern NSString* const SRXMPP_Hostname;
extern int constSRXMPP_Portname;




@interface SRXMPP : NSObject<UIApplicationDelegate, XMPPRosterDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *password;
    
    BOOL customCertEvaluation;
    BOOL isXmppConnected;

}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;


- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect;
- (void)disconnect;
- (void)teardownStream;
+(instancetype)sharedInstance;



/* Own written Methods*/

-(void)registerWithDetailsUserName :(NSString *)username andPassword:(NSString *)pwd andEmail:(NSString *)email andFullName:(NSString *)fullName;

-(void)addBuddyWithJid:(NSString *)jid andNickname:(NSString *)nickName;

-(void)searchRegisteredWithUserName:(NSString *)userNameValue;

-(void)loadRoaster;

-(NSDictionary *)sendMessageTo:(NSString *)jid andText:(NSString *)text;

-(void)updateVCard:(NSDictionary *)dict;

-(void)sendTypingStatusToJid:(NSString *)jidStr andStatus:(id)indicator;

@end
