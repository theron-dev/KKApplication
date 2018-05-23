#### 节点定义

* view

  * layout:   relative\(默认\) flex horizontal
  * background-color: 背景色
  * background-image: 背景图片 只支持应用包内图片 可配置拉伸位置如  bg.png 12 10 
  * border-width: 边框宽度
  * border-radius: 圆角
  * border-color: 边框颜色
  * opacity：透明度  0.0～1.0
  * hidden: 是否隐藏 true false
  * overflow: visible\(默认\) hidden
  * tint-color: 高亮颜色
  * keepalive: 是否保持不被重用 true false
  * animation: 动画名
  * transform: translate(x,y,z) scale(x,y,z) rotateX(角度) rotateY(角度) rotateZ(角度)

* text

  * color: 字体颜色

  * font: 字体

  * line-spacing: 行间距

  * paragraph-spacing: 段间距

  * letter-spacing: 字间距

  * text-align: left\(默认\) center right justify\(两端对齐\)

  * \#text: 文本内容

* text &gt; span

  * color: 字体颜色

  * font: 字体

  * letter-spacing: 字间距

  * \#text: 文本内容

* text &gt; img

  * width: 宽度 默认 auto
  * height: 高度 默认 auto
  * src: 图片路径 只支持应用包内图片

* image

  * src: 图片路径 支持应用包内图片,  HTTP URL
  * default-src: 图片路径 只支持应用包内图片

* button
  * status:  hover\(按下\) 默认空
  * kk:ontap: 点击事件绑定
* scroll
  * overflow-y: scroll \(垂直滚动\) 默认空
  * overflow-x: scroll \(水平滚动\) 默认空
  * taptop: 下拉刷新位置 0px则 不触发 taptop事件
  * tapbottom: 加载更多位置 0px则 不触发 tapbottom事件
  * scroll: (top bottom left right)固定 none 滚动
  * kk:ontaptop: 下拉刷新事件绑定
  * kk:ontapbototm: 加载更多事件绑定
  * kk:emit\_scrolltop: 发起滚动到顶部事件
* pager
  * 轮播如展示数据为 \[1,2,3\] 需要处理成 \[3,1,2,3,1\]
  * interval: 自动轮播时间 \(毫秒\)
  * kk:onpagechange: 绑定页面变更后事件 { pageCount : 2, pageIndex: 0}
* loading
  * 加载中组件
* switch
  * 开关选择器
  * kk:onchange: 绑定变更事件
* qr
  * 生成二维码图片
  * \#text: 二维码内容
* qr:capture
  * 摄像头扫描二维码
  * capture: 是否开始扫描（true false）扫描完成会自动设置为 false
  * kk:oncapture: 绑定扫描成功事件 { text : "扫描内容" }
* animation
  * 动画
  * name: 动画名称
  * duration: 动画时间（毫秒）
  * repeat-count: 重复次数
  * autoreverses: 自动反转 true false
  * delay: 延时 (毫秒)
* animation &gt; anim:transform
  * 变换矩阵
  * translate(x,y,z) scale(x,y,z) rotateX(角度) rotateY(角度) rotateZ(角度)
  * from: 开始值
  * to: 目标值
  * delay: 延时 (毫秒)
  * duration: 动画时间（毫秒）
* animation &gt; anim:opacity
  * 透明度 0～1
  * from: 开始值
  * to: 目标值
  * delay: 延时 (毫秒)
  * duration: 动画时间（毫秒）

#### 属性类型

* 颜色

  * \#123              
  * \#123456      
  * \#12345678     前两位表示透明度

* 尺寸单位

  * 1px
  * 50%
  * 1rpx    可以根据屏幕宽度进行自适应。规定屏幕宽为750rpx。如在 iPhone6 上，屏幕宽度为375px，共有750个物理像素，则750rpx = 375px = 750物理像素，1rpx = 0.5px = 1物理像素
  * auto

* 字体

  * 32rpx
  * 32rpx bold
  * 32rpx italic

* 间距 padding/margin

  * 1rpx                                     top=right=bottom=left=1rpx
  * 1rpx 2rpx                            top=bottom=1rpx   ,  right=left=2rpx
  * 1rpx 2rpx 3rpx                    top=1rpx right=left=2rpx bottom=3rpx
  * 1rpx 2rpx 3rpx 4rpx           top=1rpx right=2rpx bottom=3rpx left=4rpx

#### 布局

* relative  相关属性 
  * top 
  * right 
  * bottom 
  * left 
  * padding 
  * margin 
  * width
  * height
  * min-width
  * max-width
  * min-height
  * max-height

![](/doc/assets/relative.png)

* flex   从左到右 从上到下排列 
  * padding
  * margin
  * vertical-align
  * width
  * height
  * min-width
  * max-width
  * min-height
  * max-height

![](/doc/assets/flex.png)

* horizontal 从左到右排列 
  * padding
  * margin
  * vertical-align
  * width
  * height
  * min-width
  * max-width
  * min-height
  * max-height

![](/doc/assets/horizontal.png)

#### 数据绑定

* kk:text
  * 绑定文本 内容为 JavaScript 表达式
* kk:hide
  * 绑定是否隐藏 内容为 JavaScript 表达式
* kk:show
  * 绑定是否显示 内容为 JavaScript 表达式
* kk:for
  * 绑定遍历数据对象 内容为 JavaScript 表达式
  * key,value in 表达式
  * item in 表达式 
  * 表达式
* kk:_**&lt;name&gt;**_
  * 绑定属性 内容为 JavaScript 表达式

#### 事件绑定

* kk:on_**&lt;name&gt;**_

  * 绑定事件， 当节点产生事件_**&lt;name&gt;, 更新数据对应的 keyPath, 值为 节点数据**_

  ```
  <button kk:ontap="action.open" data-path="demo/index"></button>

  page.set(["action","open"], { path : "demo/index" });
  ```

* kk:emit\__**&lt;name&gt;**_

  * 发起事件，数据发生变化后对节点发送事件

  ```
  <scroll kk:emit_scrolltop="data.scrolltop"></scroll>

  page.set(["data","scrolltop"],true);
  ```



