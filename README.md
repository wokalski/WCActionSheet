WCActionSheet
=============

#####UIActionSheet is great... unless you don't use Helvetica in your app :).

I created this small alternative to UIActionSheet because I needed further customization and a bit different look.

![WCActionSheet](/Action_sheet_mov.gif)

#### How to use it

I made the API as similar to UIActionSheet as possible.

In order to initialize the WCActionSheet you can use one of following methods:

```objc

// With this initializer, you are responsible for adding buttons. Standard cancel button is added for you.

WCActionSheet *actionSheet = [[WCActionSheet alloc] init];

// Equivalent to -init. Frame argument is not taken into consideration

WCActionSheet *actionSheet = [[WCActionSheet alloc] initWithFrame:aframe];

// Designed initializer. Similar to UIActionSheet's one.

WCActionSheet *actionSheet = [[WCActionSheet alloc] initWithFrame:initWithDelegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Button !", @"Button 2", nil];

```

Adding buttons

```objc

// Adding buttons with action block. This won't fire delegate call -actionSheet:clickedButtonAtIndex

[actionSheet addButtonWithTitle:@"Hi!" actionBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hi!" message:@"My name is Wojtek and I made it" delegate:nil cancelButtonTitle:@"okay" otherButtonTitles: nil];
        [alert show];
    }];
    
// Adding buttons without action block. (This one, when tapped, will fire delegate call.

[actionSheet addButtonWithTitle:@"Bye"];

```

Show a WCActionSheet

```objc

// Showing WCActionSheet is as simple as:

[actionSheet show];

```

####License

WCActionSheet is licensed under MIT license.

####Author

You can find me on [twitter @wczekalski](https://twitter.com/wczekalski) or [mail me](mailto:me@wczekalski.com) if you are feeling friendly

