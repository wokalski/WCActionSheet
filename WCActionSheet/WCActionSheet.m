//
//  WCActionSheet.m
//  WCActionSheet
//
//  Created by Wojciech Czekalski on 27.02.2014.
//  Copyright (c) 2014 Wojciech Czekalski. All rights reserved.
//

#import "WCActionSheet.h"
#import "UIImage+ImageEffects.h"

#define kButtonHeight 50.f
#define kCancelButtonHeight 60.f

#define kAnimationDuration 0.2f

#define kSeparatorWidth .5f

#define kMargin 10.f
#define kBottomMargin 10.f

@interface WCActionSheet ()
@property (nonatomic, readonly) CGSize screenSize;

@property (nonatomic, strong, readonly) NSMutableArray *buttonTitles;

@property (nonatomic, strong, readonly) NSMutableArray *buttons;

@property (nonatomic, strong, readonly) NSMutableDictionary *buttonTitleAttributes;

@property (nonatomic, strong) UIButton *destructiveButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIImageView *blurView;

@property (nonatomic, strong, readonly) NSArray *separators;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) NSMutableDictionary *actionBlockForButtonIndex;

- (void)setCancelButtonWithTitle:(NSString *)title;
- (void)setDestructiveButtonWithTitle:(NSString *)title;

- (void)loadBlurViewContents;

- (void)dismissWithClickedButton:(UIButton *)button;

- (void)dismissWithCancelButton:(UIButton *)cancelButton;

- (void)dismissAnimated:(BOOL)animated clickedButtonIndex:(NSInteger)index;

- (void)removeObserversInButtonsForKeyPath:(NSString *)keypath;

- (void)dismissTransition;
- (void)dismissCompletionWithButtonAtIndex:(NSInteger)index;

- (NSInteger)indexOfButton:(UIButton *)button;

@end

static UIWindow *__sheetWindow = nil;

@implementation WCActionSheet {
    UIColor *__backgroundColor;
}

@synthesize buttonTitles = _buttonTitles;
@synthesize buttons = _buttons;
@synthesize buttonTitleAttributes = _buttonTitleAttributes;

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        [self __commonInit];
        
        [self setCancelButtonWithTitle:@"Cancel"];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        ;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<WCActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles,... {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self __commonInit];
        
        _delegate = delegate;
        [self setCancelButtonWithTitle:cancelButtonTitle];
        [self setDestructiveButtonWithTitle:destructiveButtonTitle];
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *title = otherButtonTitles; title != nil; title = va_arg(args, NSString*))
        {
            [self addButtonWithTitle:title];
        }
        va_end(args);
    }
    return self;
}

- (void)__commonInit {
    _blurRadius = 4.f;
    _blurView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.screenSize.width, self.screenSize.height)];
    
    _blurView.alpha = 0.f;
    
    self.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.95f];
    _highlightedButtonColor = [UIColor colorWithWhite:0.93f alpha:1.f];
    _separatorColor = [UIColor colorWithWhite:0.8 alpha:1.f];
    
    self.layer.cornerRadius = 8.f;
    self.clipsToBounds = YES;
}

#pragma mark -

- (NSInteger)addButtonWithTitle:(NSString *)title {
    if (!title) {
        [self.buttonTitles addObject:@""];
    } else [self.buttonTitles addObject:title];
    
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeSystem];
    newButton.titleLabel.font = [UIFont systemFontOfSize:19.f];
    [newButton setFrame:CGRectMake(0, 0, self.screenSize.width, kButtonHeight)];
    [newButton setTitle:title forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(dismissWithClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    NSUInteger index = [self.buttons count];
    
    [self addSubview:newButton];
    [self.buttons addObject:newButton];
    
    return index;
    
}

- (NSInteger)addButtonWithTitle:(NSString *)title actionBlock:(void (^)())actionBlock {
    NSInteger index = [self addButtonWithTitle:title];
    [self.actionBlockForButtonIndex setObject:actionBlock forKey:[NSNumber numberWithInteger:index]];
    return index;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == self.cancelButtonIndex) {
        return [self.cancelButton titleForState:UIControlStateNormal];
    }
    return self.buttonTitles[buttonIndex];
}

#pragma mark -

