//
//  SRXMPP.m
//  XMPPDemo
//
//  Created by Saheb Roy on 17/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//



#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "SRXMPP.h"
#import <CFNetwork/CFNetwork.h>
#import "XMLDictionary.h"
#import "CommonUtil.h"

#define DEBUG 1

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@implementation SRXMPP

NSString* const SRXMPP_RegisterNotification             =           @"com.notification.SRXMPP.didRegister";
NSString* const SRXMPP_ConnectNotification              =           @"com.notification.SRXMPP.didConnect";
NSString* const SRXMPP_AuthenticateNotification         =           @"com.notification.SRXMPP.didAuth";
NSString* const SRXMPP_SearchUserNotification           =           @"com.notification.SRXMPP.didFindUser";
NSString* const SRXMPP_BuddyAddedNotification           =           @"com.notification.SRXMPP.didAddBuddy";
NSString* const SRXMPP_RoasterFetchedNotification       =           @"com.notification.SRXMPP.didFetchRoaster";
NSString* const SRXMPP_MessageReceivedNotification      =           @"com.notification.SRXMPP.didRecieveMessage";
NSString* const SRXMPP_StatusOfOtherUserNotification    =           @"com.notification.SRXMPP.didChangeStatusOtherUser";

NSString* const SRXMPP_OtherUservCardUpdated            =           @"com.notification.SRXMPP.didUpdatevCardOther";



NSString* const SRXMPP_jid                          =           @"com.SRXMPP.jid";
NSString* const SRXMPP_pass                         =           @"com.SRXMPP.pass";

//Overwrite this to the IP of the server where Openfire is installed.
NSString* const SRXMPP_Hostname                     =           @"Sahebs-Macbook.local"; 
int const SRXMPP_Portname                           =           5222;


@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;


+(instancetype)sharedInstance{
    
    static SRXMPP *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SRXMPP alloc]init];
        [manager setupDefaults];
        [manager setupStream];
        [manager connect];
    });
    return manager;
    
}


-(void)setupDefaults{
    if(![[NSUserDefaults standardUserDefaults]objectForKey:SRXMPP_jid]){
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"nameless@%@",SRXMPP_Hostname] forKey:SRXMPP_jid];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:UDKEY_userFound];
        [[NSUserDefaults standardUserDefaults]setObject:@"pass" forKey:SRXMPP_pass];
    }
}


#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:SRXMPP_Hostname]; //10.0.8.46 - tirtho
    [xmppStream setHostPort:5222];
    
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:SRXMPP_jid];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:SRXMPP_pass];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:UDKEY_userFound];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:UDKEY_userFound];
    [userDef setObject:[NSString stringWithFormat:@"%@",[xmppStream.myJID bare]] forKey:SRXMPP_jid];
    [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_AuthenticateNotification object:nil userInfo:@{@"success":@"1"}];
    [self goOnline];
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_AuthenticateNotification object:nil userInfo:@{@"success":@"0"}];
    [userDef setObject:[NSNumber numberWithBool:NO] forKey:UDKEY_userFound];
    [userDef setObject:@"" forKey:SRXMPP_pass];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // IQ FOR SEARCHING USERS ---
    NSXMLElement *queryElement = [iq elementForName:@"query" xmlns:@"jabber:iq:search"];
    
    if(queryElement){
        if (queryElement) {
            NSDictionary *allUsers = [NSDictionary dictionaryWithXMLString:[queryElement XMLString]];
            [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_SearchUserNotification object:nil userInfo:allUsers];
        }
    }
    
    // IQ FOR RECIEVING ROASTER ---
    NSXMLElement *queryElementRoaster = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    if (queryElementRoaster)
    {
        NSMutableArray *allBuddies = [NSMutableArray array];
        NSArray *itemElements = [queryElementRoaster elementsForName: @"item"];
        for (int i=0; i<[itemElements count]; i++)
        {
            NSLog(@"Friend: %@",[[itemElements[i] attributeForName:@"jid"]stringValue]);
            [allBuddies addObject:[[itemElements[i] attributeForName:@"jid"]stringValue]];
        }
        if(itemElements.count > 0){
            NSDictionary *result = @{@"roaster":allBuddies,@"success":@"1"};
            [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_RoasterFetchedNotification object:nil userInfo:result];
        }
    }
    
    
    NSArray *queryElementVcardUpdate = [[iq childElement]elementsForXmlns:@"vcard-temp"];
    
    if(queryElementVcardUpdate.count>0){
        [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_OtherUservCardUpdated object:nil];
    }

    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // A simple example of inbound message handling.
    
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            
            NSError * err;
            NSData *data =[body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary * response;
            if(data!=nil){
                response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                
                if(response){
                    NSString *senderJid = [response valueForKey:@"sender"];
                    NSDictionary *received = @{@"msg":[response objectForKey:@"msg"],@"sender":senderJid,@"receiver":[xmppStream.myJID bare],@"time":[response objectForKey:@"time"],@"msgid":[response objectForKey:@"msgid"]};
                    
                    [Chat insertIntoDB:received];
                    [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_MessageReceivedNotification object:nil userInfo:received];
                }
                else {
                    [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_MessageReceivedNotification object:nil userInfo:@{@"msg":body,@"from":displayName,@"type":@"other"}];
                }
            }
        }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
    else {
        //Get Typing indicator
        NSString *status;
        if([message elementForName:@"composing"] != nil){
            
            status = @"typing";
            
        } else if ([message elementForName:@"active"] != nil) {
            
            status = @"online";
            
        } else if ([message elementForName:@"gone"] || [message elementForName:@"inactive"]||[message elementForName:@"paused"] ) {
            status = @"offline";
            
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_StatusOfOtherUserNotification object:nil userInfo:@{@"status":status}];
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);

    /* This only indicates the person who we are talking with now!*/
    if([[[presence from]bare]isEqualToString:Common_Manager.chattingWithjid]){
        
        NSString *status = [presence type];
        [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_StatusOfOtherUserNotification object:nil userInfo:@{@"status":status}];
    }
    
}

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    [xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:UDKEY_userFound];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}

