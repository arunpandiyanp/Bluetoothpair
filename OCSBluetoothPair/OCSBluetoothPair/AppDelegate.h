//
//  AppDelegate.h
//  OCSBluetoothPair
//
//  Created by OCS DEV on 19/03/18.
//  Copyright © 2018 OclockSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

