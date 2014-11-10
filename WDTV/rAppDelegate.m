//
//  rAppDelegate.m
//  WDTV
//
//  Created by Ruedi Heimlicher on 05.Juli.13.
//  Copyright (c) 2013 Ruedi Heimlicher. All rights reserved.
//

#import "rAppDelegate.h"
#import "FileSystemNode.h"
#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>
#include <ifaddrs.h>

#include <arpa/inet.h>
#include <sys/socket.h>
#import <SystemConfiguration/SCNetworkConfiguration.h>

#include <unistd.h>

@implementation rAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

-(void) monitorVolumes
{
   [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector: @selector(volumesChanged:) name:NSWorkspaceDidMountNotification object: nil];
   [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector: @selector(volumesChanged:) name:NSWorkspaceDidUnmountNotification object:nil];
}



void mountVolumeAppleScript (NSString *usr, NSString *pwd, NSString *serv, NSString *freig)
{
   
   // http://www.osxentwicklerforum.de/index.php?page=Thread&threadID=24276
   // http://stackoverflow.com/questions/6804541/getting-applescript-return-value-in-obj-c
   //NSString *mountString = [NSString localizedStringWithFormat:@"if not (exists disk freig)\n display dialog \"mounted\" \nend if\n",freig];
   
   NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"%@\") then\nbeep\nelse\nmount volume \"smb://%@:%@@%@._smb._tcp.local/%@\"\nend if\nend tell\n",freig,usr,pwd,serv,freig];

   // Pfad aus Informationsfenster
   //NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"WD_TV\") then\nbeep\nelse\nmount volume \"smb://WDTVLIVE._smb._tcp.local/WD_TV\"\nend if\nend tell\n"];

   //NSLog(@"mountString: %@",mountString);
   NSAppleScript *script = [[NSAppleScript alloc] initWithSource:mountString];
   
   NSDictionary *errorMessage = nil;
   NSAppleEventDescriptor *result = [script executeAndReturnError:&errorMessage];
   //NSLog(@"mount: %@",result);
}

void mountKellerAppleScript (NSString *usr, NSString *pwd, NSString *serv, NSString *freig)
{
   
   // http://www.osxentwicklerforum.de/index.php?page=Thread&threadID=24276
   // http://stackoverflow.com/questions/6804541/getting-applescript-return-value-in-obj-c
   //NSString *mountString = [NSString localizedStringWithFormat:@"if not (exists disk freig)\n display dialog \"mounted\" \nend if\n",freig];
   
   NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"%@\") then\nbeep\nelse\nmount volume \"smb://%@:%@@%@._smb._tcp.local/%@\"\nend if\nend tell\n",freig,usr,pwd,serv,freig];
   
   // Pfad aus Informationsfenster
  // NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"Mag\") then\nbeep\nelse\nmount volume \"smb://WDTVLIVE._smb._tcp.local/WD_TV\"\nend if\nend tell\n"];
   
   //NSLog(@"mountString: %@",mountString);
   
   NSAppleScript *script = [[NSAppleScript alloc] initWithSource:mountString];
   
   NSDictionary *errorMessage = nil;
   NSAppleEventDescriptor *result = [script executeAndReturnError:&errorMessage];
   //NSLog(@"mountKeller: %@",result);
}




-(void) volumesChanged: (NSNotification*) notification
{
   NSLog(@"dostuff");
}

- (void)browserCellSelected:(id)sender // double Click
{
   NSIndexPath *indexPath = [self.tvbrowser selectionIndexPath];
   
   //NSLog(@"Selected Item: %@ l: %ld", [indexPath description],(unsigned long)[indexPath length] );
   NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   //NSLog(@"Selected Cell: %@", [selektierteZelle stringValue]);
   
   long l=[indexPath length];
   int index = [indexPath indexAtPosition:l-1];// letzter Index
   filmLink = [[[self.tvbrowser itemAtRow: index inColumn:l-1]URL]path] ; //
   filmURL = [[self.tvbrowser itemAtRow: index inColumn:l-1]URL];
    //NSLog(@"filmLink: %@ filmURL: %@",filmLink   ,filmURL);
   if ([filmLink length])
   {
      self.linkfeld.stringValue = filmLink;
      self.opentaste.enabled = YES;
      if (l==3)
      {
         self.playtaste.enabled = YES;
         self.magtaste.enabled = YES;
         self.deletetaste.enabled = YES;
         self.archivtaste.enabled = YES;
      }
   }
}

- (void)browserClick:(id)sender
{
   //NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   //NSLog(@"browserClick col %ld ",self.tvbrowser.selectedColumn );
   long col=self.tvbrowser.selectedColumn ;
   //NSLog(@"browserClick row %ld ",[self.tvbrowser selectedRowInColumn:col] );
   long zeile = [self.tvbrowser selectedRowInColumn:col];
   if (zeile <0 || zeile == NSNotFound)
   {
      zeile=0;
   }
   NSIndexSet* newset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(col, zeile)];
   
   if (!([newset isEqualToIndexSet:self.clickset]))
   {
      self.linkfeld.stringValue = @"";
      
      
      self.opentaste.enabled = NO;
      self.magtaste.enabled = NO;
      self.deletetaste.enabled = NO;
      self.archivtaste.enabled = NO;
      self.clickset = newset;
   }
   }


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   
   [self.warteschlaufe setHidden:NO];
   [self.warteschlaufe startAnimation:NULL];
   self.Homedir_Pfad = NSHomeDirectory();
   //NSLog(@"Homedir_Pfad: %@",self.Homedir_Pfad);
   /*
   NSLog(@"Openpanel");
   NSOpenPanel * TestProfilOpenPanel = [NSOpenPanel openPanel];
   NSLog(@"readFigur ProfilOpenPanel: %@",[TestProfilOpenPanel description]);    //
   [TestProfilOpenPanel setCanChooseFiles:NO];
   [TestProfilOpenPanel setCanChooseDirectories:YES];
   [TestProfilOpenPanel setAllowsMultipleSelection:NO];
   //[TestProfilOpenPanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
   
   [NSApp runModalForWindow:TestProfilOpenPanel];
   
   long antwort=[TestProfilOpenPanel runModal];
*/
   self.Volumes_Pfad = @"/Volumes";
   //NSLog(@"Volumes_Pfad: %@",self.Volumes_Pfad);

   char* host_name = malloc(255);
   int n=gethostname(host_name, 255);
   fprintf(stderr,"host_name: %s\n",host_name);
   self.Host_Name = [NSString stringWithCString:host_name encoding:NSMacOSRomanStringEncoding];
   //NSLog(@"Host_Name: %@",self.Host_Name);
   
   self.hostnamefeld.stringValue = self.Host_Name;
 

   // you may need to include other headers
   /*
    struct ifaddrs {
    struct ifaddrs  *ifa_next;
    char		*ifa_name;
    unsigned int	 ifa_flags;
    struct sockaddr	*ifa_addr;
    struct sockaddr	*ifa_netmask;
    struct sockaddr	*ifa_dstaddr;
    void		*ifa_data;
    };

    */
   struct ifaddrs* interfaces = NULL;
   struct ifaddrs* temp_addr = NULL;
   
   // retrieve the current interfaces - returns 0 on success
   NSInteger success = getifaddrs(&interfaces);
   if (success == 0)
   {
      // Loop through linked list of interfaces
      temp_addr = interfaces;
      while (temp_addr != NULL)
      {
         if (temp_addr->ifa_addr->sa_family == AF_INET) // internetwork only
         {
          if (strcmp(temp_addr->ifa_name ,"fw0")==0)
            {
            NSString* name = [NSString stringWithUTF8String:temp_addr->ifa_name];
            NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
            NSLog(@"interface name: %@ address: %@", name,address);
               self.ipfeld.stringValue = address;
            }
         }
         
         temp_addr = temp_addr->ifa_next;
      }
   }
   
   // Free memory
   

   
   
   filmArray = [[NSMutableArray alloc]initWithCapacity:0]; // DataSource  von TableView FilmTable
   
   wdtvArray = [[NSMutableArray alloc]initWithCapacity:0]; // files auf HD an WDTVLive
   magArray = [[NSMutableArray alloc]initWithCapacity:0]; // files auf Mag an TM
   externArray = [[NSMutableArray alloc]initWithCapacity:0]; // Files auf externer HD an mini, sofern da
   filmarchivArray = [[NSMutableArray alloc]initWithCapacity:0]; // Files auf Film_HD an mini

   
   //
   [self.tvbrowser setTarget:self];
   [self.tvbrowser setColumnResizingType:NSBrowserUserColumnResizing];
   //[self.self.tvbrowser setReusesColumns:NO];
   //[self.tvbrowser setWidth:100 ofColumn:0];
   [self.tvbrowser sizeToFit];
   [self.tvbrowser  setWidth:[self.tvbrowser columnWidthForColumnContentWidth:150] ofColumn:0];

   [self.tvbrowser  setWidth:[self.tvbrowser columnWidthForColumnContentWidth:150] ofColumn:1];

   [self.self.tvbrowser setDelegate:self];
   
   [self.tvbrowser  setDoubleAction:@selector(browserCellSelected:)];
   [self.tvbrowser  setAction:@selector(browserClick:)];
   
 //  [[self.tvbrowser matrixInColumn:1] sizeToCells];
   
   //[self.tvbrowser setWidth:[self.tvbrowser columnWidthForColumnContentWidth:100] ofColumn:1];
   //[self.tvbrowser setWidth:[self.tvbrowser columnWidthForColumnContentWidth:100] ofColumn:0];
   
   // TableView
   [filmTable setDelegate:self];
   [filmTable setDataSource:self];
   
   
  
   
    NSButtonCell *cell = [[NSButtonCell alloc] init];
    [cell setButtonType:NSMomentaryPushInButton];
   [cell setBezelStyle: NSRoundRectBezelStyle];
   [cell setControlSize: NSSmallControlSize];
    //[cell setBordered:YES];
    //[cell setImagePosition:NSImageRight];
    //[cell setImage:[NSImage imageNamed:@"SizeCellReveal"]];
    //[cell setAlternateImage:[NSImage imageNamed:@"SizeCellRevealHighlighted"]];
    [cell setAction:@selector(reportPlay:)];
    [cell setTarget:self];
    [cell setTitle:@"play"];
   [[filmTable tableColumnWithIdentifier:@"play"]setDataCell:cell];
 
   NSButtonCell *deletecell = [[NSButtonCell alloc] init];
   [deletecell setButtonType:NSMomentaryPushInButton];
   [deletecell setBezelStyle: NSRoundRectBezelStyle];
   [deletecell setControlSize: NSSmallControlSize];
   [deletecell setAction:@selector(reportDeleteVonTable:)];
   [deletecell setTarget:self];
   [deletecell setTitle:@"delete"];
   [[filmTable tableColumnWithIdentifier:@"delete"]setDataCell:deletecell];

   NSButtonCell *movecell = [[NSButtonCell alloc] init];
   [movecell setButtonType:NSMomentaryPushInButton];
   [movecell setBezelStyle: NSRoundRectBezelStyle];
   [movecell setControlSize: NSSmallControlSize];
   [movecell setAction:@selector(reportMagVonTable:)];
   [movecell setTarget:self];
   [movecell setTitle:@">mag"];
   [[filmTable tableColumnWithIdentifier:@"mag"]setDataCell:movecell];
   
   self.rootNodePath = @"/Volumes/WD_TV";
   if ([_Host_Name isEqualToString:@"ruediheimlicher.local"])
       {
          self.Filmarchiv_Pfad = @"/Volumes/Magazin_HD/Filmarchiv";
          
       }
   else if ([_Host_Name isEqualToString:@"minihome.local"])
   {
      self.Filmarchiv_Pfad = @"/Volumes/Film_HD/Filmarchiv";
   }
   else if ([_Host_Name isEqualToString:@"ruediheimlicher.home"]) // auswaerts mit MBP
   {
      self.rootNodePath = @"/Volumes/TV_HD";
      //self.Filmarchiv_Pfad = @"/Volumes/Film_HD/Filmarchiv";
   
   }

   else
   {
      self.Filmarchiv_Pfad=nil;
   }
   NSLog(@"rootnode: %@",self.rootNodePath);
   // *************************************************
   // Daten auf WDTVLIVE lesen
   // *************************************************

 //  mountVolumeAppleScript(@"ruediheimlicher",@"rh47",@"WDTVLIVE",@"WD_TV");

   self.WDTV_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV"];
   NSLog(@"WDTV_Pfad: %@",self.WDTV_Pfad);
   
   NSLog(@"home: %@",NSHomeDirectory());
   
   
   
   NSURL* WDTV_URL=[NSURL fileURLWithPath:self.WDTV_Pfad];
   
   
   wdtvArray = (NSMutableArray*)[self Film_WDTV];
   //NSLog(@"wdtvArray: %@",wdtvArray );
   NSString* wdtv_ort = self.WDTV_Pfad.lastPathComponent;
   //NSLog(@"wdtv_ort: %@ count: %d",wdtv_ort ,wdtvArray.count);
   
   NSString* wdtvListe = [self titelListeAusArray:wdtvArray];
   
   //NSLog(@"wdtvListe: %@",wdtvListe );
   
   NSLog(@"***");
   
   NSMutableArray* wdtvListArray = [[NSMutableArray alloc]initWithCapacity:0];
   for (int i=0;i<wdtvArray.count;i++)
   {
     // NSString* tempFilmTitel = [[wdtvArray objectAtIndex:i]stringByDeletingLastPathComponent];
      NSString* tempFilmTitel = [[[wdtvArray objectAtIndex:i] stringByReplacingOccurrencesOfString:self.WDTV_Pfad withString:@""]substringFromIndex:1];// erstes tab weg
      
      //NSLog(@"tempFilmTitel: %@",tempFilmTitel );
      NSArray* tempElementeArray = [tempFilmTitel componentsSeparatedByString:@"/"]; // Am anfang steht ein /
      
       //NSLog(@"tempFilmTitel: %@ anz: %d",tempFilmTitel,[[tempFilmTitel componentsSeparatedByString:@"/"] count] );
      
      switch (tempElementeArray.count)
      {
         case 3: // alles vorhanden
         {
            NSString* tempZeilenString = [tempElementeArray componentsJoinedByString:@"\t"];
            NSMutableDictionary* tempZeilenDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  
                                                  [tempElementeArray objectAtIndex:0],@"art",
                                                  [tempElementeArray objectAtIndex:1],@"sub",
                                                  tempZeilenString,@"titelstring",
                                                [tempElementeArray objectAtIndex:2],@"titel", nil];
            [wdtvListArray addObject:tempZeilenDic];
            
         }break;
         case 2:
         {
            NSLog(@"3 El : %@",[tempElementeArray lastObject]);
         }break;
         case 1:
         {
            NSLog(@"2 El : %@",[tempElementeArray lastObject]);
         }break;
         default:
         {
            NSLog(@"falscher Titel : %@",tempFilmTitel);
         }break;
      }
   }
   
