# Vapor Usage

Vapor 的一些基本用法，包括两种 [GET](#GET) 请求，两种 [POST](#POST) 请求及[自定义中间件](#自定义中间件)。


<h2 id="GET">GET 请求</h2>

### 方法 1

##### 调用：

```swift
router.get("getName", use: getNameHandler)

```

##### 方法实现：

```swift
func getNameHandler(_ req: Request) throws -> [String:String] {
	guard let name = req.query[String.self, at: "name"] else {
		return ["status":"-1","message": "缺少 name 参数"]
	}
	return ["status":"0","message":"Hello,\(name) !"]
}

```

##### 请求示例： 

http://localhost:8080/getName?name=Jinxiansen

##### 返回示例：

```swift
{
    "status": "0",
    "message": "Hello, Jinxiansen !"
}
```

### 方法 2


##### 调用、实现：

```swift
router.get("getName2", String.parameter) { req -> [String:String] in
	let name = try req.parameters.next(String.self)
		return ["status":"0","message":"Hello,\(name) !"]
	}

```

##### 请求示例： 

http://localhost:8080/getName/Jinxiansen

##### 返回示例：

```swift
{
    "status": "0",
    "message": "Hello,Jinxiansen"
}
```


<h2 id="POST">POST 请求</h2>

### 方法 1

需要声明 Struct：

```swift
struct UserContainer: Content {
    var name: String
    var age: Int?
}
```


##### 调用：

```swift
router.post("post1UserInfo", use: post1UserInfoHandler)

```

##### 方法实现：

```swift
func post1UserInfoHandler(_ req: Request) throws -> Future<[String:String]> {

	return try req.content.decode(UserContainer.self).map({ container in
		let age = container.age ?? 0
		let result = ["status":"0","message":"Hello,\(container.name) !","age": age.description]
		return result
}

```

##### 请求示例：

URL ：http://localhost:8080/getName
POST 请求的 Body 中添加 Name 字段及其值，发送请求即可。

##### 返回示例：

```swift
{
    "status": "0",
    "message": "Hello,3ks !"
}
```


### 方法 2

同样需要声明 Struct：

```swift
struct UserContainer: Content {
    var name: String
    var age: Int? //当类型后加 ? 的时候，请求参数时为可选。
}
```

##### 调用：

```swift
router.post(UserContainer.self, at: "post2UserInfo", use: post2UserInfoHandler)

```

##### 方法实现：

```swift
func post2UserInfoHandler(_ req: Request,container: UserContainer) throws -> Future<[String:String]> {
        
	let age = container.age ?? 0
	let result = ["status":"0","message":"Hello,\(container.name) !","age": age.description]
	return req.eventLoop.newSucceededFuture(result: result)
}

```

##### 请求示例：
 
同上。

##### 返回示例：

```swift
{
    "status": "0",
    "message": "Hello,3ks !"
}
```







<h2 id="自定义中间件">自定义中间件</h2>

自定义中间件，需要继承于 `Middleware` ，并实现下面这个方法：

 ```swift
 func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response>
 ```

在方法体中做出判断并拦截处理。



<h3 id="自定义404">自定义404</h3>

比如要自定义`404`状态,系统默认返回的是 `String` Not found,
我们如果要返回为 `JSON`，
可以这样实现这个方法：

```swift
public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
	return try next.respond(to: request).flatMap({ (resp) in

	let status = resp.http.status
	if status == .notFound { //拦截 404，block回调处理。
		if let resp = try self.closure(request) {
			return resp
		}
	}
	return request.eventLoop.newSucceededFuture(result: resp)
	})
}
```

调用：

```swift
middlewares.use(ExceptionMiddleware(closure: { (req) -> (EventLoopFuture<Response>?) in
	let dict = ["status":"404","message":"访问路径不存在"]
	return try dict.encode(for: req)
}))
 
```
这里其实任意对象都可以转为 Response ，所以你可以在这里自定义返回1张图片、1个网页、或其他数据类型。

详情见 [ExceptionMiddleware](https://github.com/Jinxiansen/SwiftServerSide-Vapor/blob/master/VaporServer/Sources/App/Utility/Middleware/ExceptionMiddleware.swift) 。



<h3 id="自定义访问频率">自定义访问频率</h3>

亦如上，需要继承于 `Middleware` ，并实现下面这个方法：

 ```swift
 func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response>
 ```

代码量相对稍多，见 [GuardianMiddleware](https://github.com/Jinxiansen/SwiftServerSide-Vapor/blob/master/VaporServer/Sources/App/Utility/Middleware/GuardianMiddleware.swift) 。


---


未完，待续...