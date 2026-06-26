# 技术设计

## 设计

新增 `writing_practice` feature：

- `pages/writing_practice_page.dart`：练字页面、A4 比例布局、打印按钮。
- `widgets/traceable_tianzi_cell.dart`：田字格预览组件。
- `services/writing_practice_print_service.dart`：生成 A4 PDF 并调用系统打印。

## 数据流

`InteractiveImageController.vocabularyRegions`
-> 组装 `{ text, pinyin }`
-> `Get.toNamed(AppConstants.routeWritingPractice)`
-> `WritingPracticePage`
-> 按 10 格行宽布局，词语之间空 1 格，不够则换行
-> 页面预览 / PDF 打印

## 关键决策

1. 复用现有卡片词条，不新增接口。
2. 页面显示使用 Flutter 组件，打印使用 PDF，避免直接打印滚动页面。
3. 练习项按 10 格网格生成，每个词语连续铺排，词间空 1 格；上方为拼音和黑色正楷示范字，下方为对应浅红描红字。
4. 正楷字体使用 `assets/fonts/AR-PL-KaitiM-GB.ttf`，来源为 AR PL KaitiM GB / 文鼎 PL 简中楷，Arphic Public License。
5. PDF 页眉使用 `assets/icon/app_icon.png` 作为 Hi Kiki 品牌图标。
6. PDF 练习纸空白区域仅在左上角和右下角展示 `Hi Kiki` 标签，避免遮挡田字格。
7. 页面不提供手指画线能力，练习动作通过纸面描红完成。
