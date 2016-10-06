 //
//  NetworkManager.m
//  CEFSimpleSample
//
//  Created by Durai on 24/09/16.
//  Copyright © 2016 Durai Amuthan.H. All rights reserved.
//

#import "NetworkManager.h"


struct ifaddrs *allInterfaces;

@implementation NetworkManager

@synthesize delegate;

struct ifaddrs* interfaces = NULL;
struct ifaddrs* temp_addr = NULL;


+(NetworkManager*)sharedManager
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)startNetworkObserver
{
    NSLog(@" Initailzing the set up");
    
    // add Observer for network notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
}


- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NSLog(@" reachability changed ");
}


- (NSString *)getCurrentNetwork
{
    [self IsInternetConnected];
    return self.activeNetwork;
}


-(NSString*)getCurrentIPNetwork
{
    NSLog(@"current Network is %@", [self getCurrentNetwork]);
    
    
    return NULL;
}


-(int)isInternetReachable
{
    NSString *hostName = @"www.apple.com";
    self.mReachability = [Reachability reachabilityWithHostName:hostName];
    NSLog(@" reachability status is %ld",[self.mReachability currentReachabilityStatus]);
    NetworkStatus netStatus = [self.mReachability currentReachabilityStatus];

    switch (netStatus) {
        case NotReachable:
            self.activeNetwork = @"";
            NSLog(@"Not reachability");
            break;
        case ReachableViaWiFi:
            NSLog(@" reachable via Wifi");
            self.activeNetwork = @"Wi-Fi";
            break;
            
        case ReachableViaWWAN:
            NSLog(@" reachable via WWAN");
            self.activeNetwork = @"Mobile Data";
            break;
        default:
            break;
    }
    return netStatus;
}


