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
   //NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"WD_TV_A\") then\nbeep\nelse\nmount volume \"smb://WDTVLIVE._smb._tcp.local/WD_TV_A\"\nend if\nend tell\n"];

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
  // NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"Mag\") then\nbeep\nelse\nmount volume \"smb://WDTVLIVE._smb._tcp.local/WD_TV_A\"\nend if\nend tell\n"];
   
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
   
   NSLog(@"Selected Item: %@ l: %ld", [indexPath description],(unsigned long)[indexPath length] );
   NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   //NSLog(@"Selected Cell: %@", [selektierteZelle stringValue]);
   
   unsigned long l=[indexPath length];
   unsigned long index = [indexPath indexAtPosition:l-1];// letzter Index
   filmLink = [[[self.tvbrowser itemAtRow: index inColumn:l-1]URL]path] ; //
   filmURL = [[self.tvbrowser itemAtRow: index inColumn:l-1]URL];
    NSLog(@"filmLink: %@  length: %d index: %lu l: %lu",filmLink, [filmLink length],index, l);
   if ([filmLink length])
   {
      NSLog(@"filmLink: length ok");
      self.linkfeld.stringValue = filmLink;
      self.opentaste.enabled = YES;
      //if (l==3)
      {
         NSLog(@"filmLink: l ok");
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
   NSLog(@"browserClick col: %ld  row %ld ",col, zeile );
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

-(NSString *) randomStringWithLength: (int) len
{
   
   NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

   NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
   
   for (int i=0; i<len; i++) {
      [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
   }
   
   return randomString;
}

-(NSURLRequest *)postRequestWithURL: (NSString *)url

                               data: (NSData *)data
                           fileName: (NSString*)fileName
{
   
   // from http://www.cocoadev.com/index.pl?HTTPFileUpload
   
   //NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
   
   NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
   [urlRequest setURL:[NSURL URLWithString:url]];
   //[urlRequest setURL:url];
   
   [urlRequest setHTTPMethod:@"POST"];
   
   NSString *myboundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
   NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",myboundary];
   [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
   
   
   //[urlRequest addValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
   
   NSMutableData *postData = [NSMutableData data]; //[NSMutableData dataWithCapacity:[data length] + 512];
   [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
   [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName]dataUsingEncoding:NSUTF8StringEncoding]];
   [postData appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
   [postData appendData:[NSData dataWithData:data]];
   [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
   
   [urlRequest setHTTPBody:postData];
   return urlRequest;
}

- (IBAction)reportAnmelden:(id)sender
{
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   
   {
      
      
      NSMutableString* ComputerName=[NSMutableString stringWithString:@"rosmarieegli"];
      //NSLog(@"ComputerName: %@",ComputerName);
      NSTextView* neuerHostName;
      [neuerHostName setString:ComputerName];
      //NSLog(@"neuerHostName: %@",neuerHostName);
      [ComputerName replaceOccurrencesOfString:@"." withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [ComputerName length])];
      [ComputerName replaceOccurrencesOfString:@" " withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [ComputerName length])];
      NSArray* MV=[[NSWorkspace sharedWorkspace]mountedLocalVolumePaths];
      NSInteger AnzUser=[MV count];
      //NSLog(@"MV: %@  Anzahl: %d",[MV description], AnzUser);
      BOOL istOK=NO;
      NSString* afpString=@"afp://";
      NSString* ComputerNameString=[[afpString stringByAppendingString:ComputerName]stringByAppendingString:@".local"];
      //NSString* ComputerNameString=[afpString stringByAppendingString:ComputerName];
      //NSLog(@"ComputerNameString: %@",[ComputerNameString description]);
      
      //istOK=[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"afp://g4"]];
      //istOK=[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"afp://g4/ruediheimlicher/Dokumente/Lesebox/Archiv"]];
      NSURL* ComputerURL=[NSURL URLWithString:ComputerNameString];
      NSURLRequest* ComputerRequest = [NSURLRequest requestWithURL:ComputerURL];
      NSData* ComputerData = [NSMutableData data];
      NSURLConnection *ComputerConnection;
      ComputerConnection=[NSURLConnection connectionWithRequest:ComputerRequest
                                                       delegate:self];
      //[ComputerConnection retain];
      istOK=[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:ComputerNameString]];
      if (istOK)
      {
         [neuerHostName setString:ComputerName];
         
         NSString* neuerUserDocumentsPfad=[NSString stringWithFormat:@"/Volumes/%@/Documents",ComputerName];
         NSLog(@"ComputerNameString: %@",[neuerUserDocumentsPfad description]);
         NSNumber* LoginOK=[NSNumber numberWithBool:YES];
       }
      else
         NSLog(@"openURL: nichts");
      //NSLog(@"reportAnmelden: neuerHostName: %@",neuerHostName);
   }
   
   
}
- (NSError*)writeTitelListe:(NSString*)titelliste toPath:(NSString*) pfad
{
   if ([[titelliste componentsSeparatedByString:@"\n"]count])
   {
      //NSLog(@"titelliste count:%lu",[[titelliste componentsSeparatedByString:@"\n"]count] );
  //    NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/FilmListen",@"/Film_HD_Liste.txt"];
      
      NSURL* titellisteURL = [NSURL fileURLWithPath:pfad];
      NSLog(@"titellisteURL: %@",titellisteURL );
      
      NSError *listerror = nil;
      NSInteger success = [titelliste writeToURL:titellisteURL
                            atomically:YES
                              encoding:NSUTF8StringEncoding
                                 error:&listerror];
      
      NSString *liststatus = success ? @"Success" : @"Failure";
      if(success)
      {
         NSLog(@"Done Writing: %@",liststatus);
      }
      else
      {
         NSLog(@"Done Writing: %@",liststatus);
         NSLog(@"Error: %@",[listerror localizedDescription]);
      }
      return listerror;
   }
   return nil;

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   NSArray * keys = [NSArray arrayWithObjects:NSURLVolumeURLForRemountingKey, nil];
   NSArray * mountPaths = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:keys options:0];
   
   NSError * error;
   NSURL * remount;
   NSLog(@"mountPaths: %@",mountPaths);
   
   for (NSURL * mountPath in mountPaths) {
      [mountPath getResourceValue:&remount forKey:NSURLVolumeURLForRemountingKey error:&error];
      NSLog(@"mountPath: %@ remount: %@",mountPath,remount);
  /*
   if(remount){
         if ([[[NSURL URLWithString:share] host] isEqualToString:[remount host]] && [[[NSURL URLWithString:share] path] isEqualToString:[remount path]]) {
            printf("Already mounted at %s\n", [[mountPath path] UTF8String]);
            return 0;
         }
   */
      }
   
   
   int wert=300;
   int drittel = (((uint32_t)wert * (uint32_t)0xAAAB) >> 16) >> 1;
   NSLog(@"wert: %d drittel: %d",wert, drittel);
   
   
   int zehntel = (((uint32_t)wert * (uint32_t)0xCCCD) >> 16) >> 3;
   NSLog(@"wert: %d zehntel: %d",wert, zehntel);
   
   int ergebnis = (((uint32_t)(wert*10) * (uint32_t)0xAAAB) >> 16) >> 1;
    NSLog(@"wert: %d ergebnis: %d",wert, ergebnis);
   
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
   

   Missed_HD_Array = [[NSMutableArray alloc]initWithCapacity:0]; // DataSource  von TableView FilmTable

   
   filmArray = [[NSMutableArray alloc]initWithCapacity:0]; // DataSource  von TableView FilmTable
   wdtvArray = [[NSMutableArray alloc]initWithCapacity:0]; // files auf HD an WDTVLive
   magArray = [[NSMutableArray alloc]initWithCapacity:0]; // files auf Mag an TM
   TV_HD_A_Array = [[NSMutableArray alloc]initWithCapacity:0]; // Files auf externer HD an mini, sofern da
   Filmarchiv_Array = [[NSMutableArray alloc]initWithCapacity:0]; // Files auf Film_HD an mini
   WD_TV_B_Array = [[NSMutableArray alloc]initWithCapacity:0]; // Files auf  WD_TV_B an mini
   
   Volumes_Array = [[NSMutableArray alloc]initWithCapacity:0]; // Sichtbare Volumes

   
   
   
   
   [self.tvbrowser setTarget:self];
   [self.tvbrowser setColumnResizingType:NSBrowserUserColumnResizing];
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
   
   self.rootNodePath = @"/Volumes/WD_TV_B";
   //self.rootNodePath = @"/Volumes/WDTV";
   
   if ([_Host_Name isEqualToString:@"ruediheimlicher.local"])
   {
      NSLog(@"ruediheimlicher.local");
      self.Filmarchiv_Pfad = @"/Volumes/Film_HD/Filmarchiv";
      self.WD_TV_A_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV_A"];
      self.WD_TV_B_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV_B"];
      self.TV_HD_A_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD_A"];
      self.TV_HD_B_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD_B"];
   }
   else if ([_Host_Name isEqualToString:@"minihome.local"])
   {
      NSLog(@"mini.local");
      self.Filmarchiv_Pfad = @"/Volumes/Film_HD/Filmarchiv";
      self.WD_TV_A_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV_A"];
      self.WD_TV_B_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV_B"];
      self.TV_HD_A_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD_A"];
      self.TV_HD_B_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD_B"];
   }
   else if ([_Host_Name isEqualToString:@"ruediheimlicher.home"]) // auswaerts mit MBP
   {
      NSLog(@"ruediheimlicher.home");
      self.Filmarchiv_Pfad = @"/Volumes/Film_HD/Filmarchiv";
      self.WD_TV_A_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV_A"];
      self.WD_TV_B_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV_B"];
      self.TV_HD_A_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD_A"];
      self.TV_HD_B_Pfad = [NSString stringWithFormat:@"/Volumes/TV_HD_B"];
  
   }

   else
   {
      self.Filmarchiv_Pfad=nil;
   }
   
   self.FilmListe_Pfad = [NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/FilmListen"];
    [self RefreshFilmlisten];

   
   
   NSLog(@"Volumes_Array: %@",Volumes_Array);
   [self.volumepop removeAllItems];
   [self.volumepop addItemsWithTitles:[Volumes_Array valueForKey:@"volume"]];
   //[self.volumepop selectItemAtIndex:[Volumes_Array count]-1];
   // *************************************************
   // upload liste
   // Quelle: http://www.geronimobile.com/sending-image-from-xcode-to-server/
   //NSString *urlString = @"http://www.ruediheimlicher.ch/cgi-bin/wdtvlist.pl";
   NSString *urlString = @"http://www.ruediheimlicher.ch/Data";
  
   NSString * theString=@"e88d";
   NSData * listData=[theString dataUsingEncoding:NSUTF8StringEncoding];
   
   //NSLog(@"urlString: %@",urlString);
   
   //NSLog(@"listData: %@",listData);
   
   NSURLRequest *urlRequest = [self postRequestWithURL:urlString
                                                  data:listData
                                              fileName:@"hallo"];
   
   NSURLConnection* uploadConnection =[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
  

   // *************************************************
 
   NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
   [nc addObserver:self
			 selector:@selector(FensterSchliessenAktion:)
				  name:@"NSWindowWillCloseNotification"
				object:nil];

   [self.warteschlaufe stopAnimation:NULL];
   [self.warteschlaufe setHidden:YES];
   
   
   NSArray* oldkellerstring = [self KellerListe];
}





- (void)RefreshFilmlisten
{
   
   //NSLog(@"app rootnode: %@",self.rootNodePath);
   // *************************************************
   // Daten auf WDTVLIVE lesen
   // *************************************************
   
   //  mountVolumeAppleScript(@"ruediheimlicher",@"rh47",@"WDTVLIVE",@"WDTV");
   
   self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"Refresh" ];
   
   self.WDTV_Pfad = [NSString stringWithFormat:@"/Volumes/WDTV"];
   NSLog(@"WDTV_Pfad: %@",self.WDTV_Pfad);
   
   //NSLog(@"home: %@",NSHomeDirectory());
   //NSURL* WDTV_URL=[NSURL fileURLWithPath:self.WDTV_Pfad];
   
   wdtvArray = (NSMutableArray*)[self Film_WDTV];
   //NSLog(@"wdtvArray: %@",wdtvArray );
   //NSString* wdtv_ort = self.WDTV_Pfad.lastPathComponent;
   //NSLog(@"wdtv_ort: %@ count: %d",wdtv_ort ,wdtvArray.count);
   
   //NSString* wdtvListe = [self titelListeAusArray:wdtvArray];
   
   //NSLog(@"wdtvListe: %@",wdtvListe );
   
   //NSLog(@"***");
   
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
   
   NSString* ListePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/wdtvliste.txt"];
   
   NSURL* ListeURL = [NSURL fileURLWithPath:ListePfad];
   
   //NSLog(@"ListeURL: %@",ListeURL );
   
   
   // *************************************************
   // Film-Daten auf der TM lesen: File auf TM/Mag
   // *************************************************
   
   // mountKellerAppleScript(@"ruediheimlicher",@"rh47",@"TC_Basis",@"Mag");
   
   self.Mag_Pfad = [NSString stringWithFormat:@"/Volumes/Mag/Archiv_WDTV"];
   NSLog(@"Mag_Pfad: %@",self.Mag_Pfad);
   
   magArray = (NSMutableArray*)[self FilmMag];
   
   NSString* magListe = [self titelListeAusArray:magArray];
   
   //NSLog(@"magListe: %@",magListe );
   if ([[magListe componentsSeparatedByString:@"\n"]count])
   {
      //NSLog(@"magListe count:%lu",[[magListe componentsSeparatedByString:@"\n"]count] );
      NSString* magPfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/magliste.txt"];
      
      //NSURL* magURL = [NSURL fileURLWithPath:magPfad];
      //NSLog(@"magURL: %@",magURL );
      
   }
   
   
   // *************************************************
   // Filmarchiv lesen
   // *************************************************
   
   Filmarchiv_Array =(NSMutableArray*)[self FilmArchiv];
   
   if ([Filmarchiv_Array count])
   {
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"Filmarchiv auf Film_HD da"];
      //NSLog(@"filmarchivArray: %@",filmarchivArray);
      NSString* titelliste = [self titelListeAusArray:Filmarchiv_Array];
      
      //NSLog(@"Filmarchiv titelliste: \n%@",titelliste );
      if ([[titelliste componentsSeparatedByString:@"\n"]count])
      {
         //NSLog(@"titelliste count:%lu",[[titelliste componentsSeparatedByString:@"\n"]count] );
         NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/Film_HD_Liste.txt"];
         
         NSURL* titellisteURL = [NSURL fileURLWithPath:titellistePfad];
         //NSLog(@"titellisteURL: %@",titellisteURL );
      }
      
      
   }
   //   mountKellerAppleScript(@"ruediheimlicher",@"rh47",@"TV_HD_A",@"Tatort");
   
   // *************************************************
   // TV_HD_A lesen
   // *************************************************
   
   NSLog(@"TV_HD_A_Pfad: %@",self.TV_HD_A_Pfad);
   
   TV_HD_A_Array = (NSMutableArray*)[self Film_TV_HD_A];
   
   //NSLog(@"TV_HD_A_Array: %@",TV_HD_A_Array);
   if ([TV_HD_A_Array count])
   {
      //NSLog(@"TV_HD_A_Array: %@",TV_HD_A_Array);
      //NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/TV_HD_A_Liste.txt"];
      //NSString* titelliste = [self titelListeAusArray:TV_HD_A_Array];
      
      //      NSError* suc = [self writeTitelListe:titelliste toPath:titellistePfad];
      //      NSLog(@"TV_HD_A suc: %@",suc);
   }
   else
   {
      //NSLog(@"TV_HD_A : keine TitelListe");
   }
   
   // *************************************************
   // TV_HD_B lesen
   // *************************************************
   
   NSLog(@"TV_HD_B_Pfad: %@",self.TV_HD_B_Pfad);
   
   TV_HD_B_Array = (NSMutableArray*)[self Film_TV_HD_B];
   
   //NSLog(@"TV_HD_B_Array: %@",TV_HD_B_Array);
   
   // *************************************************
   // WD_TV_A lesen
   // *************************************************
   //NSLog(@"lesen WD_TV_A_Pfad: %@",self.WD_TV_A_Pfad);
   
   WD_TV_A_Array = (NSMutableArray*)[self Film_WD_TV_A];
   
   //NSLog(@"WD_TV_A_Array: %@",WD_TV_A_Array);
   if ([WD_TV_A_Array count])
   {
      //NSLog(@"WD_TV_B_Array: %@",WD_TV_B_Array);
      NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/WD_TV_A_Liste.txt"];
      NSString* titelliste = [self titelListeAusArray:WD_TV_B_Array];
      
      NSError* suc = [self writeTitelListe:titelliste toPath:titellistePfad];
      NSLog(@"WD_TV_A suc: %@",suc);
   }
   else
   {
      //NSLog(@"WD_TV_A : keine TitelListe");
   }
   
   // *************************************************
   // WD_TV_B lesen
   // *************************************************
   
   
   NSLog(@"WD_TV_B_Pfad: %@",self.WD_TV_B_Pfad);
   
   WD_TV_B_Array = (NSMutableArray*)[self Film_WD_TV_B];
   if ([WD_TV_B_Array count])
   {
      NSLog(@"WD_TV_B_Array: %@",WD_TV_B_Array);
     // NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/WD_TV_B_Liste.txt"];
      NSString* titellistePfad=[self.FilmListe_Pfad stringByAppendingPathComponent:@"/WD_TV_B_Liste.txt"];
      
      NSString* titelliste = [self titelListeAusArray:WD_TV_B_Array];
      
      NSError* suc = [self writeTitelListe:titelliste toPath:titellistePfad];
      NSLog(@"WD_TV_B suc: %@",suc);
   }
   else
   {
      NSLog(@"WD_TV_B : keine TitelListe");
   }
   
   
   //NSLog(@"Volumes_Array: %@",Volumes_Array);
   [self.volumepop removeAllItems];
   [self.volumepop addItemsWithTitles:[Volumes_Array valueForKey:@"volume"]];
   //[self.volumepop selectItemAtIndex:4];
   // *************************************************
   // upload liste
   // Quelle: http://www.geronimobile.com/sending-image-from-xcode-to-server/
   //NSString *urlString = @"http://www.ruediheimlicher.ch/cgi-bin/wdtvlist.pl";
   NSString *urlString = @"http://www.ruediheimlicher.ch/Data";
   
   NSString * theString=@"e88d";
   NSData * listData=[theString dataUsingEncoding:NSUTF8StringEncoding];
   
   //NSLog(@"urlString: %@",urlString);
   
   //NSLog(@"listData: %@",listData);
   
   NSURLRequest *urlRequest = [self postRequestWithURL:urlString
                                                  data:listData
                                              fileName:@"hallo"];
   
   NSURLConnection* uploadConnection =[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
   
   
   // *************************************************
   
   NSNotificationCenter * nc;
   nc=[NSNotificationCenter defaultCenter];
   [nc addObserver:self
          selector:@selector(FensterSchliessenAktion:)
              name:@"NSWindowWillCloseNotification"
            object:nil];
   
   [self.warteschlaufe stopAnimation:NULL];
   [self.warteschlaufe setHidden:YES];
   
   
   //NSArray* oldkellerstring = [self KellerListe];
}

- (IBAction)reportRefreshFilmlisten:(id)sender
{
   [self RefreshFilmlisten];
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
   //NSLog(@"  ++  start titelListe");
   NSMutableArray* ListeArray = [[NSMutableArray alloc]initWithCapacity:0];
   for (int i=0;i<derFilmArray.count;i++)
   {
      //NSString* tempFilmTitel = [[derFilmArray objectAtIndex:i]stringByDeletingLastPathComponent];
      NSString* tempFilm = [derFilmArray objectAtIndex:i]; // WD_TV_A		Volumes	WD_TV_A	Tatort	Mag	Tatort 130323 Summ, Summ, Summ.mpg
     //NSString* tempFilmTitel = [[[filmArray objectAtIndex:i] stringByReplacingOccurrencesOfString:self.WDTV_Pfad withString:@""]substringFromIndex:1];// erstes tab weg
      
      //NSLog(@"tempFilmTitel: %@",tempFilm );
      NSArray* tempElementeArray = [tempFilm componentsSeparatedByString:@"/"]; // Am anfang steht ein /
      
      //NSLog(@"tempFilmTitel: %@ anz: %d",tempFilm,[tempElementeArray count] );
      
      switch (tempElementeArray.count)
      {
         case 6: // alles vorhanden
         {
            NSString* tempZeilenString = [[tempElementeArray subarrayWithRange:NSMakeRange(3, 3)]componentsJoinedByString:@"\t"];
            //NSLog(@"6 El : %@",[tempElementeArray lastObject]);
            NSMutableDictionary* tempZeilenDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [tempElementeArray objectAtIndex:2],@"ort",
                                                  [tempElementeArray objectAtIndex:3],@"art",
                                                  [tempElementeArray objectAtIndex:4],@"sub",
                                                  tempZeilenString,@"titelstring",
                                                  [tempElementeArray objectAtIndex:5],@"titel", nil];
            
            NSString* titelteil = [[tempElementeArray objectAtIndex:5]stringByDeletingPathExtension];
            NSString* titelnummer =0;
            //NSLog(@"Titel raw: %@",[[tempElementeArray objectAtIndex:5]stringByDeletingPathExtension]);
            
            [ListeArray addObject:tempZeilenDic];
            
         }break;
            
         case 5:// ohne Jahrzahl
         {
            NSString* tempZeilenString = [[tempElementeArray subarrayWithRange:NSMakeRange(2, 3)]componentsJoinedByString:@"\t"];
            //NSLog(@"tempElementeArray: %@ tempZeilenString: %@", tempElementeArray, tempZeilenString);
            //NSLog(@"5 El : %@",[tempElementeArray lastObject]);
            NSMutableDictionary* tempZeilenDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [tempElementeArray objectAtIndex:1],@"ort",
                                                  [tempElementeArray objectAtIndex:2],@"art",
                                                  [tempElementeArray objectAtIndex:3],@"sub",
                                                  tempZeilenString,@"titelstring",
                                                  [tempElementeArray objectAtIndex:4],@"titel", nil];
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
   //NSLog(@"  ++  end titelListe");

   return Liste;
}




- (NSArray*)Film_WDTV
{
   // Alle Filme auf WDTV
   NSMutableArray* sammlungArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSString* sammelPfad = self.WDTV_Pfad;
   if ([Filemanager fileExistsAtPath:sammelPfad])//ist da
   {
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.WDTV_Pfad , @"path",@"WDTV",@"volume", nil]];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"WDTV da" ];
      
      self.WDTV_OK_Feld.enabled = 1;
      self.WDTV_OK_Feld.backgroundColor = [NSColor greenColor];
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
       NSString *info = NSLocalizedString(@"Volume WD_TV_A not mounted", @"Volume WD_TV_A ist nicht da.");
       NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title");
       NSString *continueButton = NSLocalizedString(@"Continue", @"Cancel button title");
       NSAlert *alert = [[NSAlert alloc] init];
       [alert setMessageText:question];
       [alert setInformativeText:info];
       [alert addButtonWithTitle:retryButton];
       [alert addButtonWithTitle:continueButton];
      
      
      NSInteger answer = 0;
      //answer = [alert runModal];
      //NSLog(@"kein WD_TV_A answer: %d NSAlertAlternateReturn: %d",(int)answer, NSAlertAlternateReturn);
      if (answer == 1000) // 1000, quit
      {
         NSLog(@"kein WD_TV_A NSAlertAlternateReturn, quit  : %d",(int)answer);
         [NSApp terminate:self];
         
      }
      else if(answer == 1001) // 1001,nichts tun
      {
         NSLog(@"kein WD_TV_A NSAlertDefaultReturn, nichts tun : %d",(int)answer);
      }
      
      
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"WDTV nicht da" ];

      self.WDTV_OK_Feld.enabled = 0;
      self.WDTV_OK_Feld.backgroundColor = [NSColor lightGrayColor];

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
   //NSLog(@"Mag_Pfad: %@",self.Mag_Pfad);
   NSMutableArray* tempFilmArray = [[NSMutableArray alloc]initWithCapacity:0];
   
   
   //return tempFilmArray;
   
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSURL* Keller_URL=[NSURL fileURLWithPath:self.Mag_Pfad];
   if ([Filemanager fileExistsAtPath:self.Mag_Pfad])//ist
   {
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Mag_Pfad , @"path",@"Filmmagazin auf mag",@"volume", nil]];

      self.mag_ok.enabled=1;
      self.mag_ok.backgroundColor = [NSColor greenColor];
      //NSLog(@"Magordner da");
      self.Mag_OK = [NSNumber numberWithBool:YES];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"Archiv_WDTV auf TC_Basis da" ];

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
         NSString *info = NSLocalizedString(@"Volume TV_HD_A is not mounted", @"Volume Mag auf TM ist nicht da.");
         NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title"); // 1000
         NSString *continueButton = NSLocalizedString(@"Continue ", @"Cancel button title"); // 1001
         NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:question];
         [alert setInformativeText:info];
         [alert addButtonWithTitle:retryButton];
         [alert addButtonWithTitle:continueButton];
         
         NSInteger answer = 0;
 //       answer = [alert runModal];
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
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"Archiv_WDTV auf TC_Basis nicht da" ];

      NSLog(@"Archiv_WDTV auf TC_Basis nicht da");
   }

   return tempFilmArray;
   
}



