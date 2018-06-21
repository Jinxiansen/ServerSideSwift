# Vapor Usage

Vapor 的一些基本用法，包括两种 GET 请求，两种 POST 请求。

## GET 请求：

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


## POST 请求：
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





