"""
交互式图片区域标注生成工具 (本地版 - 自适应 OCR 引擎)
功能：
1. 读取图片
2. OCR 识别文字（自动选择最优引擎）
3. 生成规范格式的 JSON
4. 预览标注效果
5. 导出 JSON 文件

架构：
- 默认使用 Tesseract（兼容所有 macOS）
- 如果系统支持，自动升级到 PaddleOCR（更精准）
- 用户可手动切换引擎
"""

import json
import os
import sys
from pathlib import Path
from typing import List, Dict, Any
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image, ImageDraw, ImageTk
import cv2
import numpy as np

# 确保可以导入同目录下的模块
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# 导入 OCR 引擎工厂
try:
    from ocr_engine import OCRFactory
except ImportError as e:
    print(f"错误：无法导入 ocr_engine 模块")
    print(f"详情：{e}")
    print(f"当前路径：{os.path.dirname(os.path.abspath(__file__))}")
    sys.exit(1)


class ImageRegionGenerator:
    """图片区域生成器 - 支持多引擎"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("图片区域 JSON 生成工具")
        self.root.geometry("1400x800")
        
        # 初始化 OCR 工厂
        self.ocr_factory = OCRFactory()
        
        # 数据
        self.image_path = None
        self.original_image = None
        self.display_image = None
        self.photo_image = None
        self.regions = []
        
        # 初始化 UI
        self._init_ui()
        self._show_ocr_status()
    
    def _init_ui(self):
        """初始化 UI"""
        # 菜单栏
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="文件", menu=file_menu)
        file_menu.add_command(label="打开图片", command=self.load_image)
        file_menu.add_command(label="导出 JSON", command=self.export_json)
        file_menu.add_separator()
        file_menu.add_command(label="退出", command=self.root.quit)
        
        # OCR 引擎菜单
        ocr_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="OCR 引擎", menu=ocr_menu)
        
        # 动态添加可用引擎选项
        available_engines = self.ocr_factory.get_available_engines()
        for engine_name, is_available in available_engines:
            if is_available:
                ocr_menu.add_command(
                    label=engine_name,
                    command=lambda name=engine_name: self._switch_engine(name)
                )
        
        # 帮助菜单
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="帮助", menu=help_menu)
        help_menu.add_command(label="关于", command=self._show_about)
        help_menu.add_command(label="OCR 引擎状态", command=self._show_ocr_status)
        
        # 上部：控制面板
        control_frame = tk.Frame(self.root)
        control_frame.pack(side=tk.TOP, fill=tk.X, padx=10, pady=10)
        
        tk.Button(control_frame, text="加载图片", command=self.load_image, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(control_frame, text="识别文本", command=self.recognize_text, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(control_frame, text="预览区域", command=self.preview_regions, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(control_frame, text="清空数据", command=self.clear_data, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(control_frame, text="导出 JSON", command=self.export_json, width=15).pack(side=tk.LEFT, padx=5)
        
        # 状态标签
        self.status_label = tk.Label(control_frame, text="就绪", font=("Arial", 9), fg="green")
        self.status_label.pack(side=tk.RIGHT, padx=5)
        
        # 中部：主内容
        content_frame = tk.Frame(self.root)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # 左侧：图片显示
        left_frame = tk.Frame(content_frame)
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        tk.Label(left_frame, text="图片预览", font=("Arial", 11, "bold")).pack(anchor=tk.W)
        
        # Canvas 显示图片
        self.canvas = tk.Canvas(left_frame, bg="gray", height=400)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        
        # 右侧：结果显示
        right_frame = tk.Frame(content_frame)
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=False, padx=(10, 0))
        
        tk.Label(right_frame, text="识别结果", font=("Arial", 11, "bold")).pack(anchor=tk.W)
        
        # 滚动条
        scrollbar = tk.Scrollbar(right_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # 文本框显示 JSON
        self.json_text = tk.Text(right_frame, width=40, height=30, yscrollcommand=scrollbar.set)
        self.json_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.json_text.yview)
        
        # 下部：信息栏
        info_frame = tk.Frame(self.root)
        info_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=10, pady=5)
        
        self.info_label = tk.Label(info_frame, text="未加载图片", font=("Arial", 9))
        self.info_label.pack(anchor=tk.W)
    
    def _show_ocr_status(self):
        """显示 OCR 引擎状态"""
        engine_info = self.ocr_factory.get_engine_info()
        
        status = "📊 OCR 引擎状态\n"
        status += "=" * 40 + "\n\n"
        status += f"当前使用: {engine_info['name']}\n"
        status += f"可用: {'✅ 是' if engine_info['available'] else '❌ 否'}\n\n"
        status += "所有引擎:\n"
        for name, available in engine_info['all_engines']:
            status += f"  {'✅' if available else '❌'} {name}\n"
        
        messagebox.showinfo("OCR 引擎状态", status)
    
    def _switch_engine(self, engine_name: str):
        """切换 OCR 引擎"""
        if self.ocr_factory.set_engine(engine_name):
            messagebox.showinfo("成功", f"已切换到: {engine_name}")
            self._update_status(f"当前引擎: {engine_name}")
        else:
            messagebox.showerror("错误", f"无法切换到: {engine_name}")
    
    def _show_about(self):
        """显示关于信息"""
        about_text = """
