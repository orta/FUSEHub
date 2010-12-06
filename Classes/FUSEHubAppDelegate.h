//
//  FUSEHubAppDelegate.h
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GMUserFileSystem;

@interface FUSEHubAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  GMUserFileSystem* fs_;

}

@property (retain) IBOutlet NSWindow *window;

@end