- (NSArray*)FilmArchiv
{
   NSLog(@"FilmArchiv Pfad: %@",self.Filmarchiv_Pfad);
   
   NSMutableArray* FilmarchivOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   
   //return FilmarchivOrdner;
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   if ([Filemanager fileExistsAtPath:self.Filmarchiv_Pfad])//ist
   {
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.Filmarchiv_Pfad , @"path",@"Filmarchiv auf Film-HD",@"volume", nil]];
      self.filmarchiv_ok.enabled=1;
      self.filmarchiv_ok.backgroundColor = [NSColor greenColor];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"Filmarchiv auf Film_HD da" ];

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
      
      BOOL isDir;
      if ([FilmarchivOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in FilmarchivOrdnerArray )
         {
            NSLog(@"Niveau 1 unterorderfad: %@",unterorderurl0);
            if([Filemanager fileExistsAtPath:[unterorderurl0 path] isDirectory:&isDir] && isDir)
            {
               NSArray* OrdnerArray1 =  [Filemanager contentsOfDirectoryAtURL:unterorderurl0
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&err];
               NSLog(@"OrdnerArray1: %@ error: %@",[OrdnerArray1 description],err);
               
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
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"Filmarchiv auf Film_HD nicht da" ];
      NSLog(@"Filmarchiv auf Film_HD nicht da");
   }
   
   return FilmarchivOrdner;
   
}


