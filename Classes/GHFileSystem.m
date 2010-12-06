//
//  GHFileSysytem.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "GHFileSystem.h"
#import <MacFUSE/MacFUSE.h>


@implementation GHFileSystem

static NSString *helloStr = @"Hello World!\n";
static NSString *helloPath = @"/hello.txt";


- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
  return [NSArray arrayWithObject:[helloPath lastPathComponent]];
}

- (NSData *)contentsAtPath:(NSString *)path {
  if ([path isEqualToString:helloPath])
    return [helloStr dataUsingEncoding:NSUTF8StringEncoding];
  return nil;
}

#pragma optional Custom Icon

- (NSDictionary *)finderAttributesAtPath:(NSString *)path 
                                   error:(NSError **)error {
  if ([path isEqualToString:helloPath]) {
    NSNumber* finderFlags = [NSNumber numberWithLong:kHasCustomIcon];
    return [NSDictionary dictionaryWithObject:finderFlags
                                       forKey:kGMUserFileSystemFinderFlagsKey];
  }
  return nil;
}

- (NSDictionary *)resourceAttributesAtPath:(NSString *)path
                                     error:(NSError **)error {
  if ([path isEqualToString:helloPath]) {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"hellodoc" ofType:@"icns"];
    return [NSDictionary dictionaryWithObject:[NSData dataWithContentsOfFile:file]
                                       forKey:kGMUserFileSystemCustomIconDataKey];
  }
  return nil;
}


@end
