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

@synthesize name, children, depth, user, repo;

- (NSString *) UTF8String{
  return self.name;
}


- (NSString *) description{
   NSString * string = @"";
  int i;
   for (i = 0; i < self.depth; i++) {
     string = [string stringByAppendingString:@"  "];
   }
  
  string = [string stringByAppendingString:self.name];
  
  if([self.children count]){
    for (i = 0; i < [self.children count]; i++) {
      NSLog(@"%@", [[self.children objectAtIndex:i] description]);
    }    
  }
  return string;
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
  [node retain];
  if(self.children == nil)
    self.children = [NSMutableArray array];
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
