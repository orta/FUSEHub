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
  NSString *name;
}
@property (retain) NSMutableArray *children;
@property (retain) NSString *name;

@end
