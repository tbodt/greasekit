/*
 * Copyright (c) 2006 KATO Kazuyoshi <kzys@8-p.info>
 * This source code is released under the MIT license.
 */

#import <Cocoa/Cocoa.h>

@interface CMUserScript : NSObject {
	NSString* name_;
	NSString* description_;
	NSString* script_;
	
	NSMutableArray* include_;
	NSMutableArray* exclude_;
	
	NSString* basename_;
	NSString* fullPath_;
}

+ (NSDictionary*) parseMetadata: (NSString*) script;

- (id) initWithString: (NSString*) script;
- (id) initWithContentsOfFile: (NSString*) path;
- (id) initWithContentsOfURL: (NSURL*) url;

// Getter
- (NSString*) name;
- (NSString*) description;
- (NSString*) script;

- (BOOL) isInstalled: (NSString*) path;
- (BOOL) install: (NSString*) path;
- (BOOL) uninstall;

- (BOOL) isMatched: (NSURL*) url;

@end