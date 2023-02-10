
#import <Foundation/Foundation.h>
#import "WebRTC/WebRTC.h"
//#import "ViewController.h"

@protocol WebSocketDelegateJanus <NSObject>
- (void)onCreatedRoom:(NSNumber *)handleId;
- (void)onPublisherJoined:(NSNumber *)handleId;
- (void)onPublisherRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep;
- (void)subscriberHandleRemoteJsep: (NSNumber *)handleId dict:(NSDictionary *)jsep;
- (void)onLeaving:(NSNumber *)handleId;
@end

@protocol WebSocketDelegateJanus;

typedef NS_ENUM(NSInteger, ARDSignalingChannelState) {
    kARDSignalingChannelStateClosed,
    kARDSignalingChannelStateOpen,
    kARDSignalingChannelStateCreate,
    kARDSignalingChannelStateAttach,
    kARDSignalingChannelStateJoin,
    kARDSignalingChannelStateOffer,
    kARDSignalingChannelStateError
};

@interface WebSocketChannel : NSObject

@property(nonatomic, weak) id<WebSocketDelegateJanus> delegate;

- (instancetype)initWithURL:(NSURL *)url roomId:(NSNumber *)roomId;
- (void)disconnect;

- (void)publisherCreateOffer:(NSNumber *)handleId sdp:(RTCSessionDescription *)sdp;
- (void)subscriberCreateAnswer:(NSNumber *)handleId sdp: (RTCSessionDescription *)sdp;
- (void)trickleCandidate:(NSNumber *)handleId candidate: (RTCIceCandidate *)candidate;
- (void)trickleCandidateComplete:(NSNumber *)handleId;
- (void)onCreatedRoom:(NSNumber *)handleId;
- (void)onPublisherJoined:(NSNumber *)handleId;
- (void)onPublisherRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep;
- (void)subscriberHandleRemoteJsep: (NSNumber *)handleId dict:(NSDictionary *)jsep;
- (void)onLeaving:(NSNumber *)handleId;

@end
