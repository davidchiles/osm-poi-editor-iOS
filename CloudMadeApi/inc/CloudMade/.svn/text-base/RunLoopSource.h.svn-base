#import <UIKit/UIKit.h>
#import "GeocoderManager.h"

@interface RunLoopSource : NSObject

{
   CFRunLoopSourceRef runLoopSource;
   NSMutableDictionary* commands;
   id<GeoCoderDelegate> _delegate;
	TokenManager* tokenManager; 	
    id owner;	
}

@property (retain,nonatomic) NSMutableDictionary* commands;
@property (retain,nonatomic) TokenManager* tokenManager;
@property (retain,nonatomic) id owner;


- (id)initWithDelegate:(id) delegate;
- (void) addToRunLoop:(NSRunLoop*) rLoop;
- (void)sourceFired;
- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop;
@end



// These are the CFRunLoopSourceRef callback functions.

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine (void *info);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);

// RunLoopContext is a container object used during registration of the input source.
@interface RunLoopContext : NSObject
{
   CFRunLoopRef        runLoop;
   RunLoopSource*        source;
}
@property (readonly) CFRunLoopRef runLoop;
@property (readonly) RunLoopSource* source;

- (id)initWithSource:(RunLoopSource*)src andLoop:(CFRunLoopRef)loop;
@end