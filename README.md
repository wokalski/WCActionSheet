WCActionSheet
=============

#####UIActionSheet is great... unless you don't use Helvetica in your app :).

I created this small alternative to UIActionSheet because I needed further customization and a bit different look.

![WCActionSheet](/Action_sheet_mov.gif)

#### How to use it

```ruby
#Cocoapods
pod 'WCActionSheet'

#Of course you can also download the source and copy the WCActionSheet.* and UIImage+ImageEffect.* files.
```

I made the API as similar to UIActionSheet as possible.

#####In order to initialize the WCActionSheet you can use one of following methods:

```objc

// With this initializer, you are responsible for adding buttons. Standard cancel button is added for you.

WCActionSheet *actionSheet = [[WCActionSheet alloc] init];

// Equivalent to -init. Frame argument is not taken into consideration

WCActionSheet *actionSheet = [[WCActionSheet alloc] initWithFrame:aframe];

// Designed initializer. Similar to UIActionSheet's one.

WCActionSheet *actionSheet = [[WCActionSheet alloc] initWithFrame:initWithDelegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Button !", @"Button 2", nil];

```

#####Adding buttons

```objc

// Adding buttons with action block. This won't fire delegate call -actionSheet:clickedButtonAtIndex

[actionSheet addButtonWithTitle:@"Hi!" actionBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hi!" message:@"My name is Wojtek and I made it" delegate:nil cancelButtonTitle:@"okay" otherButtonTitles: nil];
        [alert show];
    }];
    
// Adding buttons without action block. (This one, when tapped, will fire delegate call.

[actionSheet addButtonWithTitle:@"Bye"];

```

#####Show a WCActionSheet

```objc

// Showing WCActionSheet is as simple as:

[actionSheet show];

```

#####Delegate protocol

```objc
@protocol WCActionSheetDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(WCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(WCActionSheet *)actionSheet;

- (void)willPresentActionSheet:(WCActionSheet *)actionSheet;  // before animation and showing view
- (void)didPresentActionSheet:(WCActionSheet *)actionSheet;  // after animation

- (void)actionSheet:(WCActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)actionSheet:(WCActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end
```

#####Customizing appearance

```objc
// You may use UIAppearance proxy in order to set following properties. (You can also set the properties directly)

@property(nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor *blurTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor *highlightedButtonColor UI_APPEARANCE_SELECTOR;

- (NSDictionary *)buttonTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setButtonTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)cancelButtonTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setCancelButtonTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)destructiveButtonTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setDestructiveButtonTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
```

####License

WCActionSheet is licensed under MIT license.

####Author

You can find me on [twitter @wczekalski](https://twitter.com/wczekalski) or [mail me](mailto:me@wczekalski.com) if you are feeling friendly

