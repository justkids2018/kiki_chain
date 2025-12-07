"""
交互式图片区域标注生成工具 (批量版)
功能：
1. 批量加载图片（单选/多选/目录）
2. OCR 识别文字（自动选择最优引擎）
3. 生成规范格式的 JSON
4. 单图预览、格式校验
5. 支持导入现有 JSON 进行验证
6. 支持单文件/批量导出

架构：
- 默认使用 Tesseract（兼容所有 macOS）
- 如果系统支持，自动升级到 PaddleOCR（更精准）
- 用户可手动切换引擎
"""

from __future__ import annotations

import json
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple
import tkinter as tk
from tkinter import filedialog, messagebox

from PIL import Image, ImageDraw, ImageTk
import cv2
import numpy as np

try:
    from pypinyin import lazy_pinyin
except ImportError:
    lazy_pinyin = None

try:
    from googletrans import Translator
except ImportError:
    Translator = None

# 确保可以导入同目录下的模块
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# 导入 OCR 引擎工厂
try:
    from ocr_engine import OCRFactory
except ImportError as e:
    print("错误：无法导入 ocr_engine 模块")
    print(f"详情：{e}")
    print(f"当前路径：{os.path.dirname(os.path.abspath(__file__))}")
    sys.exit(1)


SUPPORTED_IMAGE_EXTS = (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff", ".webp")


@dataclass
class ImageRecord:
    """批量处理时的图片与识别结果"""

    path: Path
    original_image: Image.Image
    regions: List[Dict[str, Any]] = field(default_factory=list)
    status: str = "未识别"
    json_path: Optional[Path] = None

    def __post_init__(self) -> None:
        self.size = self.original_image.size

    @property
    def filename(self) -> str:
        return self.path.name

    @property
    def stem(self) -> str:
        return self.path.stem


class TextEnricher:
    """为识别结果补充拼音与英文译文，必要时自动降级"""

    def __init__(self) -> None:
        self._translation_cache: Dict[str, str] = {}
        self._pinyin_cache: Dict[str, str] = {}
        self._translator: Any = None
        self._translator_available = False

        if Translator is not None:
            try:
                self._translator = Translator()
                self._translator_available = True
            except Exception:
                self._translator = None
                self._translator_available = False

    def enrich(self, text: str, text_type: str) -> Tuple[str, str]:
        if not text:
            return "", ""

        pinyin = self._build_pinyin(text) if text_type == "chinese" else ""

        if text_type == "chinese":
            english = self._translate(text)
            if not english:
                english = text
        else:
            english = text

        return pinyin, english

    def _build_pinyin(self, text: str) -> str:
        if text in self._pinyin_cache:
            return self._pinyin_cache[text]
        if lazy_pinyin is None:
            return ""
        try:
            parts = [segment.strip() for segment in lazy_pinyin(text, errors="ignore") if segment.strip()]
            result = " ".join(parts)
        except Exception:
            result = ""
        self._pinyin_cache[text] = result
        return result

    def _translate(self, text: str) -> str:
        cached = self._translation_cache.get(text)
        if cached is not None:
            return cached
        if not self._translator_available or self._translator is None:
            return ""
        try:
            translation = self._translator.translate(text, dest="en")
            english = translation.text.strip()
        except Exception:
            english = ""
            self._translator_available = False
        if english:
            self._translation_cache[text] = english
        return english


class ImageRegionGenerator:
    """图片区域生成器 - 支持批量处理"""

    BUTTON_WIDTH = 12

    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("图片区域 JSON 生成工具 (批量版)")
        self.root.geometry("1500x860")

        # 初始化 OCR 工厂
        self.ocr_factory = OCRFactory()
        self.text_enricher = TextEnricher()

        # 数据存储
        self.images: List[ImageRecord] = []
        self.current_index: Optional[int] = None
        self.original_image: Optional[Image.Image] = None
        self.display_image: Optional[Image.Image] = None
        self.photo_image: Optional[ImageTk.PhotoImage] = None
        self.regions: List[Dict[str, Any]] = []
        self.image_path: Optional[str] = None

        # 初始化 UI
        self._init_ui()
        self._update_info("未加载图片")
        self._update_status("就绪")
        self._show_ocr_status()

    # ---------------------------------------------------------------------
    # UI 初始化
    # ---------------------------------------------------------------------
    def _init_ui(self) -> None:
        """初始化 UI"""
        # 菜单栏
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="文件", menu=file_menu)
        file_menu.add_command(label="添加图片", command=self.load_images)
        file_menu.add_command(label="添加目录", command=self.load_directory)
        file_menu.add_separator()
        file_menu.add_command(label="导出当前 JSON", command=self.export_json)
        file_menu.add_command(label="批量导出 JSON", command=self.export_all_json)
        file_menu.add_separator()
        file_menu.add_command(label="退出", command=self.root.quit)

        # OCR 引擎菜单
        ocr_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="OCR 引擎", menu=ocr_menu)
        available_engines = self.ocr_factory.get_available_engines()
        for engine_name, is_available in available_engines:
            if is_available:
                ocr_menu.add_command(
                    label=engine_name,
                    command=lambda name=engine_name: self._switch_engine(name),
                )

        # 帮助菜单
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="帮助", menu=help_menu)
        help_menu.add_command(label="关于", command=self._show_about)
        help_menu.add_command(label="OCR 引擎状态", command=self._show_ocr_status)

        # 控制面板
        control_frame = tk.Frame(self.root)
        control_frame.pack(side=tk.TOP, fill=tk.X, padx=10, pady=10)

        def add_btn(text: str, command) -> None:
            tk.Button(control_frame, text=text, command=command, width=self.BUTTON_WIDTH).pack(
                side=tk.LEFT, padx=4
            )

        add_btn("添加图片", self.load_images)
        add_btn("添加目录", self.load_directory)
        add_btn("识别当前", self.recognize_text)
        add_btn("识别全部", self.recognize_all)
        add_btn("预览当前", self.preview_regions)
        add_btn("校验格式", self.validate_current_regions)
        add_btn("导入 JSON", self.import_json)
        add_btn("导出当前", self.export_json)
        add_btn("导出全部", self.export_all_json)
        add_btn("清空当前", self.clear_current)
        add_btn("还原图片", self.restore_image)

        self.status_label = tk.Label(control_frame, text="就绪", font=("Arial", 9), fg="green")
        self.status_label.pack(side=tk.RIGHT, padx=5)

        # 主内容区域
        content_frame = tk.Frame(self.root)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # 左侧：图片列表 + 预览
        left_frame = tk.Frame(content_frame)
        left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        list_frame = tk.Frame(left_frame, width=250)
        list_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))
        tk.Label(list_frame, text="图片列表", font=("Arial", 11, "bold")).pack(anchor=tk.W)

        list_scrollbar = tk.Scrollbar(list_frame)
        list_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.image_listbox = tk.Listbox(
            list_frame,
            width=35,
            height=25,
            yscrollcommand=list_scrollbar.set,
            exportselection=False,
        )
        self.image_listbox.pack(side=tk.LEFT, fill=tk.Y, expand=True)
        self.image_listbox.bind("<<ListboxSelect>>", self._on_image_select)
        list_scrollbar.config(command=self.image_listbox.yview)

        # 图片预览区域
        preview_frame = tk.Frame(left_frame)
        preview_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        tk.Label(preview_frame, text="图片预览", font=("Arial", 11, "bold")).pack(anchor=tk.W)

        self.canvas = tk.Canvas(preview_frame, bg="gray", height=500)
        self.canvas.pack(fill=tk.BOTH, expand=True)

        # 右侧：JSON 结果
        right_frame = tk.Frame(content_frame)
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=False, padx=(10, 0))
        tk.Label(right_frame, text="识别结果", font=("Arial", 11, "bold")).pack(anchor=tk.W)

        scrollbar = tk.Scrollbar(right_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.json_text = tk.Text(right_frame, width=48, height=40, yscrollcommand=scrollbar.set)
        self.json_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.json_text.yview)

        # 下部信息栏
        info_frame = tk.Frame(self.root)
        info_frame.pack(side=tk.BOTTOM, fill=tk.X, padx=10, pady=5)
        self.info_label = tk.Label(info_frame, text="未加载图片", font=("Arial", 9))
        self.info_label.pack(anchor=tk.W)

    # ---------------------------------------------------------------------
    # 图片加载相关
    # ---------------------------------------------------------------------
    def load_images(self) -> None:
        """选择一个或多个图片文件"""
        file_paths = filedialog.askopenfilenames(
            title="选择图片",
            filetypes=[("图片文件", "*.jpg *.jpeg *.png *.bmp *.tif *.tiff *.webp"), ("所有文件", "*.*")],
        )
        if not file_paths:
            return
        self._add_images(file_paths)

    def load_directory(self) -> None:
        """从目录加载所有图片"""
        directory = filedialog.askdirectory(title="选择图片目录")
        if not directory:
            return
        paths = [
            str(p) for p in sorted(Path(directory).iterdir()) if p.suffix.lower() in SUPPORTED_IMAGE_EXTS
        ]
        if not paths:
            messagebox.showinfo("提示", "该目录下没有匹配的图片文件")
            return
        self._add_images(paths)

    def _add_images(self, paths: Sequence[str]) -> None:
        """将图片添加到列表中"""
        existing = {record.path.resolve() for record in self.images}
        added = 0

        for file_path in paths:
            path_obj = Path(file_path)
            if path_obj.resolve() in existing:
                continue
            try:
                with Image.open(path_obj) as img:
                    pil_image = img.convert("RGB")
                record = ImageRecord(path=path_obj, original_image=pil_image.copy())
                self.images.append(record)
                added += 1
            except Exception as exc:
                messagebox.showerror("错误", f"加载图片失败: {path_obj}\n原因: {exc}")

        if added:
            self._refresh_image_list()
            if self.current_index is None:
                self._set_current_image(0)
            self._update_status(f"已添加 {added} 张图片")
        else:
            self._update_status("未添加新图片")

    def _refresh_image_list(self) -> None:
        """刷新图片列表显示"""
        self.image_listbox.delete(0, tk.END)
        for idx, record in enumerate(self.images):
            count = len(record.regions)
            status = record.status
            label = f"[{status}] {record.filename} ({record.size[0]}x{record.size[1]}) · {count} 区域"
            self.image_listbox.insert(tk.END, label)
        if self.current_index is not None and 0 <= self.current_index < len(self.images):
            self.image_listbox.selection_clear(0, tk.END)
            self.image_listbox.selection_set(self.current_index)
            self.image_listbox.activate(self.current_index)

    def _on_image_select(self, event) -> None:
        selection = self.image_listbox.curselection()
        if not selection:
            return
        index = selection[0]
        self._set_current_image(index)

    def _set_current_image(self, index: int) -> None:
        if not (0 <= index < len(self.images)):
            return
        record = self.images[index]
        self.current_index = index
        self.image_path = str(record.path)
        self.original_image = record.original_image
        self.display_image = self.original_image.copy()
        self.regions = record.regions

        self._display_image()
        self._display_results()
        self._update_info(
            f"{index + 1}/{len(self.images)} · {record.filename} ({record.size[0]}x{record.size[1]})"
        )
        self._update_status(f"当前: {record.status}")
        self.image_listbox.selection_clear(0, tk.END)
        self.image_listbox.selection_set(index)
        self.image_listbox.activate(index)

    def _get_current_record(self) -> Optional[ImageRecord]:
        if self.current_index is None:
            return None
        if not (0 <= self.current_index < len(self.images)):
            return None
        return self.images[self.current_index]

    # ---------------------------------------------------------------------
    # OCR 识别与区域处理
    # ---------------------------------------------------------------------
    def recognize_text(self) -> None:
        """识别当前图片"""
        success = self._recognize_current(silent=False)
        if success:
            messagebox.showinfo("成功", f"识别完成，共 {len(self.regions)} 个区域")

    def recognize_all(self) -> None:
        """批量识别所有图片"""
        if not self.images:
            messagebox.showwarning("警告", "请先添加图片")
            return

        processed = 0
        for idx in range(len(self.images)):
            self._set_current_image(idx)
            self.root.update_idletasks()
            if self._recognize_current(silent=True):
                processed += 1

        self._refresh_image_list()
        self._update_status(f"批量识别完成：{processed}/{len(self.images)}")
        messagebox.showinfo("完成", f"成功识别 {processed} 张图片")

    def _recognize_current(self, silent: bool) -> bool:
        record = self._get_current_record()
        if record is None:
            if not silent:
                messagebox.showwarning("警告", "请先选择一张图片")
            return False

        try:
            self._update_status("正在识别文本...")
            self.root.update_idletasks()

            cv_image = cv2.cvtColor(np.array(record.original_image), cv2.COLOR_RGB2BGR)
            raw_results = self.ocr_factory.recognize(cv_image)
            regions = self._convert_to_regions(raw_results)
            valid, err = self._validate_regions(regions)
            if not valid:
                raise ValueError(err)

            record.regions = list(regions)
            self.regions = record.regions
            record.status = f"已识别 ({len(record.regions)})"
            record.json_path = None

            self.display_image = record.original_image.copy()
            self._display_image()
            self._display_results()
            self._refresh_image_list()
            self._update_status(f"识别完成，共 {len(record.regions)} 个区域")
            return True
        except Exception as exc:
            self._update_status("识别失败")
            if not silent:
                messagebox.showerror("错误", f"识别失败: {exc}\n\n请检查 OCR 引擎是否正确安装")
            return False

    def _convert_to_regions(self, raw_results: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """将原始识别结果转换为规范格式"""
        detections: List[Dict[str, Any]] = []

        for result in raw_results:
            text = result.get("text", "").strip()
            confidence = result.get("confidence", 0)
            box = result.get("box", [])

            if not text:
                continue

            detection = self._prepare_detection(text, confidence, box)
            if detection is not None:
                detections.append(detection)

        chinese_detections = [d for d in detections if d["category"] == "chinese"]
        latin_detections = [d for d in detections if d["category"] != "chinese"]
        for det in latin_detections:
            det["used"] = False

        regions: List[Dict[str, Any]] = []
        for idx, chinese in enumerate(
            sorted(chinese_detections, key=lambda d: (d["bbox"][1], d["bbox"][0])), start=1
        ):
            pinyin_candidate = self._match_nearby_text(chinese, latin_detections, ["pinyin"])
            if pinyin_candidate is None:
                pinyin_candidate = self._match_nearby_text(chinese, latin_detections, ["latin", "english"])

            english_candidate = self._match_nearby_text(chinese, latin_detections, ["english"], mark_used=True)
            if english_candidate is None:
                english_candidate = self._match_nearby_text(
                    chinese, latin_detections, ["latin", "pinyin"], mark_used=True
                )

            fallback_pinyin, fallback_english = self.text_enricher.enrich(chinese["text"], "chinese")
            text_pinyin = pinyin_candidate["text"] if pinyin_candidate is not None else fallback_pinyin
            text_english = english_candidate["text"] if english_candidate is not None else fallback_english

            region = {
                "type": "chinese",
                "id": f"text_{idx:02d}",
                "index": idx,
                "text": chinese["text"],
                "text_pinyin": text_pinyin,
                "text_english": text_english,
                "coordinate": [{"x": int(p[0]), "y": int(p[1])} for p in chinese["box"]],
            }
            regions.append(region)

        return regions

    def _is_chinese(self, text: str) -> bool:
        return any(0x4E00 <= ord(char) <= 0x9FFF for char in text)

    def _prepare_detection(
        self, text: str, confidence: float, box: List[List[float]]
    ) -> Optional[Dict[str, Any]]:
        category = self._categorize_text(text)
        if category == "other":
            return None
        bbox = self._compute_bbox(box)
        center = ((bbox[0] + bbox[2]) / 2.0, (bbox[1] + bbox[3]) / 2.0)
        size = (bbox[2] - bbox[0], bbox[3] - bbox[1])
        if size[0] <= 0 or size[1] <= 0:
            return None
        return {
            "text": text,
            "confidence": confidence,
            "box": box,
            "bbox": bbox,
            "center": center,
            "size": size,
            "category": category,
            "used": False,
        }

    def _categorize_text(self, text: str) -> str:
        if self._is_chinese(text):
            return "chinese"

        normalized = text.strip()
        if not normalized:
            return "other"

        if self._is_latin_text(normalized):
            if self._looks_like_pinyin(normalized):
                return "pinyin"
            if self._looks_like_english(normalized):
                return "english"
            return "latin"

        return "other"

    def _is_latin_text(self, text: str) -> bool:
        allowed = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZüÜāáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜńňǹʼ' -·–—,.")
        return all(ch in allowed for ch in text)

    def _looks_like_pinyin(self, text: str) -> bool:
        accent_chars = set("āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜńňǹüÜ·")
        letters = [c for c in text if c.isalpha()]
        if not letters:
            return False
        if any(ch in accent_chars for ch in text):
            return True
        if text.lower() == text:
            return True
        uppercase_count = sum(1 for ch in text if ch.isupper())
        if uppercase_count <= 1 and " " in text:
            return True
        return False

    def _looks_like_english(self, text: str) -> bool:
        letters = [c for c in text if c.isalpha()]
        if not letters:
            return False
        uppercase_count = sum(1 for ch in text if ch.isupper())
        if uppercase_count >= 1:
            return True
        return text.lower() != text

    def _compute_bbox(self, box: List[List[float]]) -> Tuple[float, float, float, float]:
        xs = [point[0] for point in box]
        ys = [point[1] for point in box]
        return min(xs), min(ys), max(xs), max(ys)

    def _match_nearby_text(
        self,
        chinese: Dict[str, Any],
        candidates: List[Dict[str, Any]],
        preferred_categories: List[str],
        mark_used: bool = True,
    ) -> Optional[Dict[str, Any]]:
        best_candidate: Optional[Dict[str, Any]] = None
        best_score = float("inf")

        for candidate in candidates:
            if candidate["used"]:
                continue
            if candidate["category"] not in preferred_categories:
                continue
            if not self._is_candidate_near(chinese, candidate):
                continue

            score = self._candidate_score(chinese, candidate)
            if score < best_score:
                best_candidate = candidate
                best_score = score

        if best_candidate is None and "latin" not in preferred_categories:
            # 如果严格匹配失败，适当放宽类别要求
            relaxed_categories = preferred_categories + ["latin"]
            for candidate in candidates:
                if candidate["used"]:
                    continue
                if candidate["category"] not in relaxed_categories:
                    continue
                if not self._is_candidate_near(chinese, candidate):
                    continue
                score = self._candidate_score(chinese, candidate)
                if score < best_score:
                    best_candidate = candidate
                    best_score = score

        if best_candidate is not None and mark_used:
            best_candidate["used"] = True
        return best_candidate

    def _candidate_score(self, chinese: Dict[str, Any], candidate: Dict[str, Any]) -> float:
        src_center_x, src_center_y = chinese["center"]
        cand_center_x, cand_center_y = candidate["center"]
        horizontal = abs(src_center_x - cand_center_x)
        vertical = abs(src_center_y - cand_center_y)
        return vertical + horizontal * 0.5

    def _is_candidate_near(self, chinese: Dict[str, Any], candidate: Dict[str, Any]) -> bool:
        (src_min_x, src_min_y, src_max_x, src_max_y) = chinese["bbox"]
        (cand_min_x, cand_min_y, cand_max_x, cand_max_y) = candidate["bbox"]

        src_width = src_max_x - src_min_x
        src_height = src_max_y - src_min_y

        cand_width = cand_max_x - cand_min_x
        cand_height = cand_max_y - cand_min_y

        src_center_x, src_center_y = chinese["center"]
        cand_center_x, cand_center_y = candidate["center"]

        horizontal_diff = abs(src_center_x - cand_center_x)
        vertical_diff = cand_center_y - src_center_y

        max_horizontal = max(src_width, cand_width) * 1.2
        max_vertical = max(src_height, cand_height) * 4.0

        if horizontal_diff > max_horizontal:
            return False

        if vertical_diff < -src_height * 0.6:
            return False

        if vertical_diff > max_vertical:
            return False

        return True

    # ---------------------------------------------------------------------
    # 预览 / 校验 / 导入 / 导出
    # ---------------------------------------------------------------------
    def preview_regions(self) -> None:
        record = self._get_current_record()
        if record is None:
            messagebox.showwarning("警告", "请先选择一张图片")
            return
        if not record.regions:
            messagebox.showwarning("警告", "请先识别或导入区域数据")
            return

        valid, err = self._validate_regions(record.regions)
        if not valid:
            messagebox.showerror("错误", f"区域格式无效: {err}")
            return

        preview_image = record.original_image.copy()
        draw = ImageDraw.Draw(preview_image)
        for idx, region in enumerate(record.regions, 1):
            coords = region.get("coordinate", [])
            points = [(int(c["x"]), int(c["y"])) for c in coords]
            if len(points) >= 2:
                draw.polygon(points, outline="red", width=2)
                label = region.get("text") or f"#{idx}"
                x, y = points[0]
                draw.text((x, max(0, y - 18)), label[:12], fill="red")

        self.display_image = preview_image
        self._display_image()
        self._update_status("已更新预览")

    def restore_image(self) -> None:
        record = self._get_current_record()
        if record is None:
            return
        self.display_image = record.original_image.copy()
        self._display_image()
        self._update_status("已还原原图")

    def validate_current_regions(self) -> None:
        record = self._get_current_record()
        if record is None:
            messagebox.showwarning("警告", "请先选择一张图片")
            return
        if not record.regions:
            messagebox.showwarning("警告", "没有区域数据可校验")
            return
        valid, err = self._validate_regions(record.regions)
        if valid:
            messagebox.showinfo("校验通过", f"区域格式正确，共 {len(record.regions)} 个区域")
        else:
            messagebox.showerror("校验失败", err)

    def import_json(self) -> None:
        record = self._get_current_record()
        if record is None:
            messagebox.showwarning("警告", "请先选择一张图片")
            return

        file_path = filedialog.askopenfilename(
            title="导入 JSON",
            filetypes=[("JSON 文件", "*.json"), ("所有文件", "*.*")],
        )
        if not file_path:
            return

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            valid, err = self._validate_regions(data)
            if not valid:
                raise ValueError(err)

            record.regions = list(data)
            record.status = f"已导入 ({len(record.regions)})"
            record.json_path = Path(file_path)
            self.regions = record.regions

            self._display_results()
            self.restore_image()
            self._refresh_image_list()
            self._update_status(f"已导入 JSON，共 {len(record.regions)} 个区域")
        except Exception as exc:
            messagebox.showerror("错误", f"导入失败: {exc}")

    def export_json(self) -> None:
        record = self._get_current_record()
        if record is None:
            messagebox.showwarning("警告", "请先选择一张图片")
            return
        if not record.regions:
            messagebox.showwarning("警告", "没有区域数据可导出")
            return

        default_name = record.path.with_suffix(".json").name
        file_path = filedialog.asksaveasfilename(
            title="保存 JSON",
            initialfile=default_name,
            defaultextension=".json",
            filetypes=[("JSON 文件", "*.json"), ("所有文件", "*.*")],
        )
        if not file_path:
            return

        try:
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(record.regions, f, ensure_ascii=False, indent=2)
            record.status = f"已导出 ({len(record.regions)})"
            record.json_path = Path(file_path)
            self._refresh_image_list()
            self._update_status(f"JSON 已保存: {file_path}")
        except Exception as exc:
            messagebox.showerror("错误", f"导出失败: {exc}")

    def export_all_json(self) -> None:
        if not self.images:
            messagebox.showwarning("警告", "请先添加图片")
            return

        directory = filedialog.askdirectory(title="选择导出目录")
        if not directory:
            return

        exported = 0
        for record in self.images:
            if not record.regions:
                continue
            target = Path(directory) / f"{record.stem}.json"
            try:
                with open(target, "w", encoding="utf-8") as f:
                    json.dump(record.regions, f, ensure_ascii=False, indent=2)
                exported += 1
                record.status = f"已导出 ({len(record.regions)})"
                record.json_path = target
            except Exception as exc:
                messagebox.showerror("错误", f"导出失败: {target}\n原因: {exc}")
        self._refresh_image_list()
        self._update_status(f"批量导出完成：{exported}/{len(self.images)}")
        messagebox.showinfo("完成", f"成功导出 {exported} 个 JSON 文件")

    def clear_current(self) -> None:
        record = self._get_current_record()
        if record is None:
            return
        if not messagebox.askyesno("确认", f"确定清空 {record.filename} 的区域数据吗？"):
            return
        record.regions = []
        record.status = "未识别"
        record.json_path = None
        self.regions = record.regions
        self._display_results()
        self.restore_image()
        self._refresh_image_list()
        self._update_status("已清空当前图片数据")

    # ---------------------------------------------------------------------
    # 工具方法
    # ---------------------------------------------------------------------
    def _validate_regions(self, regions: Any) -> Tuple[bool, str]:
        if not isinstance(regions, list):
            return False, "JSON 顶层必须是数组"
        for idx, region in enumerate(regions, 1):
            if not isinstance(region, dict):
                return False, f"第 {idx} 个区域不是对象"
            required = {"type", "id", "index", "text", "coordinate"}
            missing = required - set(region.keys())
            if missing:
                return False, f"第 {idx} 个区域缺少字段: {', '.join(missing)}"
            coords = region.get("coordinate")
            if not isinstance(coords, list) or len(coords) < 4:
                return False, f"第 {idx} 个区域的 coordinate 至少需要 4 个点"
            for point in coords:
                if not isinstance(point, dict):
                    return False, f"第 {idx} 个区域的坐标不是对象"
                if "x" not in point or "y" not in point:
                    return False, f"第 {idx} 个区域的坐标缺少 x 或 y"
        return True, ""

    def _display_image(self) -> None:
        if self.display_image is None:
            self.canvas.delete("all")
            return
        self.canvas.update_idletasks()
        canvas_width = max(self.canvas.winfo_width(), 400)
        canvas_height = max(self.canvas.winfo_height(), 400)

        img = self.display_image.copy()
        img.thumbnail((canvas_width, canvas_height), Image.Resampling.LANCZOS)
        self.photo_image = ImageTk.PhotoImage(img)
        self.canvas.delete("all")
        self.canvas.create_image(canvas_width // 2, canvas_height // 2, image=self.photo_image)

    def _display_results(self) -> None:
        self.json_text.delete("1.0", tk.END)
        if not self.regions:
            self.json_text.insert("1.0", "[]")
            return
        json_str = json.dumps(self.regions, ensure_ascii=False, indent=2)
        self.json_text.insert("1.0", json_str)

    def _update_status(self, message: str) -> None:
        self.status_label.config(text=message)

    def _update_info(self, message: str) -> None:
        self.info_label.config(text=message)

    # ---------------------------------------------------------------------
    # 菜单/帮助
    # ---------------------------------------------------------------------
    def _show_ocr_status(self) -> None:
        engine_info = self.ocr_factory.get_engine_info()
        status = "📊 OCR 引擎状态\n" + "=" * 40 + "\n\n"
        status += f"当前使用: {engine_info['name']}\n"
        status += f"可用: {'✅ 是' if engine_info['available'] else '❌ 否'}\n\n"
        status += "所有引擎:\n"
        for name, available in engine_info['all_engines']:
            status += f"  {'✅' if available else '❌'} {name}\n"
        messagebox.showinfo("OCR 引擎状态", status)

    def _switch_engine(self, engine_name: str) -> None:
        if self.ocr_factory.set_engine(engine_name):
            messagebox.showinfo("成功", f"已切换到: {engine_name}")
            self._update_status(f"当前引擎: {engine_name}")
        else:
            messagebox.showerror("错误", f"无法切换到: {engine_name}")

    def _show_about(self) -> None:
        about_text = """
图片区域 JSON 生成工具 (批量版)
版本: 1.1

功能:
✅ 批量添加图片
✅ 自动识别文字（支持中英文）
✅ 生成/导入/校验区域数据
✅ 单图预览 + 批量导出 JSON

架构:
- 支持 Tesseract 与 PaddleOCR
- 自动选择最优可用引擎
- 完全本地运行，无需网络

使用步骤:
1. 添加图片或目录
2. 选择图片，点击“识别当前”或“识别全部”
3. 预览/校验区域
4. 导出 JSON 或批量导出
        """
        messagebox.showinfo("关于", about_text)


def main() -> None:
    root = tk.Tk()
    app = ImageRegionGenerator(root)
    root.mainloop()


if __name__ == "__main__":
    main()
