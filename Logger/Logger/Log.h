//
//  Log.m
//  OmniclientSwift
//
//  Created by Durai on 24/09/16.
//  Copyright © 2016 Durai Amuthan.H. All rights reserved..
//

#import <Foundation/Foundation.h>

#define NSLog(args...) _Log(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
//@class DeviceManager;
@interface Log : NSObject
void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...);
@end