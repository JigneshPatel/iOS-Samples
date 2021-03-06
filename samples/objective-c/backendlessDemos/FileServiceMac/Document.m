//
//  Document.m
//  FileServiceMac
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2013 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "Document.h"
#import "Backendless.h"
#import "BEFile.h"

// *** YOU SHOULD SET THE FOLLOWING VALUES FROM YOUR BACKENDLESS APPLICATION ***
// *** COPY/PASTE APP ID and SECRET KET FROM BACKENDLESS CONSOLE (use the Manage > App Settings screen) ***

static NSString *APP_ID = @"1C5B19B3-953D-9548-FF59-95999A2FE800";
static NSString *SECRET_KEY = @"CE0A96CD-0421-B988-FF80-E16A6A8F7200";
static NSString *VERSION_NUM = @"v1";

@interface Document ()
{
    NSMutableArray *_data;
}
@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _data = [NSMutableArray array];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    [backendless initApp:APP_ID secret:SECRET_KEY version:VERSION_NUM];
    @try {
        [backendless initAppFault];
    }
    @catch (Fault *fault) {
        [[NSAlert alertWithMessageText:fault.message defaultButton:@"Done" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", fault.detail] runModal];
    }
    [backendless.persistenceService find:[BEFile class] dataQuery:[BackendlessDataQuery new] response:^(BackendlessCollection *collection) {
        _data = [NSMutableArray arrayWithArray:collection.data];
        [_tableView reloadData];
    } error:^(Fault *error) {
        NSLog(@"%@", error.detail);
    }];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

#pragma mark - Actions

-(void)uploadFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"save file (0): %ld", (long)result);
        if (result == NSOKButton) {
            for (NSURL *fileUrl in openPanel.URLs)
            {
                NSLog(@"save file (1): %@ [%@]", fileUrl, fileUrl.lastPathComponent);
                NSData *data = [[NSData alloc] initWithContentsOfURL:fileUrl];
                [backendless.fileService
                 upload:fileUrl.lastPathComponent
                 content:data
                 response:^(BackendlessFile *f) {
                    BEFile *file = [BEFile new];
                    file.path = f.fileURL;
                    [backendless.persistenceService save:file response:^(id res) {
                        NSLog(@"save file %@", res);
                        [_data insertObject:res atIndex:0];
                        [_tableView beginUpdates];
                        [_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
                        [_tableView endUpdates];
                    } error:^(Fault *error) {
                        NSLog(@"%@", error.detail);
                    }];
                } error:^(Fault *error) {
                    NSLog(@"%@", error.detail);
                }];
            }   
        }
    }];
}
-(void)downloadFile:(id)sender
{
    BEFile *file = [_data objectAtIndex:[_tableView selectedRow]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:file.path]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error)
        {
            NSSavePanel *savePanel = [NSSavePanel savePanel];
            [savePanel beginWithCompletionHandler:^(NSInteger result) {
                if (result == NSOKButton) {
                    [[NSFileManager defaultManager] createFileAtPath:savePanel.URL.path contents:data attributes:nil];
                }
            }];
            
        }
    }];
}
-(void)deleteFile:(id)sender
{
    BEFile *file = [_data objectAtIndex:[_tableView selectedRow]];
    [backendless.fileService remove:file.path response:^(id res) {
        [backendless.persistenceService remove:[BEFile class] sid:[file valueForKey:@"objectId"] response:^(NSNumber *r) {
            [_tableView beginUpdates];
            [_tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
            [_tableView endUpdates];
            [_data removeObject:file];
        } error:^(Fault *error) {
            NSLog(@"%@", error.detail);
        }];
    } error:^(Fault *error) {
        NSLog(@"%@", error.detail);
    }];
}
#pragma mark - Table View

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    BEFile *file = [_data objectAtIndex:rowIndex];
    if ([aTableColumn.identifier isEqualToString:@"Title"]) {
        return file.path.lastPathComponent;
    }
    return [NSNumber numberWithBool:YES];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return _data.count;
}

@end
