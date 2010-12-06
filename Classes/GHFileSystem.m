//
//  GHFileSysytem.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "GHFileSystem.h"
#import <MacFUSE/MacFUSE.h>
#import "GHBlobParser.h"
#import "GHFile.h"

@implementation GHFileSystem

static NSString *helloStr = @"Hello World!\n";
static NSString *helloPath = @"/hello.txt";


- (id) init{
  self = [super init];
  GHBlobParser* parser = [[GHBlobParser alloc] initWithGitHubURL:@"http://github.com/api/v2/yaml/blob/all/defunkt/facebox/master" andDelegate:self];
  [parser retain];
  
  root = [[GHFile alloc] init];
  root.name = @"root";
  root.children = [NSMutableArray array];

  return self;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
  return [root stringArray];
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

- (void)addItemToStore:(NSString*) item{
  
  if ([item rangeOfString:@"/"].location == NSNotFound) {
    NSLog(@"hello %@", item);
    
    GHFile* node = [[GHFile alloc] init];
    node.name = item;
    [root add:node];
  }
  
  return;
}

@end
