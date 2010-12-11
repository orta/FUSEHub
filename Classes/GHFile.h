//
//  GHFile.h
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GHFile : NSObject {
  NSMutableArray *children;
  NSString *name, *user, *repo;
  int depth;
}
@property (retain) NSMutableArray *children;
@property (retain) NSString *name, *user, *repo;
@property () int depth;

- (GHFile*) findChildWithName:(NSString *) string;
- (void) add:(GHFile *)node;
- (NSArray *) fileArray;

@end
