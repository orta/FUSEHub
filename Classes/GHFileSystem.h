//
//  GHFileSysytem.h
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GHBlobParser.h"

@class GHFile;

@interface GHFileSystem : NSObject <GHBlob> {
  GHFile *root;
}

- (void)addItemToStore:(NSString*) item;

@end
