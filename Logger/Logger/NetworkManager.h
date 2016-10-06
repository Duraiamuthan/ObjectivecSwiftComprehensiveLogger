//
//  NetworkManager.h
//  CEFSimpleSample
//
//  Created by Durai on 24/09/16.
//  Copyright © 2016 Durai Amuthan.H. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <SystemConfiguration/SystemConfiguration.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <netdb.h>
#import "Reachability.h"
#include <arpa/inet.h>
#include <SystemConfiguration/SCDynamicStore.h>

@protocol NetworkDelegate

-(void)OnNetworkChangeNotification;

@end

@interface NetworkManager : NSObject
{
    //Reachability *mReachability;
}

+(NetworkManager*)sharedManager;
-(NSString *)getCurrentNetwork;
@property (nonatomic, assign) id <NetworkDelegate> delegate;
@property (nonatomic, strong) Reachability *mReachability;
@property (nonatomic,strong) NSString* activeNetwork;
-(void)CheckInternetStatus;
-(int)isInternetReachable;

-(NSMutableArray*)getConnectedNetworkList;
-(BOOL)checkNetworkAvailabilityForAddress:(NSString*)ipAddress;
-(void)startNetworkObserver;
@end
