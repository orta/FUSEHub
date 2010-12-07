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

@implementation GHFileSystem

static NSString *helloStr = @"Hello World!\n";
static NSString *helloPath = @"/hello.txt";


- (id) init{
  self = [super init];
  GHBlobParser* parser = [[GHBlobParser alloc] initWithGitHubURL:@"http://github.com/api/v2/yaml/blob/all/orta/tickets/master" andDelegate:self];
  [parser retain];

  root = [[GHFile alloc] init];
  root.name = @"root";
  root.children = [NSMutableArray array];
  
  [[ASIDownloadCache sharedCache] setCacheMode:ASIOnlyLoadIfNotCachedCachePolicy];
  [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
  
  
  return self;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
  NSLog(@"contents of dir: %@", path);
  return [root stringArray];
}

- (NSData *)contentsAtPath:(NSString *)path {
  NSLog(@"contents at path: %@", path);

  if ([path rangeOfString:@"_"].location != NSNotFound) {
    return nil;
  }

  NSLog(@"getting at path: %@", path);
  NSString * address = [NSString stringWithFormat:@"https://github.com/orta/tickets/raw/master%@", path];
  NSURL *url = [ NSURL URLWithString: address]; 
  NSURLRequest *req = [ NSURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:30.0 ];
  NSError *err;
  NSURLResponse *res;
  NSData *d = [ NSURLConnection sendSynchronousRequest:req
                                     returningResponse:&res
                                                 error:&err ];
    return d;

//  
//  NSLog(@"getting at path: %@", path);
//  NSString * address = [NSString stringWithFormat:@"https://github.com/orta/tickets/raw/master%@", path];
//  NSURL *url = [NSURL URLWithString:address];
//  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//  [request startSynchronous];
//  NSError *error = [request error];
//  if (!error) {
//    return [request responseData];;
//  }
//  return nil;
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
