//
//  GHBlobParser.m
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "GHBlobParser.h"
#import "ASIHTTPRequest.h"

@implementation GHBlobParser

@synthesize address;

- (id)initWithGitHubURL:(NSString*) blobaddress andDelegate:(id <GHBlob>) newDelegate {
    if ((self = [super init])) {
      self.address = blobaddress;
      delegate = newDelegate;
      
      NSURL *url = [NSURL URLWithString:self.address];
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
      [request setDelegate:self];
      [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        NSArray *lines = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSUInteger i, count = [lines count];
        // there are 2 lines we dont want at the top, and a blank newline at the end
        for (i = 2; i < count-1; i++) {
          NSString * line = [lines objectAtIndex:i];
          NSString * item = [[line componentsSeparatedByString:@":"] objectAtIndex:0];
          item = [item stringByReplacingOccurrencesOfString:@" " withString:@""];
          [delegate addItemToStore:item];
        }

      }];
      [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"ERROR: %@", [error localizedDescription]);
      }];

      [request startAsynchronous];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

@end
