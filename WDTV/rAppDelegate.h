//
//  rAppDelegate.h
//  WDTV
//
//  Created by Ruedi Heimlicher on 05.Juli.13.
//  Copyright (c) 2013 Ruedi Heimlicher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileSystemNode;
 
@interface rAppDelegate : NSObject <NSApplicationDelegate, NSBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate,NSURLConnectionDelegate, NSURLConnectionDataDelegate,NSURLConnectionDownloadDelegate>
{
   FileSystemNode *rootNode;  // Data source für Browser
   
   NSMutableArray* filmArray; // Data Source fuer TableView FilmTable
   
    NSMutableArray * FilmOrdnerArray;
   // Arrays fuer Filmsammlungen
   NSMutableArray * wdtvArray; // HD an WDTVLive
   NSMutableArray * magArray;
   NSMutableArray * TV_HD_A_Array;
   NSMutableArray * TV_HD_B_Array;
   NSMutableArray * Filmarchiv_Array;
   NSMutableArray * WD_TV_A_Array;
   NSMutableArray * WD_TV_B_Array;
   
   NSMutableArray * Volumes_Array;
   
   NSMutableArray * Missed_HD_Array; // fehlende HDs, sollen bei Refresh gecheckt werden
   
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

@property (assign) IBOutlet  NSButton* listetaste;


@property (assign) IBOutlet  NSTextField* mag_ok;
@property (assign) IBOutlet  NSTextField* filmarchiv_ok;
@property (assign) IBOutlet  NSTextField* WD_TV_A_OK_Feld;
@property (assign) IBOutlet  NSTextField* WD_TV_B_OK_Feld;

@property (assign) IBOutlet  NSTextField* WDTV_OK_Feld;
@property (assign) IBOutlet  NSTextField* TV_HD_A_OK_Feld;
@property (assign) IBOutlet  NSTextField* TV_HD_B_OK_Feld;
@property (assign) IBOutlet  NSTextField* wdtva_ok;
@property (assign) IBOutlet  NSTextField* wdtvb_ok;


@property (assign) IBOutlet  NSTextField* suchfeld;
@property (assign) IBOutlet  NSTextField* resultatfeld;
@property (assign) IBOutlet  NSTextField* linkfeld;

@property (assign) IBOutlet  NSTextView* errorfeld;
@property (assign) IBOutlet  NSTextField* hostnamefeld;
@property (assign) IBOutlet  NSTextField* ipfeld;

@property (assign) IBOutlet  NSProgressIndicator* warteschlaufe;


@property (assign) IBOutlet  NSPopUpButton * volumepop;





@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property NSMutableArray*   FilmOrdnerArray;


@property NSIndexSet * clickset;
@property NSString * WDTV_Pfad; // HD an WDTVLive
@property NSArray * WDTV_Array;

@property NSString* rootNodePath;
@property NSString * Mag_Pfad; // HD an TM
@property NSArray * Mag_Array;
@property NSNumber * Mag_OK; // Mag an TM ist da

@property NSString * Filmarchiv_Pfad; // HD an mini
@property NSArray * Filmarchiv_Array;
@property NSNumber * Filmarchiv_OK; // Filmarchiv an mini ist da

@property NSString * TV_HD_A_Pfad; // TV_HD_A an mini, sofern da
@property NSArray * TV_HD_A_Array;
@property NSNumber * TV_HD_A_OK; // TV_HD_A ist da

@property NSString * TV_HD_B_Pfad; // TV_HD_A an mini, sofern da
@property NSArray * TV_HD_B_Array;
@property NSNumber * TV_HD_B_OK; // TV_HD_A ist da

@property NSString * WD_TV_A_Pfad; // WD_TV_A an mini, sofern da
@property NSArray * WD_TV_A_Array;
@property NSNumber * WD_TV_A_OK; // WD_TV_A HD ist da

@property NSString * WD_TV_B_Pfad; // WD_TV_B an mini, sofern da
@property NSArray * WD_TV_B_Array;
@property NSNumber * WD_TV_B_OK; // WD_TV_B HD ist da



@property NSString * Machine_Pfad;
@property NSString * Homedir_Pfad;
@property NSString * Volumes_Pfad;

@property NSString * FilmListe_Pfad;

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
- (IBAction)reportOpenExtern:(id)sender;
- (IBAction)reportListe:(id)sender;
- (IBAction)reportRefreshFilmlisten:(id)sender;
- (IBAction)reportVolumePop:(id)sender;
- (NSArray*)Film_WDTV;
- (NSArray*)FilmArchiv;
- (NSArray*)FilmMag;
- (NSArray*)Film_TV_HD_A;
- (NSArray*)FilmeAnPfad:(NSString*)pfad;
- (NSError*)writeTitelListe:(NSString*)titelliste toPath:(NSString*) pfad;
@end