//   NSLog(@"wdtvListArray: %@",wdtvListArray );
   /*
   NSString* wdtvListe = [NSString string];
   for (int i=0;i<wdtvListArray.count;i++)
   {
      wdtvListe = [wdtvListe stringByAppendingFormat:@"%@\t%@\n",self.WDTV_Pfad.lastPathComponent,[[wdtvListArray objectAtIndex:i]objectForKey:@"titelstring"]];
   }
//   NSLog(@"wdtvListe: \n%@",wdtvListe );
   */
   NSString* ListePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/wdtvliste.txt"];

   NSURL* ListeURL = [NSURL fileURLWithPath:ListePfad];
   
   NSLog(@"ListeURL: %@",ListeURL );

   NSError *error = nil;
   success = [wdtvListe writeToURL:ListeURL
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:&error];
   
   NSString *status = success ? @"Success" : @"Failure";
   if(success){
      NSLog(@"Done Writing: %@",status);
   }
   else{
      NSLog(@"Done Writing: %@",status);
      NSLog(@"Error: %@",[error localizedDescription]);
   }
   BOOL erfolg = [wdtvListe writeToURL:ListeURL atomically:YES encoding: NSUTF8StringEncoding error:NULL];
   
   NSLog(@"write wdtvListe: %d",erfolg );
   
   /*
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   if ([Filemanager fileExistsAtPath:self.WDTV_Pfad])//ist
       {
          //NSArray* OrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.WDTV_Pfad error:&err];
          //NSArray* OrdnerArray
          self.WDTV_Array =  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.WDTV_Pfad]
                     includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                          error:&err];
         //NSLog(@"OrdnerArray: %@",[self.WDTV_Array description]);
       }
 

   // Daten in Mag_WDTV.txt lesen. Filme auf der externen Festplatte
   
   */
   
   
   /*
   self.Archiv_Pfad = [NSString stringWithFormat:@"%@/Documents/WDTVDaten/Mag_WDTV.txt",NSHomeDirectory()];
   //NSLog(@"self.Archiv_Pfad: %@",self.Archiv_Pfad);
   NSURL* Archiv_URL=[NSURL fileURLWithPath:self.Archiv_Pfad];
   if ([Filemanager fileExistsAtPath:self.Archiv_Pfad])//ist
   {
      NSError* err;
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[ArchivOrdnerArray description]);
      NSArray* OrdnerArray=  [NSArray arrayWithContentsOfURL:Archiv_URL];
      //NSLog(@"OrdnerArray: %@",[OrdnerArray description]);
      
      for (NSString* tempurl in OrdnerArray)
      {
         //NSLog(@"tempurl: %@",[tempurl  lastPathComponent]);
         [archivArray addObject:tempurl];
      }
      //NSLog(@"archivArray: %@",[archivArray description]);
   }
   */
   
   // *************************************************
   // Film-Daten auf der TM lesen: File auf TM/Mag
   // *************************************************
   
  // mountKellerAppleScript(@"ruediheimlicher",@"rh47",@"TC_Basis",@"Mag");

   self.Mag_Pfad = [NSString stringWithFormat:@"/Volumes/Mag/Archiv_WDTV"];
   //NSLog(@"Mag_Pfad: %@",self.Mag_Pfad);
   
   magArray = (NSMutableArray*)[self FilmMag];
   
   NSString* magListe = [self titelListeAusArray:magArray];
   
   NSLog(@"magListe: %@",magListe );
   
   NSLog(@"***");
   NSString* magPfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/magliste.txt"];
   
   NSURL* magURL = [NSURL fileURLWithPath:magPfad];
   
   NSLog(@"magURL: %@",magURL );
   
   NSError *magerror = nil;
   success = [magListe writeToURL:magURL
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:&magerror];
   
   NSString *magstatus = success ? @"Success" : @"Failure";
   if(success){
      NSLog(@"Done Writing: %@",magstatus);
   }
   else{
      NSLog(@"Done Writing: %@",magstatus);
      NSLog(@"Error: %@",[error localizedDescription]);
   }
   BOOL magerfolg = [magListe writeToURL:magURL atomically:YES encoding: NSUTF8StringEncoding error:NULL];
   
   NSLog(@"write magListe: %d",magerfolg );


   
   
   //NSLog(@"magArray: %@",magArray);
   
   // *************************************************
   // Filmarchiv lesen
    // *************************************************
   filmarchivArray =(NSMutableArray*)[self FilmArchiv];
   
   if ([filmarchivArray count])
   {
      self.errorfeld.stringValue = [[self.errorfeld stringValue]stringByAppendingFormat:@"\n%@",[filmarchivArray lastObject] ];
   }
   
//   mountKellerAppleScript(@"ruediheimlicher",@"rh47",@"TV_HD",@"Tatort");

   // *************************************************
   // Externes Filmarchiv lesen
   // *************************************************

   self.extern_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD"];
   NSLog(@"externPfad: %@",self.extern_Pfad);
   
   //externArray = (NSMutableArray*)[self FilmeAnPfad:externPfad];
   externArray = (NSMutableArray*)[self FilmExtern];
   //NSLog(@"externarray: %@",externArray);
   
   NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
   [nc addObserver:self
			 selector:@selector(FensterSchliessenAktion:)
				  name:@"NSWindowWillCloseNotification"
				object:nil];

   [self.warteschlaufe stopAnimation:NULL];
   [self.warteschlaufe setHidden:YES];
}

/*
- (NSArray*)FilmArchiv // Textfile lesen
{
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSMutableArray* temparchivArray = [[NSMutableArray alloc]initWithCapacity:0];

   self.Archiv_Pfad = [NSString stringWithFormat:@"%@/Documents/WDTVDaten/Mag_WDTV.txt",NSHomeDirectory()];
   //NSLog(@"self.Archiv_Pfad: %@",self.Archiv_Pfad);
   NSURL* Archiv_URL=[NSURL fileURLWithPath:self.Archiv_Pfad];
   if ([Filemanager fileExistsAtPath:self.Archiv_Pfad])//ist
   {
      NSError* err;
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[ArchivOrdnerArray description]);
      NSArray* OrdnerArray=  [NSArray arrayWithContentsOfURL:Archiv_URL];
      //NSLog(@"OrdnerArray: %@",[OrdnerArray description]);
      
      for (NSString* tempurl in OrdnerArray)
      {
         //NSLog(@"tempurl: %@",[tempurl  lastPathComponent]);
         [temparchivArray addObject:tempurl];
      }
      NSLog(@"Archiv_Pfad OK");
      //NSLog(@"archivArray: %@",[archivArray description]);
   }
   else{
      NSLog(@"Archiv_Pfad leer");
   }
   return temparchivArray;
}
 */

