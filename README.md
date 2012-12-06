# TUSafariActivity

`TUSafariActivity` is a `UIActivity` subclass that provides an "Open In Safari" action to a `UIActivityViewController`.

![TUSafariActivity screenshot](http://f.cl.ly/items/1M0O380i110g3K1F3f2m/Screenshot%202012.11.30%2015.02.16.png "TUSafariActivity screenshot")

## Requirements

- As `UIActivity` is iOS 6 only, so is the subclass.
- This project doesn't use ARC. If you want an ARC version check out https://github.com/davbeck/TUSafariActivity, the original fork.

## Installation

Add the `TUSafariActivity` subfolder to your project. There are no required libraries other than `UIKit`.

## Usage

*(See example Xcode project)*

Simply `alloc`/`init` an instance of `TUSafariActivity` and pass that object into the applicationActivities array when creating a `UIActivityViewController`.

```objectivec
NSURL *URL = [NSURL URLWithString:@"http://google.com"];
TUSafariActivity *activity = [[TUSafariActivity new] autorelease];
UIActivityViewController *activityViewController =
	[[[UIActivityViewController alloc] initWithActivityItems:@[URL]
	applicationActivities:@[activity]] autorelease];
```

Note that you can include the activity in any `UIActivityViewController` and it will only be shown to the user if there is a URL in the activity items.
