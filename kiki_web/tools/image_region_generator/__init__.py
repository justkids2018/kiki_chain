"""
图片区域生成工具包
用于解析图片并生成文本区域坐标数据
"""

__version__ = '1.0.0'
__author__ = 'Kiki Chain'

from image_region_generator import ImageRegionGenerator, RegionData
from utils import (
    CoordinateUtils,
    JSONUtils,
    ValidationUtils,
    ExportUtils
)

__all__ = [
    'ImageRegionGenerator',
    'RegionData',
    'CoordinateUtils',
    'JSONUtils',
    'ValidationUtils',
    'ExportUtils',
]
