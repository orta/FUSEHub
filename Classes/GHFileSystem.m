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

  NSString * tempDir = NSTemporaryDirectory();
  if (tempDir == nil)
    tempDir = @"/tmp";
  
  NSString * template = [tempDir stringByAppendingPathComponent: @"GSFS.XXXXXX"];
  NSLog(@"Template: %@", template);

  const char * fsTemplate = [template fileSystemRepresentation];
  NSMutableData * bufferData = [NSMutableData dataWithBytes: fsTemplate
                                                     length: strlen(fsTemplate)+1];
  char * buffer = [bufferData mutableBytes];
  char * result = mkdtemp(buffer);
  temporaryDirectory = [[NSFileManager defaultManager]
                                   stringWithFileSystemRepresentation: buffer
                                   length: strlen(buffer)];
  
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

  NSArray * components = [path pathComponents];
  
  
  if ([path rangeOfString:@"_"].location != NSNotFound) {
    return nil;
  }

  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[temporaryDirectory stringByAppendingString:path]];
  if(fileExists){
    return [NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingString:path]];
  }
  
  NSLog(@"getting at path: %@", path);
  NSString * address = [NSString stringWithFormat:@"https://github.com/orta/tickets/raw/master%@", path];
  NSURL *url = [NSURL URLWithString:address];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setCompletionBlock:^{
   
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    [responseData  writeToFile:[temporaryDirectory stringByAppendingString:path] atomically:YES];
  }];
  [request startAsynchronous];
  
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

