
<p align="center">
    <img height="80" src="Source/icon.png"/>
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

## Brief Description
#### This is a Swift server open source project based on the Swift 4.1 and Vapor 3 framework. The currently listed APIs have been deployed in a formal environment application.

Completed and open APIs are in this column:

The interface is deployed at [http://api.jinxiansen.com](http://api.jinxiansen.com),
You can download [VaporServer](https://github.com/Jinxiansen/SwiftServerSide-Vapor) and run the project to debug, or you can test it at http://api.jinxiansen.com according to the parameter description of the API document.


#### [View](Source/API.md) Currently supported API sample documentation and debugging.

#### [View](Source/VaporUsage.md) Some basic usages of Vapor.

Include:

* [User related interface: including login, registration, password change, logout](Source/API.md/#用户)
* [Dynamic related interface: including sending news, getting all dynamic lists, getting dynamic pictures, getting my published dynamic list, reporting](Source/API.md/#动态)
* [supports the query of Chinese characters, idioms, and proverbs](Source/API.md/#字典)
* [Send Mail](Source/API.md/#邮件)
* [Webpage small example](Source/API.md/#网页)


## Usage

**Pre-work before running the project:**

Click on [Clone or download](https://github.com/Jinxiansen/SwiftServerSide-Vapor/archive/master.zip) to download the project.

* Based on macOS environment, need to install Xcode, Vapor 3, MySQL.

> [Vapor for macOS Installation](https://docs.vapor.codes/3.0/install/macos/)

> [MySQL for macOS Installation](https://segmentfault.com/a/1190000007838188)

* Based on Linux environment, need to install Swift 4.1, vapor 3, MySQL.

> [Swift for ubuntu Installation](https://swift.org/download/#releases)

> [Vapor for ubuntu Installation](https://docs.vapor.codes/3.0/install/ubuntu/)

> [MySQL for ubuntu installation](http://prog3.com/sbdm/blog/vXueYing/article/details/52330180)

After Vapor and MySQL are installed,
Need to enter MySQL as root on the terminal, execute the following command:

Create a database in Debug mode:
`create database vaporDebugDB character set utf8mb4;`

Create a database in Release mode:
`create database vaporDB character set utf8mb4;`

Create a database login user for the project:
`grant all privileges on *.* to sqluser@"%" identified by "qwer1234" with grant option;`

Ok, now open the terminal `cd` to the `VaporServer` directory.

Execute on macOS:

* `vapor build && vapor xcode -y`, wait for a while, when Xcode opens, click `Run` to start the experience!

Execute on Linux:

* `vapor build && vapor run`, when you see Server starting on http://localhost:8080, it is already successful!


## Feedback

If you have any questions or suggestions, you can mention one [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues)

Or contact me: ![](Source/zz.jpg)

Email : [@JinXiansen](hi@jinxiansen.com)

Twitter : [@Jinxiansen](https://twitter.com/jinxiansen)

## License 📄


SwiftServerSide-Vapor is released under the [MIT license](LICENSE). See LICENSE for details.
