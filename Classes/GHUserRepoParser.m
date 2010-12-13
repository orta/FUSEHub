//
//  GHUserRepoParser.m
//  FUSEHub
//
//  Created by orta on 12/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import "GHUserRepoParser.h"
#import "ASIHTTPRequest.h"
@implementation GHUserRepoParser

  // $ curl http://github.com/api/v2/xml/repos/show/schacon

  - (id)initWithUser:(NSString*) user andDelegate:(id<GHBlob>)newDelegate {

    
    if ((self = [super init])) {
      delegate = newDelegate;
      
      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/xml/repos/show/%@", user]];
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
      [request setDelegate:self];
      [request setCompletionBlock:^{
        DBLog(@"got file");
          // Use when fetching text data
        NSString *responseString = [request responseString];
        NSError * error = nil;
        NSXMLDocument * xml = [[NSXMLDocument alloc] initWithXMLString:responseString options:nil error:&error];
        if(error == nil){

          NSArray *children = [[xml rootElement] children];
          int i, count = [children count];
          DBLog(@"got file");

          for (i=0; i < count; i++) {
            NSXMLElement *membersElement = [children objectAtIndex:i];
            NSString* repo = [[[membersElement elementsForName:@"name"] objectAtIndex:0] stringValue] ;
            [delegate addRepo: repo toUser:user];
          }
        }else{
          DBLog(@"XML Error %@", [error localizedDescription] );
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
    // Clean-up code here.
    
    [super dealloc];
}

@end
