//
//  HomeVC.h
//  XMPPDemo
//
//  Created by Saheb Roy on 18/05/16.
//  Copyright © 2016 OrderOfTheLight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HomeVC : UIViewController<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
}

@end
