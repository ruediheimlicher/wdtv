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
   NSMutableArray* filmArray; // Data Source fuer TableView FilmTable
   
   // Arrays fuer Filmsammlungen
   NSMutableArray * wdtvArray;
   NSMutableArray * magArray;
   NSMutableArray * externArray;
   NSMutableArray * filmarchivArray;
   
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
@property (assign) IBOutlet  NSButton* playtaste;

@property (assign) IBOutlet  NSButton* archivtaste;
@property (assign) IBOutlet  NSButton* openexterntaste;

@property (assign) IBOutlet  NSTextField* suchfeld;
@property (assign) IBOutlet  NSTextField* resultatfeld;
@property (assign) IBOutlet  NSTextField* linkfeld;

@property (assign) IBOutlet  NSTextField* errorfeld;
@property (assign) IBOutlet  NSTextField* hostnamefeld;




@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSIndexSet * clickset;
@property NSString * WDTV_Pfad; // HD an WDTVLive
@property NSArray * WDTV_Array;

@property NSString * Mag_Pfad; // HD an TM
@property NSArray * Mag_Array;


@property NSString * Filmarchiv_Pfad; // HD an mini
@property NSArray * Filmarchiv_Array;

@property NSString * extern_Pfad; // externe HD an mini, sofern da
@property NSArray * Extern_Array;



@property NSString * Machine_Pfad;
@property NSString * Homedir_Pfad;
@property NSString * Volumes_Pfad;
@property NSString * Host_Name;





- (IBAction)saveAction:(id)sender;

- (IBAction)reportSuchen:(id)sender;
- (IBAction)reportOpen:(id)sender;
- (IBAction)reportMag:(id)sender;
- (IBAction)reportBrowserMag:(id)sender;
- (IBAction)reportBrowserPlay:(id)sender;
- (IBAction)reportDelete:(id)sender;
- (IBAction)reportMagazinAktualisieren:(id)sender;
- (IBAction)reportKellerAktualisieren:(id)sender;
- (IBAction)reportDouble:(id)sender;
- (IBAction)reportDeleteVonTable:(id)sender;
-(IBAction)reportOpenExtern:(id)sender;
- (NSArray*)Film_WDTV;
- (NSArray*)FilmArchiv;
- (NSArray*)FilmMag;
- (NSArray*)FilmExtern;
- (NSArray*)FilmeAnPfad:(NSString*)pfad;
@end
