
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


#### [English](README_EN.md)


这是基于 [Swift 4.1](https://swift.org) 和 [Vapor 3](http://vapor.codes) 框架的 Swift 服务端开源项目。

由于 Apple 发布了酷炫的事件驱动的非阻塞网络框架 [SwiftNIO](https://github.com/apple/swift-nio) 的缘故，Vapor 3 以迅雷不及掩耳盗铃当之势将其接入，导致 Vapor2 和 Vapor3 的语法差异很大，所以用 Vapor 3 重写了部分接口并开源出来，供感兴趣的伙伴参考、交流。

目前文档列举的 [API](Source/API.md) 已经部署在正式环境应用中，后续根据需求会不断完善。

##### 项目部署在 [http://api.jinxiansen.com](http://api.jinxiansen.com) 

## 查看
[用户相关](Source/API.md/#用户)

- [x] [注册](Source/API.md/#注册)
- [x] [登录](Source/API.md/#登录)
- [x] [修改密码](Source/API.md/#修改密码)
- [x] [退出登录](Source/API.md/#退出登录)

[动态相关](Source/API.md/#动态)

- [x] [发布动态](Source/API.md/#发布动态)
- [x] [获取全部动态列表](Source/API.md/#获取全部动态列表)
- [x] [获取我的动态列表](Source/API.md/#获取我的动态列表)
- [x] [获取动态图片](Source/API.md/#获取动态图片)
- [x] [举报](Source/API.md/#举报)

[字典](Source/API.md/#字典)

- [x] [汉字查询](Source/API.md/#汉字查询)
- [x] [成语查询](Source/API.md/#成语查询)
- [x] [歇后语查询](Source/API.md/#歇后语查询)

[其他](Source/API.md/#发送邮件)

- [x] [发送邮件](Source/API.md/#发送邮件)
- [x] [网页部署](Source/API.md/#网页)
- [x] [自定义404](Source/VaporUsage.md/#自定义404)
- [x] [自定义访问频率](Source/VaporUsage.md/#自定义访问频率)
- [ ] ...


#### [查看👈](Source/API.md) 目前已完成的 API 示例文档并调试。
	
#### [查看✍️](Source/VaporUsage.md) Vapor 的一些基本用法。


**另：** 这里有几个 Vapor 部署的 H5 页面示例，你可以点击查看效果。
[Keyboard](http://api.jinxiansen.com/h5/keyboard)
[Line](http://api.jinxiansen.com/h5/line)
[Color](http://api.jinxiansen.com/h5/color)
[Reboot](http://api.jinxiansen.com/h5/reboot)
[Loader](http://api.jinxiansen.com/h5/loader)
[Login](http://api.jinxiansen.com/h5/login)

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


* 创建 Debug 模式下的数据库：
`create database vaporDebugDB character set utf8mb4; `

* 创建 Release 模式下的数据库：
`create database vaporDB character set utf8mb4; `

* 创建项目中用到的数据库登录用户：
`grant all privileges on *.* to  sqluser@"%" identified by "qwer1234" with grant option;`

ok，现在打开终端，依次执行：

1. `cd` 到 `VaporServer` 
2. 执行 `vapor build && vapor run` 
3. 当你看到 **Server starting on http: //localhost:8080** 的时候，便是已经运行成功了！
4. 此时可以 [查看](Source/API.md) 目前已完成的 API 示例文档并调试。

> 提示：在 macOS 上 可以通过 `vapor xcode -y` 生成 Xcode 项目进行开发和调试。




## 反馈

如果有任何问题或建议，可以提一个 [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues)
或联系我：![](Source/zz.jpg)

Email : [@JinXiansen](hi@jinxiansen.com)

Twitter : [@Jinxiansen](https://twitter.com/jinxiansen)

## License 📄


SwiftServerSide-Vapor is released under the [MIT license](LICENSE). See LICENSE for details.
