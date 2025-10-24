




### 业务逻辑开发框架约束
业务逻辑要符合符合DDD架构框架
1、严格按照**登录业务逻辑的开发功能**为新功能开发的依据，
2、API 请求都要使用：RequestManager
3、UI的 Controller 必须使用 Getx，可以放到当前目录的一个独立的目录里
4、实体对象创建 ：在data/domain/entities/目录下
5、新功能的Repository： 在/data/repositories/目录下
6、所有业务的请求path， 都要在ApiEndpoints里进行赋值和引用
7、所有的颜色在： AppColors中
8、路由的初始化：AppRoutes里，路由的path在AppConstants
### UI风格
#### 风格
设计风格：现代简约，采用毛玻璃背景和半透明卡片。
#### 色彩方案：

字体颜色（#27273F），
主色为浅绿色（#00C37D）
主色为浅绿色（#3FD280）
文字用浅白色（#E2E8F0）。

布局：顶部为搜索栏，中部是可滑动的日历视图，下方是智能推荐任务卡片流。
组件：使用圆角卡片、浮动按钮、下拉刷新动效。
平台：适配移动端 iOS，遵循苹果人机界面指南。
参考：类似 Apple Calendar 的清晰排版 + Notion 的卡片交互。”