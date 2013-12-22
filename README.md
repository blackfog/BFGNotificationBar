# Purpose
``BFGNotificationBar`` is a common drop-down notification library used in a number of my own projects. It has a number of color themes, has many customizable options (including gesture support), uses iOS 7 dynamics, supports both iPhone and iPad, supports both landscape and portrait orientation, and manages multiple successive notification bars in a queue.

# Overview
Notification bars are managed through the ``BFGNotificationBarManager`` singleton. This manages the notification queue. To use it, you create a ``BFGNotificationBar`` object and then add the notification bar to the manager and it does the rest of the work setting up the bar and managing its display. An example:

`````objective-c
BFGNotificationBar *bar = [BFGNotificationBar alloc] init];

bar.backgroundImage = [BFGNotificationBar backgroundImageForTheme:BFGNotificationBarThemeRed];
bar.message = [error localizedDescription];
bar.gesturesEnabled = YES;
bar.dismissAfterInterval = 6.0f;
bar.targetView = self.view;

[[BFGNotificationBarManager sharedManager] addNotificationBar:bar];
`````

# Requirements
``BFGNotificationBar`` requires iOS 7.

# Installation
Copy the contents of the project to your project. You only need the classes; import the images in ``backgrounds/`` if you want to use the built-in "themes."

# Known Issues

* The ``notificationImage`` property is not yet implemented.

# License
``BFGNotificationBar`` is licensed under the MIT License. While you are under no obligation to attribute the use of the library in your application, attribution is appreciated.

# Contact
If you run into any issues, find me on Twitter under [@blackfog](https://twitter.com/blackfog) or [@blackfoggames](https://twitter.com/blackfoggames). You can also email me at craig at blackfoggames dot com.