"""
Tesseract OCR 引擎实现
兼容所有 macOS 版本和跨平台使用
"""

import sys
from typing import List, Dict, Any
import cv2
import numpy as np

try:
    import pytesseract
except ImportError:
    pytesseract = None

from .base import OCREngine, OCRRegion, OCRError


class TesseractOCR(OCREngine):
    """Tesseract OCR 引擎"""
    
    def __init__(self):
        super().__init__()
        self.name = "Tesseract OCR"
        self.tesseract_cmd = None
        self._set_tesseract_path()
    
    def _set_tesseract_path(self):
        """设置 Tesseract 可执行文件路径"""
        if sys.platform == "darwin":
            # macOS
            self.tesseract_cmd = "/usr/local/bin/tesseract"
        elif sys.platform == "win32":
            # Windows
            self.tesseract_cmd = "tesseract"
        else:
            # Linux
            self.tesseract_cmd = "tesseract"
        
        pytesseract.pytesseract.pytesseract_cmd = self.tesseract_cmd
    
    def initialize(self) -> bool:
        """初始化 Tesseract OCR"""
        try:
            if pytesseract is None:
                raise OCRError("pytesseract 未安装")
            
            # 测试 Tesseract 可用性
            version = pytesseract.get_tesseract_version()
            self.available = True
            print(f"✅ Tesseract 已初始化: {version}")
            return True
        
        except Exception as e:
            self.available = False
            error_msg = f"❌ Tesseract 初始化失败: {e}\n"
            error_msg += "   请确保已安装 Tesseract:\n"
            if sys.platform == "darwin":
                error_msg += "   brew install tesseract"
            elif sys.platform == "win32":
                error_msg += "   从 https://github.com/UB-Mannheim/tesseract/wiki 下载安装"
            else:
                error_msg += "   sudo apt-get install tesseract-ocr"
            print(error_msg)
            return False
    
    def recognize(self, image_path: str) -> List[OCRRegion]:
        """使用 Tesseract 识别文字"""
        if not self.available:
            raise OCRError("Tesseract OCR 未初始化")
        
        try:
            # 读取图片
            image = cv2.imread(image_path)
            if image is None:
                raise OCRError(f"无法读取图片: {image_path}")
            
            # 使用 Tesseract 识别（支持中文）
            data = pytesseract.image_to_data(
                image,
                output_type=pytesseract.Output.DICT,
                lang='chi_sim+eng'
            )
            
            # 转换结果
            regions = self._convert_results(data)
            return regions
        
        except Exception as e:
            raise OCRError(f"识别失败: {e}")
    
    def _convert_results(self, data: Dict[str, Any]) -> List[OCRRegion]:
        """将 Tesseract 结果转换为标准格式"""
        regions = []
        
        for i in range(len(data['text'])):
            text = data['text'][i].strip()
            conf = int(data['conf'][i])
            
            # 过滤空文本和低置信度
            if not text or conf < 30:
                continue
            
            # 获取坐标
            x = int(data['left'][i])
            y = int(data['top'][i])
            w = int(data['width'][i])
            h = int(data['height'][i])
            
            # 转换为标准格式（四角坐标）
            coordinates = [
                {"x": x, "y": y},           # 左上
                {"x": x + w, "y": y},      # 右上
                {"x": x + w, "y": y + h},  # 右下
                {"x": x, "y": y + h}       # 左下
            ]
            
            region = OCRRegion(
                text=text,
                confidence=conf / 100.0,
                coordinates=coordinates,
                language=self._detect_language(text)
            )
            regions.append(region)
        
        return regions
    
    def _detect_language(self, text: str) -> str:
        """检测文本语言"""
        for char in text:
            if ord(char) > 0x4E00 and ord(char) < 0x9FFF:
                return "chinese"
        return "english"
    
    def cleanup(self):
        """清理资源"""
        pass
    
    def get_info(self) -> Dict[str, Any]:
        """获取引擎信息"""
        info = super().get_info()
        if self.available:
            try:
                info["version"] = str(pytesseract.get_tesseract_version())
            except:
                info["version"] = "unknown"
        return info