- (void)browserCellSelected2:(id)sender
{
   //NSIndexPath *indexPath = [_browser selectionIndexPath];
   //NSLog(@"indexPath: %@ ", indexPath);
   //NSLog(@"indexPath: %@ cell: %@", indexPath,[_browser selectedCell]);
   NSLog(@"cell: %@ ", [[self.tvbrowser selectedCell]stringValue]);
   
}

- (NSString*)titelListeAusArray:(NSArray*)derFilmArray
{
   NSMutableArray* ListeArray = [[NSMutableArray alloc]initWithCapacity:0];
   for (int i=0;i<derFilmArray.count;i++)
   {
      //NSString* tempFilmTitel = [[derFilmArray objectAtIndex:i]stringByDeletingLastPathComponent];
      NSString* tempFilm = [derFilmArray objectAtIndex:i]; // WD_TV		Volumes	WD_TV	Tatort	Mag	Tatort 130323 Summ, Summ, Summ.mpg
     //NSString* tempFilmTitel = [[[filmArray objectAtIndex:i] stringByReplacingOccurrencesOfString:self.WDTV_Pfad withString:@""]substringFromIndex:1];// erstes tab weg
      
      //NSLog(@"tempFilmTitel: %@",tempFilmTitel );
      NSArray* tempElementeArray = [tempFilm componentsSeparatedByString:@"/"]; // Am anfang steht ein /
      
     // NSLog(@"tempFilmTitel: %@ anz: %d",tempFilm,[[tempFilm componentsSeparatedByString:@"/"] count] );
      
      switch (tempElementeArray.count)
      {
         case 6: // alles vorhanden
         {
            NSString* tempZeilenString = [[tempElementeArray subarrayWithRange:NSMakeRange(3, 3)]componentsJoinedByString:@"\t"];
            
            NSMutableDictionary* tempZeilenDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [tempElementeArray objectAtIndex:2],@"ort",
                                                  [tempElementeArray objectAtIndex:3],@"art",
                                                  [tempElementeArray objectAtIndex:4],@"sub",
                                                  tempZeilenString,@"titelstring",
                                                  [tempElementeArray objectAtIndex:5],@"titel", nil];
            [ListeArray addObject:tempZeilenDic];
            
         }break;
         case 2:
         {
            NSLog(@"3 El : %@",[tempElementeArray lastObject]);
         }break;
         case 1:
         {
            NSLog(@"2 El : %@",[tempElementeArray lastObject]);
         }break;
         default:
         {
            NSLog(@"falscher Titel : %@",tempFilm);
         }break;
      }
   }
   
  // NSLog(@"ListeArray: %@",ListeArray );
   NSString* Liste = [NSString string];
   for (int i=0;i<ListeArray.count;i++)
   {
      Liste = [Liste stringByAppendingFormat:@"%@\t%@\n",[[ListeArray objectAtIndex:i]objectForKey:@"ort"],[[ListeArray objectAtIndex:i]objectForKey:@"titelstring"]];
   }
   //NSLog(@"wdtvListe: %@",wdtvListe );

   return Liste;
}


- (NSArray*)Film_WDTV
{
   // Alle Filme auf WDTV
   NSMutableArray* sammlungArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSString* sammelPfad = self.WDTV_Pfad;
   if ([Filemanager fileExistsAtPath:sammelPfad])//ist
   {
      self.errorfeld.stringValue = [[self.errorfeld stringValue]stringByAppendingFormat:@"%@\n",@"WDTV_Ordner da" ];
      self.wdtv_ok.enabled = 1;
      self.wdtv_ok.backgroundColor = [NSColor greenColor];
      //NSArray* OrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.WDTV_Pfad error:&err];
      //NSArray* OrdnerArray
      NSArray* OrdnerArray0 =  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.WDTV_Pfad]
                                    includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                         error:&err];
      //NSLog(@"OrdnerArray0: %@",[OrdnerArray0 description]);
      BOOL isDir;
      if ([OrdnerArray0 count])
      {
         for (NSURL* unterorderurl0 in OrdnerArray0 )
         {
            
            if([Filemanager fileExistsAtPath:[unterorderurl0 path] isDirectory:&isDir] && isDir)
            {
               NSArray* OrdnerArray1 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl0
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&err];
               //NSLog(@"OrdnerArray1: %@",[OrdnerArray1 description]);
               
               if ([OrdnerArray1 count])
               {
                  for (NSURL* unterorderurl1 in OrdnerArray1 )
                  {
                     
                     if([Filemanager fileExistsAtPath:[unterorderurl1 path] isDirectory:&isDir] && isDir)
                     {
                        sammelPfad = [unterorderurl1 path];
                        NSArray* OrdnerArray2 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl1
                                                            includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                 error:&err];
                        //NSLog(@"OrdnerArray2: %@",[OrdnerArray2 description]);
                        for (NSURL* titel in OrdnerArray2)
                        {
                           //[sammlungArray addObject:[[titel path] lastPathComponent]];
                           [sammlungArray addObject:[titel path]];
                        }
                        
                     } // isDir Ordner1
                  
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
      
      }// orderarray0
   }
   else
   {
     
       NSString *question = NSLocalizedString(@"Data for Films", @"Daten für Quelle");
       NSString *info = NSLocalizedString(@"Volume WD_TV not mounted", @"Volume WD_TV ist nicht da.");
       NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title");
       NSString *continueButton = NSLocalizedString(@"Continue", @"Cancel button title");
       NSAlert *alert = [[NSAlert alloc] init];
       [alert setMessageText:question];
       [alert setInformativeText:info];
       [alert addButtonWithTitle:retryButton];
       [alert addButtonWithTitle:continueButton];
       
      
      NSInteger answer = [alert runModal];
      NSLog(@"kein Filmmagazin answer: %d NSAlertAlternateReturn: %d",(int)answer, NSAlertAlternateReturn);
      if (answer == 1000) // 1000, quit
      {
         NSLog(@"kein Filmmagazin NSAlertAlternateReturn, quit  : %d",(int)answer);
         [NSApp terminate:self];
         
      }
      else if(answer == 1001) // 1001,nichts tun
      {
         NSLog(@"kein Filmmagazin NSAlertDefaultReturn, nichts tun : %d",(int)answer);
      }
      
      self.wdtv_ok.enabled = 0;
      self.wdtv_ok.backgroundColor = [NSColor lightGrayColor];

   }
   
   //NSLog(@"sammlungArray: %@",[sammlungArray description]);
   
   return sammlungArray;
}


