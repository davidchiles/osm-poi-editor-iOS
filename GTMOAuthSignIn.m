/* Copyright (c) 2010 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define GTMOAUTHSIGNIN_DEFINE_GLOBALS 1
#import "GTMOAuthSignIn.h"

// we'll default to timing out if the network becomes unreachable for more
// than 30 seconds when the sign-in page is displayed
static const NSTimeInterval kDefaultNetworkLossTimeoutInterval = 30.0;

@interface GTMOAuthSignIn ()

@property (nonatomic, retain, readwrite) NSURL *requestTokenURL;
@property (nonatomic, retain, readwrite) NSURL *authorizeTokenURL;
@property (nonatomic, retain, readwrite) NSURL *accessTokenURL;

- (void)invokeFinalCallbackWithError:(NSError *)error;

- (void)startWebRequest;
#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
- (void)fetchGoogleUserInfo;
#endif

- (GTMHTTPFetcher *)pendingFetcher;
- (void)setPendingFetcher:(GTMHTTPFetcher *)obj fetchType:(NSString *)fetchType;

- (void)accessFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
- (void)requestFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
- (void)infoFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
#endif

- (void)closeTheWindow;

- (void)startReachabilityCheck;
- (void)stopReachabilityCheck;
- (void)reachabilityTarget:(SCNetworkReachabilityRef)reachabilityRef
              changedFlags:(SCNetworkConnectionFlags)flags;
- (void)reachabilityTimerFired:(NSTimer *)timer;
@end

@implementation GTMOAuthSignIn

@synthesize delegate = delegate_,
            authentication = auth_,
            fetcherService = fetcherService_,
            userData = userData_,
            requestTokenURL = requestURL_,
            authorizeTokenURL = authorizeURL_,
            accessTokenURL = accessURL_,
#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
            shouldFetchGoogleUserInfo = shouldFetchGoogleUserInfo_,
#endif
            networkLossTimeoutInterval = networkLossTimeoutInterval_;

#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
- (id)initWithGoogleAuthenticationForScope:(NSString *)scope
                                  language:(NSString *)language
                                  delegate:(id)delegate
                        webRequestSelector:(SEL)webRequestSelector
                          finishedSelector:(SEL)finishedSelector {
  // standard Google OAuth endpoints
  //
  // http://code.google.com/apis/accounts/docs/OAuth_ref.html
  NSURL *requestURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthGetRequestToken"];
  NSURL *authorizeURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthAuthorizeToken"];
  NSURL *accessURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthGetAccessToken"];

  GTMOAuthAuthentication *auth = [GTMOAuthAuthentication authForInstalledApp];
  [auth setScope:scope];
  [auth setLanguage:language];
  [auth setServiceProvider:kGTMOAuthServiceProviderGoogle];

  // open question: should we call [auth setHostedDomain: ] here too?

  // we'll use the mobile user interface for embedded sign-in as it's smaller
  // and somewhat more suitable for embedded usage
  [auth setMobile:@"mobile"];

  // we'll use a non-existent callback address, and close the window
  // immediately when it's requested
  [auth setCallback:@"http://www.google.com/OAuthCallback"];

  return [self initWithAuthentication:auth
                      requestTokenURL:requestURL
                    authorizeTokenURL:authorizeURL
                       accessTokenURL:accessURL
                             delegate:delegate
                   webRequestSelector:webRequestSelector
                     finishedSelector:finishedSelector];
}
#endif

- (id)initWithAuthentication:(GTMOAuthAuthentication *)auth
             requestTokenURL:(NSURL *)requestURL
           authorizeTokenURL:(NSURL *)authorizeURL
              accessTokenURL:(NSURL *)accessURL
                    delegate:(id)delegate
          webRequestSelector:(SEL)webRequestSelector
            finishedSelector:(SEL)finishedSelector {

  // check the selectors on debug builds
  GTMAssertSelectorNilOrImplementedWithArgs(delegate, webRequestSelector,
    @encode(GTMOAuthSignIn *), @encode(NSURLRequest *), 0);
  GTMAssertSelectorNilOrImplementedWithArgs(delegate, finishedSelector,
    @encode(GTMOAuthSignIn *), @encode(GTMOAuthAuthentication *),
    @encode(NSError *), 0);

  // designated initializer
  self = [super init];
  if (self != nil) {
    auth_ = [auth retain];
    requestURL_ = [requestURL retain];
    authorizeURL_ = [authorizeURL retain];
    accessURL_ = [accessURL retain];

    delegate_ = [delegate retain];
    webRequestSelector_ = webRequestSelector;
    finishedSelector_ = finishedSelector;

#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
    // for Google authentication, we want to automatically fetch user info
    if ([[authorizeURL host] isEqual:@"www.google.com"]) {
      shouldFetchGoogleUserInfo_ = YES;
    }
#endif

    // default timeout for a lost internet connection while the server
    // UI is displayed is 30 seconds
    networkLossTimeoutInterval_ = kDefaultNetworkLossTimeoutInterval;
  }
  return self;
}

- (void)dealloc {
  [self stopReachabilityCheck];

  [auth_ release];
  [delegate_ release];
  [requestURL_ release];
  [authorizeURL_ release];
  [accessURL_ release];
  [fetcherService_ release];
  [userData_ release];

  [super dealloc];
}

#pragma mark Sign-in Sequence Methods

// utility method to create a fetcher, either from the fetcher service object
// or from the class method
- (GTMHTTPFetcher *)fetcherWithRequest:(NSMutableURLRequest *)request {
  GTMHTTPFetcher *fetcher;
  id <GTMHTTPFetcherServiceProtocol> fetcherService = self.fetcherService;
  if (fetcherService) {
    fetcher = [fetcherService fetcherWithRequest:request];
  } else {
    fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
  }
  return fetcher;
}

// stop any pending fetches, and close the window (but don't call the
// delegate's finishedSelector)
- (void)cancelSigningIn {
  [pendingFetcher_ stopFetching];
  [self setPendingFetcher:nil fetchType:nil];

  [self closeTheWindow];

  [delegate_ autorelease];
  delegate_ = nil;
}

//
// This is the entry point to begin the sequence
//  - fetch a request token
//  - display the authentication web page
//  - exchange the request token for an access token
//  - tell the delegate we're finished
//
- (BOOL)startSigningIn {
  // the authentication object won't have an access token until the access
  // fetcher successfully finishes; any auth token held before then is a request
  // token
  [auth_ reset];

#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
  // add the Google-specific scope for obtaining the authenticated user info
  if (shouldFetchGoogleUserInfo_) {
    NSString *uiScope = @"https://www.googleapis.com/auth/userinfo.email";
    NSString *scope = [auth_ scope];
    if ([scope rangeOfString:uiScope].location == NSNotFound) {
      scope = [scope stringByAppendingFormat:@" %@", uiScope];
      [auth_ setScope:scope];
    }
  }
#endif

  // start fetching a request token
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL_];
  [auth_ addRequestTokenHeaderToRequest:request];

  GTMHTTPFetcher *fetcher = [self fetcherWithRequest:request];
  [fetcher setCommentWithFormat:@"request token for %@", [requestURL_ host]];

  BOOL didStart = [fetcher beginFetchWithDelegate:self
                                didFinishSelector:@selector(requestFetcher:finishedWithData:error:)];
  if (didStart) {
    [self setPendingFetcher:fetcher fetchType:kGTMOAuthFetchTypeRequest];
  }
  return didStart;
}

- (void)requestFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
  [self setPendingFetcher:nil fetchType:nil];
  if (error) {
    [self invokeFinalCallbackWithError:error];
  } else {
    [auth_ setKeysForResponseData:data];

    // notify the app so it can hide any pre-sign in UI that was displayed
    // during the request fetch
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kGTMOAuthUserWillSignIn
                      object:self
                    userInfo:nil];

    [self startWebRequest];
  }
}

- (void)startWebRequest {
  // if the auth object has a request token, we can proceed
  NSString *token = [auth_ token];
  if ([token length] > 0) {
    // invoke the user's web request selector to display the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authorizeURL_];
    [auth_ addAuthorizeTokenParamsToRequest:request];

    [delegate_ performSelector:webRequestSelector_
                    withObject:self
                    withObject:request];

    // at this point, we're waiting on the server-driven html UI, so
    // we want notification if we lose connectivity to the web server
    [self startReachabilityCheck];
  }
}

// entry point for the window controller to tell us that the window
// prematurely closed
- (void)windowWasClosed {
  [self stopReachabilityCheck];

  [pendingFetcher_ stopFetching];
  [self setPendingFetcher:nil fetchType:nil];

  NSError *error = [NSError errorWithDomain:kGTMOAuthErrorDomain
                                       code:kGTMOAuthErrorWindowClosed
                                   userInfo:nil];

  [self invokeFinalCallbackWithError:error];
}

// internal method to tell the window controller to close the window
- (void)closeTheWindow {
  [self stopReachabilityCheck];

  [delegate_ performSelector:webRequestSelector_
                  withObject:self
                  withObject:nil];
}

// entry point for the window controller to tell us what web page has been
// requested
//
// when the request is for the callback URL, this method returns YES, and begins
// the fetch to exchange the request token for an access token
- (BOOL)requestRedirectedToRequest:(NSURLRequest *)redirectedRequest {
  // compare the callback URL, which tells us when the web sign-in is done,
  // to the actual redirect URL
  NSString *callback = [auth_ callback];
  if ([callback length] == 0) {
    // with no callback specified for the auth, the window will never
    // automatically close
#if DEBUG
    NSAssert(0, @"GTMOAuthSignIn: No authentication callback specified");
#endif
    return NO;
  }

  NSURL *callbackURL = [NSURL URLWithString:callback];

  NSURL *requestURL = [redirectedRequest URL];

  BOOL isCallback = [[callbackURL host] isEqual:[requestURL host]]
    && [[callbackURL path] isEqual:[requestURL path]];

  if (!isCallback) {
    // tell the caller that this request is nothing interesting
    return NO;
  }

  // the callback page was requested, so tell the window to close
  [self closeTheWindow];

  // notify the app so it can put up a post-sign in, pre-access token fetch UI
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:kGTMOAuthUserHasSignedIn
                    object:self
                  userInfo:nil];

  // once the authorization finishes, try to get a validated access token
  NSString *responseStr = [[redirectedRequest URL] query];
  [auth_ setKeysForResponseString:responseStr];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:accessURL_];
  [auth_ addAccessTokenHeaderToRequest:request];

  GTMHTTPFetcher *fetcher = [self fetcherWithRequest:request];
  [fetcher setCommentWithFormat:@"access token for %@", [accessURL_ host]];

  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(accessFetcher:finishedWithData:error:)];

  [self setPendingFetcher:fetcher fetchType:kGTMOAuthFetchTypeAccess];

  // tell the delegate that we did handle this request
  return YES;
}

- (void)accessFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
  [self setPendingFetcher:nil fetchType:nil];

  if (error) {
    [self invokeFinalCallbackWithError:error];
  } else {
    // we have an access token
    [auth_ setKeysForResponseData:data];
    [auth_ setHasAccessToken:YES];

#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
    if (shouldFetchGoogleUserInfo_
        && [[auth_ serviceProvider] isEqual:kGTMOAuthServiceProviderGoogle]) {
      // fetch the user's information from the Google server
      [self fetchGoogleUserInfo];
    } else {
      // we're not authorizing with Google, so we're done
      [self invokeFinalCallbackWithError:nil];
    }
#else
    [self invokeFinalCallbackWithError:nil];
#endif
  }
}

#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
- (void)fetchGoogleUserInfo {
  // fetch the additional user info
  NSString *infoURLStr = @"https://www.googleapis.com/userinfo/email";
  NSURL *infoURL = [NSURL URLWithString:infoURLStr];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:infoURL];
  [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];

  [auth_ authorizeRequest:request];

  GTMHTTPFetcher *fetcher = [self fetcherWithRequest:request];
  fetcher.comment = @"user info";

  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(infoFetcher:finishedWithData:error:)];

  [self setPendingFetcher:fetcher fetchType:kGTMOAuthFetchTypeUserInfo];
}

- (void)infoFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
  [self setPendingFetcher:nil fetchType:nil];

  if (error) {
    [self invokeFinalCallbackWithError:error];
  } else {
    // we have the authenticated user's info
    if (data) {
      [auth_ setKeysForResponseData:data];
    }

    [self invokeFinalCallbackWithError:nil];
  }
}
#endif

// convenience method for making the final call to our delegate
- (void)invokeFinalCallbackWithError:(NSError *)error {
  if (delegate_ && finishedSelector_) {
    NSMethodSignature *sig = [delegate_ methodSignatureForSelector:finishedSelector_];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:finishedSelector_];
    [invocation setTarget:delegate_];
    [invocation setArgument:&self atIndex:2];
    [invocation setArgument:&auth_ atIndex:3];
    [invocation setArgument:&error atIndex:4];
    [invocation invoke];
  }

  // we'll no longer send messages to the delegate
  [delegate_ autorelease];
  delegate_ = nil;
}

- (void)notifyFetchIsRunning:(BOOL)isStarting
                        type:(NSString *)fetchType {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  NSString *name = (isStarting ? kGTMOAuthFetchStarted : kGTMOAuthFetchStopped);
  NSDictionary *dict = [NSDictionary dictionaryWithObject:fetchType
                                                   forKey:kGTMOAuthFetchTypeKey];
  [nc postNotificationName:name
                    object:self
                  userInfo:dict];
}

#pragma mark Reachability monitoring

static void ReachabilityCallBack(SCNetworkReachabilityRef target,
                                 SCNetworkConnectionFlags flags,
                                 void *info) {
  // pass the flags to the signIn object
  GTMOAuthSignIn *signIn = (GTMOAuthSignIn *)info;

  [signIn reachabilityTarget:target
                changedFlags:flags];
}

- (void)startReachabilityCheck {
  // the user may set the timeout to 0 to skip the reachability checking
  // during display of the sign-in page
  if (networkLossTimeoutInterval_ <= 0.0 || reachabilityRef_ != NULL) {
    return;
  }

  // create a reachability target from the authorization URL, add our callback,
  // and schedule it on the run loop so we'll be notified if the network drops
  const char* host = [[authorizeURL_ host] UTF8String];
  reachabilityRef_ = SCNetworkReachabilityCreateWithName(kCFAllocatorSystemDefault,
                                                         host);
  if (reachabilityRef_) {
    BOOL isScheduled = NO;
    SCNetworkReachabilityContext ctx = { 0, self, NULL, NULL, NULL };

    if (SCNetworkReachabilitySetCallback(reachabilityRef_,
                                         ReachabilityCallBack, &ctx)) {
      if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef_,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode)) {
        isScheduled = YES;
      }
    }

    if (!isScheduled) {
      CFRelease(reachabilityRef_);
      reachabilityRef_ = NULL;
    }
  }
}

- (void)destroyUnreachabilityTimer {
  [networkLossTimer_ invalidate];
  [networkLossTimer_ autorelease];
  networkLossTimer_ = nil;
}

- (void)reachabilityTarget:(SCNetworkReachabilityRef)reachabilityRef
              changedFlags:(SCNetworkConnectionFlags)flags {
  BOOL isConnected = (flags & kSCNetworkFlagsReachable) != 0
    && (flags & kSCNetworkFlagsConnectionRequired) == 0;

  if (isConnected) {
    // server is again reachable
    [self destroyUnreachabilityTimer];

    if (hasNotifiedNetworkLoss_) {
      // tell the user that the network has been found
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      [nc postNotificationName:kGTMOAuthNetworkFound
                        object:self
                      userInfo:nil];
      hasNotifiedNetworkLoss_ = NO;
    }
  } else {
    // the server has become unreachable; start the timer, if necessary
    if (networkLossTimer_ == nil
        && networkLossTimeoutInterval_ > 0
        && !hasNotifiedNetworkLoss_) {
      SEL sel = @selector(reachabilityTimerFired:);
      networkLossTimer_ = [[NSTimer scheduledTimerWithTimeInterval:networkLossTimeoutInterval_
                                                            target:self
                                                          selector:sel
                                                          userInfo:nil
                                                           repeats:NO] retain];
    }
  }
}

- (void)reachabilityTimerFired:(NSTimer *)timer {
  // the user may call [[notification object] cancelSigningIn] to
  // dismiss the sign-in
  if (!hasNotifiedNetworkLoss_) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kGTMOAuthNetworkLost
                      object:self
                    userInfo:nil];
    hasNotifiedNetworkLoss_ = YES;
  }

  [self destroyUnreachabilityTimer];
}

- (void)stopReachabilityCheck {
  [self destroyUnreachabilityTimer];

  if (reachabilityRef_) {
    SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef_,
                                               CFRunLoopGetCurrent(),
                                               kCFRunLoopDefaultMode);
    SCNetworkReachabilitySetCallback(reachabilityRef_, NULL, NULL);

    CFRelease(reachabilityRef_);
    reachabilityRef_ = NULL;
  }
}

#pragma mark Token Revocation

#if !GTM_OAUTH_SKIP_GOOGLE_SUPPORT
+ (void)revokeTokenForGoogleAuthentication:(GTMOAuthAuthentication *)auth {
  // we can revoke Google tokens with the old AuthSub API,
  // http://code.google.com/apis/accounts/docs/AuthSub.html
  if ([auth canAuthorize]
      && [[auth serviceProvider] isEqual:kGTMOAuthServiceProviderGoogle]) {

    NSURL *url = [NSURL URLWithString:@"https://www.google.com/accounts/accounts/AuthSubRevokeToken"];

    // create a signed revocation request for this authentication object
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [auth addResourceTokenHeaderToRequest:request];

    // remove the no-longer-usable token from the authentication object
    [auth setHasAccessToken:NO];
    [auth setToken:nil];

    // we'll issue the request asynchronously, and there's nothing to be done if
    // revocation succeeds or fails
    [NSURLConnection connectionWithRequest:request
                                  delegate:nil];
  }
}
#endif

#pragma mark Accessors

- (GTMHTTPFetcher *)pendingFetcher {
  return pendingFetcher_;
}



- (void)setPendingFetcher:(GTMHTTPFetcher *)fetcher
                fetchType:(NSString *)fetchType {
  // send notification of the end of the pending fetcher
  //
  // we always expect either fetcher or pendingFetcher_ to be nil when
  // this is called
  BOOL isStopping = (fetcher != pendingFetcher_);
  if (isStopping) {
    NSString *oldType = [pendingFetcher_ propertyForKey:kGTMOAuthFetchTypeKey];
    if (oldType) {
      [self notifyFetchIsRunning:NO
                            type:oldType];
    }
  }

  BOOL isStarting = (fetcher != nil);
  if (isStarting) {
    [self notifyFetchIsRunning:YES
                          type:fetchType];
    [fetcher setProperty:fetchType
                  forKey:kGTMOAuthFetchTypeKey];
  }

  [pendingFetcher_ autorelease];
  pendingFetcher_ = [fetcher retain];
}

@end
