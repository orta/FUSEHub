//
//  GHFile.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "GHFile.h"
#import <MacFUSE/MacFUSE.h>

@implementation GHFile

@synthesize name, children;

- (NSString *) UTF8String{
  return self.name;
}


- (NSString *) description{
  return self.name;
}

- (GHFile*) findChildWithName:(NSString *) string{
  NSUInteger i, count = [self.children count];
  for (i = 0; i < count; i++) {
    GHFile *item = [self.children objectAtIndex:i];
    if([item.name isEqualToString:string]){
      return item;
    }
  }
  return nil;
}

- (void) add:(GHFile *)node{
  [self.children addObject:node];
}

- (NSArray *) fileArray{
  NSMutableArray * stringArray = [NSMutableArray array];
  NSUInteger i, count = [self.children count];
  for (i = 0; i < count; i++) {
    GHFile *item = [self.children objectAtIndex:i];
//    GMFinderInfo * info = [GMFinderInfo finderInfo];
    
    [stringArray addObject:item.name];
    
    
  }
  return stringArray;
}


@end