- (void)setDestructiveButtonWithTitle:(NSString *)title {
    if (title) {
        UIButton *newDestructiveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        newDestructiveButton.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
        [newDestructiveButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [newDestructiveButton setFrame:CGRectMake(0, 0, self.screenSize.width, kButtonHeight)];
        [newDestructiveButton setTitle:title forState:UIControlStateNormal];
        [newDestructiveButton addTarget:self action:@selector(dismissWithClickedButton:) forControlEvents:UIControlEventTouchUpInside];
        self.destructiveButton = newDestructiveButton;
        
        [self addSubview:newDestructiveButton];
        [self.buttons insertObject:newDestructiveButton atIndex:0];
        [self.buttonTitles insertObject:title atIndex:0];
    }
}

- (void)setCancelButtonWithTitle:(NSString *)title {
    if (self.cancelButton) {
        [self.cancelButton removeFromSuperview];
        self.cancelButton = nil;
    }
    if (title) {
        UIButton *newCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        newCancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
        [newCancelButton setFrame:CGRectMake(0, 0, self.screenSize.width, kCancelButtonHeight)];
        [newCancelButton setTitle:title forState:UIControlStateNormal];
        [newCancelButton addTarget:self action:@selector(dismissWithCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton = newCancelButton;

        [self addSubview:newCancelButton];
    }
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    // calculate frames here
    
    CGSize screenSize = self.screenSize;
    
    CGFloat contentWidth = screenSize.width - (2*kMargin);
    
    CGFloat sheetHeight = ([self.buttons count] * kButtonHeight) + kCancelButtonHeight;
    
    CGFloat contentOffset = screenSize.height - sheetHeight  - kBottomMargin;
    
    self.frame = CGRectMake(kMargin, contentOffset, contentWidth, sheetHeight);
    
    contentOffset = 0.f;
    
    for (UIButton *button in self.buttons) {
        button.frame = CGRectMake(0.f, contentOffset, contentWidth, kButtonHeight);
        contentOffset += kButtonHeight;
    }
    
    if (self.cancelButton) {
        self.cancelButton.frame = CGRectMake(0.f, contentOffset, contentWidth, kCancelButtonHeight);
        contentOffset += kCancelButtonHeight;
    }
}

- (void)loadBlurViewContents {
    UIGraphicsBeginImageContextWithOptions(self.blurView.frame.size, NO, 0);
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow drawViewHierarchyInRect:self.blurView.frame afterScreenUpdates:NO];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurredImage = [newImage applyBlurWithRadius:self.blurRadius tintColor:self.blurTintColor saturationDeltaFactor:1.f maskImage:nil];
    
    self.blurView.image = blurredImage;
}

#pragma mark - Show

- (void)show {
    UIWindow *window = [[UIWindow alloc] initWithFrame:(CGRect) {{0.f, 0.f}, self.screenSize}];
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelNormal;
    window.alpha = 1.f;
    [self layoutIfNeeded];
    [window addSubview:self.blurView];
    
    for (UIView *separator in self.separators) {
        [self addSubview:separator];
    }
    
    [window addSubview:self];
    [self loadBlurViewContents];
	
    [window makeKeyAndVisible];
    
    self.frame = CGRectOffset(self.frame, 0.f, self.frame.size.height+kMargin);

    if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:self];
    }

    [UIView animateWithDuration:kAnimationDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.blurView.alpha = 1.f;
        self.frame = CGRectOffset(self.frame, 0.f, -(self.frame.size.height+kMargin));
    } completion:^(BOOL finished) {
        [self addObserversInButtonsForKeyPath:@"highlighted"];
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
    }];
    
    __sheetWindow = window;
}

#pragma mark - Dismissal

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [self dismissAnimated:animated clickedButtonIndex:buttonIndex];
}

- (void)dismissWithClickedButton:(UIButton *)button {
    NSInteger buttonIndex = [self indexOfButton:button];
    
    void (^actionBlockForButton)() = [self.actionBlockForButtonIndex objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    
    if (actionBlockForButton) {
        actionBlockForButton();
    } else if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
    }
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

- (void)dismissWithCancelButton:(UIButton *)cancelButton {
    if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.delegate actionSheetCancel:self];
    } else if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:self.cancelButtonIndex];
    }
    [self dismissAnimated:YES clickedButtonIndex:self.cancelButtonIndex];
}

- (void)dismissAnimated:(BOOL)animated clickedButtonIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self willDismissWithButtonIndex:index];
    }
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self dismissTransition];
        } completion:^(BOOL finished) {
            [self dismissCompletionWithButtonAtIndex:index];
        }];
    } else {
        [self dismissCompletionWithButtonAtIndex:index];
    }
}

- (void)dismissTransition {
    self.blurView.alpha = 0.f;
    self.frame = CGRectOffset(self.frame, 0.f, self.frame.size.height + kBottomMargin);
}

- (void)dismissCompletionWithButtonAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self didDismissWithButtonIndex:index];
    }
    __sheetWindow.hidden = YES;
    [self removeObserversInButtonsForKeyPath:@"highlighted"];
    __sheetWindow = nil;
}

#pragma mark - KVO

- (void)addObserversInButtonsForKeyPath:(NSString *)keypath {
    [self.cancelButton addObserver:self forKeyPath:keypath options:0 context:NULL];
    for (UIButton *button in self.buttons) {
        [button addObserver:self forKeyPath:keypath options:0 context:NULL];
    }
    [self.destructiveButton addObserver:self forKeyPath:keypath options:0 context:NULL];
}