图片区域 JSON 生成工具
版本: 1.0

功能:
✅ 读取图片
✅ 自动识别文字（支持中英文）
✅ 生成坐标标注
✅ 导出 JSON 文件

架构:
- 支持 Tesseract 和 PaddleOCR
- 自动选择最优可用引擎
- 完全本地运行，无需网络

使用步骤:
1. 加载图片
2. 点击"识别文本"
3. 预览结果
4. 导出 JSON
        """
        messagebox.showinfo("关于", about_text)
    
    def load_image(self):
        """加载图片"""
        file_path = filedialog.askopenfilename(
            title="选择图片",
            filetypes=[("图片文件", "*.jpg *.jpeg *.png *.bmp"), ("所有文件", "*.*")]
        )
        
        if not file_path:
            return
        
        try:
            self.image_path = file_path
            self.original_image = Image.open(file_path).convert('RGB')
            self.display_image = self.original_image.copy()
            
            # 显示图片
            self._display_image()
            
            # 更新状态
            size = self.original_image.size
            self._update_status(f"图片已加载: {Path(file_path).name} ({size[0]}x{size[1]})")
            self._update_info(f"文件: {Path(file_path).name}")
            
        except Exception as e:
            messagebox.showerror("错误", f"加载图片失败: {e}")
            self._update_status("加载失败")
    
    def _display_image(self):
        """在 Canvas 上显示图片"""
        if not self.display_image:
            return
        
        # 获取 Canvas 大小
        canvas_width = self.canvas.winfo_width()
        canvas_height = self.canvas.winfo_height()
        
        if canvas_width <= 1 or canvas_height <= 1:
            canvas_width = 600
            canvas_height = 400
        
        img = self.display_image.copy()
        img.thumbnail((canvas_width, canvas_height), Image.Resampling.LANCZOS)
        
        self.photo_image = ImageTk.PhotoImage(img)
        self.canvas.delete("all")
        self.canvas.create_image(canvas_width // 2, canvas_height // 2, image=self.photo_image)
    
    def recognize_text(self):
        """识别图片中的文字"""
        if not self.original_image:
            messagebox.showwarning("警告", "请先加载图片")
            return
        
        try:
            self._update_status("正在识别文本...")
            self.root.update()
            
            # 将 PIL 图像转换为 OpenCV 格式
            cv_image = cv2.cvtColor(np.array(self.original_image), cv2.COLOR_RGB2BGR)
            
            # 使用 OCR 工厂识别
            raw_results = self.ocr_factory.recognize(cv_image)
            
            # 转换为规范格式
            self.regions = self._convert_to_regions(raw_results)
            
            # 显示结果
            self._display_results()
            self._update_status(f"识别完成，共识别 {len(self.regions)} 个区域")
            
        except Exception as e:
            messagebox.showerror("错误", f"识别失败: {e}\n\n请检查 OCR 引擎是否正确安装")
            self._update_status("识别失败")
    
    def _convert_to_regions(self, raw_results: List[Dict]) -> List[Dict[str, Any]]:
        """将原始识别结果转换为规范格式"""
        regions = []
        index = 1
        
        for result in raw_results:
            text = result['text'].strip()
            confidence = result['confidence']
            box = result['box']
            
            # 过滤空文本
            if not text:
                continue
            
            region = {
                "type": "chinese" if self._is_chinese(text) else "english",
                "id": f"text_{index:02d}",
                "index": index,
                "text": text,
                "text_pinyin": "",
                "text_english": "",
                "coordinate": [{"x": int(p[0]), "y": int(p[1])} for p in box]
            }
            
            regions.append(region)
            index += 1
        
        return regions
    
    def _is_chinese(self, text: str) -> bool:
        """判断文本是否包含中文"""
        for char in text:
            if 0x4E00 <= ord(char) <= 0x9FFF:
                return True
        return False
    
    def preview_regions(self):
        """预览识别区域"""
        if not self.original_image or not self.regions:
            messagebox.showwarning("警告", "请先识别文本")
            return
        
        try:
            # 在图片上绘制区域
            preview_image = self.original_image.copy()
            draw = ImageDraw.Draw(preview_image)
            
            for region in self.regions:
                coords = region['coordinate']
                points = [(c['x'], c['y']) for c in coords]
                
                # 绘制矩形
                if len(points) >= 2:
                    draw.polygon(points, outline="red", width=2)
                    
                    # 绘制文字标签
                    x, y = points[0]
                    text = region['text'][:10]
                    draw.text((x, max(0, y - 15)), text, fill="red")
            
            self.display_image = preview_image
            self._display_image()
            self._update_status("预览已更新")
            
        except Exception as e:
            messagebox.showerror("错误", f"预览失败: {e}")
    
    def _display_results(self):
        """显示识别结果"""
        self.json_text.delete("1.0", tk.END)
        json_str = json.dumps(self.regions, ensure_ascii=False, indent=2)
        self.json_text.insert("1.0", json_str)
    
    def export_json(self):
        """导出 JSON 文件"""
        if not self.regions:
            messagebox.showwarning("警告", "没有数据可导出")
            return
        
        file_path = filedialog.asksaveasfilename(
            title="保存 JSON 文件",
            defaultextension=".json",
            filetypes=[("JSON 文件", "*.json"), ("所有文件", "*.*")]
        )
        
        if not file_path:
            return
        
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(self.regions, f, ensure_ascii=False, indent=2)
            
            messagebox.showinfo("成功", f"JSON 已导出到:\n{file_path}")
            self._update_status(f"已导出 {len(self.regions)} 个区域")
            
        except Exception as e:
            messagebox.showerror("错误", f"导出失败: {e}")
    
    def clear_data(self):
        """清空所有数据"""
        if messagebox.askyesno("确认", "确定要清空所有数据吗？"):
            self.regions = []
            self.json_text.delete("1.0", tk.END)
            self.display_image = self.original_image.copy() if self.original_image else None
            if self.display_image:
                self._display_image()
            self._update_status("数据已清空")
    
    def _update_status(self, message: str):
        """更新状态标签"""
        self.status_label.config(text=message)
    
    def _update_info(self, message: str):
        """更新信息标签"""
        self.info_label.config(text=message)


def main():
    """主函数"""
    root = tk.Tk()
    app = ImageRegionGenerator(root)
    root.mainloop()


if __name__ == "__main__":
    main()
