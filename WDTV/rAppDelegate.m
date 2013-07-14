//
//  rAppDelegate.m
//  WDTV
//
//  Created by Ruedi Heimlicher on 05.Juli.13.
//  Copyright (c) 2013 Ruedi Heimlicher. All rights reserved.
//

#import "rAppDelegate.h"
#import "FileSystemNode.h"

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
   NSLog(@"mountKeller: %@",result);
}




-(void) volumesChanged: (NSNotification*) notification
{
   NSLog(@"dostuff");
}

- (void)browserCellSelected:(id)sender
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
   filmArray = [[NSMutableArray alloc]initWithCapacity:0];
   archivArray = [[NSMutableArray alloc]initWithCapacity:0];
   kellerArray = [[NSMutableArray alloc]initWithCapacity:0];

   
   [self.tvbrowser setTarget:self];
   //[self.self.tvbrowser setReusesColumns:NO];
   //[self.tvbrowser setWidth:100 ofColumn:0];
   [self.tvbrowser sizeToFit];
   [self.tvbrowser  setWidth:[self.self.tvbrowser columnWidthForColumnContentWidth:150] ofColumn:0];

   [self.tvbrowser  setWidth:[self.self.tvbrowser columnWidthForColumnContentWidth:150] ofColumn:1];

   [self.self.tvbrowser setDelegate:self];
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

   
   
   
   [self.tvbrowser  setDoubleAction:@selector(browserCellSelected:)];
   [self.tvbrowser  setAction:@selector(browserClick:)];

   
   
   // Daten auf WDTVLiIVE lesen

   mountVolumeAppleScript(@"ruediheimlicher",@"rh47",@"WDTVLIVE",@"WD_TV");

   self.WDTV_Pfad = [NSString stringWithFormat:@"/Volumes/WD_TV"];
   //NSLog(@"WDTV_Pfad: %@",self.WDTV_Pfad);
   
   NSURL* WDTV_URL=[NSURL fileURLWithPath:self.WDTV_Pfad];
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
   
   archivArray =(NSMutableArray*)[self FilmArchiv];
   
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
   
   // Daten auf der TM lesen: File auf TM/Mag
      
   mountKellerAppleScript(@"ruediheimlicher",@"rh47",@"TC_Basis",@"Mag");

   self.Keller_Pfad = [NSString stringWithFormat:@"/Volumes/Mag/Archiv_WDTV"];
   NSLog(@"Keller_Pfad: %@",self.Keller_Pfad);
   
   kellerArray = (NSMutableArray*)[self FilmKeller];
   
   NSLog(@"kellerArray: %@",kellerArray);
   
   
   
   NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
   [nc addObserver:self
			 selector:@selector(FensterSchliessenAktion:)
				  name:@"NSWindowWillCloseNotification"
				object:nil];

}

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
      //NSLog(@"archivArray: %@",[archivArray description]);
   }
   return temparchivArray;
}

- (NSArray*)FilmSammlung
{
   // Alle Filme auf WDTV
   NSMutableArray* sammlungArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSString* sammelPfad = self.WDTV_Pfad;
   if ([Filemanager fileExistsAtPath:sammelPfad])//ist
   {
      //NSArray* OrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.WDTV_Pfad error:&err];
      //NSArray* OrdnerArray
      NSArray* OrdnerArray0 =  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:sammelPfad]
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
   
   //NSLog(@"sammlungArray: %@",[sammlungArray description]);
   
   return sammlungArray;
}

