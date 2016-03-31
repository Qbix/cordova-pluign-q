/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  CordovaApp
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "QWebViewController.h"

@implementation QWebViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ((UIWebView*)self.webView).delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

- (id)initWithUrl:(NSString*) url andParameters:(NSDictionary*) dict
{
    self = [super init];
    if (self) {
        [self setStartPage:[self getUrl:url withParams:dict]];
    }
    return self;
}

-(NSString*) getUrl:(NSString*) mainUrl withParams:(NSDictionary*) params
{
    if(!params) {
        return mainUrl;
    }
    
    NSString *paramsString = @"";
    
    for (NSString* key in params) {
        id value = [params objectForKey:key];
        if(value != nil)
            paramsString = [paramsString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, (NSString*)value]];
    }
    
    NSString* newUrl = [[NSString alloc] init];
    if([mainUrl rangeOfString:@"?"].length > 0) {
        newUrl = [NSString stringWithFormat:@"%@&%@",mainUrl, paramsString];
    } else {
        newUrl = [NSString stringWithFormat:@"%@?%@",mainUrl, paramsString];
    }
    
    return newUrl;
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    Config *conf = [[Config alloc] init];
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];
    
    if([conf injectCordovaScripts]) {
        NSString *pathToCordovaJS = [NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], @"www/", @"cordova.js"];
        theWebView = [self injectJavascript:pathToCordovaJS toWebView:theWebView];
    }
    
//    ((UIWebView*)self.webView) 
//    return [super webViewDidFinishLoad:theWebView];
}

- (UIWebView*)injectJavascript:(NSString *)jsPath toWebView:(UIWebView*) webView {
    NSString *js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
    
    return webView;
}

@end

@implementation QCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation QCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end