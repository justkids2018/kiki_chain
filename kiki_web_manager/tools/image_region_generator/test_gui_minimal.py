#!/usr/bin/env python3
"""Minimal GUI test to find the issue"""

import sys
import os

print("1. Testing imports...")

try:
    import tkinter as tk
    print("✅ tkinter loaded")
except Exception as e:
    print(f"❌ tkinter failed: {e}")
    sys.exit(1)

try:
    import cv2
    print(f"✅ cv2 loaded (version {cv2.__version__})")
except Exception as e:
    print(f"❌ cv2 failed: {e}")
    sys.exit(1)

try:
    from PIL import Image, ImageTk
    print("✅ PIL loaded")
except Exception as e:
    print(f"❌ PIL failed: {e}")
    sys.exit(1)

try:
    import numpy as np
    print(f"✅ numpy loaded (version {np.__version__})")
except Exception as e:
    print(f"❌ numpy failed: {e}")
    sys.exit(1)

print("\n2. Creating minimal Tkinter window...")

try:
    root = tk.Tk()
    root.withdraw()  # Hide the window
    print("✅ Tkinter window created successfully")
    
    # Try to create a PhotoImage (PIL-based image display)
    print("3. Testing PIL image creation...")
    img = Image.new('RGB', (100, 100), color='red')
    photo = ImageTk.PhotoImage(img)
    print("✅ PIL PhotoImage created successfully")
    
    root.destroy()
    print("✅ GUI test passed!")
    
except Exception as e:
    print(f"❌ GUI test failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
