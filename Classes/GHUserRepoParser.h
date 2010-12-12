//
//  GHUserRepoParser.h
//  FUSEHub
//
//  Created by orta on 12/12/2010.
//  Copyright (c) 2010 http://www.ortatherox.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GHBlobParser.h"


@interface GHUserRepoParser : NSObject {
@private
  id delegate;
}
- (id)initWithUser:(NSString*) user andDelegate:(id<GHBlob>)newDelegate;

@end
