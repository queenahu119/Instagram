# Instagram

Clone Instagram app with Parse Server

## features

* Practice MVVM in Swift
* Use Parse Server on AWS
* Auto layout programmatically
* Using fake data to create a test environment
* Implement some function of Instagram
	- Login/Signup
	- Follow/Unfollow user
	- Post new photo from Library/Camera
	- See the following's post
	- Write post's comment

## Getting Started


### CocoaPods


Install the pods and open the .xcworkspace file to see the project in Xcode.

```
$ cd project-name
$ pod install
$ open project-name.xcworkspace
```

### Setting Parse Server on AWS 

[Using Parse SDKs with Parse Server](http://docs.parseplatform.org/parse-server/guide/#using-parse-sdks-with-parse-server)

1.Create the **Constants** folder

2.Create new Constants.swift file

```
struct PARSE_CLIENT {
    static let APP_ID = "YOUR_APP_ID"
    static let MASTER_KEY = ""
    static let SERVER = "http://localhost:1337/parse"
}
```

### Using the fake data
1.Change to **InstagramStub** target and Edit Scheme

2.Select arguments variables **USE\_STUB\_API**


## Runtime Requirements

 * XCode 9.2
 * Swift 4.1