- (NSArray*)Film_TV_HD_A
{
   NSLog(@"TV_HD_A Pfad: %@",self.TV_HD_A_Pfad);
   
   NSMutableArray* Film_TV_HD_A_Ordner = [[NSMutableArray alloc]initWithCapacity:0];
   //return kellerFilmArray;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   //NSURL* Keller_URL=[NSURL fileURLWithPath:self.TV_HD_A_Pfad];
   if ([Filemanager fileExistsAtPath:self.TV_HD_A_Pfad])//ist
   {
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.TV_HD_A_Pfad , @"path",@"TV_HD_A",@"volume", nil]];
      self.TV_HD_A_OK = [NSNumber numberWithBool:YES];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"TV_HD_A da" ];
      self.TV_HD_A_OK_Feld.enabled=1;
      self.TV_HD_A_OK_Feld.backgroundColor = [NSColor greenColor];
      //NSLog(@"TV_HD_A da");
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* TV_HD_A_OrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.TV_HD_A_Pfad]
                                                includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     error:&err];
      //NSLog(@"TV_HD_A_OrdnerArray: %@",TV_HD_A_OrdnerArray);
      
      BOOL isDir;
      if ([TV_HD_A_OrdnerArray count])
      {
         for (NSURL* unterorderurl0 in TV_HD_A_OrdnerArray )
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
                              [Film_TV_HD_A_Ordner addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [Film_TV_HD_A_Ordner addObject:[unterorderurl1 path]];
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
         NSString *info = NSLocalizedString(@"Volume TV_HD_A is not mounted", @"Volume TV_HD_A ist nicht da.");
         NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title"); // 1000
         NSString *continueButton = NSLocalizedString(@"Continue ", @"Cancel button title"); // 1001
         NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:question];
         [alert setInformativeText:info];
         [alert addButtonWithTitle:retryButton];
         [alert addButtonWithTitle:continueButton];
         NSInteger answer = 0;
         //      answer = [alert runModal];
         //      NSLog(@"keine TV_HD_A answer: %d NSAlertAlternateReturn: %d",(int)answer, NSAlertAlternateReturn);
         if (answer == 1000) // 1000, quit
         {
            NSLog(@"keine TV_HD_A NSAlertAlternateReturn, quit  : %d",(int)answer);
            [NSApp terminate:self];
            
         }
         else if(answer == 1001) // 1001,nichts tun
         {
            NSLog(@"keine TV_HD_A NSAlertDefaultReturn, nichts tun : %d",(int)answer);
         }
      }
      self.TV_HD_A_OK_Feld.enabled=0;
      self.TV_HD_A_OK_Feld.backgroundColor = [NSColor lightGrayColor];
      self.TV_HD_A_OK = [NSNumber numberWithBool:NO];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"TV_HD_A nicht da" ];
      
      NSLog(@"TV_HD_A nicht da");
   }
   
   return Film_TV_HD_A_Ordner;
   
}
- (NSArray*)Film_TV_HD_B
{
   NSLog(@"TV_HD_B Pfad: %@",self.TV_HD_B_Pfad);
   
   NSMutableArray* Film_TV_HD_BOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   //return kellerFilmArray;
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   //NSURL* Keller_URL=[NSURL fileURLWithPath:self.TV_HD_B_Pfad];
   if ([Filemanager fileExistsAtPath:self.TV_HD_B_Pfad])//ist
   {
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.TV_HD_B_Pfad , @"path",@"TV_HD_B",@"volume", nil]];
      self.TV_HD_B_OK = [NSNumber numberWithBool:YES];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"TV_HD_B da" ];
      self.TV_HD_B_OK_Feld.enabled=1;
      self.TV_HD_B_OK_Feld.backgroundColor = [NSColor greenColor];
      NSLog(@"TV_HD_B da");
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* TV_HD_B_OrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.TV_HD_B_Pfad]
                                                  includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       error:&err];
      //NSLog(@"TV_HD_B_OrdnerArray: %@",TV_HD_B_OrdnerArray);
      
      BOOL isDir;
      if ([TV_HD_B_OrdnerArray count])
      {
         for (NSURL* unterorderurl0 in TV_HD_B_OrdnerArray )
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
                              [Film_TV_HD_BOrdner addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [Film_TV_HD_BOrdner addObject:[unterorderurl1 path]];
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
         NSString *info = NSLocalizedString(@"Volume TV_HD_B is not mounted", @"Volume TV_HD_B ist nicht da.");
         NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title"); // 1000
         NSString *continueButton = NSLocalizedString(@"Continue ", @"Cancel button title"); // 1001
         NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:question];
         [alert setInformativeText:info];
         [alert addButtonWithTitle:retryButton];
         [alert addButtonWithTitle:continueButton];
         NSInteger answer = 0;
   //      answer = [alert runModal];
   //      NSLog(@"keine TV_HD_B answer: %d NSAlertAlternateReturn: %d",(int)answer, NSAlertAlternateReturn);
         if (answer == 1000) // 1000, quit
         {
            NSLog(@"keine TV_HD_B NSAlertAlternateReturn, quit  : %d",(int)answer);
            [NSApp terminate:self];
            
         }
         else if(answer == 1001) // 1001,nichts tun
         {
             NSLog(@"keine TV_HD_B NSAlertDefaultReturn, nichts tun : %d",(int)answer);
         }
      }
      self.TV_HD_B_OK_Feld.enabled=0;
      self.TV_HD_B_OK_Feld.backgroundColor = [NSColor lightGrayColor];
      self.TV_HD_B_OK = [NSNumber numberWithBool:NO];
      //self.errorfeld.stringValue =@"Kein FilmArchiv da";
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"TV_HD_B nicht da" ];

      NSLog(@"TV_HD_B nicht da");
   }
   
   return Film_TV_HD_BOrdner;
   
}

