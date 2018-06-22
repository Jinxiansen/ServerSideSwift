
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


#### [English version](README_EN.md)

## 简述
#### 这是基于 Swift 4.1 和 Vapor 3 框架的 Swift 服务端开源项目，目前文档列举的 API 已经部署在正式环境应用中，后续有新增会不断完善。

#### 项目部署在 [http://api.jinxiansen.com](http://api.jinxiansen.com) 

### [👉查看👈](Source/API.md) 目前已完成的 API 示例文档并调试。
	
### [查看✍️](Source/VaporUsage.md) Vapor 的一些基本用法。


**另：** 这里有几个 Vapor 部署的 H5 页面示例，你可以点击查看效果。

[Keyboard](http://api.jinxiansen.com/h5/keyboard)
[Reboot](http://api.jinxiansen.com/h5/reboot)
[Login](http://api.jinxiansen.com/h5/login)
[Loader](http://api.jinxiansen.com/h5/loader)
[Color](http://api.jinxiansen.com/h5/color)
[Line](http://api.jinxiansen.com/h5/line)

## 使用
**运行项目前的前期工作：**
点击 [Clone or download](https://github.com/Jinxiansen/SwiftServerSide-Vapor/archive/master.zip) 下载项目。

* 基于 macOS 环境，需要安装 Xcode、 Vapor 3、MySQL 。
	> [Vapor for macOS 安装说明](https://docs.vapor.codes/3.0/install/macos/)
	
	> [MySQL for macOS 安装说明](https://segmentfault.com/a/1190000007838188)

* 基于 Linux 环境，需要安装 Swift 4.1、 vapor 3、MySQL 。

	> [Swift for ubuntu 安装说明](https://swift.org/download/#releases)
	
	> [Vapor for ubuntu 安装说明](https://docs.vapor.codes/3.0/install/ubuntu/)
	
	> [MySQL for ubuntu 安装说明](http://blog.csdn.net/vXueYing/article/details/52330180)

以上 Vapor 和 MySQL 安装完成后，
需要在终端以 Root 身份进入 MySQL ，执行以下命令：


创建 Debug 模式下的数据库：
`create database vaporDebugDB character set utf8mb4; `

创建 Release 模式下的数据库：
`create database vaporDB character set utf8mb4; `

创建项目中用到的数据库登录用户：
`grant all privileges on *.* to  sqluser@"%" identified by "qwer1234" with grant option;`

ok,现在打开终端 `cd` 到 `VaporServer` 目录，

在 macOS 上执行：

* `vapor build && vapor xcode -y`,等待片刻，当 Xcode 打开的时候，点击 `Run` ，即可开始体验！

在 Linux 上执行：

* `vapor build && vapor run`,当你看到 **Server starting on http://localhost:8080** 的时候，便是已经运行成功了！



## 反馈

如果有任何问题或建议，可以提一个 [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues)

或联系我：![](Source/zz.jpg)

Email : [@JinXiansen](hi@jinxiansen.com)

Twitter : [@Jinxiansen](https://twitter.com/jinxiansen)

## License 📄


SwiftServerSide-Vapor is released under the [MIT license](LICENSE). See LICENSE for details.
