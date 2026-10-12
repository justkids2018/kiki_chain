# 原生 iOS 文案国际化

界面固定文案位于 `Sources/Resources/Localizable.xcstrings`，提供简体中文（`zh-Hans`）和英文（`en`）。App 使用 iOS 选定的应用语言；未单独指定应用语言时跟随系统，其他语言回退到简体中文。设置页只显示“跟随系统”，不保存独立语言偏好。

SwiftUI 的 `Text`、`Button`、`Section` 等固定字符串由系统读取目录。传入 `String` 属性、状态消息或错误提示的文案需显式使用 `String(localized:)`；带数字或变量的文案使用目录中的格式字符串。麦克风权限提示分别位于 `en.lproj/InfoPlist.strings` 和 `zh-Hans.lproj/InfoPlist.strings`。

场景、词条、图片中的文字及服务端返回内容属于学习数据，不在固定 UI 文案目录中翻译。内置离线场景标题和描述按系统语言显示。法律文档目前只有中文正文，英文法律文本应由业务方审定后再添加。
