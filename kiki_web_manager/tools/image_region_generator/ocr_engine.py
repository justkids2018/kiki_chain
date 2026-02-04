"""
OCR 引擎抽象层（安全版）
支持多种 OCR 实现，自动选择最优可用引擎
避免导入不兼容的库导致崩溃
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Any
import sys
import os

try:
    import cv2
    import numpy as np
except ImportError:
    cv2 = None
    np = None


class OCREngine(ABC):
    """OCR 引擎基类"""
    
    @abstractmethod
    def recognize(self, image) -> List[Dict[str, Any]]:
        """识别图片中的文字"""
        pass
    
    @abstractmethod
    def is_available(self) -> bool:
        """检查引擎是否可用"""
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        """获取引擎名称"""
        pass


class TesseractOCR(OCREngine):
    """Tesseract OCR 引擎（默认，兼容所有 macOS）"""
    
    def __init__(self):
        self.available = False
        self.pytesseract = None
        self._check_availability()
    
    def _check_availability(self):
        """检查 Tesseract 是否安装"""
        try:
            import pytesseract
            # 设置 Tesseract 路径
            pytesseract.pytesseract.pytesseract_cmd = '/opt/homebrew/bin/tesseract'
            # 测试是否可用
            pytesseract.get_tesseract_version()
            self.pytesseract = pytesseract
            self.available = True
        except Exception as e:
            self.available = False
    
    def is_available(self) -> bool:
        return self.available
    
    def get_name(self) -> str:
        return "Tesseract OCR"
    
    def recognize(self, image) -> List[Dict[str, Any]]:
        """使用 Tesseract 识别文字"""
        if not self.available:
            raise RuntimeError("Tesseract 未安装或不可用")
        
        try:
            data = self.pytesseract.image_to_data(
                image,
                output_type=self.pytesseract.Output.DICT,
                lang='chi_sim+eng'
            )
            
            results = []
            for i in range(len(data['text'])):
                text = data['text'][i].strip()
                conf = int(data['conf'][i]) / 100.0
                
                if not text or conf < 0.3:
                    continue
                
                x = int(data['left'][i])
                y = int(data['top'][i])
                w = int(data['width'][i])
                h = int(data['height'][i])
                
                box = [
                    [x, y],
                    [x + w, y],
                    [x + w, y + h],
                    [x, y + h]
                ]
                
                results.append({
                    'text': text,
                    'confidence': conf,
                    'box': box
                })
            
            return results
        except Exception as e:
            raise RuntimeError(f"Tesseract 识别失败: {e}")


class PaddleOCREngine(OCREngine):
    """PaddleOCR 引擎（可选，更高精准度）"""
    
    def __init__(self):
        self.available = False
        self.ocr = None
        self._check_availability()
    
    def _check_availability(self):
        """检查 PaddleOCR 是否可用"""
        try:
            # 在单独的进程中测试，避免崩溃影响主程序
            import subprocess
            result = subprocess.run(
                [sys.executable, '-c', 
                 'from paddleocr import PaddleOCR; PaddleOCR(use_angle_cls=True, lang="ch")'],
                timeout=10,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                # 只在确认可用后才导入
                from paddleocr import PaddleOCR
                self.ocr = PaddleOCR(use_angle_cls=True, lang='ch')
                self.available = True
            else:
                self.available = False
        except Exception:
            self.available = False
    
    def is_available(self) -> bool:
        return self.available
    
    def get_name(self) -> str:
        return "PaddleOCR"
    
    def recognize(self, image) -> List[Dict[str, Any]]:
        """使用 PaddleOCR 识别文字"""
        if not self.available or not self.ocr:
            raise RuntimeError("PaddleOCR 未安装或不可用")
        
        try:
            result = self.ocr.ocr(image, cls=True)
            
            results = []
            if result:
                for line in result:
                    if not line:
                        continue
                    for item in line:
                        box, (text, conf) = item
                        
                        if conf < 0.5:
                            continue
                        
                        box_list = [[int(p[0]), int(p[1])] for p in box]
                        
                        results.append({
                            'text': text,
                            'confidence': conf,
                            'box': box_list
                        })
            
            return results
        except Exception as e:
            raise RuntimeError(f"PaddleOCR 识别失败: {e}")


class OCRFactory:
    """OCR 引擎工厂 - 自动选择最优可用引擎"""
    
    # 按优先级排列（Tesseract 优先，因为更稳定）
    ENGINE_CLASSES = [
        TesseractOCR,      # 首先尝试 Tesseract（最稳定）
        PaddleOCREngine,   # 备选 PaddleOCR
    ]
    
    _instance = None
    _engine = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if self._engine is None:
            self._engine = self._select_engine()
    
    def _select_engine(self):
        """选择第一个可用的 OCR 引擎"""
        for engine_class in self.ENGINE_CLASSES:
            try:
                engine = engine_class()
                if engine.is_available():
                    print(f"✅ 使用 OCR 引擎: {engine.get_name()}")
                    return engine
            except Exception as e:
                print(f"⚠️  无法初始化 {engine_class.__name__}: {e}")
                continue
        
        # 如果都失败，返回 Tesseract（即使不可用，方便调试）
        print("⚠️  没有可用的 OCR 引擎")
        return TesseractOCR()
    
    def get_engine(self):
        """获取当前选择的 OCR 引擎"""
        return self._engine
    
    def get_available_engines(self) -> List[tuple]:
        """获取所有可用引擎列表"""
        engines = []
        for engine_class in self.ENGINE_CLASSES:
            try:
                engine = engine_class()
                engines.append((engine.get_name(), engine.is_available()))
            except:
                pass
        return engines
    
    def set_engine(self, engine_name: str) -> bool:
        """手动选择指定的 OCR 引擎"""
        for engine_class in self.ENGINE_CLASSES:
            try:
                engine = engine_class()
                if engine.get_name() == engine_name:
                    if engine.is_available():
                        self._engine = engine
                        return True
                    else:
                        return False
            except:
                pass
        return False
    
    def recognize(self, image) -> List[Dict[str, Any]]:
        """使用当前引擎识别文字"""
        return self._engine.recognize(image)
    
    def get_engine_info(self) -> Dict[str, Any]:
        """获取当前引擎信息"""
        return {
            'name': self._engine.get_name(),
            'available': self._engine.is_available(),
            'all_engines': self.get_available_engines()
        }
