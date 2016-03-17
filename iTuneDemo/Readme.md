# iTune Demo

iTunes Demo is an iOS app in which you can see top 20 [Free iTunes App], offline-storage for apps as well you can block apps to block in future list .
It consist following app screens:

  - App list Screen
  - App Grid Screen
  - App Detail Screen

> This app is developed as test demo app for [Momentous Technologies Corp].
> In this demo I learn newly how to create custom app setting in default Setting
> App. Also I learn how to create Readme file.

You can also share these free apps on [Facebook] or [Twitter].

### Version
1.0

### Tech

  This project developed in [Objective-C] 2.0 programming language.
[Objective-C] is the primary programming language you use when writing software for OS X and iOS. It’s a superset of the C programming language and provides object-oriented capabilities and a dynamic runtime. Objective-C inherits the syntax, primitive types, and flow control statements of C and adds syntax for defining classes and methods.

 * [iTunes RSS Generator] - webservice to get free app list.
 * [Core Data] - to manipulate with data in offline data
 * [Singleton] - Used singleton design pattern for Service and Database Manager
 * [Category] - Created category for asynchronously download images from url.
 * [Protocol] - Created custom protocol to update list / Grid Screen.
 * [UIRefreshControl] - Used to pull and refresh app list.
 * [Social Framework] - Implemented social share using [SLComposeViewController] class.
 * [Prefix header] - Added prefix header Constant.pch file which holds macros as well as import required files to compiler
 * [Nullability] - Implemented nullability in code.

### Todos

 - Write Tests
 - Rethink Github Save
 - Add Code Comments

**Free Software**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [Objective-C]: <https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html>
   [Free iTunes App]: <http://www.apple.com/in/itunes/charts/free-apps/>
   [Momentous Technologies Corp]: <http://www.momentoustech.com/index.html>
   [Facebook]: <https://www.facebook.com/>
   [Twitter]: <https://twitter.com/>
   [iTunes RSS Generator]: <https://rss.itunes.apple.com/us/?urlDesc=>
   [Core Data]: <https://developer.apple.com/library/watchos/documentation/Cocoa/Conceptual/CoreData/index.html>
   [Singleton]: <http://www.oodesign.com/singleton-pattern.html>
   [Category]: <https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/Category.html>
   [Protocol]: <https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html>
   [Social Framework]: <https://developer.apple.com/library/ios/documentation/NetworkingInternet/Reference/SLComposeViewController_Class/index.html#//apple_ref/occ/cl/SLComposeViewController>
   [SLComposeViewController]: <https://developer.apple.com/library/ios/documentation/Social/Reference/Social_Framework/index.html#//apple_ref/doc/uid/TP40012233>
   [UIRefreshControl]:<https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIRefreshControl_class/>
   [Prefix header]: <http://useyourloaf.com/blog/modules-and-precompiled-headers/>
   [Nullability]: <https://developer.apple.com/swift/blog/?id=25>