- (NSArray*)FilmKeller
{
   NSMutableArray* kellerFilmArray = [[NSMutableArray alloc]initWithCapacity:0];
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
   NSURL* Keller_URL=[NSURL fileURLWithPath:self.Keller_Pfad];
   if ([Filemanager fileExistsAtPath:self.Keller_Pfad])//ist
   {
      //NSLog(@"alles da");
      
      NSError* err;
      //NSArray* tempOrdnerArray = [Filemanager contentsOfDirectoryAtPath:self.Keller_Pfad error:&err];
      //NSLog(@"err: %@ ArchivOrdnerArray: %@",err,[tempOrdnerArray description]);
      //NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtPath:self.Keller_Pfad error:&err];
      NSArray* KellerOrdnerArray=  [Filemanager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.Keller_Pfad]
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
                           NSLog(@"OrdnerArray2: %@",OrdnerArray2);
                           for (NSURL* titel in OrdnerArray2)
                           {
                              //[sammlungArray addObject:[[titel path] lastPathComponent]];
                              [kellerFilmArray addObject:[titel path]];
                           }
                        }
                        else
                        {
                           [kellerFilmArray addObject:[unterorderurl1 path]];
                        }
                        
                     } // isDir Ordner1
                     
                  } // for order1 count
                  
               }// orderarray1 count
            } // isDir in Order0
            
         } // for order0
         
      }// orderarray0
      //NSLog(@"kellerFilmArray: %@",[kellerFilmArray description]);
   }
   else
   {
      NSLog(@"kein Kellerordner da");
   }

   return kellerFilmArray;
}

