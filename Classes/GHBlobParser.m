//
//  GHBlobParser.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "GHBlobParser.h"
#import "Seriously.h"

@implementation GHBlobParser

@synthesize address;

- (id)initWithGitHubURL:(NSString*) blobaddress andDelegate:(id <GHBlob>) newDelegate {
    if ((self = [super init])) {
      self.address = blobaddress;
      delegate = newDelegate;
      
      [Seriously get:self.address handler:^(id body, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
          NSLog(@"Error: %@", error);
        }
        else {
          
          NSArray *lines = [body componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
          NSUInteger i, count = [lines count];
          // there are 2 lines we dont want at the top
          for (i = 2; i < count; i++) {
            NSString * line = [lines objectAtIndex:i];
            NSString * item = [[line componentsSeparatedByString:@":"] objectAtIndex:0];
            item = [item stringByReplacingOccurrencesOfString:@" " withString:@""];
            [delegate addItemToStore:item];
          }
        }
      }];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

@end
