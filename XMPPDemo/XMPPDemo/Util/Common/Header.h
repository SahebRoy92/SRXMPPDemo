//
//  Header.h
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#ifndef Header_h
#define Header_h


/******* IMPORTS *********/

#import "SRXMPP.h"
#import "SRCoreData.h"


/******* SEGUE *********/

#define kFromLoginToHomeSegue               @"fromLoginToHomeSegue"
#define kFromRegisterToHomeSegue            @"fromRegistrationToHomeSegue"
#define kFromSplashToLoginSegue             @"fromSplashToLoginSegue"
#define kFromSplashToHomeSegue              @"fromSplashToHomeSegue"
#define kFromHomeToAddFriendSegue           @"fromHomeToAddFriendSegue"
#define kFromHomeToChatSegue                @"fromHomeToChatSegue"
#define kFromHomeToEditProfileSegue         @"fromHomeToEditProfileSegue"


/******* Constants *********/

#define SRXMPP_Manager                  [SRXMPP sharedInstance]
#define Common_Manager                  [CommonUtil sharedInstance]
#define userDef_get(args)               [[NSUserDefaults standardUserDefaults]objectForKey:args]
#define userDef                         [NSUserDefaults standardUserDefaults]
#define SRCoreDataManager               [SRCoreData sharedInstance]

/******* String Key *********/

#define UDKEY_userFound                 @"com.SRXMPP.NSUD.userfound"
#define k24HourTimeFormat               @"HH:mm"
#define k12HourTimeFormat               @"hh:mm a"
#define kChatBackgroundImageName        @"chatbackgroundimage"

/******* ENUM *********/

typedef enum {
    kXMPPNormal,
    kXMPPAdium
} SRXMPPMode;

typedef enum {
    k24Hour,
    k12Hour
} ChatDateFormat;


typedef enum {
    kChatTyping,
    kChatOnline,
    kChatLastSeen
} ChatTypingIndicator;

typedef enum {
    kCamera,
    kGallery
} UploadPhotoFrom;


#endif /* Header_h */
