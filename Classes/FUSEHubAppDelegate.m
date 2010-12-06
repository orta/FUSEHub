//
//  FUSEHubAppDelegate.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "FUSEHubAppDelegate.h"
#import <MacFUSE/MacFUSE.h>
#import "GHFileSystem.h"

@implementation FUSEHubAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(didMount:)
                 name:kGMUserFileSystemDidMount object:nil];
  [center addObserver:self selector:@selector(didUnmount:)
                 name:kGMUserFileSystemDidUnmount object:nil];
  
  
  
  NSString* mountPath = @"/Volumes/Hello";
  GHFileSystem* fileSystem = [[GHFileSystem alloc] init];
  fs_ = [[GMUserFileSystem alloc] initWithDelegate:fileSystem isThreadSafe:YES];
  NSMutableArray* options = [NSMutableArray array];
  [options addObject:@"rdonly"];
  [options addObject:@"volname=GHFileSystem"];
  [options addObject:[NSString stringWithFormat:@"volicon=%@", 
                      [[NSBundle mainBundle] pathForResource:@"Fuse" ofType:@"icns"]]];
  [fs_ mountAtPath:mountPath withOptions:options];
}

- (void)didMount:(NSNotification *)notification {
  NSDictionary* userInfo = [notification userInfo];
  NSString* mountPath = [userInfo objectForKey:kGMUserFileSystemMountPathKey];
  NSString* parentPath = [mountPath stringByDeletingLastPathComponent];
  [[NSWorkspace sharedWorkspace] selectFile:mountPath
                   inFileViewerRootedAtPath:parentPath];
}


- (void)didUnmount:(NSNotification*)notification {
  [[NSApplication sharedApplication] terminate:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [fs_ unmount];  // Just in case we need to unmount;
  [[fs_ delegate] release];  // Clean up HelloFS
  [fs_ release];
  return NSTerminateNow;
}


- (void)dealloc {

  [window release];
    [super dealloc];
}

@end
