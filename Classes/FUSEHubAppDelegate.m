//
//  FUSEHubAppDelegate.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "FUSEHubAppDelegate.h"

@implementation FUSEHubAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
}

- (void)dealloc {

  [window release];
    [super dealloc];
}

@end
