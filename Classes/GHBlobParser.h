//
//  GHBlobParser.h
//  FUSEHub
//
//  Created by orta on 06/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol GHBlob <NSObject>
@required
 - (void)addItemToStore:(NSString*) item;
@end



@interface GHBlobParser : NSObject {
  NSObject <GHBlob> * delegate;
  NSString* address;
}

- (id)initWithGitHubURL:(NSString*) blobaddress andDelegate:(id <GHBlob>) newDelegate;

@property (retain) NSString* address;

@end