- (IBAction)reportSuchen:(id)sender;
{
   [filmArray removeAllObjects];
   [filmTable reloadData];
   self.resultatfeld.stringValue =@"suchen ...";
   
   self.opentaste.enabled = NO;
   self.magtaste.enabled = NO;
   self.deletetaste.enabled = NO;
   self.archivtaste.enabled = NO;
   
   
   NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"suchen ...", @"titel",@"",@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
   [filmArray addObject:findDic];
   [filmTable reloadData];


   NSString* suchstring = [self.suchfeld stringValue];
   NSLog(@"reportSuchen: %@ WDTV_Pfad: %@",[self.suchfeld stringValue],self.WDTV_Pfad);
   
   //NSLog(@"rootNode: %@",[[rootNode children] description]);
   NSDictionary* childrenDic = [rootNode childrenDic];
   NSArray* childrenKeyArray = [[rootNode childrenDic]allKeys];
   //NSLog(@"childrenKeyArray: %@",childrenKeyArray);
   NSFileManager *Filemanager=[NSFileManager defaultManager];
   NSError* err=NULL;
  
   // Externe HD durchsuchen
   NSString* archivVolumePfad = @"/Volumes/RH 1TB";
   BOOL archivda = [Filemanager fileExistsAtPath:archivVolumePfad];
   NSLog(@"archivda: %d",archivda);
   
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
   
   
   
   // Mag auf TM durchsuchen
   NSString* kellerVolumePfad = @"/Volumes/Mag/Archiv_WDTV";
   BOOL kellerda = [Filemanager fileExistsAtPath:kellerVolumePfad];
   NSLog(@"kellerda: %d",kellerda);
   //if (kellerda)
   {
      for (NSString* kellerpfad in kellerArray)
      {
         
         if ([kellerpfad rangeOfString:suchstring options:NSCaseInsensitiveSearch].length)
         {
            NSLog(@"kellerpfad: %@",kellerpfad);
            NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[kellerpfad lastPathComponent],@"titel",kellerpfad, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:archivda], @"playok", nil];
            [filmArray addObject:findDic];
            if ([self.resultatfeld.stringValue length])
            {
               self.resultatfeld.stringValue = [NSString stringWithFormat:@"%@ \n %@",self.resultatfeld.stringValue,kellerpfad];
            }
            else
            {
               self.resultatfeld.stringValue = kellerpfad;
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
   
   
   
   if ([filmArray count]==0)
   {
      NSMutableDictionary* findDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Kein Film gefunden", @"titel",@"",@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
      [filmArray addObject:findDic];
      [filmTable reloadData];
      
   }
   else
   {
      [filmArray removeObjectAtIndex:0];
   
   }
   [filmTable reloadData];

   return;
   
   
   for (NSURL* pfadURL in self.WDTV_Array)
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

- (IBAction)reportPlay:(id)sender
{
   long selektierteZeile = [filmTable selectedRow];
   NSLog(@"reportPlay: selektierteZeile: %ld",selektierteZeile);
   NSString* selektierterPfad = [[filmArray objectAtIndex:selektierteZeile ]objectForKey:@"url"];
   NSLog(@"reportPlay selektierterPfad: %@", selektierterPfad);

   NSFileManager* Filemanager = [NSFileManager defaultManager];
   [[NSWorkspace sharedWorkspace]openFile:selektierterPfad ];
}


- (IBAction)reportMag:(id)sender
{
   NSTextFieldCell* selektierteZelle = (NSTextFieldCell*)[self.tvbrowser selectedCell];
   //NSLog(@"reportMag Selected Cell: %@", [selektierteZelle stringValue]);

   NSString* moveLink = [[[filmLink stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Mag"];
   //NSString* magLink = moveLink;
   moveLink = [moveLink stringByAppendingPathComponent:[filmLink lastPathComponent]];
   //NSLog(@"moveLink: %@",moveLink);
   //[[NSWorkspace sharedWorkspace]openFile:moveLink ];
   
   
   NSError* err=NULL;
   NSFileManager* Filemanager = [NSFileManager defaultManager];
   //NSLog(@"OrdnerArray vor: %@",[self.WDTV_Array description]);
//   [self.tvbrowser loadColumnZero];
   
   int erfolg = [Filemanager moveItemAtPath:filmLink toPath:moveLink error:&err];
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
   
   NSString* moveLink = [[[selektierterPfad stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"mag"];
   
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
   int erfolg = [Filemanager removeItemAtPath:filmLink error:&err];
   NSLog(@"delete err: %@",[err description]);
   if (erfolg)
   {
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
         [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser clickedColumn]]invalidateChildren];
         [[self.tvbrowser parentForItemsInColumn:1]invalidateChildren];
         [self.tvbrowser loadColumnZero];
         self.linkfeld.stringValue = @"";
      }
      
   }
   else
   {
      NSAlert *theAlert = [NSAlert alertWithError:err];
      [theAlert runModal]; // Ignore return value.

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
   
   int erfolg = [Filemanager removeItemAtPath:selektierterPfad error:&err];
   //NSLog(@"delete err: %@",[err description]);
   if (erfolg)
   {
      NSLog(@"reportDeleteVonTable OK");
      NSAlert *alert = [[NSAlert alloc] init];
      [alert addButtonWithTitle:@"OK"];
      [alert addButtonWithTitle:@"Cancel"];
      [alert setMessageText:@"Delete Film?"];
      [alert setInformativeText:@"Deleted films cannot be restored."];
      [alert setAlertStyle:NSWarningAlertStyle];
      if ([alert runModal] == NSAlertFirstButtonReturn)
      {
         // OK clicked, delete the record
         [filmArray removeObjectAtIndex:selektierteZeile];
         [filmTable reloadData];
         [[self.tvbrowser parentForItemsInColumn:[self.tvbrowser lastColumn]]invalidateChildren];
         [self.tvbrowser loadColumnZero];


      }
   }
   else
   {
      NSAlert *theAlert = [NSAlert alertWithError:err];
      [theAlert runModal]; // Ignore return value.
      
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
       kellerArray = (NSMutableArray*)[self FilmKeller]; // in reportKellerAktualisieren verschoben
       if ([kellerArray count])
       {
       for (NSString* tempFilm in kellerArray)
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
   
   kellerArray = (NSMutableArray*)[self FilmKeller]; // in reportKellerAktualisieren verschoben
   if ([kellerArray count])
   {
      for (NSString* tempFilm in kellerArray)
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

- (IBAction)reportDouble:(id)sender
{
   //NSLog(@"reportDouble");
   [archivArray setArray:[self FilmArchiv]];
    [kellerArray setArray:[self FilmKeller]];
   //NSLog(@"reportDouble archivArray: %@ ",archivArray);
   self.suchfeld.stringValue = @"";
   [filmArray removeAllObjects];
   [filmTable reloadData];
   
   NSArray* sammlungOrdner = [self FilmSammlung]; // alle Filme auf WDTV
   
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
   NSRegularExpression *blankregex = [NSRegularExpression regularExpressionWithPattern:@"^[ \t]+"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

   // Filme auf Volumes ausserhalb WDTVLIVE suchen
   
   // Filme auf externer HD
   for (NSString* archivfilm in archivArray) // Inhalt des Files Mag_WDTV.txt auf Dokumente/WDTVDaten
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
         
         
         
         //NSLog(@"suchFilmtitel: %@ regexstring: %@ grupperegexstring: *%@* blankregexstring: *%@*",suchFilmtitel,regexstring,grupperegexstring, blankregexstring);
         
      [titelArray addObject:blankregexstring];
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm,@"path", nil]];
         
   }
   
   // Filme auf TM/Mag
   for (NSString* kellerfilm in kellerArray) // Inhalt des Files Keller_WDTV.txt auf Dokumente/WDTVDaten
   {
      //NSLog(@"kellerfilm: %@",[kellerfilm lastPathComponent]);
      NSString* suchFilmtitel = [[kellerfilm lastPathComponent]stringByDeletingPathExtension];
      
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
      [titelDicArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",kellerfilm,@"path", nil]];
      
   }
  
   
   //NSLog(@"reportDouble titelArray aus WDTV.txt: %@ ",titelArray);
   //NSLog(@"reportDouble titelDicArray aus WDTV.txt: %@ ",[titelDicArray valueForKey:@"titel"]);
   
   for (NSString* archivfilm in sammlungOrdner) // Filme auf WDTV
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
         int b=[blankregexstring length];
         /*
         if ([titelArray containsObject:blankregexstring])
         {
            [doppelOrdner addObject:archivfilm];
            NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm, @"url", [NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
            //[filmArray addObject:doppelDic];
            
         }
         
         long archivindex = [[titelDicArray valueForKey:@"titel"]indexOfObject:blankregexstring];
         if (archivindex < NSNotFound)
         {
            
            NSString* tempPfad = [[titelDicArray objectAtIndex:archivindex]objectForKey:@"path"];
            NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm, @"url", tempPfad,@"path",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
 //           [filmArray addObject:doppelDic];
            //NSLog(@"archivindex: %ld path: %@ url: %@",archivindex,tempPfad,archivfilm);
            
         }
         */
         // For string kind of values:
          
         //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", blankregexstring];
         //NSArray *results = [[titelDicArray valueForKey:@"titel"] filteredArrayUsingPredicate:predicate];
         //if ([results count])
         //{
         //NSLog(@"results: %@",results);
         //}
         
         int zeile=0;
         for (NSDictionary* tempzeilenDic in  titelDicArray)
         {
            NSString* zeilentitel = [tempzeilenDic objectForKey:@"titel"];
            if (([zeilentitel rangeOfString:blankregexstring].length) && (b==[zeilentitel length]))
            {
               int z=[zeilentitel length];
               NSLog(@"b: %d z: %d",b,z);
               
               [doppelOrdner addObject:[tempzeilenDic objectForKey:@"titel"]];
               NSString* tempPfad = [tempzeilenDic objectForKey:@"path"];
               NSMutableDictionary* doppelDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:blankregexstring,@"titel",archivfilm, @"path", tempPfad,@"url",[NSNumber numberWithInt:0], @"mark",[NSNumber numberWithInt:1], @"playok", nil];
               [filmArray addObject:doppelDic];
               NSLog(@"zeile: %d \ntitel: %@ \npath: %@ \nurl: %@",zeile,[tempzeilenDic objectForKey:@"titel"],tempPfad,archivfilm);

            }
            zeile++;
         }

         
      }//bis
   }
   
   
   
   //[kellerArray setArray:[self FilmKeller]];
   
   /*
   for (NSString* archivfilm in kellerArray) // Filme auf TM
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
  
   
   NSLog(@"reportDouble doppelOrdner: %@ ",doppelOrdner);
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
      rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:@"/Volumes/WD_TV"]];
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
