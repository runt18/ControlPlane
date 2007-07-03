//
//  ContextsDataSource.h
//  MarcoPolo
//
//  Created by David Symonds on 3/07/07.
//

#import <Cocoa/Cocoa.h>


@interface Context : NSObject {
	NSString *uuid;
	NSString *parent;	// UUID
	NSString *name;
}

- (id)init;
- (id)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isRoot;
- (NSString *)parent;
- (void)setParent:(NSString *)parentUUID;
- (NSString *)name;
- (void)setName:(NSString *)newName;

@end


@interface ContextsDataSource : NSObject {
	NSMutableDictionary *contexts;
}

- (void)loadContexts;

@end