-(NSMutableArray*)getConnectedNetworkList
{
    NSMutableArray *networkArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Get list of all interfaces on the local machine:
    if (getifaddrs(&allInterfaces) == 0)
    {
        struct ifaddrs *interface;
        
        // For each interface ...
        for (interface = allInterfaces; interface != NULL; interface = interface->ifa_next)
        {
            unsigned int flags = interface->ifa_flags;
            struct sockaddr *addr = interface->ifa_addr;
            struct sockaddr *netaddr = interface->ifa_netmask;
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if ((flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING))
            {
                //if (addr->sa_family == AF_INET || addr->sa_family == AF_INET6) {
                if (addr->sa_family == AF_INET )
                {
                    
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
                    // Convert interface address to a human readable string:
                    char host[NI_MAXHOST];
                    
                    getnameinfo(addr, addr->sa_len, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
                    
                    printf("interface:%s, address:%s\n", interface->ifa_name, host);
                    NSLog(@" Interface is %s", interface->ifa_name);
                    
                    char nethost[NI_MAXHOST];
                    getnameinfo(netaddr, netaddr->sa_len, nethost, sizeof(nethost), NULL, 0, NI_NUMERICHOST);
                     NSString *netstr = [[NSString alloc] initWithFormat:@"%s",nethost];
                   
                    NSString *str = [[NSString alloc] initWithFormat:@"%s",interface->ifa_name];
                    
                    [dic setObject:str forKey:@"name"];
                    [dic setObject:[[NSString alloc] initWithFormat:@"%s",host] forKey:@"id"];
                    
                    [networkArray addObject:dic];
                }
            }
            
        }
        freeifaddrs(allInterfaces);
    }
    return networkArray;
}


-(BOOL)checkNetmask:(NSString*)mask InterfaceName:(NSString*)name
{
    NSArray *ary = [mask componentsSeparatedByString:@"."];
    NSString *val =[ary objectAtIndex:2];
    
    if  ([val isEqualToString:@"0"] && [name isEqualToString:@"Wi-Fi"] )
    {
        return false;
    }
    else if ( [name isEqualToString:@"bridge100"] )
    {
        return false;
    }
    else
    {
        return true;
    }
    return false;
}


-(BOOL)IsInternetConnected
{
    return false;
}


//-(NSString*)GetWifiName
//{
//    CWInterface *wif = [CWInterface interface];
//    
//    DDLogInfo(@"BSD if name: %@", wif.interfaceName);
//    DDLogInfo(@"SSID: %@", wif.ssid);
//    return wif.interfaceName;
//}

//
//-(void)CheckInternetStatus
//{
//    [self registerWifiNotification];
//    NSString *pingHost = @"www.apple.com";
//    SCNetworkConnectionFlags flags = 0;
//    if (pingHost && [pingHost length] > 0)
//    {
//        flags = 0;
//        int err = 0;
//        Boolean ok;
//        BOOL found = NO;
//        SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [pingHost UTF8String]);
//        
//        if (reachabilityRef == NULL)
//        {
//            err = SCError();
//        }
//
//        SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
//        
//        if (err == 0)
//        {
//            if (SCNetworkReachabilitySetCallback(reachabilityRef, NetworkReachabilityCallback, &context))
//            {
//                ok = SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
//                if (! ok)
//                {
//                    err = SCError();
//                }
//            }
//        }
//        
//        if (found)
//        {
//            DDLogInfo(@"Connection established");
//        }
//        if (!found)
//        {
//            DDLogInfo(@"Connection not established");
//        }
//    }
//}


static void NetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
    NSLog(@"========== %@ %d",target, flags);
    
    NSLog(@" On Network CallBack %u", flags);
    switch (flags)
    {
        case kSCNetworkFlagsTransientConnection:
            NSLog(@" Flag Transient Connection");
            break;
        case kSCNetworkFlagsReachable:
            NSLog(@" Flag Reachable");
            break;
        case kSCNetworkFlagsConnectionRequired:
            NSLog(@" Flag Connection Required");
            break;
        case kSCNetworkFlagsConnectionAutomatic:
            NSLog(@" Flag Connection Automatic");
            break;
        case kSCNetworkFlagsInterventionRequired:
            NSLog(@" Flag Intervention Required");
            break;
        case kSCNetworkFlagsIsLocalAddress:
            NSLog(@" Flag IsLocal Address");
            break;
        case kSCNetworkFlagsIsDirect:
            NSLog(@" Flag Is Direct");
            break;
        default:
            break;
    }

}

//
//// Check for Network Reachability with a specific domain name.
//-(BOOL)checkNetworkAvailabilityForAddress:(NSString*)ipAddress
//{
//    //NSString *ip = [[ipAddress componentsSeparatedByString:kSPACE_STRING] firstObject];
//    NSString *ip = ipAddress;
//    DDLogInfo(@" Ip value is %@", ip);
//    struct sockaddr_in address;
//    address.sin_len = sizeof(address);
//    address.sin_family = AF_INET;
//    address.sin_port = htons(8080);
//    address.sin_addr.s_addr = inet_addr([ip UTF8String]);
//    
//    Reachability* hostReachability = [Reachability reachabilityWithAddress:&address];
//    return [self updateInterfaceWithReachability:hostReachability];
//}
//
//
//- (BOOL)updateInterfaceWithReachability:(Reachability *)reachability
//{
//    BOOL isReachable = false;
//    NetworkStatus netStatus = [reachability currentReachabilityStatus];
//    
//    switch (netStatus)
//    {
//        case NotReachable:
//        {
//            DDLogInfo(@"-------- Access Not Available");
//            isReachable = false;
//            break;
//        }
//            
//        case ReachableViaWWAN:
//        {
//            DDLogInfo(@"-------- Reachable WWAN");
//            isReachable = true;
//            break;
//        }
//        case ReachableViaWiFi:
//        {
//            DDLogInfo(@"-------- Reachable WiFi");
//            isReachable = true;
//            break;
//        }
//    }
//    return isReachable;
//}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
@end
