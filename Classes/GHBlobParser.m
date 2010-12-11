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

- (id)initWithGitHubUser:(NSString*) user Repository:(NSString*)repo andDelegate:(id <GHBlob>) newDelegate {
  NSString * blobaddress = [NSString stringWithFormat:@"http://github.com/api/v2/yaml/blob/all/%@/%@/master", user, repo];
    
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
//          NSString * formatted = [NSString stringWithFormat: @"%@/%@/%@", user, repo, item];
          [delegate addItemToStore:item withUser:user andRepo:repo];
        }

      }];
      [request setFailedBlock:^{
        NSError *error = [request error];
        DBLog(@"ERROR: %@", [error localizedDescription]);
      }];

      [request startAsynchronous];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

@end
