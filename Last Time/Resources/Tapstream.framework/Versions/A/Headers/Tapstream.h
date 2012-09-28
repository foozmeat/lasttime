//
//  Tapstream.h
//  TapstreamSDK
//
//  Created by Benjamin Fox on 12-03-08.
//  Copyright (c) 2012 Paperlabs Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void(^TapstreamLoggingDelegate)(NSString*);
typedef void(^TapstreamHitCompletionHandler)(NSHTTPURLResponse *, NSError *);

// The main class used to interact with TapStream.
@interface Tapstream : NSObject {
@private
	NSString *accountName;
	NSString *secret;
	NSMutableSet *blacklist;
	NSMutableSet *blacklistTemp;
	NSString *postData;
	TapstreamLoggingDelegate logger;
	uint _nextUid;
	int _retryDelay;
	uint _failingJob;
}

+ (id)shared;

// The first method that should be called - sets up your account information.
// This method *must* be called before using any other TapStream methods.
- (void)setAccountName:(NSString *)name developerSecret:(NSString *)secret;

// Fires an event with the given name.  This is just shorthand for [Tapstream fireEvent:name oneTimeOnly:NO]
- (void)fireEvent:(NSString *)eventName;
- (void)fireEvent:(NSString *)eventName withArgs:(NSDictionary *)args;

// Fires an event with the given name.  If oneTimeOnly is YES, the sdk will ensure that the
// specified event name is sent to the server only once.  After a successful oneTimeOnly event
// is fired, subsequent attempts to send the same event as one time only will be No-ops.
- (void)fireEvent:(NSString *)eventName oneTimeOnly:(BOOL)once;
- (void)fireEvent:(NSString *)eventName withArgs:(NSDictionary *)args oneTimeOnly:(BOOL)once;

// Fires a hit to the specified hit tracker with an optional list of hit tracker tags
- (void)fireHit:(NSString *)hitTracker withTags:(NSArray *)tags completionHandler:(TapstreamHitCompletionHandler)handler;

// Provide your own logging delegate if you want to log to somewhere special.
// You can also just provide an empty block if you want to silence the logging completely.
- (void)setLoggingDelegate:(TapstreamLoggingDelegate)delegate;

@end

@interface TapstreamEvent : NSObject {
	uint _uid;
	NSString *_name;
	NSTimeInterval _created;
	BOOL _oneTimeOnly;
	NSString *_encodedPost;
}

	@property(nonatomic, assign) uint uid;
	@property(nonatomic, retain) NSString *name;
	@property(nonatomic, assign) NSTimeInterval created;
	@property(nonatomic, assign) BOOL oneTimeOnly;
	@property(nonatomic, retain) NSString *encodedPost;
@end
