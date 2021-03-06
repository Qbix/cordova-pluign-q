//
//  AppDelegateBase.h
//  CordovaApp
//
//  Created by adventis on 12/3/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVAppDelegate.h>
#import "QWebViewController.h"
#import "CordovaWebViewURLCache.h"
#import "QFileSystemHelper.h"
#import "NSString+SHA1.h"

@interface Q : NSObject {}

@property(nonatomic, retain) CDVAppDelegate *appDelegate;

+(Q*)initTestWith:(CDVAppDelegate *)appDelegate;
+(Q*)initTestWith:(CDVAppDelegate *)appDelegate andInitUrl:(NSString*) url;
+(Q*) initWith:(CDVAppDelegate*) appDelegate;
+(Q*) getInstance;

//-(void) initPlugin:(CDVAppDelegate*) appDelegate;
-(void) showQWebView;
-(void) initSharedCache;
-(void) resetTestMode;
-(CordovaWebViewURLCache*) prepeareCordovaWebViewUrlCacheMemory:(int) cache_size_memory andDisk:(int) cache_size_disk;
-(QWebViewController*) prepeareQGroupsController;
-(QWebViewController*) prepeareQWebViewControllerWith:(NSString*) url;
-(NSDictionary*) getAdditionalParamsForUrl;
-(void)handleOpenUrlScheme:(NSURL*)url;


@end
