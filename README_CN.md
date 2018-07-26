
<p align="center">
    <img src="Source/icon2.png"/>
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


#### [English](README.md)


这是基于 [Swift 4.1](https://swift.org) 和 [Vapor 3](http://vapor.codes) 框架的 Swift 服务端开源项目。

由于 Apple 发布了酷炫的事件驱动的非阻塞网络框架 [SwiftNIO](https://github.com/apple/swift-nio) 的缘故，Vapor 3 以迅雷不及掩耳盗铃当之势将其接入，导致 Vapor 2 和 Vapor 3 的语法差异很大，所以用 Vapor 3 重写了部分接口并开源出来，供感兴趣的伙伴参考、交流。

##### 项目部署在 [http://api.jinxiansen.com](http://api.jinxiansen.com) (Ubuntu 16.04)，大部分 API 可直接在此进行调试。

这里只是列举了一些基本的 API 和说明，更多内容请下载项目查看。

## 预览 📑

本项目包括但不限于以下内容：

- [x] 完整登录、注册、修改密码、退出功能；
- [x] 发送个人动态、获取动态列表，获取动态图片、举报；
- [x] 汉字、成语、歇后语查询；
- [x] 爬虫示例：爬取 拉勾网 iOS 职位信息，获取爬取结果；
- [x] 小说爬取示例：凡人修仙传；
- [x] **Python** 交互：`Swift` 调用 本地 `Python(.py)` 带参交互示例；
- [x] 邮件发送示例；
- [x] HTML 展示示例。


[👉 **从这里**](Source/API.md) 查看列出的 API 示例文档和调试。

## 安装 🚀

运行项目前的准备：


* [**下载 📁**](https://github.com/Jinxiansen/SwiftServerSide-Vapor/archive/master.zip) 这个项目；
* [**查看 📚**](Source/Install.md) Vapor 3 和 PostgreSQL 的快速安装步骤。

>
>  如果你偏爱 MySQL，可以查看 [这里](https://github.com/Jinxiansen/SwiftServerSide-Vapor/tree/mysql)

## 反馈 🤔

如果你有任何问题或建议，可以提一个 [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues)
，

或 Q 我邮箱： [hi@jinxiansen.com](hi@jinxiansen.com)

## License 📄


SwiftServerSide-Vapor is released under the [MIT license](LICENSE). See LICENSE for details.
