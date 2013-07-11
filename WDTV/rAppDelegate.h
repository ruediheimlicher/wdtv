//
//  rAppDelegate.h
//  WDTV
//
//  Created by Ruedi Heimlicher on 05.Juli.13.
//  Copyright (c) 2013 Ruedi Heimlicher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileSystemNode;
 
@interface rAppDelegate : NSObject <NSApplicationDelegate, NSBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>
{
   FileSystemNode *rootNode;
   NSMutableArray* filmArray;
   NSMutableArray * archivArray;
   
   IBOutlet NSTableView* filmTable;
   NSString* filmLink;
   NSURL* filmURL;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet  NSBrowser* tvbrowser;
@property (assign) IBOutlet  NSButton* suchentaste;
@property (assign) IBOutlet  NSButton* deletetaste;
@property (assign) IBOutlet  NSButton* opentaste;
@property (assign) IBOutlet  NSButton* magtaste;
@property (assign) IBOutlet  NSButton* archivtaste;

@property (assign) IBOutlet  NSTextField* suchfeld;
@property (assign) IBOutlet  NSTextField* resultatfeld;
@property (assign) IBOutlet  NSTextField* linkfeld;



@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSIndexSet * clickset;
@property NSString * WDTV_Pfad;
@property NSArray * WDTV_Array;

@property NSString * Archiv_Pfad;



- (IBAction)saveAction:(id)sender;

- (IBAction)reportSuchen:(id)sender;
- (IBAction)reportOpen:(id)sender;
- (IBAction)reportMag:(id)sender;
- (IBAction)reportDelete:(id)sender;
- (IBAction)reportArchivAktualisieren:(id)sender;
- (IBAction)reportDouble:(id)sender;
- (IBAction)reportDeleteVonTable:(id)sender;
- (NSArray*)FilmSammlung;
@end