- (void)removeObserversInButtonsForKeyPath:(NSString *)keypath {
    [self.cancelButton removeObserver:self forKeyPath:keypath];
    for (UIButton *button in self.buttons) {
        [button removeObserver:self forKeyPath:keypath];
    }
    [self.destructiveButton removeObserver:self forKeyPath:keypath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UIButton *button = object;
    if ([button isKindOfClass:[UIButton class]]) {
        [UIView animateWithDuration:0.2f animations:^{
            if (button.isHighlighted) {
                button.backgroundColor = self.highlightedButtonColor;
            } else button.backgroundColor = [UIColor clearColor];
        }];
    }
}

#pragma mark - Appearance

- (void)setDestructiveButtonTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [UIView performWithoutAnimation:^{
        NSAttributedString *attributedTitleForState = [[NSAttributedString alloc] initWithString:[self.destructiveButton titleForState:state] attributes:attributes];
        [self.destructiveButton setAttributedTitle:attributedTitleForState forState:state];
    }];
}

- (NSDictionary *)destructiveButtonTextAttributesForState:(UIControlState)state {
    return [[self.destructiveButton attributedTitleForState:state] attributesAtIndex:0 effectiveRange:0];
}

- (void)setCancelButtonTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [UIView performWithoutAnimation:^{
        NSAttributedString *attributedTitleForState = [[NSAttributedString alloc] initWithString:[self.cancelButton titleForState:state] attributes:attributes];
        [self.cancelButton setAttributedTitle:attributedTitleForState forState:state];
    }];
}

- (NSDictionary *)cancelButtonTextAttributesForState:(UIControlState)state {
    return [[self.cancelButton attributedTitleForState:state] attributesAtIndex:0 effectiveRange:0];
}

- (void)setButtonTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    [UIView performWithoutAnimation:^{
        [self.buttonTitleAttributes setObject:attributes forKey:[NSNumber numberWithInt:state]];
        for (UIButton *button in self.buttons) {
            NSAttributedString *attributedTitleForState = [[NSAttributedString alloc] initWithString:[button titleForState:state] attributes:attributes];
            [button setAttributedTitle:attributedTitleForState forState:state];
        }
    }];
}

- (NSDictionary *)buttonTextAttributesForState:(UIControlState)state {
    return [self.buttonTitleAttributes objectForKey:[NSNumber numberWithInt:state]];
}

#pragma mark - Getters

- (NSInteger)indexOfButton:(UIButton *)button {
    if (button == self.cancelButton) {
        return [self cancelButtonIndex];
    }
    return [self.buttons indexOfObject:button];
}

- (NSInteger)destructiveButtonIndex {
    return self.destructiveButton ? 0 : NSNotFound;
}

- (NSInteger)cancelButtonIndex {
    return [self.buttons count];
}

- (NSMutableDictionary *)actionBlockForButtonIndex {
    if (!_actionBlockForButtonIndex) {
        _actionBlockForButtonIndex = [NSMutableDictionary dictionary];
    }
    return _actionBlockForButtonIndex;
}
- (NSMutableDictionary *)buttonTitleAttributes {
    if (!_buttonTitleAttributes) {
        _buttonTitleAttributes = [@{@(UIControlStateNormal): @{}, @(UIControlStateHighlighted): @{}, @(UIControlStateDisabled): @{}, @(UIControlStateSelected): @{}, @(UIControlStateApplication): @{}, @(UIControlStateReserved): @{}} mutableCopy];
    }
    return _buttonTitleAttributes;
}

- (NSInteger)numberOfButtons {
    return [self.buttons count] + 1; //Add cancel button to the count.
}

- (NSArray *)separators {
    NSInteger buttonCount = self.buttons.count;
    NSMutableArray *mutableSeparators = [NSMutableArray arrayWithCapacity:buttonCount];
    
    CGFloat contentOffset = kButtonHeight - kSeparatorWidth;
    for (int i = 0; i < buttonCount; i++) {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, contentOffset, self.frame.size.width, kSeparatorWidth)];
        separator.backgroundColor = self.separatorColor;
        contentOffset += kButtonHeight;
        [mutableSeparators addObject:separator];
    }
    
    return [mutableSeparators copy];
}

- (CGSize)screenSize {
    return [[UIScreen mainScreen] bounds].size;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        return [UIColor clearColor];
    }
    return _separatorColor;
}

- (BOOL)isVisible {
    return [self window] ? YES : NO;
}

- (NSMutableArray *)buttonTitles {
    if (!_buttonTitles) {
        _buttonTitles = [NSMutableArray array];
    }
    return _buttonTitles;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
