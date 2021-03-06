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
#import "GHUserRepoParser.h"

@implementation GHFileSystem
@synthesize mounted, activity;

- (id) init {
  self = [super init];
  
  root = [[GHFile alloc] init];
  root.name = @"root";
  root.depth = 0;
  root.children = [NSMutableArray array];

//  [self getUser:@"orta" andRepo:@"FUSEHub"];
  self.mounted = NO;
  
  NSString * tempDir = NSTemporaryDirectory();
  if (tempDir == nil)
    tempDir = @"/tmp";
  
  NSString * template = [tempDir stringByAppendingPathComponent: @"GHFS.XXXXXX"];

  const char * fsTemplate = [template fileSystemRepresentation];
  NSMutableData * bufferData = [NSMutableData dataWithBytes: fsTemplate
                                                     length: strlen(fsTemplate)+1];
  char * buffer = [bufferData mutableBytes];
  mkdtemp(buffer);

  temporaryDirectory = [[NSFileManager defaultManager]
                                   stringWithFileSystemRepresentation: buffer
                                   length: strlen(buffer)];
  return self;
}

- (void) getUser:(NSString*)user {
  GHUserRepoParser * repoparser = [[GHUserRepoParser alloc] initWithUser:user andDelegate:self];
  [self addUser:user];
  [repoparser retain];
}

- (void) getUser:(NSString*)user andRepo:(NSString*)repo{
  GHBlobParser* parser = [[GHBlobParser alloc] initWithGitHubUser:user Repository:repo andDelegate:self];
  [self addUser:user];
  [parser retain];
  
  GHUserRepoParser * repoparser = [[GHUserRepoParser alloc] initWithUser:user andDelegate:self];
  [repoparser retain];
}

#pragma delegate methods

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
  
  GHFile * node = [self findNodeAtPath:path];
  if(node.depth == 2){
    if([node.children count] < 1){      
      //looking for a new repo
      GHBlobParser* parser = [[GHBlobParser alloc] initWithGitHubUser:node.parent.name Repository:node.name andDelegate:self];
      [parser retain];
    }
  }
  
  if([[root children] count] == 0 ){
    return [NSArray arrayWithObject:@"Go find a project!..."];
  }
  
  if([[node fileArray] count] == 0 ){
    return [NSArray arrayWithObject:@"Loading..."];
  }
  return [node fileArray];
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path userData:(id)userData error:(NSError **)error {
  GHFile * node =[self findNodeAtPath:path];
  if( node.depth < 3){
      //    first two directories are only folders
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:0777], NSFilePosixPermissions,
            [NSNumber numberWithInt:geteuid()], NSFileOwnerAccountID,
            [NSNumber numberWithInt:getegid()], NSFileGroupOwnerAccountID,
            [NSDate date], NSFileCreationDate,
            [NSDate date], NSFileModificationDate,
            NSFileTypeDirectory, NSFileType,  nil];
  }else{
      //     if the node has kids, it's a folder
    if([[node children] count]){
      return [NSDictionary dictionaryWithObjectsAndKeys:
              [NSNumber numberWithInt:0700], NSFilePosixPermissions,
              [NSNumber numberWithInt:geteuid()], NSFileOwnerAccountID,
              [NSNumber numberWithInt:getegid()], NSFileGroupOwnerAccountID,
              [NSDate date], NSFileCreationDate,
              [NSDate date], NSFileModificationDate,
              NSFileTypeDirectory, NSFileType,  nil];
    }
      //    the file *should* exist, this can be wrong
      //    TODO, unsure.
    NSString * newPath = [NSString stringWithFormat:@"%@/%@/%@/%@", temporaryDirectory ,node.user, node.repo, node.path];
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isDir = false;
    if([fm fileExistsAtPath:newPath isDirectory:&isDir]){
      NSError *error = nil;
      return [fm  attributesOfItemAtPath:newPath error:&error];
      if(error){
        DBLog(@"ERROR RE: attributes of item at path %@ ( %@ )", newPath, [error localizedDescription])
      }
    }
  }
  return nil;
}

- (NSData *)contentsAtPath:(NSString *)path {
  if ([path rangeOfString:@"_"].location != NSNotFound) {
    return nil;
  }
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[temporaryDirectory stringByAppendingString:path]];
  if(fileExists){
    return [NSData dataWithContentsOfFile:[temporaryDirectory stringByAppendingString:path]];
  }
  
  return nil;
}

#pragma helper functions

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

-(void)addUser:(NSString*) user{
  GHFile* newNode = [[[GHFile alloc] init] retain];
  newNode.name = user;
  newNode.depth = root.depth + 1;
  newNode.user = user;
  newNode.parent = root;
  newNode.path = user;
  [root add:newNode];
  [newNode release];

}

- (void)addRepo:(NSString*) repo toUser:(NSString*)user{

  GHFile * userNode = [root findChildWithName:user];
  GHFile* newNode = [[[GHFile alloc] init] retain];
  newNode.name = repo;
  newNode.depth = userNode.depth + 1;
  newNode.user = user;
  newNode.repo = repo;
  newNode.parent = userNode;
  newNode.path = @"";
  [userNode add:newNode];
  [newNode release];
}

- (void)addItemToStore:(NSString*) path withUser:(NSString*) user andRepo:(NSString*)repo{
  
  NSMutableArray * components = [[path pathComponents] mutableCopy];
  [components insertObject:repo atIndex:0];
  [components insertObject:user atIndex:0];
  NSUInteger i, count = [components count];
  GHFile* node = root;
  for (i = 0; i < count; i++) {
    NSString * component = [components objectAtIndex:i];
    GHFile* parent = node;
    node = [node findChildWithName:component];
    if(node == nil){
      
      // this is not the end leaf of the tree
      // make the folder for it
      if(i != count){
        NSUInteger j;
        NSString * dir = temporaryDirectory;
        for (j = 0; j < i; j++) {
          dir = [NSString stringWithFormat:@"%@/%@",dir, [components objectAtIndex:j]];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:dir] == NO){
          NSError * error = nil;
          [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        }
      }
      
      GHFile* newNode = [[[GHFile alloc] init] retain];
      newNode.name = component;
      newNode.depth = parent.depth + 1;
      newNode.user = user;
      newNode.repo = repo;
      newNode.path = path;
      newNode.parent = parent;
      [parent add:newNode];
      [newNode writeDataWithTempDirectory:temporaryDirectory];
      [newNode release];        
      NSString * fullPath = [NSString stringWithFormat:@"/Volumes/github/%@/%@/%@", user, repo, path];
      [[NSWorkspace sharedWorkspace] noteFileSystemChanged:fullPath];
    }      
  }  
}

- (void) print{
  DBLog(@"%@", [root description]);
}

@end