- (NSArray*)Film_WD_TV_A
{
   NSLog(@"WD_TV_A_Pfad: %@",self.WD_TV_A_Pfad);
   
   NSMutableArray* Film_wdtvOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   
   
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   if ([Filemanager fileExistsAtPath:self.WD_TV_A_Pfad])//ist
   {
      NSLog(@"WD_TV_A da");
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.WD_TV_A_Pfad , @"path",@"WD_TV_A",@"volume", nil]];
      self.WD_TV_A_OK_Feld.enabled=1;
      self.WD_TV_A_OK_Feld.backgroundColor = [NSColor greenColor];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"WD_TV_A da" ];
      //NSLog(@"wdtv da");
      self.WD_TV_A_OK = [NSNumber numberWithBool:YES];
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* wdtvOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.WD_TV_A_Pfad]
                                             includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                  error:&err];
      //NSLog(@"wdtvOrdnerArray: %@",wdtvOrdnerArray);
      
      BOOL isDir;
      if ([wdtvOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in wdtvOrdnerArray )
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
                              [Film_wdtvOrdner addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [Film_wdtvOrdner addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"Film_wdtvOrdner: %@",[Film_wdtvOrdner description]);
   }
   else
   {
      self.WD_TV_A_OK_Feld.enabled=0;
      self.WD_TV_A_OK_Feld.backgroundColor = [NSColor lightGrayColor];
      
      self.WD_TV_A_OK = [NSNumber numberWithBool:NO];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"WD_TV_A nicht da" ];
      NSLog(@"WD_TV_A nicht da");
   }
   
   return Film_wdtvOrdner;
   
}

