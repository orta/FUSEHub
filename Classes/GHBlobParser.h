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
- (void)addItemToStore:(NSString*) path withUser:(NSString*) user andRepo:(NSString*)repo;
- (void)addRepo:(NSString*) repo toUser:(NSString*)user;
@end



@interface GHBlobParser : NSObject {
  NSObject <GHBlob> * delegate;
  NSString* address;
}

- (id)initWithGitHubUser:(NSString*) user Repository:(NSString*)repo andDelegate:(id <GHBlob>) newDelegate;

@property (retain) NSString* address;

@end
