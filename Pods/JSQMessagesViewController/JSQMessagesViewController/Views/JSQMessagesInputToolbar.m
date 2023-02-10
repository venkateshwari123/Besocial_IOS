//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesInputToolbar.h"

#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UIView+JSQMessages.h"

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;


@interface JSQMessagesInputToolbar ()

@property (assign, nonatomic) BOOL jsq_isObserving;

@end



@implementation JSQMessagesInputToolbar

@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.jsq_isObserving = NO;
    self.sendButtonLocation = JSQMessagesInputSendButtonLocationRight;
    self.enablesSendButtonAutomatically = YES;

    self.preferredDefaultHeight = 44.0f;
    self.maximumHeight = NSNotFound;

    JSQMessagesToolbarContentView *toolbarContentView = [self loadToolbarContentView];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;

    [self jsq_addObservers];

    JSQMessagesToolbarButtonFactory *toolbarButtonFactory = [[JSQMessagesToolbarButtonFactory alloc] initWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    self.contentView.leftBarButtonItem = [toolbarButtonFactory defaultAccessoryButtonItem];
    self.contentView.rightBarButtonItem = [toolbarButtonFactory defaultSendButtonItem];

    [self updateSendButtonEnabledState];
    self.contentView.rightBarButtonItem.enabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:_contentView.textView];
}

/*
 Bug Name:- change chat send button UI
 Fix Date:- 10/05/21
 Fix By  :- Jayaram G
 Description of Fix:- required refactor for send button
 */
-(void) didMoveToWindow{
    [super didMoveToWindow];
    
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        
        if (@available(iOS 11.0, *) && ((int)[[UIScreen mainScreen] nativeBounds].size.height) == 2436) {
            
            UILayoutGuide *layoutGuide = self.window.safeAreaLayoutGuide;
            if (layoutGuide != nil){
                [[self bottomAnchor] constraintLessThanOrEqualToSystemSpacingBelowAnchor:layoutGuide.bottomAnchor multiplier:1.0].active = YES;
            }
        }
        
    }
}


- (JSQMessagesToolbarContentView *)loadToolbarContentView
{
    NSArray *nibViews = [[NSBundle bundleForClass:[JSQMessagesInputToolbar class]] loadNibNamed:NSStringFromClass([JSQMessagesToolbarContentView class])
                                                                                          owner:nil
                                                                                        options:nil];
    return nibViews.firstObject;
}

- (void)dealloc
{
    [self jsq_removeObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight
{
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

- (void)setEnablesSendButtonAutomatically:(BOOL)enablesSendButtonAutomatically
{
    _enablesSendButtonAutomatically = enablesSendButtonAutomatically;
    [self updateSendButtonEnabledState];
}

#pragma mark - Actions

- (void)jsq_leftBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)jsq_rightBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)updateSendButtonEnabledState
{
    
    BOOL enabled = [self.contentView.textView hasText];
    switch (self.sendButtonLocation) {
            case JSQMessagesInputSendButtonLocationRight:
            self.contentView.rightBarButtonItem.enabled = enabled;
            if (self.contentView.textView.text.length > 0){
                self.contentView.rightBarButtonItem.hidden = false;
                UIImage *sendImage = [UIImage jsq_sendImage];
                [self.contentView.rightBarButtonItem setImage:sendImage forState:UIControlStateNormal];}
            else{
                self.contentView.rightBarButtonItem.hidden = true;
//                UIImage *voiceImage = [UIImage jsq_voiceImage];
//                [self.contentView.rightBarButtonItem setImage:voiceImage forState:UIControlStateNormal];
            }
            case JSQMessagesInputSendButtonLocationLeft:
            self.contentView.leftBarButtonItem.enabled = enabled;
            break;
        default:
            break;
    }
    
    self.contentView.rightBarButtonItem.enabled = YES;
    self.contentView.leftBarButtonItem.enabled = YES;
}

#pragma mark - Notifications

- (void)textViewTextDidChangeNotification:(NSNotification *)notification
{
    [self updateSendButtonEnabledState];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {

            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {

                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {

                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(jsq_rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }

            [self updateSendButtonEnabledState];
        }
    }
}

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }

    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];

        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    _jsq_isObserving = NO;
}

@end
