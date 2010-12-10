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
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "NSError+POSIX.h"

@implementation GHFileSystem

- (id) init{
  self = [super init];
  GHBlobParser* parser = [[GHBlobParser alloc] initWithGitHubURL:@"http://github.com/api/v2/yaml/blob/all/orta/tickets/master" andDelegate:self];
  [parser retain];

  root = [[GHFile alloc] init];
  root.name = @"root";
  root.children = [NSMutableArray array];
  
//  [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
//  [[ASIDownloadCache sharedCache] setCacheMode:ASIOnlyLoadIfNotCachedCachePolicy];
//
  
  return self;
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
  if (!path || !isDirectory)
    return NO;
  // Handle "._" and "Icon\r" that we don't deal with.
  NSString* lastComponent = [path lastPathComponent];
  if ([lastComponent hasPrefix:@"._"] ||
      [lastComponent isEqualToString:@"Icon\r"]) {
    return NO;
  }

  return YES;
  
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
  NSLog(@"contents of dir: %@", path);
  return [root fileArray];
}

- (NSData *)contentsAtPath:(NSString *)path {
  NSLog(@"contents at path: %@", path);

  if ([path rangeOfString:@"_"].location != NSNotFound) {
    return nil;
  }

//  File caching method
//  NSString *decodedPath = DecodePath([path lastPathComponent]);
//  NSFileManager *fm = [NSFileManager defaultManager];
//  attr = [[[fm fileAttributesAtPath:decodedPath traverseLink:NO] mutableCopy] autorelease];
//  if (!attr)
//    attr = [NSMutableDictionary dictionary];
//  [attr setObject:NSFileTypeSymbolicLink forKey:NSFileType];
  
  NSLog(@"getting at path: %@", path);
  NSString * address = [NSString stringWithFormat:@"https://github.com/orta/tickets/raw/master%@", path];
  NSURL *url = [NSURL URLWithString:address];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request startSynchronous];
  NSError *error = [request error];
  if (!error) {
    return [request responseData];;
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

