# iOS

#### 1 Podfile 增加引用库

> ```
> pod "KKApplication" ,~> "1.0.6"
> ```

#### 2 启动小应用

> ```
> [[KKShell main]open:[NSURL URLWithString: @"https://kkserver.cn/kk/doc/app.json"  ]];
> ```

# 开发小应用

#### 1 创建小应用  [下载 kk-cli](https://github.com/hailongz/KKApplication/releases/download/1.0.6/kk-cli)

> ```
> kk-cli app init
> ```

#### 2 修改 app.json

> ```
> {
>     "version":"1.0",    // 应用版本号， 每次启动应用会检测版本号，若本地不存在则下载, 下次启动自动更新
>     "items":[]          // 下载的文件相对路径，可使用 kk-cli app update 自动生成  
> }
> ```

#### 3 主代码 main.js  [详细文档](/doc/code.md)

> ```
> app.set(["action","open"], {    //打开小应用
>     "type": "app",
>     "url" :"<url>"
> });
>
> app.set(["action","open"], {    //打开界面
>     "path" :"<path>",
>     "query" : {},
>     "target" : ""    不设置按默认方式打开界面; window 在主window上显示界面; root 作为根界面显示            
> });
>
> app.set(["action","open"], {    //打开界面
>     "scheme" :"<url | scheme>"    // http URL使用WKWebView显示，其他使用系统调度规则           
> });
>
> app.set(["action","open"], { //打开界面
>     "url" :"<url>" // 使用WKWebView显示     
> });
> ```

#### 4 页面

* home.js   界面主代码 [详细文档](/doc/code.md)

* home.xml  界面视图 [详细文档](/doc/view.md)

* home\_view.js 自动生成视图代码

```
kk-cli app update    // 更新小应用，自动生成视图代码
```



