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
  
  
  root = [[GHFile alloc] init];
  root.name = @"root";
  root.depth = 0;
  root.children = [NSMutableArray array];

  GHBlobParser* parser = [[GHBlobParser alloc] initWithGitHubUser:@"orta" Repository:@"FUSEHub" andDelegate:self];
  [parser retain];

  NSString * tempDir = NSTemporaryDirectory();
  if (tempDir == nil)
    tempDir = @"/tmp";
  
  NSString * template = [tempDir stringByAppendingPathComponent: @"GSFS.XXXXXX"];

  const char * fsTemplate = [template fileSystemRepresentation];
  NSMutableData * bufferData = [NSMutableData dataWithBytes: fsTemplate
                                                     length: strlen(fsTemplate)+1];
  char * buffer = [bufferData mutableBytes];
  char * result = mkdtemp(buffer);

  temporaryDirectory = [[NSFileManager defaultManager]
                                   stringWithFileSystemRepresentation: buffer
                                   length: strlen(buffer)];
  NSLog(@"temp: %@", temporaryDirectory);

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
  return [[self findNodeAtPath:path] fileArray];
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path userData:(id)userData error:(NSError **)error {
  NSLog(@"attributes at path: %@", path);
  GHFile * node =[self findNodeAtPath:path];
  if( node.depth < 3){
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:0700], NSFilePosixPermissions,
            [NSNumber numberWithInt:geteuid()], NSFileOwnerAccountID,
            [NSNumber numberWithInt:getegid()], NSFileGroupOwnerAccountID,
            [NSDate date], NSFileCreationDate,
            [NSDate date], NSFileModificationDate,
            NSFileTypeDirectory, NSFileType,  nil];
  }else{
    
    return  nil;
  }
}



- (NSData *)contentsAtPath:(NSString *)path {
  
  if ([path rangeOfString:@"_"].location != NSNotFound) {
    return nil;
  }

  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[temporaryDirectory stringByAppendingString:path]];
  if(fileExists){
    return [NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingString:path]];
  }
  
  NSLog(@"getting at path: %@", path);
  GHFile * node =[self findNodeAtPath:path];

  if([node.children count]){
    //   is a folder
    [[NSFileManager defaultManager] createDirectoryAtPath: [temporaryDirectory stringByAppendingString: path] attributes: nil];
    return nil;
  }
  
  NSString * address = [NSString stringWithFormat:@"https://github.com/%@/%@/raw/master/%@", node.user, node.repo, node.name];
  NSURL *url = [NSURL URLWithString:address];
  NSLog(@"fetching %@", address);

  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setCompletionBlock:^{
   
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSString * newPath = [temporaryDirectory stringByAppendingString: path];
    NSLog(@"new path %@", newPath);
    
    [responseData  writeToFile:newPath atomically:YES];
  }];
  [request startSynchronous];
  
  return nil;
}

- (GHFile *)findNodeAtPath:(NSString *) path{
  if([path isEqualToString:@"/"])
    return root;
  
  path = [path substringFromIndex:1];
  NSArray * components = [path pathComponents];
  NSUInteger i, count = [components count];
  GHFile* node = root;
  for (i = 0; i < count; i++) {
    NSString * component = [components objectAtIndex:i];
    node = [node findChildWithName:component];
  }  
  return node;
}

- (void)addItemToStore:(NSString*) path withUser:(NSString*) user andRepo:(NSString*)repo{
  NSArray * components = [path pathComponents];
  NSUInteger i, count = [components count];
  GHFile* node = root;
  for (i = 0; i < count; i++) {
    NSString * component = [components objectAtIndex:i];
    GHFile* parent = node;
    node = [node findChildWithName:component];
    if(node == nil){
      GHFile* newNode = [[[GHFile alloc] init] retain];
      newNode.name = component;
      newNode.depth = parent.depth + 1;
      newNode.user = user;
      newNode.repo = repo;
      [parent add:newNode];
      [newNode release];
    }      
  }  
}

- (void) print{
  NSLog(@"%@", [root description]);
}

@end