- (NSArray*)FilmeAnPfad:(NSString*)pfad
{
   NSMutableArray* tempFilmArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSURL* Keller_URL=[NSURL fileURLWithPath:pfad];
   if ([Filemanager fileExistsAtPath:pfad])//ist
   {
      NSLog(@"FilmeAnPfad: Filme sind da an Pfad %@",pfad);
      
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* FilmOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:pfad]
                                              includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                   error:&err];
      NSLog(@"FilmeAnPfad FilmOrdnerArray: %@",FilmOrdnerArray);
      
      BOOL isDir;
      if ([FilmOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in FilmOrdnerArray )
         {
            //NSLog(@"FilmeAnPfad Niveau 1 unterorderfad: %@",unterorderurl0);
            if([Filemanager fileExistsAtPath:[unterorderurl0 path] isDirectory:&isDir] && isDir)
            {
               NSArray* OrdnerArray1 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl0
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&err];
               //NSLog(@"FilmeAnPfad OrdnerArray1: %@",[OrdnerArray1 description]);
               
               if ([OrdnerArray1 count])
               {
                  for (NSURL* unterorderurl1 in OrdnerArray1 )
                  {
                     //NSLog(@"Niveau 2 unterorderfad: %@",[unterorderurl1 path]);
                     if([Filemanager fileExistsAtPath:[unterorderurl1 path] isDirectory:&isDir] )
                     {
                        //NSLog(@"Niveau 2 File da");
                        if (isDir)
                        {
                           
                           NSArray* OrdnerArray2 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl1
                                                               includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&err];
                           //NSLog(@"FilmeAnPfad OrdnerArray2: %@",OrdnerArray2);
                           for (NSURL* titel in OrdnerArray2)
                           {
                              //[sammlungArray addObject:[[titel path] lastPathComponent]];
                              [tempFilmArray addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [tempFilmArray addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"FilmeAnPfad: %@",[tempFilmArray description]);
   }
   else
   {
      NSLog(@"kein Filmordner da an Pfad %@",pfad);
   }
   
   return tempFilmArray;
}

- (NSArray*)FilmMag
{

   NSMutableArray* tempFilmArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSURL* Keller_URL=[NSURL fileURLWithPath:self.Mag_Pfad];
   if ([Filemanager fileExistsAtPath:self.Mag_Pfad])//ist
   {
      self.mag_ok.enabled=1;
      self.mag_ok.backgroundColor = [NSColor greenColor];
      //NSLog(@"Magordner da");
      self.Mag_OK = [NSNumber numberWithBool:YES];
      self.errorfeld.stringValue = [[self.errorfeld stringValue]stringByAppendingFormat:@"\n%@",@"Mag_Ordner da" ];

      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.Mag_Pfad]
                                              includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                   error:&err];
      //NSLog(@"KellerOrdnerArray: %@",KellerOrdnerArray);
      
      BOOL isDir;
      if ([KellerOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in KellerOrdnerArray )
         {
            //NSLog(@"Niveau 1 unterorderfad: %@",unterorderfad);
            if([Filemanager fileExistsAtPath:[unterorderurl0 path] isDirectory:&isDir] && isDir)
            {
               NSArray* OrdnerArray1 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl0
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&err];
               //NSLog(@"OrdnerArray1: %@",[OrdnerArray1 description]);
               
               if ([OrdnerArray1 count])
               {
                  for (NSURL* unterorderurl1 in OrdnerArray1 )
                  {
                     //NSLog(@"Niveau 2 unterorderfad: %@",[unterorderurl1 path]);
                     if([Filemanager fileExistsAtPath:[unterorderurl1 path] isDirectory:&isDir] )
                     {
                        //NSLog(@"Niveau 2 File da");
                        if (isDir)
                        {
                           
                           NSArray* OrdnerArray2 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl1
                                                               includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&err];
                           //NSLog(@"OrdnerArray2: %@",OrdnerArray2);
                           for (NSURL* titel in OrdnerArray2)
                           {
                              //[sammlungArray addObject:[[titel path] lastPathComponent]];
                              [tempFilmArray addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [tempFilmArray addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"tempFilmArray: %@",[tempFilmArray description]);
   }
   else
   {
      
      if ([_Host_Name isEqualToString:@"ruediheimlicher.local"] && [_Host_Name isEqualToString:@"minihome.local"])
      {
         NSString *question = NSLocalizedString(@"Source for Films", @"Daten aus Film-Magazin");
         NSString *info = NSLocalizedString(@"Volume TV_HD is not mounted", @"Volume Mag auf TM ist nicht da.");
         NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title"); // 1000
         NSString *continueButton = NSLocalizedString(@"Continue ", @"Cancel button title"); // 1001
         NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:question];
         [alert setInformativeText:info];
         [alert addButtonWithTitle:retryButton];
         [alert addButtonWithTitle:continueButton];
         
         NSInteger answer = [alert runModal];
         NSLog(@"kein Filmmagazin answer: %d NSAlertAlternateReturn: %d",(int)answer, NSAlertAlternateReturn);
         if (answer == 1000) // 1000, quit
         {
            NSLog(@"kein Filmmagazin NSAlertAlternateReturn, quit  : %d",(int)answer);
            [NSApp terminate:self];
            
         }
         else if(answer == 1001) // 1001,nichts tun
         {
            NSLog(@"kein Filmmagazin NSAlertDefaultReturn, nichts tun : %d",(int)answer);
         }
      }

      
      self.mag_ok.enabled=0;
      self.mag_ok.backgroundColor = [NSColor lightGrayColor];
      self.Mag_OK = [NSNumber numberWithBool:NO];
      NSLog(@"kein Magordner da");
   }

   return tempFilmArray;
   
}


- (NSArray*)FilmArchiv
{
   //NSLog(@"FilmArchiv: %@",self.Filmarchiv_Pfad);
   
   NSMutableArray* FilmarchivOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   //return kellerFilmArray;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   //NSURL* Keller_URL=[NSURL fileURLWithPath:self.Mag_Pfad];
   if ([Filemanager fileExistsAtPath:self.Filmarchiv_Pfad])//ist
   {
      self.filmarchiv_ok.enabled=1;
      self.filmarchiv_ok.backgroundColor = [NSColor greenColor];
      self.errorfeld.stringValue = [[self.errorfeld stringValue]stringByAppendingFormat:@"\n%@",@"Filmarchiv_Ordner da" ];

      //NSLog(@"FilmArchiv da");
      self.Filmarchiv_OK = [NSNumber numberWithBool:YES];
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* FilmarchivOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.Filmarchiv_Pfad]
                                              includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                   error:&err];
      //NSLog(@"KellerOrdnerArray: %@",KellerOrdnerArray);
      
      BOOL isDir;
      if ([FilmarchivOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in FilmarchivOrdnerArray )
         {
            //NSLog(@"Niveau 1 unterorderfad: %@",unterorderfad);
            if([Filemanager fileExistsAtPath:[unterorderurl0 path] isDirectory:&isDir] && isDir)
            {
               NSArray* OrdnerArray1 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl0
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&err];
               //NSLog(@"OrdnerArray1: %@",[OrdnerArray1 description]);
               
               if ([OrdnerArray1 count])
               {
                  for (NSURL* unterorderurl1 in OrdnerArray1 )
                  {
                     //NSLog(@"Niveau 2 unterorderfad: %@",[unterorderurl1 path]);
                     if([Filemanager fileExistsAtPath:[unterorderurl1 path] isDirectory:&isDir] )
                     {
                        //NSLog(@"Niveau 2 File da");
                        if (isDir)
                        {
                           
                           NSArray* OrdnerArray2 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl1
                                                               includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&err];
                           //NSLog(@"OrdnerArray2: %@",OrdnerArray2);
                           for (NSURL* titel in OrdnerArray2)
                           {
                              //[sammlungArray addObject:[[titel path] lastPathComponent]];
                              [FilmarchivOrdner addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [FilmarchivOrdner addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"FilmarchivOrdner: %@",[FilmarchivOrdner description]);
   }
   else
   {
      self.filmarchiv_ok.enabled=0;
      self.filmarchiv_ok.backgroundColor = [NSColor lightGrayColor];
      
      self.Filmarchiv_OK = [NSNumber numberWithBool:NO];
      //self.errorfeld.stringValue =@"Kein FilmArchiv da";
      NSLog(@"kein Filmarchivordner da");
   }
   
   return FilmarchivOrdner;
   
}


- (NSArray*)FilmExtern
{
   //NSLog(@"FilmArchiv: %@",self.extern_Pfad);
   
   NSMutableArray* FilmexternOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   //return kellerFilmArray;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   //NSURL* Keller_URL=[NSURL fileURLWithPath:self.extern_Pfad];
   if ([Filemanager fileExistsAtPath:self.extern_Pfad])//ist
   {
      self.extern_OK = [NSNumber numberWithBool:YES];
      self.errorfeld.stringValue = [[self.errorfeld stringValue]stringByAppendingFormat:@"\n%@",@"Externe HD da" ];
      self.extern_ok.enabled=1;
      self.extern_ok.backgroundColor = [NSColor greenColor];
      //NSLog(@"externe HD da");
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* externOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.extern_Pfad]
                                                  includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       error:&err];
      //NSLog(@"externOrdnerArray: %@",externOrdnerArray);
      
      BOOL isDir;
      if ([externOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in externOrdnerArray )
         {
            //NSLog(@"Niveau 1 unterorderfad: %@",unterorderfad);
            if([Filemanager fileExistsAtPath:[unterorderurl0 path] isDirectory:&isDir] && isDir)
            {
               NSArray* OrdnerArray1 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl0
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&err];
               //NSLog(@"OrdnerArray1: %@",[OrdnerArray1 description]);
               
               if ([OrdnerArray1 count])
               {
                  for (NSURL* unterorderurl1 in OrdnerArray1 )
                  {
                     //NSLog(@"Niveau 2 unterorderfad: %@",[unterorderurl1 path]);
                     if([Filemanager fileExistsAtPath:[unterorderurl1 path] isDirectory:&isDir] )
                     {
                        //NSLog(@"Niveau 2 File da");
                        if (isDir)
                        {
                           NSArray* OrdnerArray2 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl1
                                                               includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    error:&err];
                           //NSLog(@"OrdnerArray2: %@",OrdnerArray2);
                           for (NSURL* titel in OrdnerArray2)
                           {
                              //[sammlungArray addObject:[[titel path] lastPathComponent]];
                              [FilmexternOrdner addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [FilmexternOrdner addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"FilmarchivOrdner: %@",[FilmarchivOrdner description]);
      [self.tvbrowser loadColumnZero];

   }
   else
   {
      if ([_Host_Name isEqualToString:@"ruediheimlicher.home"])
      {
         NSString *question = NSLocalizedString(@"Source for Films", @"Daten für Quelle");
         NSString *info = NSLocalizedString(@"Volume TV_HD is not mounted", @"Volume TV_HD ist nicht da.");
         NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title"); // 1000
         NSString *continueButton = NSLocalizedString(@"Continue ", @"Cancel button title"); // 1001
         NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:question];
         [alert setInformativeText:info];
         [alert addButtonWithTitle:retryButton];
         [alert addButtonWithTitle:continueButton];
         
         NSInteger answer = [alert runModal];
         NSLog(@"keine externe HD answer: %d NSAlertAlternateReturn: %d",(int)answer, NSAlertAlternateReturn);
         if (answer == 1000) // 1000, quit
         {
            NSLog(@"keine externe HD NSAlertAlternateReturn, quit  : %d",(int)answer);
            [NSApp terminate:self];
            
         }
         else if(answer == 1001) // 1001,nichts tun
         {
             NSLog(@"keine externe HD NSAlertDefaultReturn, nichts tun : %d",(int)answer);
         }
      }
      self.extern_ok.enabled=0;
      self.extern_ok.backgroundColor = [NSColor lightGrayColor];
      self.extern_OK = [NSNumber numberWithBool:NO];
      //self.errorfeld.stringValue =@"Kein FilmArchiv da";
      
      NSLog(@"keine externe HD da");
   }
   
   return FilmexternOrdner;
   
}


- (IBAction)reportSuchen:(id)sender;
{
   [filmArray removeAllObjects];
   [filmTable reloadData];
   /*
   NSLog(@"reportSuchen: count: %lu",(unsigned long)[filmArray count]);
   if ([filmTable numberOfRows]==1)
   {
      [filmTable beginUpdates];
   [filmTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0]withAnimation:NSTableViewAnimationSlideUp];
   [filmTable reloadData];
      [filmTable endUpdates];
   }
   else
   {
      [filmArray removeAllObjects];
      [filmTable reloadData];
   }
    
    */
   self.resultatfeld.stringValue =@"suchen ...";
   
   self.opentaste.enabled = NO;
   self.magtaste.enabled = NO;
   self.deletetaste.enabled = NO;
   self.archivtaste.enabled = NO;
   
   
   NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"suchen ...", @"titel",@"",@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
   [filmArray addObject:findDic];
   [filmTable reloadData];
   
   
   NSString* suchstring = [self.suchfeld stringValue];
   //NSLog(@"reportSuchen: %@ WDTV_Pfad: %@",[self.suchfeld stringValue],self.WDTV_Pfad);
   
   //NSLog(@"rootNode: %@",[[rootNode children] description]);
   NSDictionary* childrenDic = [rootNode childrenDic];
   NSArray* childrenKeyArray = [[rootNode childrenDic]allKeys];
   //NSLog(@"childrenKeyArray: %@",childrenKeyArray);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   
   // Externe HD durchsuchen
   NSString* archivVolumePfad = @"/Volumes/TV_HD";
   BOOL archivda = [Filemanager fileExistsAtPath:archivVolumePfad];
   NSLog(@"suchen: extern da: %d",archivda);
   
   if (archivda)
   {
      for (NSString* magpfad in externArray)
      {
         
         if ([magpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"magpfad: %@",magpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[magpfad lastPathComponent],@"titel",magpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:archivda], @"playok", nil];
            [filmArray addObject:findDic];
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,magpfad];
            }
            else
            {
               self.resultatfeld.stringValue = magpfad;
            }
            
            
         }
         
      }

   }
   /*
   //if (archivda)
   {
      // Archiv durchsuchen
      for (NSString* temppfad in archivArray)
      {
         if ([temppfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"temppfad: %@",temppfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[temppfad lastPathComponent],@"titel",temppfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:archivda], @"playok", nil];
            [filmArray addObject:findDic];
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,temppfad];
            }
            else
            {
               self.resultatfeld.stringValue = temppfad;
            }
            
            
         }
         
      }
   } // archifda
   */
   
   
   // Mag auf TM durchsuchen
   NSString* magVolumePfad = @"/Volumes/Mag/Archiv_WDTV";
   BOOL magda = [Filemanager fileExistsAtPath:self.Mag_Pfad];
   NSLog(@"magda: %d",magda);
   //if (magda)
   {
      for (NSString* magpfad in magArray)
      {
         
         if ([magpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"magpfad: %@",magpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[magpfad lastPathComponent],@"titel",magpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:magda], @"playok", nil];
            [filmArray addObject:findDic];
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,magpfad];
            }
            else
            {
               self.resultatfeld.stringValue = magpfad;
            }
            
            
         }
         
      }
   } // kellerda
   
   
   // Filmarchiv auf Film_HD durchsuchen
   //NSString* magVolumePfad = @"/Volumes/Mag/Archiv_WDTV";
   BOOL filmarchivda = [Filemanager fileExistsAtPath:self.Filmarchiv_Pfad];
   NSLog(@"filmarchivda: %d",filmarchivda);
   //NSLog(@"filmarchivArray: %@",filmarchivArray);
   //if (filmarchivda)
   {
      for (NSString* tempfilmpfad in filmarchivArray)
      {
         
         if ([tempfilmpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            //NSLog(@"tempfilmpfad: %@",tempfilmpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[tempfilmpfad lastPathComponent],@"titel",tempfilmpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:filmarchivda], @"playok", nil];
            [filmArray addObject:findDic];
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,tempfilmpfad];
            }
            else
            {
               self.resultatfeld.stringValue = tempfilmpfad;
            }
            
            
         }
         
      }
   } // kellerda
   
  
   
   
   
   // rootnode durchsuchen
   for (NSString* key0 in childrenKeyArray)
   {
      //NSLog(@"\n\n*********************************** key0: %@",key0);
      
      FileSystemNode* node0 = [childrenDic objectForKey:key0];
      //NSLog(@"key0: %@ *** node0: %@",key0,[node0 description]);
      if ([key0 rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
      {
         NSLog(@"Name da in node0: %@",[node0 URL]);
      }
      // Ebene node1 durchsuchen
      // NSLog(@"node0 children: %@",[node0 children]);
      
      NSArray* childrenArray0 = [node0 children];
      NSDictionary* children1Dic = [node0 childrenDic];
      
      //NSLog(@"node0 children1Dic: %@",[children1Dic description]);
      NSArray* childrenKey1Array = [[node0 childrenDic]allKeys];
      //NSLog(@"node0 childrenKey1Array: %@",childrenKey1Array);
      for (NSString* key1 in childrenKey1Array)
      {
         //NSLog(@"\n\n*************** key1: %@",key1);
         FileSystemNode* node1 = [children1Dic objectForKey:key1];
         
         //NSLog(@"key0: %@ ***  key1: %@ *** node1: %@",key0,key1,[node1 description]);
         
         if ([key1 rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            //NSLog(@"Name da in node 1: %@",[node1 URL]);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:key1,@"titel",[node1 URL], @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
            [filmArray addObject:findDic];
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,[[node1 URL] path]];
            }
            else
            {
               self.resultatfeld.stringValue = [[node1 URL] path];
            }
            
         }
         
         
         // Ebene node2 durchsuchen
         NSArray* childrenArray1 = [node1 children];
         NSDictionary* children2Dic = [node1 childrenDic];
         NSArray* childrenKey2Array = [[node1 childrenDic]allKeys];
         for (NSString* key2 in childrenKey2Array)
         {
            
            FileSystemNode* node2 = [children2Dic objectForKey:key2];
            
            
            if ([key2 rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
            {
               NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:key2, @"titel",[[node2 URL]path],@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
               [filmArray addObject:findDic];
               [filmTable reloadData];
               //NSLog(@"Name da in node 2: %@",[node2 URL]);
               if ([self.resultatfeld.stringValue length])
               {
                  self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,[[node2 URL] path]];
               }
               else
               {
                  self.resultatfeld.stringValue = [[node2 URL] path];
               }
               
            }
            
            NSDictionary* children3Dic = [node2 childrenDic];
            NSArray* childrenKey3Array = [[node2 childrenDic]allKeys];
            //NSLog(@"node0 childrenKey3Array: %@",childrenKey3Array);
            
         }
         
         
         
      }
      
      
   }// for tempkey
   
   //NSLog(@"filmArray: : %@",[filmArray description]);
   // FileSystemNode* node1 = [childrenDic objectForKey:@"Tatort"];
   // NSLog(@"node1: %@",[[node1 children] description]);
   // NSDictionary* children1Dic = [node1 childrenDic];
   //NSLog(@"children1Keys: %@",[children1Dic allKeys]);
   
   
   
   if (([[[filmArray objectAtIndex:0]objectForKey:@"url"]length]==0)&& ([filmArray count]==1))
   {
      [filmArray removeAllObjects];
      [filmTable reloadData];
 filmArray = [[NSMutableArray alloc]initWithCapacity:0];
      NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Kein Film gefunden", @"titel",@"",@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:0], @"playok", nil];
      [filmArray addObject:findDic];
      [filmTable reloadData];
      
   }
   else
   {
      [filmArray removeObjectAtIndex:0];
      
   }
   [filmTable reloadData];
   
   return;
   
   
   for (NSURL* pfadURL in wdtvArray)
   {
      NSString* tempPfadstring = [pfadURL path];
      NSRange r = [tempPfadstring rangeOfString:suchstring];
      //NSLog(@"Pfad %@ r: %ld %ld",tempPfadstring, (unsigned long)r.location,(unsigned long)r.length);
      if ([tempPfadstring rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
      {
         //NSLog(@"File da in %@ r: %ld %ld",tempPfadstring, (unsigned long)r.location,(unsigned long)r.length);
         
      }
      
      //NSLog(@"File da");
      
      //NSLog(@"pfadzeile: %@",pfadzeile);
      // NSString* childpfad = pfadzeile;
      //NSURL* WDTV_URL=[NSURL fileURLWithPath:pfadzeile];
      
      NSArray* OrdnerArray= [Filemanager contentsOfDirectoryAtURL:pfadURL
                                       includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:&err];
      BOOL istOrdner=NO;
      //NSLog(@"OrdnerArray: %@ Pfad: %@",[OrdnerArray description],[pfadURL lastPathComponent]);
      for (NSURL* pfadURL in OrdnerArray)
      {
         
         if ([[pfadURL path] rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSRange r=[[pfadURL path] rangeOfString:suchstring options:NSCaseInsensitiveSearch];
            //NSLog(@"File da in %@ r: %ld %ld",pfadURL, (unsigned long)r.location,(unsigned long)r.length);
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,[pfadURL path]];
            }
            else
            {
               self.resultatfeld.stringValue = [pfadURL path];
            }
         }
         
         
         NSArray* SubOrdnerArray= [Filemanager contentsOfDirectoryAtURL:pfadURL
                                             includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                  error:&err];
         for (NSURL* subpfadURL in SubOrdnerArray)
         {
            
            if ([[subpfadURL path] rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
            {
               NSRange r=[[subpfadURL path] rangeOfString:suchstring options:NSCaseInsensitiveSearch];
               //NSLog(@"File da in %@ r: %ld %ld",subpfadURL, (unsigned long)r.location,(unsigned long)r.length);
               if ([self.resultatfeld.stringValue length])
               {
                  self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,[subpfadURL path]];
               }
               else
               {
                  
                  self.resultatfeld.stringValue = [subpfadURL path];
               }
               
            }
            
         }
      }
      
      
      
   }
   
   [filmTable reloadData];
}

- (IBAction)reportOpen:(id)sender
{
    NSFileManager* Filemanager = [NSFileManager defaultManager];
   [[NSWorkspace sharedWorkspace]openFile:filmLink ];
}

- (IBAction)reportOpenExtern:(id)sender
{
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   NSOpenPanel* panel = [NSOpenPanel openPanel];
   [panel setCanChooseDirectories:YES];
   // This method displays the panel and returns immediately.
   // The completion handler is called when the user selects an
   // item or cancels the panel.
   [panel beginWithCompletionHandler:^(NSInteger result)
   {
      if (result == NSFileHandlingPanelOKButton) {
         NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
         
         NSLog(@"theDoc: %@",[theDoc path]);
         // Open  the document.
      }
      
   }];

   //[[NSWorkspace sharedWorkspace]openFile:filmLink ];
}

- (IBAction)reportBrowserPlay:(id)sender
{
  // long selektierteZeile = [filmTable selectedRow];
   //NSLog(@"reportBrowserPlay: selektierteZeile: %ld",selektierteZeile);
   
   NSString* selektierterPfad = [filmURL path];
   //NSLog(@"reportPlay selektierterPfad: %@", selektierterPfad);
   
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   [[NSWorkspace sharedWorkspace]openFile:selektierterPfad ];
}



- (IBAction)reportPlay:(id)sender
{
   long selektierteZeile = [filmTable selectedRow];
   NSLog(@"reportPlay: selektierteZeile: %ld",selektierteZeile);
   NSString* selektierterPfad = [[filmArray objectAtIndex:selektierteZeile ]objectForKey:@"url"];
   //NSLog(@"reportPlay selektierterPfad: %@", selektierterPfad);

   NSFileManager* Filemanager = [NSFileManager defaultManager];
   [[NSWorkspace sharedWorkspace]openFile:selektierterPfad ];
}


- (IBAction)reportBrowserMag:(id)sender
{
   //NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   //NSLog(@"reportMag Selected Cell: %@", [selektierteZelle stringValue]);
   NSLog(@"reportBrowserMag filmLink: %@",filmLink);
   // Bsp: /Volumes/WD_TV/Tatort/2014/140506 Tatort - Bienzle und der Taximord.mp4

   // erste 2 Teile loeschen
   NSString* moveLink = [[filmLink stringByDeletingLastPathComponent]stringByDeletingLastPathComponent];
   NSLog(@"reportBrowserMag moveLink A: %@",moveLink);

   // Bsp: /Tatort/Mag/140506 Tatort - Bienzle und der Taximord.mp4
   
   //NSString* magLink = moveLink;
   
   //[[NSWorkspace sharedWorkspace]openFile:moveLink ];
   
  // NSLog(@"reportBrowserMag filmarchiv_ok: %d",[self.filmarchiv_ok isEnabled]);
   NSArray*filmlinkArray = [filmLink componentsSeparatedByString:@"/"];
   if ([[filmlinkArray objectAtIndex:0]isEqualToString:@""])
       {
          filmlinkArray = [filmlinkArray subarrayWithRange:NSMakeRange(1, [filmlinkArray  count]-1)];
       }
   NSLog(@"reportBrowserMag filmlinkArray: %@",filmlinkArray);
   /*
    Volumes,
    "WD_TV",
    Tatort,
    2014,
    "140804 Tatort - 597-912, Minenspiel.mp4"
    */
   moveLink = [moveLink stringByAppendingPathComponent:@"Mag"];
   if ([self.filmarchiv_ok isEnabled])
   {
      
      //moveLink = [NSString stringWithFormat:@"%@/Archiv_%@/%@",self.Filmarchiv_Pfad,[filmlinkArray objectAtIndex:2],[filmlinkArray objectAtIndex:4]];
   }
   else if ([self.mag_ok  isEnabled])
   {
      
   }
   else
   {
      //moveLink = [moveLink stringByAppendingPathComponent:@"Mag"];
   }
   
   NSLog(@"reportBrowserMag moveLink C: %@",moveLink);
   
   moveLink = [moveLink stringByAppendingPathComponent:[filmLink lastPathComponent]];
   NSLog(@"reportBrowserMag moveLink D: %@",moveLink);

   
   NSError* err=NULL;
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   //NSLog(@"OrdnerArray vor: %@",[self.WDTV_Array description]);
   //   [self.tvbrowser loadColumnZero];
   
   int erfolg = [Filemanager moveItemAtPath:filmLink toPath:moveLink error:&err];
 //int erfolg = [Filemanager copyItemAtURL:[NSURL fileURLWithPath:filmLink isDirectory:NO] toURL:[NSURL fileURLWithPath:moveLink  isDirectory:NO] error:&err];
   //NSLog(@"mag erfolg: %d err: %@",erfolg, [err description]);
   //NSLog(@"matrix: %@",[[self.tvbrowser matrixInColumn:2]description]);
   if (erfolg==0)
   {
      NSAlert *theAlert = [NSAlert alertWithError:err];
      [theAlert runModal]; // Ignore return value.
   }
   else
   {
      NSLog(@"mag erfolg: %d",erfolg);
   }
   
   [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser clickedColumn]]invalidateChildren];
   [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];
   
   [self.tvbrowser loadColumnZero];
   self.linkfeld.stringValue = @"";
   
}

- (IBAction)reportMag:(id)sender
{
   NSString*    moveLink = [[[filmLink stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Mag"];

   NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   //NSLog(@"reportMag Selected Cell: %@", [selektierteZelle stringValue]);

   if (self.filmarchiv_ok.integerValue)
   {
      
      moveLink = [[[filmLink stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Mag"];
   }
   else if (self.mag_ok.integerValue)
   {
      
   }
   else
   {
   
   }
   //NSString* magLink = moveLink;
   moveLink = [moveLink stringByAppendingPathComponent:[filmLink lastPathComponent]];
   NSLog(@"reportMag moveLink: %@",moveLink);
   //[[NSWorkspace sharedWorkspace]openFile:moveLink ];
   return;
   
   NSError* err=NULL;
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   //NSLog(@"OrdnerArray vor: %@",[self.WDTV_Array description]);
//   [self.tvbrowser loadColumnZero];
   int erfolg=0;
   erfolg = [Filemanager moveItemAtPath:filmLink toPath:moveLink error:&err];
   //NSLog(@"mag erfolg: %d err: %@",erfolg, [err description]);
   //NSLog(@"matrix: %@",[[self.tvbrowser matrixInColumn:2]description]);
   if (erfolg==0)
   {
      NSAlert *theAlert = [NSAlert alertWithError:err];
      [theAlert runModal]; // Ignore return value.
   }
   
   [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser clickedColumn]]invalidateChildren];
   [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];

   [self.tvbrowser loadColumnZero];
   self.linkfeld.stringValue = @"";
   
}

- (IBAction)reportMagVonTable:(id)sender
{
   long selektierteZeile = [filmTable selectedRow];
   NSLog(@"reportDeleteVonTable: selektierteZeile: %ld",selektierteZeile);
   NSString* selektierterPfad = [[filmArray objectAtIndex:selektierteZeile ]objectForKey:@"url"];
   
   //NSLog(@"reportMagVonTable selektierterPfad: *%@*", selektierterPfad);
   
   NSString* moveLink = [[[selektierterPfad stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Mag"];
   
   moveLink = [moveLink stringByAppendingPathComponent:[selektierterPfad lastPathComponent]];
   NSLog(@"moveLink: %@",moveLink);
   //[[NSWorkspace sharedWorkspace]openFile:moveLink ];
   
   
   NSError* err=NULL;
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   //NSLog(@"OrdnerArray vor: %@",[self.WDTV_Array description]);
   //   [self.tvbrowser loadColumnZero];
   
   
   int erfolg = [Filemanager moveItemAtPath:selektierterPfad toPath:moveLink error:&err];
   //NSLog(@"mag erfolg: %d err: %@",erfolg, [err description]);
   //NSLog(@"matrix: %@",[[self.tvbrowser matrixInColumn:2]description]);
   if (erfolg)
   {
      [filmArray removeObjectAtIndex:selektierteZeile];
      [filmTable reloadData];
      
      [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser lastColumn]]invalidateChildren];
      [self.tvbrowser loadColumnZero];
   }
      else
   {
      NSAlert *theAlert = [NSAlert alertWithError:err];
      [theAlert runModal]; // Ignore return value.
   }
   
    self.linkfeld.stringValue = @"";
   
}


- (IBAction)reportDelete:(id)sender
{
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   NSError* err=NULL;
   
   NSLog(@"delete err: %@",[err description]);
   NSLog(@"reportDelete OK");
   NSAlert *alert = [[NSAlert alloc] init];
   [alert addButtonWithTitle:@"OK"];
   [alert addButtonWithTitle:@"Cancel"];
   [alert setMessageText:@"Delete Film?"];
   [alert setInformativeText:@"Deleted films cannot be restored."];
   [alert setAlertStyle:NSWarningAlertStyle];
   if ([alert runModal] == NSAlertFirstButtonReturn)
   {
      // OK clicked, delete the record
      NSLog(@"filmLink: %@",filmLink   );
      
      [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser clickedColumn]]invalidateChildren];
      [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];
      [self.tvbrowser loadColumnZero];
      self.linkfeld.stringValue = @"";
      int erfolg = [Filemanager removeItemAtPath:filmLink error:&err];
      if (erfolg)
      {
         NSString* WDTV_String = @"WD_TV/";
         NSString* TM_String = @"Archiv_WDTV/";
         NSString* Archiv_String = @"Filmarchiv/";
         
         if (([filmLink rangeOfString:WDTV_String].length))
         {
            wdtvArray = (NSMutableArray*)[self Film_WDTV];
         }
         else if(([filmLink rangeOfString:TM_String].length)) // TM erneuern
         {
            magArray =(NSMutableArray*)[self FilmMag];
         }
         else if(([filmLink rangeOfString:Archiv_String].length)) //
         {
            filmarchivArray =(NSMutableArray*)[self FilmArchiv];
         }
         
      }
      
      
      else
      {
         NSAlert *theAlert = [NSAlert alertWithError:err];
         [theAlert runModal]; // Ignore return value.
         
      }
   }
}

- (IBAction)reportDeleteVonTable:(id)sender
{
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   NSError* err=NULL;
   long selektierteZeile = [filmTable selectedRow];
   //NSLog(@"reportDeleteVonTable: selektierteZeile: %ld",selektierteZeile);
   NSString* selektierterPfad = [[filmArray objectAtIndex:selektierteZeile ]objectForKey:@"url"];
   
   //NSLog(@"reportDEleteVonTable selektierterPfad: %@", selektierterPfad);
   
   //if (erfolg)
   
   //NSLog(@"reportDeleteVonTable OK");
   NSAlert *alert = [[NSAlert alloc] init];
   [alert addButtonWithTitle:@"OK"];
   [alert addButtonWithTitle:@"Cancel"];
   [alert setMessageText:@"Delete Film?"];
   [alert setInformativeText:@"Deleted films cannot be restored."];
   [alert setAlertStyle:NSWarningAlertStyle];
   if ([alert runModal] == NSAlertFirstButtonReturn)
   {
      // OK clicked, delete the record
      int erfolg = [Filemanager removeItemAtPath:selektierterPfad error:&err];
      if (erfolg)
      {
         //NSLog(@"selektierterPfad: %@",selektierterPfad   );
         //NSLog(@"delete erfolg: %d  err: %@",erfolg,[err description]);
         
         [filmArray removeObjectAtIndex:selektierteZeile];
         [filmTable reloadData];
         [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser lastColumn]]invalidateChildren];
         [self.tvbrowser loadColumnZero];
         
         NSString* WDTV_String = @"WD_TV/";
         NSString* TM_String = @"Archiv_WDTV/";
         NSString* Archiv_String = @"Filmarchiv/";
         
         if (([selektierterPfad rangeOfString:WDTV_String].length))
         {
            wdtvArray = (NSMutableArray*)[self Film_WDTV];
         }
         else if(([selektierterPfad rangeOfString:TM_String].length)) // TM erneuern
         {
            magArray =(NSMutableArray*)[self FilmMag];
         }
         else if(([selektierterPfad rangeOfString:Archiv_String].length)) //
         {
            filmarchivArray =(NSMutableArray*)[self FilmArchiv];
         }
         
      }
      else
      {
         NSAlert *theAlert = [NSAlert alertWithError:err];
         [theAlert runModal]; // Ignore return value.
         
      }
   }
}


- (IBAction)reportArchivieren:(id)sender
{
   NSLog(@"reportArchivieren return");
   
   NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   NSLog(@"reportArchivieren Selected Cell: %@", [selektierteZelle stringValue]);
   NSLog(@"filmLink: %@",filmLink);

   NSMutableArray* filmOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
   [openPanel setCanChooseFiles:NO];
   [openPanel setCanChooseDirectories:YES];
   
   [openPanel setPrompt:@"Archiv"];
   
   [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
      if (result == NSFileHandlingPanelOKButton)
      {
         NSLog(@"OK");
         NSURL *fileURL = [openPanel URL]; //OpenDlg is my NSOpenPanel
         NSLog(@"filePath raw: %@", [fileURL path]);
         
         NSString* destLink = [[fileURL path]stringByAppendingPathComponent:[filmLink lastPathComponent]];
         NSLog(@"destLink : %@", destLink);

         NSError* err;
         NSFileManager* Filemanager = [NSFileManager defaultManager];

         int erfolg = [Filemanager moveItemAtPath:filmLink toPath:destLink error:&err];
         //NSLog(@"mag erfolg: %d err: %@",erfolg, [err description]);
         if (erfolg==0)
         {
            NSAlert *theAlert = [NSAlert alertWithError:err];
            [theAlert runModal]; // Ignore return value.
         
         
         
         [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser clickedColumn]]invalidateChildren];
         [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];

         [self.tvbrowser loadColumnZero];
         self.linkfeld.stringValue = @"";
         }
 
         
      }
   }];//
}




- (IBAction)reportMagazinAktualisieren:(id)sender // Daten auf externer HD
{
   NSLog(@"reportMagazinAktualisieren");
   NSMutableArray* filmOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
   [openPanel setCanChooseFiles:NO];
   [openPanel setCanChooseDirectories:YES];
   
   [openPanel setPrompt:@"Aktualisieren"];
   
   [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
   {
      if (result == NSFileHandlingPanelOKButton)
      {
         NSLog(@"OK");
         NSURL *fileURL = [openPanel URL]; //OpenDlg is my NSOpenPanel
         NSLog(@"filePath: %@", [fileURL path]);
         NSError* err;
         NSFileManager* Filemanager = [NSFileManager defaultManager];
         NSArray *contentsAtPath = [Filemanager contentsOfDirectoryAtURL:fileURL
                                              includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                   error:&err];
         
         
         //NSArray *contentsAtPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[fileURL path] error:NULL];
         
         if (contentsAtPath)
         {	// We don't deal with the error
            NSMutableArray* archivOrdner = [[NSMutableArray alloc]initWithCapacity:0];
            for (NSURL *fileURL in contentsAtPath)
            {
               
               BOOL isDir;
               if([Filemanager fileExistsAtPath:[fileURL path] isDirectory:&isDir] && isDir)
               {
                  //NSLog(@"Is directory: %@",[fileURL path]);
                  if ([[fileURL path] rangeOfString:@"archiv" options:NSCaseInsensitiveSearch].length)
                  {
                     [archivOrdner addObject:[fileURL path]];
                     
                  }
                  
               }
            }
            NSLog(@"archivOrdner: %@",archivOrdner);
            
            if ([archivOrdner count])
            {
               for (NSString* archivName in archivOrdner)
               {
                  NSLog(@"archivName: %@",archivName);
                  NSURL* tempurl =[NSURL fileURLWithPath:archivName];
                  NSArray *filmsAtPath = [Filemanager contentsOfDirectoryAtURL:tempurl
                                                    includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                         error:&err];
                  NSLog(@"filmsAtPath: %@",filmsAtPath);
                  for (NSURL* film in filmsAtPath)
                  {
                     [filmOrdner addObject:[film path]];
                  }
                  
               }
            }
         }
      }
      else
      {
         //[openPanel close];
      }
      
      // Muss im Block von Sheet erledigt werden
      // Check Mag auf HD
      
      /*
       magArray = (NSMutableArray*)[self FilmMag]; // in reportKellerAktualisieren verschoben
       if ([magArray count])
       {
       for (NSString* tempFilm in magArray)
       {
       [filmOrdner addObject:tempFilm];
       }
       
       }
       */
      
      if ([filmOrdner count])
      {
         NSLog(@"filmOrdner: %@",filmOrdner);
         NSString* ArchivPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"WDTVDaten/Mag_WDTV.txt"];
         int erfolg = [filmOrdner writeToFile:ArchivPfad atomically:YES];
         NSLog(@"ArchivPfad: %@ erfolg: %d",ArchivPfad,erfolg );
      }
      
      
      
      NSLog(@"filmOrdner nach archiv: %@",filmOrdner);
      
   }]; // Sheet
   
   NSLog(@"filmOrdner nach archiv: %@",filmOrdner);
   // Check Mag auf HD
   
 }

- (IBAction)reportKellerAktualisieren:(id)sender // Daten auf TM
{
   NSLog(@"reportKellerAktualisieren");
   NSMutableArray* filmOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   
   magArray = (NSMutableArray*)[self FilmMag]; // in reportKellerAktualisieren verschoben
   if ([magArray count])
   {
      for (NSString* tempFilm in magArray)
      {
         [filmOrdner addObject:tempFilm];
      }
      
   }

   if ([filmOrdner count])
   {
      NSLog(@"Keller filmOrdner: %@",filmOrdner);
      NSString* KellerPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"WDTVDaten/Keller_WDTV.txt"];
      int erfolg = [filmOrdner writeToFile:KellerPfad atomically:YES];
      NSLog(@"KellerPfad: %@ erfolg: %d",KellerPfad,erfolg );
   }
   
   
   
   NSLog(@"filmOrdner nach keller: %@",filmOrdner);

}


- (IBAction)reportExterneHDAktualisieren:(id)sender // Daten auf HD_TV
{
   NSLog(@"reportExterneHDAktualisieren");
   NSMutableArray* filmOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   
   externArray = (NSMutableArray*)[self FilmMag]; // in reportKellerAktualisieren verschoben
   if ([magArray count])
   {
      for (NSString* tempFilm in magArray)
      {
         [filmOrdner addObject:tempFilm];
      }
      
   }
   
   if ([filmOrdner count])
   {
      NSLog(@"Keller filmOrdner: %@",filmOrdner);
      NSString* KellerPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"WDTVDaten/Keller_WDTV.txt"];
      int erfolg = [filmOrdner writeToFile:KellerPfad atomically:YES];
      NSLog(@"KellerPfad: %@ erfolg: %d",KellerPfad,erfolg );
   }
   
   
   
   NSLog(@"filmOrdner nach keller: %@",filmOrdner);
   
}

- (NSString*)Filmtitelsauber:(NSString*)titel
{
   NSError *error = NULL;
   NSRegularExpression *zifferregex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSRegularExpression *grupperegex = [NSRegularExpression regularExpressionWithPattern:@"Tatort"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSRegularExpression *divregex = [NSRegularExpression regularExpressionWithPattern:@"-"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
   
   NSRegularExpression *blankregex = [NSRegularExpression regularExpressionWithPattern:@"^[ \t]+"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

   NSString* zifferregexstring  = [zifferregex stringByReplacingMatchesInString:titel
                                                                        options:0
                                                                          range:NSMakeRange(0, [titel length])
                                                                   withTemplate:@""];
   //NSLog(@"zifferregexstring: %@",zifferregexstring);
   
   
   zifferregexstring = [zifferregexstring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   /*
    while ([zifferregexstring rangeOfString:@","].location != NSNotFound) {
    zifferregexstring = [zifferregexstring stringByReplacingOccurrencesOfString:@"," withString:@""];
    zifferregexstring = [zifferregexstring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    */
   /*
    NSCharacterSet *KommaSet = [NSCharacterSet characterSetWithCharactersInString:@","] ;
    //NSLog(@"zifferregexstring: %@ %c",zifferregexstring,[zifferregexstring characterAtIndex:0]);
    if ([KommaSet characterIsMember:[zifferregexstring characterAtIndex:0]])
    {
    NSLog(@"komma");
    zifferregexstring = [zifferregexstring substringFromIndex:1];
    }
    */
   NSString* grupperegexstring  = [grupperegex stringByReplacingMatchesInString:zifferregexstring
                                                                        options:0
                                                                          range:NSMakeRange(0, [zifferregexstring length])
                                                                   withTemplate:@""];
   //NSLog(@"grupperegexstring: %@",grupperegexstring);
   
   NSString* divregexstring  = [divregex stringByReplacingMatchesInString:grupperegexstring
                                                                  options:0
                                                                    range:NSMakeRange(0, [grupperegexstring length])
                                                             withTemplate:@""];
   
   while ([divregexstring characterAtIndex:0]==' ')
   {
      divregexstring = [divregexstring substringFromIndex:1];
   }
   if ([divregexstring characterAtIndex:0]==',')
   {
      divregexstring = [divregexstring substringFromIndex:1];
   }
   while ([divregexstring characterAtIndex:0]==' ')
   {
      divregexstring = [divregexstring substringFromIndex:1];
   }
   
   
   NSString* blankregexstring  = [blankregex stringByReplacingMatchesInString:divregexstring
                                                                      options:0
                                                                        range:NSMakeRange(0, [divregexstring length])
                                                                 withTemplate:@""];
   
   
   return blankregexstring;
}

- (IBAction)reportDouble:(id)sender
{
   //NSLog(@"reportDouble");
  // [archivArray setArray:[self FilmArchiv]];
   //[magArray setArray:[self FilmMag]];
   //NSLog(@"reportDouble archivArray: %@ ",archivArray);
   self.suchfeld.stringValue = @"";
   [filmArray removeAllObjects];
   [filmTable reloadData];
   
   
   // check, ob einer der Filme in  den Mag schon vorhanden ist.
   
   
   
   NSMutableArray* doppelOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* titelArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* titelDicArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSError *error = NULL;
   NSRegularExpression *zifferregex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSRegularExpression *grupperegex = [NSRegularExpression regularExpressionWithPattern:@"Tatort"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSRegularExpression *divregex = [NSRegularExpression regularExpressionWithPattern:@"-"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSRegularExpression *blankregex = [NSRegularExpression regularExpressionWithPattern:@"^[ \t]+"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

   // Filme auf Volumes ausserhalb WDTVLIVE suchen
   
   // Filme auf externer HD
   for (NSString* archivfilm in externArray) // Inhalt der Files auf der externen HD
   {
         //NSLog(@"archivfilm: %@",[archivfilm lastPathComponent]);
         NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
         
   }
   
   // Filme auf TM/Mag
   //NSLog(@"TM/Mag");
   for (NSString* tempfilm in magArray) // Inhalt des Files Keller_WDTV.txt auf Dokumente/WDTVDaten
   {
      //NSLog(@"tempfilm: %@",[tempfilm lastPathComponent]);
      NSString* suchFilmtitel = [[tempfilm lastPathComponent]stringByDeletingPathExtension];
     //NSLog(@"suchFilmtitel: %@",suchFilmtitel);
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      //NSLog(@"blankregexstring: %@",blankregexstring);
      
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",tempfilm,@"path", nil]];
      
   }

   // Filme auf Filmarchiv
   //NSLog(@"Filmarchiv");
   for (NSString* tempfilm in filmarchivArray) // Inhalt des Files Keller_WDTV.txt auf Dokumente/WDTVDaten
   {
      //NSLog(@"tempfilm: %@",[tempfilm lastPathComponent]);
      NSString* suchFilmtitel = [[tempfilm lastPathComponent]stringByDeletingPathExtension];
      //NSLog(@"suchFilmtitel: %@",suchFilmtitel);
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      //NSLog(@"blankregexstring: %@",blankregexstring);
      
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",tempfilm,@"path", nil]];
      
   }

   
   //NSLog(@"reportDouble titelArray aus Mag: %@ ",titelArray);
   //NSLog(@"reportDouble titelDicArray aus WDTV.txt: %@ ",[titelDicArray valueForKey:@"titel"]);
   
   for (NSString* tempfilm in wdtvArray) // Filme auf WDTV
   {
      {
         //NSLog(@"wdtv tempfilm: %@",tempfilm );
         //NSLog(@"tempfilm: %@",[tempfilm lastPathComponent]);
         NSString* suchFilmtitel = [[tempfilm lastPathComponent]stringByDeletingPathExtension];
         NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
         
         
         int zeile=0;
         unsigned long b=[blankregexstring length];
         
         
         for (NSDictionary* tempzeilenDic in  titelDicArray) // Filme ausserhalb WDTV
         {
            
            NSString* zeilentitel = [tempzeilenDic objectForKey:@"titel"];
            if (([zeilentitel rangeOfString:blankregexstring].length) && (b==[zeilentitel length]))
            {
               //NSLog(@"tempzeilenDic: %@",tempzeilenDic );
               NSString* tempzeilenpfad = [tempzeilenDic objectForKey:@"path"];
               //NSLog(@"tempzeilenpfad: %@",tempzeilenpfad );
               unsigned long z=[zeilentitel length];
              // NSLog(@"b: %d z: %d",b,z);
               
               [doppelOrdner addObject:[tempzeilenDic objectForKey:@"titel"]];
               
               NSString* tempPfad = [tempzeilenDic objectForKey:@"path"];
               NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",tempfilm, @"path", tempzeilenpfad,@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
              //
               NSMutableDictionary* wdtvDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",tempfilm, @"path", tempfilm,@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];

               
               [filmArray addObject:wdtvDic];
               
               [filmArray addObject:doppelDic];
               
               
               //NSLog(@"zeile: %d \ntitel: %@ \npath: %@ \nurl: %@",zeile,[tempzeilenDic objectForKey:@"titel"],tempPfad,tempfilm);

            }
            zeile++;
         }

         
      }//bis
   }
   
   /*
   for (NSString* archivfilm in filmarchivArray) // Inhalt des Files Mag_WDTV.txt auf Dokumente/WDTVDaten
   {
      //NSLog(@"archivfilm: %@",[archivfilm lastPathComponent]);
      NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
      // NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      
      
      NSString* zifferregexstring  = [zifferregex stringByReplacingMatchesInString:suchFilmtitel
                                                                           options:0
                                                                             range:NSMakeRange(0, [suchFilmtitel length])
                                                                      withTemplate:@""];
      
      
      NSString* grupperegexstring  = [grupperegex stringByReplacingMatchesInString:zifferregexstring
                                                                           options:0
                                                                             range:NSMakeRange(0, [zifferregexstring length])
                                                                      withTemplate:@""];
      
      
      
      NSString* blankregexstring  = [blankregex stringByReplacingMatchesInString:grupperegexstring
                                                                         options:0
                                                                           range:NSMakeRange(0, [grupperegexstring length])
                                                                    withTemplate:@""];
      
    
      
      //NSLog(@"suchFilmtitel: %@ regexstring: %@ grupperegexstring: *%@* blankregexstring: *%@*",suchFilmtitel,regexstring,grupperegexstring, blankregexstring);
      
      [titelArray addObject:blankregexstring];
      
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
      
   }
    */
   
   //[magArray setArray:[self FilmMag]];
   
   /*
   for (NSString* archivfilm in magArray) // Filme auf TM
   {
      {
         //NSLog(@"archivfilm: %@",[archivfilm lastPathComponent]);
         NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
         NSString* zifferregexstring  = [zifferregex stringByReplacingMatchesInString:suchFilmtitel
                                                                              options:0
                                                                                range:NSMakeRange(0, [suchFilmtitel length])
                                                                         withTemplate:@""];
         
         NSString* grupperegexstring  = [grupperegex stringByReplacingMatchesInString:zifferregexstring
                                                                              options:0
                                                                                range:NSMakeRange(0, [zifferregexstring length])
                                                                         withTemplate:@""];
         
         NSString* blankregexstring  = [blankregex stringByReplacingMatchesInString:grupperegexstring
                                                                            options:0
                                                                              range:NSMakeRange(0, [grupperegexstring length])
                                                                       withTemplate:@""];
      */   
         /*
         long archivindex = [[titelDicArray valueForKey:@"titel"]indexOfObject:blankregexstring];
         if (archivindex < NSNotFound)
         {
            NSString* tempPfad = [[titelDicArray objectAtIndex:archivindex]objectForKey:@"path"];
            NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm, @"url", tempPfad,@"path",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
            [filmArray addObject:doppelDic];
            NSLog(@"archivindex: %ld path: %@ url: %@",archivindex,tempPfad,archivfilm);
         
         }
         */
      /*
         
         if ([titelArray containsObject:blankregexstring])
         {
            [doppelOrdner addObject:archivfilm];
            NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
            [filmArray addObject:doppelDic];
            
         }
      }//bis
   }
   */

   //NSLog(@"reportDouble doppelOrdner: %@ ",doppelOrdner);
   if ([doppelOrdner count]==0)
   {
      NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Keine doppelten Filme gefunden",@"titel",@"", @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:0], @"playok", nil];
      [filmArray addObject:doppelDic];

   }
   [filmTable reloadData];
  // NSLog(@"reportDouble doppelOrdner: %@ ",doppelOrdner);
}

- (id)rootItemForBrowser:(NSBrowser *)browser
{
   if (rootNode == nil)
   {
      rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:self.rootNodePath]];
      
      //rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:@"/Volumes/WD_TV"]];
      //rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:@"/Volumes/TV_HD"]];

   }
   return rootNode;
}


- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
   
   FileSystemNode *node = (FileSystemNode *)item;
   //NSLog(@"numberOfChildrenOfItem: %ld",node.children.count);
   self.linkfeld.stringValue = @"";
   return node.children.count;
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item
{
   FileSystemNode *node = (FileSystemNode *)item;
   return [node.children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item
{
   FileSystemNode *node = (FileSystemNode *)item;
   return !node.isDirectory;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item
{
   
   FileSystemNode *node = (FileSystemNode *)item;
   //NSLog(@"objectValueForItem: %@",node.displayName);
   
    NSRange r = [node.displayName rangeOfString:@"couldn’t" options:NSCaseInsensitiveSearch];
   
   //if ([node.displayName rangeOfString:@"couldn’t" options:NSCaseInsensitiveSearch].location)
   //if (r.length && r.length < NSNotFound)
   {
      //NSLog(@"objectValueForItem kill loc: %ld",r.length);
      //return NULL;
   }
   
   return node.displayName;
}

/*
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell
          atRow:(NSInteger)row column:(NSInteger)column
{
   //NSLog(@"willDisplayCell row: %ld col: %ld",row,column );
}
*/

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "RH.WDTV" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"RH.WDTV"];
}



// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WDTV" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"WDTV.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (long)numberOfRowsInTableView:(NSTableView *)tableView
{
   //NSLog(@"numberOfRowsInTableView: %ld",(unsigned long)[filmArray count]);
   return [filmArray count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(long)row
{
   
   if ([[tableColumn identifier] isEqual: @"play"])
   {
      //NSLog(@"row: %ld playok : %@",row,[[filmArray objectAtIndex:row]objectForKey:@"playok"]);
      
      int playok = [[[filmArray objectAtIndex:row]objectForKey:@"playok"]intValue];
      
      
      [[tableColumn dataCellForRow:row]setEnabled:playok];
   }

   return [[filmArray objectAtIndex:row]objectForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
   
   if ([[tableColumn identifier] isEqual: @"mark"])
   {
      NSMutableDictionary* markdic = (NSMutableDictionary* )[filmArray objectAtIndex:row];
      BOOL mark = [[markdic objectForKey:@"mark"]boolValue];
      [markdic setObject:[NSNumber numberWithBool:!mark]forKey:@"mark"];
      
      //[[filmArray objectAtIndex:row]setObject:[NSNumber numberWithInt:1]forKey:@"mark"];
   }
   if ([[tableColumn identifier] isEqual: @"play"])
   {
      int playok = [[[filmArray objectAtIndex:row]objectForKey:@"playok"]intValue];
      [[tableColumn dataCellForRow:row]setEnabled:playok];
      //NSLog(@"playok: %d",playok);
      //NSMutableDictionary* playdic = (NSMutableDictionary* )[filmArray objectAtIndex:row];
      if (playok)
      {
      NSString* playPfad = [[filmArray objectAtIndex:row]objectForKey:@"url"];
         
      NSLog(@"playPfad: %@",playPfad);
      }
      else
      {
         NSString* playPfad = [NSString string];
      
      }
   }
}

- (void)tableViewSelectionDidChange:(NSNotification *)note
{
   //NSLog(@"tableViewSelectionDidChange %d",[[note object]selectedRow]);
   {
      [[note object]selectedRow];
      self.linkfeld.stringValue = @"";
   }
   // [[note object] scrollRowToVisible:[[note object]selectedRow]];
}

- (void)controlTextDidChange:(NSNotification *)notification {
   NSTextField *textField = [notification object];
   //NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
   self.suchentaste.enabled = [[textField stringValue]length];
    [[self window] setDefaultButtonCell:[self.suchentaste cell]];
}

/*
- (NSIndexSet *)browser:(NSBrowser *)browser selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes inColumn:(NSInteger)column

{
   NSLog(@"selectionIndexesForProposedSelection");
}
*/
- (void) FensterSchliessenAktion:(NSNotification*)note
{
   //NSLog(@"FensterSchliessenAktion");
   [NSApp terminate:self];
}


@end
