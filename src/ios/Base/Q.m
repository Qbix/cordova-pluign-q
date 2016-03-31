//
//  Q.m
//  CordovaApp
//
//  Created by adventis on 12/3/15.
//
//

#import "Q.h"

@implementation Q
#define CACHE_SIZE_MEMORY 8*1024*1024
#define CACHE_SIZE_DISK 32*1024*1024

@synthesize appDelegate;

static Q *instance = nil;

+ (Q*)initWith:(CDVAppDelegate *)appDelegate {
    if (instance == nil) {
        instance = [[super alloc] init];
    }
    [instance setAppDelegate:appDelegate];
    [instance initialize];
    
    return instance;
}

+(Q*) getInstance {
    if(instance == nil) {
        @throw [[NSException alloc] initWithName:@"Q plugin isn't inited. Please run static method initWith:(CDVAppDelegate *)appDelegate" reason:@"" userInfo:nil];
        return nil;
    }
    
    return instance;
}


-(void) initialize {
    [self initSharedCache];
    
    if([[[Config alloc] init] remoteMode]) {
        self.appDelegate.viewController = [self prepeareQGroupsController];
    } else {
        self.appDelegate.viewController = [[QWebViewController alloc] init];
    }
    
    if(![[[[Config alloc] init] userAgentHeader] isEqualToString:@""]) {
        self.appDelegate.viewController.baseUserAgent = [[[Config alloc] init] userAgentHeader];
    }
    
    [self sendPingRequest];
    
}

-(void) sendPingRequest {
    //    [[[QbixApi alloc] init] sendAnotherPing:^(PingDataResponse* response, NSError* error) {
    //        NSLog(@"Response");
    //    }];
}

-(void) initSharedCache {
    if([[[Config alloc] init] remoteMode]) {
        CordovaWebViewURLCache* sharedCache = [self prepeareCordovaWebViewUrlCacheMemory:CACHE_SIZE_MEMORY andDisk:CACHE_SIZE_DISK];
        [NSURLCache setSharedURLCache:sharedCache];
    } else {
        NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:CACHE_SIZE_MEMORY diskCapacity:CACHE_SIZE_DISK diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
    }
}

-(CordovaWebViewURLCache*) prepeareCordovaWebViewUrlCacheMemory:(int) cache_size_memory andDisk:(int) cache_size_disk {
    Config *conf = [[Config alloc] init];
    
    CordovaWebViewURLCache* sharedCache = [[CordovaWebViewURLCache alloc] initWithMemoryCapacity:cache_size_memory diskCapacity:cache_size_disk diskPath:@"nsurlcache"];
    
    [sharedCache setIsReturnCahceFilesFromBundle:[conf enableLoadBundleCache]];
    [sharedCache setPathToBundle:[conf pathToBundle]];
    [sharedCache setRemoteCacheId:[conf remoteCacheId]];
    
    if([[[Config alloc] init] injectCordovaScripts]) {
        NSMutableArray *filesToInject = [NSMutableArray array];
        
        // add cordova_plugins.js files with all plugins
        [filesToInject addObject:[NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], @"www/", @"cordova_plugins.js"]];
        
        // add another files
        NSString *pathToCordovaPlugins = [NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], @"www/", @"plugins"];
        [filesToInject addObjectsFromArray:[FileSystemHelper recursivePathsForResourcesOfType:@"js" inDirectory:pathToCordovaPlugins]];
        
        [sharedCache setListOfJsInjects:filesToInject];
    }
    
    return sharedCache;
}

- (QWebViewController*) prepeareQGroupsController {
    Config *conf = [[Config alloc] init];
    
    return [[QWebViewController alloc] initWithUrl:[conf loadUrl] andParameters:[self getAdditionalParamsForUrl]];
}

-(NSDictionary*) getAdditionalParamsForUrl {
    Config *conf = [[Config alloc] init];
    NSDictionary *paramsLoadUrl = nil;
    if([conf enableLoadBundleCache]) {
        paramsLoadUrl = @{
                          @"Q.udid" : [NSString stringWithString:[OpenUDID value]],
                          @"Q.cordova" : [NSString stringWithString:CDV_VERSION],
                          @"Q.ct" : [NSNumber numberWithInt:[conf bundleTimestamp]]
                          };
    } else {
        paramsLoadUrl = @{
                          @"Q.udid" : [NSString stringWithString:[OpenUDID value]],
                          @"Q.cordova" : [NSString stringWithString:CDV_VERSION]
                          };
    }
    
    return paramsLoadUrl;
}

-(void)handleOpenUrlScheme:(NSURL*)url {
    
    Config* conf = [[Config alloc] init];
    
    if([conf remoteMode]) {
        if([[url scheme] isEqualToString:[conf openUrlScheme]]) {
        
            NSDictionary *customParamsDict = [self getAdditionalParamsForUrl];
            NSString *customParams = @"";
            for (NSString* key in customParamsDict) {
                id value = [customParamsDict objectForKey:key];
                if(value != nil)
                    customParams = [customParams stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, (NSString*)value]];
            }
            
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@?%@%@#%@", [[[Config alloc] init] loadBaseUrl], [url path], customParams, [url query], [url fragment]];
            
            NSString *fragment = [url fragment];
            if([fragment isEqualToString:@"newWindow"]) {
                //Open in additional webview
            } else {
                //Open in main webview
            }
        }
    }
}

@end