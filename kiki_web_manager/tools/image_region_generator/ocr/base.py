"""
OCR 引擎抽象基类
定义所有 OCR 引擎必须实现的接口
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Any, Tuple, Optional
from dataclasses import dataclass


@dataclass
class OCRRegion:
    """OCR 识别结果区域"""
    text: str                              # 识别的文本
    confidence: float                      # 置信度 (0.0-1.0)
    coordinates: List[Dict[str, float]]   # 四角坐标 [左上、右上、右下、左上]
    language: str = "unknown"             # 识别语言


class OCREngine(ABC):
    """OCR 引擎抽象基类"""
    
    def __init__(self):
        """初始化引擎"""
        self.available = False
        self.name = self.__class__.__name__
    
    @abstractmethod
    def initialize(self) -> bool:
        """
        初始化 OCR 引擎
        返回：True 表示初始化成功，False 表示失败
        """
        pass
    
    @abstractmethod
    def recognize(self, image_path: str) -> List[OCRRegion]:
        """
        识别图片中的文字
        
        参数：
            image_path: 图片文件路径
        
        返回：
            识别结果列表
        
        异常：
            OCRError: 识别失败
        """
        pass
    
    @abstractmethod
    def cleanup(self):
        """清理资源"""
        pass
    
    def is_available(self) -> bool:
        """检查引擎是否可用"""
        return self.available
    
    def get_name(self) -> str:
        """获取引擎名称"""
        return self.name
    
    def get_info(self) -> Dict[str, Any]:
        """获取引擎信息"""
        return {
            "name": self.name,
            "available": self.available,
            "type": self.__class__.__module__
        }


class OCRError(Exception):
    """OCR 错误"""
    pass