- (NSArray*)Film_WD_TV_B
{
   //NSLog(@"WD_TV_B_Pfad: %@",self.WD_TV_B_Pfad);
   
   NSMutableArray* Film_wdtvOrdner = [[NSMutableArray alloc]initWithCapacity:0];
   
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   //NSURL* Keller_URL=[NSURL fileURLWithPath:self.Mag_Pfad];
   if ([Filemanager fileExistsAtPath:self.WD_TV_B_Pfad])//ist
   {
      [Volumes_Array addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.WD_TV_B_Pfad , @"path",@"WD_TV_B",@"volume", nil]];
      self.WD_TV_B_OK_Feld.enabled=1;
      self.WD_TV_B_OK_Feld.backgroundColor = [NSColor greenColor];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"WD_TV_B da" ];
      
      //NSLog(@"wdtv da");
      self.WD_TV_B_OK = [NSNumber numberWithBool:YES];
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Mag_Pfad error:&err];
      NSArray* wdtvOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.WD_TV_B_Pfad]
                                                  includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       error:&err];
      //NSLog(@"wdtvOrdnerArray: %@",wdtvOrdnerArray);
      
      BOOL isDir;
      if ([wdtvOrdnerArray count])
      {
         for (NSURL* unterorderurl0 in wdtvOrdnerArray )
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
                              [Film_wdtvOrdner addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [Film_wdtvOrdner addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"Film_wdtvOrdner: %@",[Film_wdtvOrdner description]);
   }
   else
   {
      self.WD_TV_B_OK_Feld.enabled=0;
      self.WD_TV_B_OK_Feld.backgroundColor = [NSColor lightGrayColor];
      
      self.WD_TV_B_OK = [NSNumber numberWithBool:NO];
      self.errorfeld.string = [[self.errorfeld string]stringByAppendingFormat:@"%@\n",@"WD_TV_B nicht da" ];
      NSLog(@"WD_TV_B nicht da");
   }
   
   return Film_wdtvOrdner;
   
}

- (NSError*)writeArray:(NSArray*)filmarray   inFile:(NSString*)listname
{
   NSError* listerror=0;
   NSString* Filmordnerpfad = [NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten",@"/FilmListen/"];

   if (filmarray.count)
   {
      NSString* titelliste = [self titelListeAusArray:filmarray];
      NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@%@",@"/Documents",@"/WDTVDaten",@"/FilmListen/",listname];
      NSLog(@"writeArray titellistePfad: %@",titellistePfad);
      NSError* suc = [self writeTitelListe:titelliste toPath:titellistePfad];
      NSLog(@"HD von %@ suc: %@",listname,suc);

   }// count
   return listerror;
}

- (NSArray*)readListeAnPfad:(NSString*)listpfad
{
   NSArray* filelistArray = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:listpfad]];
   if (filelistArray.count)
   {
      for ( NSString* listzeile in filelistArray)
      {
         //NSLog(@"listzeile: %@",listzeile);
         fprintf(stderr, "%s\n",[listzeile UTF8String]);
         
      }
   }
   
   NSMutableArray* dicArray = [[NSMutableArray alloc]initWithCapacity:0];
   
   return dicArray;
}


- (IBAction)reportListe:(id)sender
{
   if ([Filmarchiv_Array count])
   {
      [self writeArray:Filmarchiv_Array inFile:@"Filmarchiv_Liste.txt"];
   }
   else
   {
      NSLog(@"kein Filmarchiv_Array");
   }

   if ([WD_TV_A_Array count])
   {
      [self writeArray:WD_TV_A_Array inFile:@"WD_TV_A_Liste.txt"];
      /*
      //NSLog(@"WD_TV_B_Array: %@",WD_TV_B_Array);
      NSString* titellistePfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@%@",@"/Documents",@"/WDTVDaten/FilmListen/",@"/WD_TV_B_Liste.txt"];
      NSString* titelliste = [self titelListeAusArray:WD_TV_B_Array];
      
      NSError* suc = [self writeTitelListe:titelliste toPath:titellistePfad];
      NSLog(@"WD_TV_B suc: %@",suc);
       */
   }
   else
   {
      NSLog(@"kein WD_TV_A_Array");
   }
   
   if ([WD_TV_B_Array count])
   {
      [self writeArray:WD_TV_B_Array inFile:@"WD_TV_B_Liste.txt"];
   }
   else
   {
      NSLog(@"kein WD_TV_B_Array");
   }
   return;
   
   
   if ([TV_HD_A_Array count])
   {
      [self writeArray:TV_HD_A_Array inFile:@"TV_HD_A_Liste.txt"];
   }
   else
   {
      NSLog(@"kein TV_HD_A_Array");
   }

   if ([TV_HD_B_Array count])
   {
      [self writeArray:TV_HD_B_Array inFile:@"TV_HD_B_Liste.txt"];
   }
   else
   {
      NSLog(@"kein TV_HD_B_Array");
   }


}

