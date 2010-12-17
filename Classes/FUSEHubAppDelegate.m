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

- (id) init{
  self = [super init];
//  this needs to be set before the app is finished so we get the event
  [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                     andSelector:@selector(gotIncomingURL: withReplyEvent:) 
                                                   forEventClass:kInternetEventClass
                                                      andEventID:kAEGetURL];  
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//  FUSE stuff
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(didMount:)
                 name:kGMUserFileSystemDidMount object:nil];
  [center addObserver:self selector:@selector(didUnmount:)
                 name:kGMUserFileSystemDidUnmount object:nil];

  //Bookmark stuff

  mountPath = @"/Volumes/github";
  fileSystem = [[GHFileSystem alloc] init];
  fs_ = [[GMUserFileSystem alloc] initWithDelegate:fileSystem isThreadSafe:YES];
  NSMutableArray* options = [NSMutableArray array];
  [options addObject:@"volname=GitHub"];
  [options addObject:[NSString stringWithFormat:@"volicon=%@", 
                      [[NSBundle mainBundle] pathForResource:@"FS" ofType:@"icns"]]];
  [fs_ mountAtPath:mountPath withOptions:options];
  
//  [self setUpGUINotifications];
}


- (void)didMount:(NSNotification *)notification {
  NSDictionary* userInfo = [notification userInfo];
  mountPath = [userInfo objectForKey:kGMUserFileSystemMountPathKey];
  NSString* parentPath = [mountPath stringByDeletingLastPathComponent];
  fileSystem.mounted = YES;
  
  [[NSWorkspace sharedWorkspace] selectFile:mountPath
                   inFileViewerRootedAtPath:parentPath];
  if(openedURL != nil){
    [self parseStoredURL];
  }
}


- (void)didUnmount:(NSNotification*)notification {
  [[NSApplication sharedApplication] terminate:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [fs_ unmount];  // Just in case we need to unmount;
  [[fs_ delegate] release];
  [fs_ release];
  return NSTerminateNow;
}

- (void) parseStoredURL{
  NSString *incomingURL = openedURL;
  incomingURL = [incomingURL stringByReplacingOccurrencesOfString:@"fusehub:" withString:@""];
  NSArray *fields = [incomingURL componentsSeparatedByString:@"&"];
  NSEnumerator *e = [fields objectEnumerator];
  NSString *field = @"";
  NSString *username = @"";
  while ((field = [e nextObject])) {
    NSArray *keyvalue = [field componentsSeparatedByString:@"="];
    NSString *key = [keyvalue objectAtIndex:0] ;
    NSString *value = [keyvalue objectAtIndex:1];
    
    if([key isEqualToString:@"user"]){
      username = value;
    }
    
    if([key isEqualToString:@"repo"]){
      [fileSystem getUser:username andRepo:value];
    }
    
    if([value isEqualToString:@"browse"]){
      [fileSystem getUser:username];
    }
  }
}
- (void) gotIncomingURL:(NSAppleEventDescriptor*) event withReplyEvent:(NSAppleEventDescriptor *) reply{
  // we want to do this, but we have to be mounted first
  openedURL =  [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
  if( fileSystem.mounted ){
    [self parseStoredURL];
    
    NSString* parentPath = [mountPath stringByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] selectFile:mountPath
                     inFileViewerRootedAtPath:parentPath];
  }
}


- (void)dealloc {

  [window release];
    [super dealloc];
}

- (IBAction)break:(id)sender {
  [fileSystem print];
}
@end
