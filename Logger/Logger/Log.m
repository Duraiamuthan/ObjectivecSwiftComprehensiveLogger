//
//  Log.m
//  OmniclientSwift
//
//  Created by Durai on 24/09/16.
//  Copyright © 2016 Durai Amuthan.H. All rights reserved.
//

#import "Log.h"
#import "Logger-Swift.h"

@implementation Log

void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...) {
    va_list ap;
    va_start (ap, format);
    format = [format stringByAppendingString:@"\n"];
    NSString *msg = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@",format] arguments:ap];
    va_end (ap);
    fprintf(stderr,"%s%50s:%3d - %s",[prefix UTF8String], funcName, lineNumber, [msg UTF8String]);
    DeveloperConsoleManager *consoleManagerObj=[DeveloperConsoleManager sharedInstance];
    [consoleManagerObj writeObcLog:msg];
}

@end