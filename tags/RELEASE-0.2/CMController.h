/*
 * Copyright (c) 2006 KATO Kazuyoshi <kzys@8-p.info>
 * This source code is released under the MIT license.
 */

#import <Cocoa/Cocoa.h>

@interface CMController : NSObject {
	IBOutlet NSMenu* menu;	
	IBOutlet NSArrayController* scriptsController;
	
	NSMenuItem* root_;
	NSMutableArray* scripts_;
	NSString* scriptDir_;
}

- (IBAction) uninstallSelected: (id) sender;
- (IBAction) orderFrontAboutPanel: (id) sender;
- (IBAction) reloadUserScripts: (id) sender;
- (NSArray*) scripts;

@end