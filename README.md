
<p align="center">
    <img height="80" src="Source/icon2.png"/>
    <br>
    <br>
    <a href="http://swift.org">
        <img src="https://img.shields.io/badge/Swift-4.1-brightgreen.svg" alt="Swift Version">
    </a>
    <a href="http://vapor.codes">
        <img src="https://img.shields.io/badge/Vapor-3-F6CBCA.svg" alt="Vapor Version">
    </a>
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="GitHub license">
    </a>
</p>

[中文文档🇨🇳](README_CN.md)

This is a Swift server open source project based on the [Swift 4.1](https://swift.org) and [Vapor 3](http://vapor.codes) frameworks.

Because of apple’s release of the cool event-driven non-blocking network framework [SwiftNIO](https://github.com/apple/swift-nio), Vapor 3 introduced it at a blazing pace, leading to Vapor2 and Vapor3. The grammar is very different. For me personally, it looks like the difference between Swift 2 -> Swift 3 is awkward. So I used Vapor 3 to rewrite part of the interface and open it for reference and communication with interested partners.
Currently listed in the document [API](Source/API.md) has been deployed in a formal environment application, and will continue to be perfected as needed.

##### Projects are deployed at [http://api.jinxiansen.com](http://api.jinxiansen.com)

## View
[User Related](Source/API.md/#user)

- [x] [Registration](Source/API.md/#注册)
- [x] [Login](Source/API.md/#登录)
- [x] [Change password](Source/API.md/#修改密码)
- [x] [Get user info](Source/API.md/#获取用户信息)
- [x] [Modify user info](Source/API.md/#修改用户信息)
- [x] [Logout](Source/API.md/#退出登录)

[Dynamically Related](Source/API.md/#动态)

- [x] [Posting news](Source/API.md/#发布动态)
- [x] [Get all dynamic list](Source/API.md/#获取全部动态列表)
- [x] [Get my dynamic list](Source/API.md/#获取我的动态列表)
- [x] [Get dynamic image](Source/API.md/#获取动态图片)
- [x] [Report](Source/API.md/#举报)

[Dictionary Query](Source/API.md/字典)

- [x] [Chinese query](Source/API.md/#汉字查询)
- [x] [Idiom query](Source/API.md/#成语查询)
- [x] [Check post query](Source/API.md/#歇后语查询)

[About Crawler](Source/API.md/#爬虫)

- [x] [Crawler iOS](Source/API.md/#拉勾iOS)
- [x] [Get iOS crawler results](Source/API.md/#获取iOS爬取结果)
- [x] [Crawler example](Source/API.md/#爬虫示例)
- [x] [Custom crawler](Source/API.md/#自定义爬虫)


[Others](Source/API.md/#发送邮件)

- [x] [Send mail](Source/API.md/#发送邮件)
- [x] [Web deployment](Source/API.md/#网页)
- [x] [Custom 404 middleware](Source/VaporUsage.md/#自定义404)
- [x] [Custom access frequency middleware](Source/VaporUsage.md/#自定义访问频率)
- [ ] ...


##### [View👈](Source/API.md) Currently completed API sample documentation and debugging.

##### [View ✍️](Source/VaporUsage.md) Some basic usages of Vapor.


**Other:** Here are a few examples of Vapor deployed H5 pages that you can click to see the effect.
[Keyboard](http://api.jinxiansen.com/h5/keyboard)
[Line](http://api.jinxiansen.com/h5/line)
[Color](http://api.jinxiansen.com/h5/color)
[Reboot](http://api.jinxiansen.com/h5/reboot)
[Loader](http://api.jinxiansen.com/h5/loader)
[Login](http://api.jinxiansen.com/h5/login)


## Usage

**Pre-work before running the project:**

Click on [Clone or download](https://github.com/Jinxiansen/SwiftServerSide-Vapor/archive/master.zip) to download the project.

* On **macOS**, you need to install Xcode、 Vapor 3、 MySQL

> [Vapor for macOS Installation](https://docs.vapor.codes/3.0/install/macos/)

> [MySQL for macOS Installation](https://segmentfault.com/a/1190000007838188)

* On **Linux**, you need to install Swift 4.1、 Vapor 3、 MySQL

> [Swift for ubuntu Installation](https://swift.org/download/#releases)

> [Vapor for ubuntu Installation](https://docs.vapor.codes/3.0/install/ubuntu/)

> [MySQL for ubuntu installation](http://prog3.com/sbdm/blog/vXueYing/article/details/52330180)

After Vapor and MySQL are installed,
you need to enter MySQL as root on the terminal, execute the following command:

> Create a database in Debug mode:
`create database vaporDebugDB character set utf8mb4;`

> Create a database in Release mode:
`create database vaporDB character set utf8mb4;`

> Create a database login user for the project:
`grant all privileges on *.* to sqluser@"%" identified by "qwer1234" with grant option;`

Ok, now open the terminal and execute in order:

1. `cd VaporServer`
2. Execute `vapor build && vapor run`, then please wait patiently
3. When you see **Server starting on http: //localhost:8080**, it is already running successfully
4. You can now [View](Source/API.md) the currently completed API sample documentation and debug

> Tip: You can generate and debug Xcode projects using `vapor xcode -y` on macOS



## Feedback ![](Source/zz.jpg)

If you have any questions or suggestions, you can submit a [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues) ,or contact me: 

Email : [@JinXiansen](hi@jinxiansen.com)

## License 📄


SwiftServerSide-Vapor is released under the [MIT license](LICENSE). See LICENSE for details.