- (BOOL)suchenNachFilm:(NSString*)filmsuchstring inArray:(NSArray*)filmarray anPfad:(NSString*)filmpfad
{
   // Filmarchiv auf TV_HD_A durchsuchen
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;

   BOOL hd_da = [Filemanager fileExistsAtPath:filmpfad];
   NSLog(@"hd_da: %d Pfad: %@",hd_da,filmpfad);
   if (hd_da)
   {
      for (NSString* tempfilmpfad in filmarray)
      {
         
         if ([tempfilmpfad rangeOfString:filmsuchstring options:NSCaseInsensitiveSearch].length)
         {
            //NSLog(@"tempfilmpfad: %@",tempfilmpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[tempfilmpfad lastPathComponent],@"titel",tempfilmpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:hd_da], @"playok", nil];
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
   } // hd_da

   return hd_da;
}

- (IBAction)reportSuchen:(id)sender;
{
   NSLog(@" *****");
   NSLog(@"reportSuchen *****");
   NSLog(@" *****");
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
   NSLog(@"childrenKeyArray: %@",childrenKeyArray);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   
   // TV_HD_A durchsuchen
   NSString* archivVolumePfad = @"/Volumes/TV_HD_A";
   BOOL archiva_da = [Filemanager fileExistsAtPath:archivVolumePfad];
   NSLog(@"suchen: archiva_da da: %d Pfad: %@",archiva_da,archivVolumePfad);
   
   if (archiva_da)
   {
      for (NSString* magpfad in TV_HD_A_Array)
      {
         
         if ([magpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"suchen archiva_da magpfad: %@",magpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[magpfad lastPathComponent],@"titel",magpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:archiva_da], @"playok", nil];
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
   
   // Filmarchiv auf TV_HD_B durchsuchen
   BOOL tvhdb_da = [Filemanager fileExistsAtPath:self.TV_HD_B_Pfad];
   NSLog(@"tvhdb_da: %d Pfad: %@",tvhdb_da,self.TV_HD_B_Pfad);
   if (tvhdb_da)
   {
      for (NSString* tempfilmpfad in TV_HD_B_Array)
      {
         
         if ([tempfilmpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            //NSLog(@"tempfilmpfad: %@",tempfilmpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[tempfilmpfad lastPathComponent],@"titel",tempfilmpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:tvhdb_da], @"tvhdb_da", nil];
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

   
   
   // Mag auf TM durchsuchen
   NSString* magVolumePfad = @"/Volumes/Mag/Archiv_WDTV";
   BOOL mag_da = [Filemanager fileExistsAtPath:self.Mag_Pfad];
   NSLog(@"suchen magda: %d Pfad: %@",mag_da,magVolumePfad);
   //if (magda)
   {
      for (NSString* magpfad in magArray)
      {
         
         if ([magpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"Archiv_WDTV suchstring da  magpfad: %@",magpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[magpfad lastPathComponent],@"titel",magpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:mag_da], @"playok", nil];
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
   BOOL filmarchiv_da = [Filemanager fileExistsAtPath:self.Filmarchiv_Pfad];
   NSLog(@"filmarchiv_da: %d Filmarchiv_Pfad: %@",filmarchiv_da,self.Filmarchiv_Pfad);
   //NSLog(@"filmarchivArray: %@",filmarchivArray);
   if (filmarchiv_da)
   {
      for (NSString* tempfilmpfad in Filmarchiv_Array)
      {
         
         if ([tempfilmpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"suchstring da Filmarchiv_Pfad tempfilmpfad: %@",tempfilmpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[tempfilmpfad lastPathComponent],@"titel",tempfilmpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:filmarchiv_da], @"playok", nil];
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
  
 
    // Filmarchiv auf WD_TV_A durchsuchen
   BOOL wdtva_da = [Filemanager fileExistsAtPath:self.WD_TV_A_Pfad];
   NSLog(@"suchen wdtva_da: %d Pfad: %@",wdtva_da,self.WD_TV_A_Pfad);
   
   if (wdtva_da)
   {
      for (NSString* tempfilmpfad in WD_TV_A_Array)
      {
         
         if ([tempfilmpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"WD_TV_A suchstring da tempfilmpfad: %@",tempfilmpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[tempfilmpfad lastPathComponent],@"titel",tempfilmpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:wdtva_da], @"playok", nil];
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

   // Filmarchiv auf WD_TV_B durchsuchen
   BOOL wdtvb_da = [Filemanager fileExistsAtPath:self.WD_TV_B_Pfad];
   NSLog(@"suchen wdtvb_da: %d Pfad: %@",wdtvb_da,self.WD_TV_B_Pfad);
   if (wdtvb_da)
   {
      for (NSString* tempfilmpfad in WD_TV_B_Array)
      {
         
         if ([tempfilmpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"WD_TV_B_Pfad suchstring da tempfilmpfad: %@",tempfilmpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[tempfilmpfad lastPathComponent],@"titel",tempfilmpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:wdtvb_da], @"playok", nil];
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
//            [filmArray addObject:findDic];
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
//               [filmArray addObject:findDic];
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
      NSString *question = NSLocalizedString(@"No Film found", @"Kein Film gefunden");
      //NSString *info = NSLocalizedString(@"Volume TV_HD_A is not mounted", @"Volume Mag auf TM ist nicht da.");
      //NSString *retryButton = NSLocalizedString(@"Quit and try mounting", @"Quit anyway button title"); // 1000
      //NSString *continueButton = NSLocalizedString(@"Continue ", @"Cancel button title"); // 1001
      NSString *OKButton = NSLocalizedString(@"OK", @"OK"); // 1001
      NSAlert *alert = [[NSAlert alloc] init];
      [alert setMessageText:question];
      //[alert setInformativeText:info];
      [alert addButtonWithTitle:OKButton];
      
      NSInteger answer = 0;
      answer = [alert runModal];

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
   
   NSLog(@" *****");
   NSLog(@"reportSuchen end *****");
   NSLog(@" *****");

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
   // Bsp: /Volumes/WD_TV_A/Tatort/2014/140506 Tatort - Bienzle und der Taximord.mp4

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
    "WD_TV_A",
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
   NSLog(@"reportMag filmLink: %@ * moveLink: %@", filmLink,moveLink);
   NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   NSLog(@"reportMag Selected Cell: %@", [selektierteZelle stringValue]);
   
   
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
   NSLog(@"reportMagVonTable: selektierteZeile: %ld",selektierteZeile);
   NSString* selektierterPfad = [[filmArray objectAtIndex:selektierteZeile ]objectForKey:@"url"];
   
   NSLog(@"reportMagVonTable selektierterPfad: *%@*", selektierterPfad);
   
   NSString* moveLink = [[[selektierterPfad stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"mag"];
   
   moveLink = [moveLink stringByAppendingPathComponent:[selektierterPfad lastPathComponent]];
   NSLog(@"moveLink: %@",moveLink);
   //[[NSWorkspace sharedWorkspace]openFile:moveLink ];
   
   
   NSError* err=NULL;
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   //NSLog(@"OrdnerArray vor: %@",[self.WDTV_Array description]);
   //   [self.tvbrowser loadColumnZero];
   BOOL isDir=NO;
   if ([Filemanager fileExistsAtPath:moveLink isDirectory:&isDir] && isDir)
   {
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
      [self writeTitelToKellerliste:filmLink];

      [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser clickedColumn]]invalidateChildren];
      
   //   [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];
      [self.tvbrowser loadColumnZero];
      self.linkfeld.stringValue = @"";
      int erfolg = [Filemanager removeItemAtPath:filmLink error:&err];
      if (erfolg)
      {
         NSAlert *OKalert = [[NSAlert alloc] init];
         [OKalert addButtonWithTitle:@"OK"];
         [OKalert setMessageText:@"Film is deleted"];
         [OKalert setAlertStyle:NSWarningAlertStyle];
         [OKalert runModal];

         NSString* WDTV_String = @"WD_TV_A/";
         NSString* TM_String = @"Archiv_WDTV/";
         NSString* Archiv_String = @"Filmarchiv/";
         NSString* WD_TV_A_String = @"WD_TV_A/";
         NSString* WD_TV_B_String = @"WD_TV_B/";
         NSString* TV_HD_A_String = @"TV_HD_A/";
         NSString* TV_HD_B_String = @"TV_HD_B/";

         
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
            Filmarchiv_Array =(NSMutableArray*)[self FilmArchiv];
         }
         else if(([filmLink rangeOfString:WD_TV_A_String].length)) //
         {
            WD_TV_A_Array =(NSMutableArray*)[self Film_WD_TV_A];
         }
         else if(([filmLink rangeOfString:WD_TV_B_String].length)) //
         {
            WD_TV_B_Array =(NSMutableArray*)[self Film_WD_TV_B];
         }
         else if(([filmLink rangeOfString:TV_HD_A_String].length)) //
         {
            TV_HD_A_Array =(NSMutableArray*)[self Film_TV_HD_A];
         }
         else if(([filmLink rangeOfString:TV_HD_B_String].length)) //
         {
            TV_HD_B_Array =(NSMutableArray*)[self Film_TV_HD_B];
         }
         

         
         
      }
      
      
      else
      {
         NSAlert *OKalert = [NSAlert alertWithError:err];
         [OKalert addButtonWithTitle:@"OK"];
         [OKalert setMessageText:@"Film is not deleted"];
         [OKalert setAlertStyle:NSWarningAlertStyle];
         [OKalert setInformativeText:[err description]];
         [OKalert runModal]; // Ignore return value.
         
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
      [self writeTitelToKellerliste:selektierterPfad];
      int erfolg = [Filemanager removeItemAtPath:selektierterPfad error:&err];
      if (erfolg)
      {
         //NSLog(@"selektierterPfad: %@",selektierterPfad   );
         //NSLog(@"delete erfolg: %d  err: %@",erfolg,[err description]);
         NSAlert *OKalert = [[NSAlert alloc] init];
         [OKalert addButtonWithTitle:@"OK"];
         [OKalert setMessageText:@"Film is deleted"];
         [OKalert setAlertStyle:NSWarningAlertStyle];
         [OKalert runModal];
         
         
         
         [filmArray removeObjectAtIndex:selektierteZeile];
         [filmTable reloadData];
         [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser lastColumn]]invalidateChildren];
         [self.tvbrowser loadColumnZero];
         
         NSString* WDTV_String = @"WDTV/";
         NSString* TM_String = @"Archiv_WDTV/";
         NSString* Archiv_String = @"Filmarchiv/";
         
         NSString* WD_TV_A_String = @"WD_TV_A/";
         NSString* WD_TV_B_String = @"WD_TV_B/";
         NSString* TV_HD_A_String = @"TV_HD_A/";
         NSString* TV_HD_B_String = @"TV_HD_B/";
         
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
            Filmarchiv_Array =(NSMutableArray*)[self FilmArchiv];
         }
         else if(([selektierterPfad rangeOfString:WD_TV_A_String].length)) //
         {
            WD_TV_A_Array =(NSMutableArray*)[self Film_WD_TV_A];
         }
         else if(([selektierterPfad rangeOfString:WD_TV_B_String].length)) //
         {
            WD_TV_B_Array =(NSMutableArray*)[self Film_WD_TV_B];
         }
         else if(([selektierterPfad rangeOfString:TV_HD_A_String].length)) //
         {
            TV_HD_A_Array =(NSMutableArray*)[self Film_TV_HD_A];
         }
         else if(([selektierterPfad rangeOfString:TV_HD_B_String].length)) //
         {
            TV_HD_B_Array =(NSMutableArray*)[self Film_TV_HD_B];
         }
         
         
      }
      else
      {
         NSAlert *OKalert = [NSAlert alertWithError:err];
         [OKalert addButtonWithTitle:@"OK"];
         [OKalert setMessageText:@"Film is not deleted"];
         [OKalert setAlertStyle:NSWarningAlertStyle];
         [OKalert setInformativeText:[err description]];
         [OKalert runModal]; // Ignore return value.
         
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
   
   TV_HD_A_Array = (NSMutableArray*)[self FilmMag]; // in reportKellerAktualisieren verschoben
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
      NSString* KellerPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"WDTVDaten/FilmListen/Keller_Liste.txt"];
       int erfolg = [filmOrdner writeToFile:KellerPfad atomically:YES ];
      NSLog(@"KellerPfad: %@ erfolg: %d",KellerPfad,erfolg );
   }
   
   
   
   NSLog(@"filmOrdner nach keller: %@",filmOrdner);
   
}

- (NSString*)KellerListe
{
   //NSLog(@"KellerListe");
   NSMutableArray* kellerliste = [[NSMutableArray alloc]initWithCapacity:0];
   NSString* KellerPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"WDTVDaten/FilmListen/Keller_Liste.txt"];
   NSError* err = NULL;
   NSString* oldKellerListe = [NSString stringWithContentsOfFile:KellerPfad encoding:NSUTF8StringEncoding error:&err];
   //NSLog(@"oldKellerListe: \n%@",oldKellerListe);
   NSArray* oldKellerArray = [oldKellerListe componentsSeparatedByString:@"\n"];
   NSString* newKellerString = [NSString string];
   for (int zeile=0; zeile < [oldKellerArray count];zeile++)
   {
      NSString* tempZeilenTitel =[[[oldKellerArray objectAtIndex:zeile]componentsSeparatedByString:@"\t"] lastObject];
      //NSLog(@"tempZeilenTitel: %@",tempZeilenTitel);
      newKellerString = [newKellerString stringByAppendingFormat:@"%@\n",tempZeilenTitel];
     
   }
   //NSLog(@"newKellerString: \n%@",newKellerString);
   return newKellerString;
}

- (void)writeTitelToKellerliste:(NSString*)kellertitel
{
   NSLog(@"kellertitel: \n%@",kellertitel);
   NSString* kellerstring = [self KellerListe];
   //NSLog(@"kellerstring original: \n%@",kellerstring);
   
   NSString* KellerPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"WDTVDaten/FilmListen/Keller_Liste.txt"];
   NSString* tempkellertitel = [self Filmtitelsauber:kellertitel];
   //NSLog(@"tempZeilenTitel: %@",tempkellertitel);
   tempkellertitel = [[tempkellertitel componentsSeparatedByString:@"/" ]lastObject];
   tempkellertitel = [tempkellertitel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

   kellerstring = [kellerstring stringByAppendingFormat:@"%@",[[tempkellertitel componentsSeparatedByString:@"/" ]lastObject]];
   NSError* err = NULL;
   
   int erfolg = [kellerstring writeToFile:KellerPfad atomically:YES encoding: NSUTF8StringEncoding error:&err];
   NSLog(@"***\nwriteTitelToKellerliste Pfad: %@ >> erfolg: %d",KellerPfad,erfolg );
   
   kellerstring = [self KellerListe];
   //NSLog(@"kellerstring neu: \n%@",kellerstring);


}

- (NSString*)Filmtitelsauber:(NSString*)titel
{
   
   NSString* extensionstring = [[titel componentsSeparatedByString:@"."]lastObject];
   NSLog(@"extensionstring: %@",extensionstring);
   NSLog(@"extensionweg: %@",[titel stringByDeletingPathExtension]);

   
                                
   NSError *error = NULL;
   NSRegularExpression *zifferregex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSString* muster=@"Tatort";
   NSRegularExpression *grupperegextatort = [NSRegularExpression regularExpressionWithPattern:@"Tatort"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
   NSRegularExpression *grupperegexpolizeiruf = [NSRegularExpression regularExpressionWithPattern:@"Polizeiruf"
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:&error];
   
   
   NSRegularExpression *divregex = [NSRegularExpression regularExpressionWithPattern:@"-"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
   
   NSRegularExpression *blankregex = [NSRegularExpression regularExpressionWithPattern:@"^[ \t]+"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
   
   NSRegularExpression *satzzeichenregex = [NSRegularExpression regularExpressionWithPattern:@"^[ \t]+"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
   NSString* temptitel =[titel stringByDeletingPathExtension];
   NSString* zifferregexstring  = [zifferregex stringByReplacingMatchesInString:temptitel
                                                                        options:0
                                                                          range:NSMakeRange(0, [temptitel length])
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
   NSString* tatortregexstring  = [grupperegextatort stringByReplacingMatchesInString:zifferregexstring
                                                                        options:0
                                                                          range:NSMakeRange(0, [zifferregexstring length])
                                                                   withTemplate:@""];
   //NSLog(@"grupperegexstring A: %@",grupperegexstring);
   
   NSString* polizeirufregexstring  = [grupperegexpolizeiruf stringByReplacingMatchesInString:tatortregexstring
                                                                    options:0
                                                                      range:NSMakeRange(0, [tatortregexstring length])
                                                               withTemplate:@""];
   
   
   NSString* divregexstring  = [divregex stringByReplacingMatchesInString:polizeirufregexstring
                                                                  options:0
                                                                    range:NSMakeRange(0, [polizeirufregexstring length])
                                                             withTemplate:@""];
   //NSLog(@"grupperegexstring B: %@",grupperegexstring);
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
   
   //NSLog(@"titel: %@ \tblankregexstring: %@",titel, blankregexstring);
//printf ("%s\n",[blankregexstring UTF8String]);
   return blankregexstring;
}

- (IBAction)reportDouble:(id)sender
{
   NSLog(@"reportDouble");
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
   int index=0;
   // Filme auf TV_HD_A
  // NSLog(@"reportDouble Filme auf TV_HD_A");
   if ([TV_HD_A_Array count])
   {
   NSLog(@"TV_HD_A_Array 0: %@*\n",[TV_HD_A_Array objectAtIndex:0]);
   }
   
   for (NSString* archivfilm in TV_HD_A_Array) // Inhalt der Files auf der externen HD
   {
         //NSLog(@"archivfilm: %@",[archivfilm lastPathComponent]);

      NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
      if (index<10)
      {
         NSLog(@"archivfilm: %@*",archivfilm);
      }
      index++;

   }
   //NSLog(@"reportDouble end Filme auf TV_HD_A");
   // Filme auf TV_HD_B
   for (NSString* archivfilm in TV_HD_B_Array) // Inhalt der Files auf der externen HD
   {
      //NSLog(@"archivfilm: %@",[archivfilm lastPathComponent]);
      NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
      
   }

   // Filme auf WD_TV_A
   for (NSString* archivfilm in WD_TV_A_Array) // Inhalt der Files auf der externen HD
   {
      //NSLog(@"archivfilm: %@",[archivfilm lastPathComponent]);
      NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
      
   }

   // Filme auf WD_TV_B
   //NSLog(@"\nreportDouble Filme auf WD_TV_B");
   index=0;
   for (NSString* archivfilm in WD_TV_B_Array) // Inhalt der Files auf der externen HD
   {
      if (index<10)
      {
         NSLog(@"archivfilm: %@",archivfilm);
      }
      index++;
      NSString* suchFilmtitel = [[archivfilm lastPathComponent]stringByDeletingPathExtension];
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
      
   }
   //NSLog(@"reportDouble end Filme auf WD_TV_B\n");
   
   
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
   for (NSString* tempfilm in Filmarchiv_Array) // Inhalt des Files Keller_WDTV.txt auf Dokumente/WDTVDaten
   {
      //NSLog(@"tempfilm: %@",[tempfilm lastPathComponent]);
      NSString* suchFilmtitel = [[tempfilm lastPathComponent]stringByDeletingPathExtension];
      //NSLog(@"suchFilmtitel: %@",suchFilmtitel);
      NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
      //NSLog(@"blankregexstring: %@",blankregexstring);
      
      // Filmtitel eintragen
      [titelArray addObject:tempfilm];
      
      // Titel mit Pfad eintragen
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",tempfilm,@"path", nil]];
      
   }
   

   for (int i=0;i<5;i++)
   {
 //     NSLog(@"reportDouble titelArray aus Mag: %@ ",[titelArray objectAtIndex:i]);
 //     NSLog(@"reportDouble titelDicArray titel: %@ path: %@",[[titelDicArray  objectAtIndex:i] valueForKey:@"titel"],[[titelDicArray  objectAtIndex:i] valueForKey:@"path"]);
    }
   int suchfilmindex=0;
   for (NSString* suchfilm in titelArray) // vorhandene Filmtitel vorgeben
   {
      
         //NSLog(@"***      suchfilmindex: %d suchfilm: %@",suchfilmindex,suchfilm );
         //NSLog(@"tempfilm: %@",[tempfilm lastPathComponent]);
    //     NSString* suchFilmtitel = [[tempfilm lastPathComponent]stringByDeletingPathExtension];
    //     NSString* blankregexstring = [self Filmtitelsauber:suchFilmtitel];
         
         
      
         unsigned long b=[suchfilm length];
         int anzVorkommen=0;
         
          NSMutableDictionary* firstDic = [NSMutableDictionary dictionary]; // Buffer fuer erstes Auftreteneines Films
      
         int checkfilmindex=0;
         for (NSDictionary* tempzeilenDic in  titelDicArray) // Filme mit Pfad und titel
         {
            
            NSString* zeilentitel = [tempzeilenDic objectForKey:@"titel"]; // gleiche Verarbeitung wie tempfilm: Nur Titel
            NSString* zeilenpfad = [tempzeilenDic objectForKey:@"path"]; // Pfad zum Film
            
            // Test, ob der Titel dem Suchtitel entspricht. Pfad kann anders sein
            if (([zeilentitel rangeOfString:suchfilm].length) && ([suchfilm length]==[zeilentitel length]))
            {
               // check, ob der Film schon als Doppel erkannt wurde
               if ([doppelOrdner containsObject:zeilentitel])
               {
                  
               }
               else
               {
               if (anzVorkommen == 0) // erstes Auftreten des Film, Titel und Pfad speichern, nichts weiter tun
               {
                  //NSLog(@"Film zum ersten Mal da checkfilmindex: %d: checktitel: %@",checkfilmindex, zeilentitel);

                  firstDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:suchfilm,@"titel",zeilenpfad, @"path", zeilenpfad,@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
               }
               else // weiteres Vorkommen des Filmtitels
               {
                  NSLog(@"Film ein weiteres Mal da checkfilmindex: %d: checktitel: %@",checkfilmindex, zeilentitel);

                  
                  
                  if (anzVorkommen == 1) // firstDic eintragen
                  {
                     [filmArray addObject:firstDic];
                     
                  }
                  
                  // Doppel eintragen
                  NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:zeilentitel,@"titel",zeilenpfad, @"path", zeilenpfad,@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
                  [filmArray addObject:doppelDic];
                  
                  // Filmtitel in Doppelordner eintragen, damit er nicht noch einmal als erstes Vorkommen gecheckt wird
                  [doppelOrdner addObject:zeilentitel];
                  
               }
               anzVorkommen++; // Zaehler incremetieren
               //NSLog(@"zeile: %d \ntitel: %@ \npath: %@ \nurl: %@",zeile,[tempzeilenDic objectForKey:@"titel"],tempPfad,tempfilm);
               }
            }
            checkfilmindex++;
         }

      suchfilmindex++;
      //bis
   }
   
   if ([filmArray count] == 0)
   {
      NSLog(@"reportDouble keine Doppel");
      NSMutableDictionary* leerDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"keine doppelten Filme",@"titel", @"-", @"path", @"-",@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
      [filmArray addObject:leerDic];

   }

   [filmTable reloadData];
  // NSLog(@"reportDouble doppelOrdner: %@ ",doppelOrdner);
}


- (IBAction)reportVolumePop:(id)sender
{
   NSLog(@"reportVolumePop selectedItem: %ld neuer path: %@",(long)[sender indexOfSelectedItem],[[Volumes_Array objectAtIndex:[sender indexOfSelectedItem]] objectForKey:@"path"]);
   
   self.rootNodePath = [[Volumes_Array objectAtIndex:[sender indexOfSelectedItem]] objectForKey:@"path"];
   
   NSLog(@"reportVolumePop path: %@ separator: %@",[self.tvbrowser path], [self.tvbrowser pathSeparator]);
   NSLog(@"reportVolumePop clickedColumn: %ld",(long)[self.tvbrowser clickedColumn]);
   //[self.tvbrowser setPath:@"Volumes/WDTV"];
   
   rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:self.rootNodePath]];
   [self.tvbrowser loadColumnZero];
   NSLog(@"reportVolumePop path: *%@*",[self.tvbrowser path]);
  if ([self.tvbrowser clickedColumn]>=0)
  {
     NSLog(@"reportVolumePop clickedColumn: %ld",(long)[self.tvbrowser clickedColumn]);
    // [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser lastColumn]]invalidateChildren];
  
   
  }
   
  // [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];
   
   
   
}

- (id)rootItemForBrowser:(NSBrowser *)browser
{
   if (rootNode == nil)
   {
      rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:self.rootNodePath]];
      
      //rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:@"/Volumes/WD_TV_A"]];
      //rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:@"/Volumes/TV_HD_A"]];

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


- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell
          atRow:(NSInteger)row column:(NSInteger)column
{
  // NSLog(@"willDisplayCell row: %ld col: %ld path: %@",row,column,sender.path );
}


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