#pragma mark --- Registration and XMPP Delegates ---

-(void)registerWithDetailsUserName :(NSString *)username andPassword:(NSString *)pwd andEmail:(NSString *)email andFullName:(NSString *)fullName {
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:username]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:pwd]];
    [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:fullName]];
    [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:email]];
    
    [xmppStream registerWithElements:elements error:nil];
}




- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSDictionary *dic = @{@"success":@"1",@"message":@"Registration successfull"};
    [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_RegisterNotification object:nil userInfo:dic];
}



- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    if([errorCode isEqualToString:@"409"]){
        
        //@"Username Already Exists!;
        regError = @"Username Already Exists!";
    }
    NSDictionary *dic = @{@"success":@"0",@"message":regError};
    [[NSNotificationCenter defaultCenter]postNotificationName:SRXMPP_RegisterNotification object:nil userInfo:dic];
}



#pragma mark ---- Add Buddy ----

-(void)addBuddyWithJid:(NSString *)jid andNickname:(NSString *)nickName{
    
    XMPPJID *newBuddy = [XMPPJID jidWithString:jid];
    [xmppRoster addUser:newBuddy withNickname:nickName groups:nil subscribeToPresence:YES];
}




#pragma  mark -- Search Registered Users in Server ----

-(void)searchRegisteredWithUserName:(NSString *)userNameValue{
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
    
    NSXMLElement *email = [NSXMLElement elementWithName:@"email" stringValue:userNameValue];
    [query addChild:email];
    
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"search2"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",self.xmppStream.myJID.domain]];
    [iq addAttributeWithName:@"from" stringValue:[[xmppStream myJID]bare]];
    [iq addAttributeWithName:@"xml:lang" stringValue:@"en"];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
    
    
}


#pragma mark -- Load Roaster ---

-(void)loadRoaster{
    NSError *error = [[NSError alloc] init];
    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='jabber:iq:roster'/>"error:&error];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"ANY_ID_NAME"];
    [iq addAttributeWithName:@"from" stringValue:@"ANY_ID_NAME@weejoob.info"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
    
}


#pragma mark -- Send Text Message ---

-(NSDictionary *)sendMessageTo:(NSString *)jid andText:(NSString *)text{
    NSXMLElement *body;
    NSDictionary *dic;
    if(Common_Manager.currentCode == kXMPPAdium){
        //testing via adium
        
        body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:text];
        dic = nil;
    }
    else {
        // simulator or device
        
        body = [NSXMLElement elementWithName:@"body"];
        dic = @{@"msg":text,@"time":[Common_Manager convertDateToformat],@"receiver":jid,@"sender":[xmppStream.myJID bare],@"msgid":[Common_Manager timeStamp]};
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dic options:0 error:&err];
        NSString * stringDic = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        [body setStringValue:stringDic];
        
    }
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:jid];
    [message addChild:body];
    
    [SRXMPP_Manager.xmppStream sendElement:message];
    return dic;
    
}



#pragma mark --- Chat Typing Indicator Methods ----

-(void)sendTypingStatusToJid:(NSString *)jidStr andStatus:(ChatTypingIndicator)indicator{
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:jidStr];
    XMPPMessage *xmppMessage = [XMPPMessage messageFromElement:message];
    
    if(indicator == kChatTyping){
        [xmppMessage addComposingChatState];
    }
    else if (indicator == kChatOnline){
        [xmppMessage addActiveChatState];
    }
    else if (indicator == kChatLastSeen){
        [xmppMessage addGoneChatState];
    }
    else {
        /*
         [xmppMessage addInactiveChatState];
         [xmppMessage addPausedChatState];
         */
    }
    
    [xmppStream sendElement:message];
}



#pragma mark -- Update / Create vCard ---

-(void)updateVCard:(NSDictionary *)dict{
    
    NSString *newNic = dict[@"nick"];
    NSString *newFullname = dict[@"fullname"];
    NSData *avatarImg = dict[@"avatar"];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *tmpImage = [[UIImage alloc] initWithData:avatarImg];
        NSData *imageData1 = UIImageJPEGRepresentation(tmpImage,0.0);
        
            XMPPvCardTemp *newVCardTemp = [xmppvCardTempModule myvCardTemp];
        if(newNic)
            [newVCardTemp setNickname:newNic];
        if(newFullname)
            [newVCardTemp setFormattedName:newFullname];
        if(avatarImg)
            [newVCardTemp setPhoto:imageData1];
            
            [xmppvCardTempModule updateMyvCardTemp:newVCardTemp];
        
    });

}




@end
