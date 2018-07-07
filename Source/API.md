

## API Instructions

Here are some basic APIs and instructions. For more information, please [download](https://github.com/Jinxiansen/SwiftServerSide-Vapor) and view the project source code.

example: [http://api.jinxiansen.com/words/idiom?str=天道](http://api.jinxiansen.com/words/idiom?str=天道)


[User Related / 用户相关](API.md/#用户)

- [x] [register](API.md/#注册)
- [x] [login](API.md/#登录)
- [x] [change password](API.md/#修改密码)
- [x] [get user info ](API.md/#获取用户信息)
- [x] [modify user info ](API.md/#修改用户信息)
- [x] [logout ](API.md/#退出登录)

[Dynamically Related / 动态相关](API.md/#动态)

- [x] [posting news](API.md/#发布动态)
- [x] [get all dynamic list ](API.md/#获取全部动态列表)
- [x] [get my dynamic list](API.md/#获取我的动态列表)
- [x] [get dynamic image ](API.md/#获取动态图片)
- [x] [report ](API.md/#举报)

[Dictionary Query / 字典查询](API.md/字典)

- [x] [chinese query ](API.md/#汉字查询)
- [x] [idiom query ](API.md/#成语查询)
- [x] [check post query ](API.md/#歇后语查询)

[Crawler Related / 爬虫](API.md/#爬虫)

- [x] [crawler iOS ](API.md/#拉勾iOS)
- [x] [get iOS crawler results ](API.md/#获取iOS爬取结果)
- [x] [crawler example ](API.md/#爬虫示例)
- [x] [custom crawler](API.md/#自定义爬虫)


[Others / 其他](API.md/#发送邮件)

- [x] [send mail ](API.md/#发送邮件)
- [x] [web deployment ](API.md/#网页)
- [x] [custom 404 middleware ](VaporUsage.md/#自定义404)
- [x] [custom access frequency middleware](VaporUsage.md/#自定义访问频率)
- [ ] ...


##### [View ✍️](VaporUsage.md) Some basic usages of Vapor(查看一些基础用法).


<h2 id="用户">用户</h2>

用户相关接口包括登录、注册、修改密码、退出登录。

> 目前用户登录设置的 Token 有效期为 60 * 60 * 24 * 30 

<h3 id="注册">注册</h3>

> users/register

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| account | 是 | string | 账号 |
| password | 是 | string | 密码 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |
| accessToken | string | 注册成功则返回 Token |

#### 返回示例
  
 <details> 
  <summary> 终端测试 </summary>

   curl --request POST \
  --url http://localhost:8080/users/register \
  --header 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' \
  --form account=hello@foxmail.com \
  --form password=qbter123 

</details> 

```
{
    "status": 0,
    "message": "注册成功",
    "data": {
        "accessToken": "6xETNQp3kyKMZvv1SMOBO_f0L_oYIjm4q8zeGtfEOBg"
    }
}
```



<h3 id="登录">登录</h3>

> users/login

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| account | 是 | string | 账号 |
| password | 是 | string | 密码 |


#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |
| accessToken | string | 登录成功则返回 Token |

#### 返回示例

```
{
    "status": 0,
    "message": "登录成功",
    "data": {
        "accessToken": "qgdoPf3v9OqaUwBtGlzX69c6Xz-Jqdsm4X7bu-alF-c"
    }
}

```



<h3 id="修改密码">修改密码</h3>

> users/changePassword

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| account | 是 | string | 账号 |
| password | 是 | string | 旧密码 |
| newPassword | 是 | string | 新密码 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |

#### 返回示例

```
{
    "status": 0,
    "message": "修改成功，请重新登录"
}
```

<h3 id="获取用户信息">获取用户信息</h3>

> users/getUserInfo

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |
| userID | string | 用户 ID |
| phone | string | 手机号 |
| location | string | 所在地 |
| id | int | 表id |
| age | int | 年龄 |
| picName | string | 头像图片名称 |
| birthday | string | 出生日 |
| sex | int | 性别,1男 2女 其他未知 |
| nickName | string | 昵称 |

#### 返回示例

```
{
    "status": 0,
    "message": "请求成功",
    "data": {
        "userID": "D1D0CEBC-91B5-47D1-B62A-C2AAC0197343",
        "phone": "13333312312",
        "location": "花果山",
        "id": 1,
        "age": 18,
        "picName": "9fe6d4e771ddde55a60166e1c4688b39.jpg",
        "birthday": "10240301",
        "sex": 3,
        "nickName": "成昆"
    }
}
```




<h3 id="修改用户信息">修改用户信息</h3>

> users/updateInfo

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |
| age | 否 | Int | 年龄 |
| sex | 否 | Int | 性别,1男 2女 0未知 |
| nickName | 否 | string | 昵称 |
| phone | 否 | string | 手机号 |
| birthday | 否 | string | 出生日 |
| location | 否 | string | 位置 |
| picImage | 否 | Data | 用户头像 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述字段 |

#### 返回示例

```
{
    "status": 0,
    "message": "修改成功"
}
```



<h3 id="退出登录">退出登录</h3>

> users/exit

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 登录/注册时接口返回的 AccessToken |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "退出成功"
}
```


<h2 id="动态">动态</h2>

动态相关接口，包括发动态、获取全部动态列表、获取动态图片、获取我发布的动态列表、举报等。

> 图片名用 随机数+时间戳 以 md5 编码存储在指定目录。
> 
> 图片大小不能超过 2M 。


<h3 id="发布动态">发布动态</h3>

> record/add

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户Token |
| content | 是 | string | 动态内容 |
| title | 是 | string | 动态标题 |
| image | 否 | Data | 上传的图片 |
| county | 是 | string | 动态对应的城市 |


#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "发布成功"
}
 
```



<h3 id="获取全部动态列表">获取全部动态列表</h3>


> record/getRecords

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/record/getRecords?page=0&county=huxian](http://api.jinxiansen.com/record/getRecords?page=0&county=huxian)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| page | 是 | int | 分页索引，起始为 0 |
| county | 是 | string | 动态对应的城市 |


#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |


#### 返回示例

```
{
    "status": 0,
    "data": [
        {
            "county": "huxian",
            "id": 1,
            "imgName": "6fa5bb4b4a2371c6a6bc83573bb4c558.jpg",
            "title": "身穿道袍戴道冠一道士任景区管理局沙窝村党支部书记",
            "time": "2018-06-17 11:26:50",
            "content": "有一位身着道袍、头戴道冠、手持令牌“做法”的沙窝村共产党员朱新财近日在鄠邑区景区管理局涝峪沙窝村任新一届村党支部书记。\n      《中共中央、国务院关于加强宗教工作的决定》指出：“共产党员不得信仰宗教，要教育党员、干部坚定共产主义信念，防止宗教的侵蚀。对笃信宗教丧失党员条件、利用职权助长宗教狂热的要严肃处理。”\n       2016年4月30日，习总书记在全国宗教工作会议上也明确指出：“共产党员要做坚定的马克思主义无神论者，严守党章规定，坚定理想信念，牢记党的宗旨，绝不能在宗教中寻找自己的价值和信念。”\n       朱新财加入道教多年，多次在涝峪山区，以身穿道袍，头戴法帽，手拿令牌“跳端公”，进行迷信活动，无人不知，无人不晓。其骗取钱财一事曾被户县公安局机关处罚过。不知什么原因今年能被鄠邑区景区管理局党委批准为沙窝村任新一届村党支部书记？\n       此事发生后党员、群众向鄠邑区景区管理局党委、纪委反映无果。\n       西安鄠邑区景区管理局党委应该给党员和群众一个公开的答复。\n       消息来源：户县人民网",
            "userID": "310370D2-65FE-4478-B412-4163CB7DFA5A"
        }
    ],
    "message": "请求成功"
}
 
```

<h3 id="获取动态图片">获取动态图片</h3>

> record/image

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| name | 是 | string | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
|返回一张图片|

#### 接口示例
  
[http://api.jinxiansen.com/record/image?name=be0bf2d70f6bbe05efbe2e89578ba84b.jpg](http://api.jinxiansen.com/record/image?name=be0bf2d70f6bbe05efbe2e89578ba84b.jpg)


<h3 id="获取动态图片二">获取动态图片(2)</h3>

在 URL 后面追加图片名称，见示例

> record/image

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| 图片名称 | 是 | string | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
|返回一张图片|

#### 接口示例
  
[http://api.jinxiansen.com/record/image/be0bf2d70f6bbe05efbe2e89578ba84b.jpg](http://api.jinxiansen.com/record/image/be0bf2d70f6bbe05efbe2e89578ba84b.jpg)



<h3 id="获取我的动态列表">获取我的动态列表</h3>

> record/getMyRecords

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/record/getMyRecords?page=0&county=huxian&token=DJ_ssuG_vEpnt4te1ho2fK2PqmhPxaSo5B9SoXxnfn4](http://api.jinxiansen.com/record/getMyRecords?page=0&county=huxian&token=DJ_ssuG_vEpnt4te1ho2fK2PqmhPxaSo5B9SoXxnfn4)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |
| county | 是 | string | 城市 |
| page | 是 | int | 分页索引，由 0 开始 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |
| county | string | 城市 |
| content | string | 内容 |
| userID | string | 用户 ID |
| title | string | 标题 |
| time | string | 发布时间 |

  
#### 返回示例

```
 {
    "status": 0,
    "message": "请求成功",
    "data": [
        {
            "county": "huxian",
            "content": "And to generate the TOC, open the command palette ( Ctrl + Shift + P ) and select the Markdown TOC:Insert/Update option or use Ctrl + M T",
            "userID": "2F2E4E60-4FDF-41C3-AB3A-409A8396ECC2",
            "title": "Markdown TOC",
            "time": "2018-06-18 22:04:52"
        }
    ]
}

```




<h3 id="举报">举报</h3>

> record/report

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| token | 是 | string | 用户 Token |
| content | 是 | string | 举报内容 |
| county | 是 | string | 对应城市 |
| image | 否 | Data | 举报上传的图片 |
| contact | 否 | string | 联系信息 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例
  
```
 {
    "status": 0,
    "message": "举报成功"
}
```



<h2 id="字典">字典</h2>

支持汉字、成语、歇后语查询。

> 查询采用的是模糊匹配，可能会有多个结果。

<h3 id="汉字查询">汉字查询</h3>

> words/word

##### 请求方式：GET

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| str | 是 | string | 查询的汉字 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |
| pinyin | string | 汉字对应的拼音 |
| word | string | 查询的汉字 |
| explanation | string | 释义 |
| strokes | string | 笔画 |
| radicals | string | 偏旁 |
| oldword | string | 繁体字 |
| more | string | 更多解释、拓展 |


#### 接口示例

[http://api.jinxiansen.com/words/word?str=中](http://api.jinxiansen.com/words/word?str=中)

#### 返回示例

```
{
    "status": 0,
    "data": [
        {
            "pinyin": "zhōnɡ",
            "word": "中",
            "explanation": "中 \n\n (指事。甲骨文字形,中象旗杆,上下有旌旗和飘带,旗杆正中竖立。本义中心 ----- 此处省略一大段 ------ ③在某个方面占重要位置的地方政治～心。商贸～心。",
            "strokes": "4",
            "radicals": "丨",
            "oldword": "中",
            "more": "中 zhong 部首 丨 部首笔画 01 总笔画 04  中 ----- 此处省略一大段 ------。\n郑码j/jivv，u4e2d，gbkd6d0\n笔画数4，部首丨，笔顺编号2512"
        }
    ],
    "message": "请求成功"
}
 
```

 


<h3 id="成语查询">成语查询</h3>

> words/idiom

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/words/idiom?str=水性](http://api.jinxiansen.com/words/idiom?str=水性)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| str | 是 | string | 查询的成语 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |
| example | string | 举例 |
| pinyin | string | 拼音 |
| word | string | 查询的成语 |
| abbreviation | string | 拼音缩写 |
| derivation | string | 来源 |
| explanation | string | 解释 |


#### 返回示例

```
{
    "status": 0,
    "data": [
        {
            "example": "无",
            "pinyin": "shuǐ xìng yáng huā",
            "word": "水性杨花",
            "abbreviation": "sxyh",
            "derivation": "清·曹雪芹《红楼梦》第九十二回大凡女人都是水性杨花。”",
            "explanation": "象流水那样易变，象杨花那样轻飘。比喻妇女在感情上不专一。"
        },
        {
            "example": "无",
            "pinyin": "yáng hu huǐ xìng",
            "word": "杨花水性",
            "abbreviation": "yhhx",
            "derivation": "清·李宝嘉《官场现形记》第四十三回不过瞿耐庵惧内得很，一直不敢接他上任。那爱珠又是堂子里出身，杨花水性。”",
            "explanation": "柳絮飘扬，水性流动，因以杨花水性”比喻轻薄女子等用情不专。"
        },
        {
            "example": "无",
            "pinyin": "yún xīn shuǐ xìng",
            "word": "云心水性",
            "abbreviation": "yxsx",
            "derivation": "明·叶宪祖《鸾鎞记·喜谐》若是云心水性情分寡，怎供出梦蝶寻花。”",
            "explanation": "指女子作风轻浮，爱情不专一。"
        }
    ],
    "message": "请求成功"
}
 
```


<h3 id="歇后语查询">歇后语查询</h3>

> words/xxidiom

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/words/xxidiom?str=菩萨](http://api.jinxiansen.com/words/xxidiom?str=菩萨)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| str | 是 | string | 查询的成语 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |
| riddle | string | 前半句 |
| answer | string | 后半句 |


#### 返回示例

```
{
    "status": 0,
    "data": [
        {
            "riddle": "泥菩萨过河",
            "answer": "自身难保"
        }
    ],
    "message": "请求成功"
}
 
```



<h2 id="发送邮件">发送邮件</h2>

邮件发送请自行配置 SMTP 相关参数。

> sendEmail

##### 请求方式：POST

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| email | 是 | string | 接收人邮箱 |
| myName | 是 | string | 发送人姓名 |
| subject | 是 | string | 邮件主题 |
| text | 是 | string | 邮件内容 |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "发送成功"
}
 
```


<h2 id="爬虫">爬虫</h2>

这里只是简单展示了如何解析URL，你可以在此基础扩展使用，爬取目标URL并解析和创建 SQL Model 保存数据库，然后添加 API 调用，美滋滋。☺️

<h3 id="拉勾iOS">拉勾网iOS爬取示例</h3>

拉勾网爬虫示例，目标地址： [https://www.lagou.com/jobs/list_ios?labelWords=&fromSearch=true&suginput=](https://www.lagou.com/jobs/list_ios?labelWords=&fromSearch=true&suginput=)


> crawler/lagou/start

##### 请求方式：GET

#### 接口示例

请运行项目后开始爬取：[http://localhost:8080/crawler/lagou/start](http://localhost:8080/crawler/lagou/start)


 <details> 
  <summary> 查看爬取结果 </summary>
	http://api.jinxiansen.com/crawler/lagou/ios

</details> 

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| 无 |  | | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |


#### 返回示例

你可以修改项目中的城市和关键字，以爬取自己需要的数据。

```
{
    "status":0,
    "message":"开始爬取任务：上海 ios"
}
```

<h3 id="获取iOS爬取结果">获取iOS爬取结果</h3>

> crawler/lagou/ios

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/crawler/lagou/ios](http://api.jinxiansen.com/crawler/lagou/ios)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| 无 | | | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |


#### 返回示例

```
{
    "status":0,
    "message":"请求成功",
    "data":[
        {
            "industryField":"移动互联网,金融",
            "firstType":"开发/测试/运维类",
            "positionAdvantage":"亿级平台,准上市,极客文化,比较",
            "id":1,
            "education":"本科",
            "imState":"today",
            "workYear":"3-5年",
            "secondType":"前端开发/移动开发",
            "appShow":0,
            "address":"上海 - 徐汇区 - 桂平路391号新漕河泾国际商务中心A座5层 ",
            "adWord":0,
            "resumeProcessDay":1,
            "companySize":"500-2000人",
            "salary":"15k-25k",
            "score":0,
            "subwayline":"9号线",
            "district":"徐汇区",
            "tag":"15k-25k /上海 / 经验3-5年 / 本科及以上 / 全职 高级 中级 移动端 iOS Android 09:13 发布于拉勾网",
            "formatCreateTime":"09:13发布",
            "stationname":"东兰路",
            "pcShow":0,
            "resumeProcessRate":100,
            "approve":1,
            "longitude":"121.40391",
            "positionId":4806768,
            "city":"上海",
            "companyId":1738,
            "positionName":"ios开发",
            "publisherId":105490,
            "isSchoolJob":0,
            "companyShortName":"有鱼金融科技",
            "financeStage":"不需要融资",
            "companyLogo":"i/image/M00/61/D3/CgqKkVf8uQeAOqJ2AAArfl5skXY149.png",
            "companyFullName":"上海彩亿信息技术有限公司",
            "lastLogin":1530686988000,
            "createTime":"2018-07-04 09:13:17",
            "jobNature":"全职",
            "deliver":0,
            "linestaion":"9号线_漕河泾开发区;12号线_东兰路;12号线_虹梅路;12号线_虹漕路",
            "jobDesc":"职位描述： 职位描述： 岗位职责： 1、负责IOS移动端的产品开发及维护； 2、独立完成产品需求的整理和软件设计； 3、高效完成开发任务，提交高质量代码； 4、优化移动端产品的质量、性能、用户体验。 任职资格： 1、本科及以上学历，计算机相关专业，具有独立开发能力； 2、掌握Objective-C语言的特性，精通内存管理、多线程、响应式链条、绘图等； 3、熟练使用IOS主流开发工具、开源框架，如Cocoa touch、Xcode、IOS SDK等； 4、熟悉UI组件以及原理，对交互有造诣者优先； 5、了解算法、数据库、底层架构者优先； 6、逻辑思维强，有钻研精神，Github上有贡献优秀代码者优先； 7、乐观开朗，善于团队合作，有强烈的责任心。",
            "latitude":"31.164019"
        }
    ]
}
 
```




<h3 id="爬虫示例">爬虫示例</h3>

爬虫示例，目标地址： [http://swiftdoc.org](http://swiftdoc.org)

> crawler/swiftDoc

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/crawler/swiftDoc](http://api.jinxiansen.com/crawler/swiftDoc)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| 无 |  | | |

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |


#### 返回示例

```
{
    "status":0,
    "message":"解析成功",
    "data":[
        {
            "type":"Types",
            "titles":[
                "AnyBidirectionalCollection",
                "AnyCollection",
                "AnyHashable",
                "Zip2Iterator",
                "Zip2Sequence"
            ]
        }
    ]
}
 
```



<h3 id="自定义爬虫">自定义爬虫地址和规则</h3>

> crawler/query

##### 请求方式：GET

#### 接口示例

[http://api.jinxiansen.com/crawler/query?url=http://api.jinxiansen.com&parse=div](http://api.jinxiansen.com/crawler/query?url=http://api.jinxiansen.com&parse=div)

##### 请求参数

|参数|必选|类型|说明|
|:--|:---|:---|:--- |
| url | 是 | string | 目标 URL |
| parse | 是 | string | 爬取规则标签,例如 `title`,`div`,`div,li` ,更多请参考 [https://github.com/scinfu/SwiftSoup](https://github.com/scinfu/SwiftSoup)|

#### 返回字段

|返回字段|字段类型|说明 |
|:----- |:------|:---|
| status | int | 0 = 请求成功 |
| message | string | 描述 |

#### 返回示例

```
{
    "status": 0,
    "message": "解析成功",
    "data": [
        {
            "text": "Auto-generated documentation for Swift. Command-click no more.",
            "html": "<p>Auto-generated documentation for <a href=\"https://developer.apple.com/swift/\">Swift</a>. Command-click no more.</p>"
        }
    ]
}
 
```


<h3 id="网页">网页</h3>


这里有几个 Vapor 部署的 H5 页面示例，你可以点击查看效果。

[Keyboard](http://api.jinxiansen.com/h5/keyboard)
[Line](http://api.jinxiansen.com/h5/line)
[Color](http://api.jinxiansen.com/h5/color)
[Reboot](http://api.jinxiansen.com/h5/reboot)
[Loader](http://api.jinxiansen.com/h5/loader)
[Login](http://api.jinxiansen.com/h5/login)


## 反馈

如果有任何问题或建议，可以提一个 [Issue](https://github.com/Jinxiansen/SwiftServerSide-Vapor/issues)

或联系我：[Jinxiansen](http://jinxiansen.com)


