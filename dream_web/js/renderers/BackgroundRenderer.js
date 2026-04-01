/**
 * PDP魔法森林大冒险 - 背景渲染器
 * 使用Canvas 2D绘制各场景背景（渐变+装饰元素+微动画）
 */
window.BackgroundRenderer = (function() {
  'use strict';

  /** 绘制渐变天空 */
  function _drawSky(ctx, w, h, colors) {
    var grad = ctx.createLinearGradient(0, 0, 0, h);
    for (var i = 0; i < colors.length; i++) {
      grad.addColorStop(i / (colors.length - 1), colors[i]);
    }
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, w, h);
  }

  /** 绘制远山层 */
  function _drawMountains(ctx, w, h, baseY, color, amplitude, count) {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(0, h);
    for (var i = 0; i <= count; i++) {
      var x = (w / count) * i;
      var y = baseY - Math.sin(i * 0.8 + 1.5) * amplitude - Math.sin(i * 1.3) * (amplitude * 0.5);
      if (i === 0) ctx.lineTo(0, y);
      else ctx.lineTo(x, y);
    }
    ctx.lineTo(w, h);
    ctx.closePath();
    ctx.fill();
  }

  /** 绘制星星 */
  function _drawStars(ctx, w, h, count, t) {
    for (var i = 0; i < count; i++) {
      var seed = i * 137.508;
      var x = (seed * 7.31) % w;
      var y = (seed * 3.17) % (h * 0.6);
      var size = 1 + (seed % 2);
      var alpha = 0.3 + 0.7 * Math.abs(Math.sin(t * 0.001 + seed));
      ctx.globalAlpha = alpha;
      ctx.fillStyle = '#FFFFFF';
      ctx.beginPath();
      ctx.arc(x, y, size, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }

  /** 绘制树木剪影 */
  function _drawTree(ctx, x, baseY, height, width) {
    ctx.fillStyle = 'rgba(10, 30, 20, 0.8)';
    // 树干
    ctx.fillRect(x - width * 0.08, baseY - height * 0.4, width * 0.16, height * 0.4);
    // 树冠（三角堆叠）
    for (var i = 0; i < 3; i++) {
      var layerW = width * (1 - i * 0.25);
      var layerH = height * 0.35;
      var layerY = baseY - height * 0.4 - i * layerH * 0.6;
      ctx.beginPath();
      ctx.moveTo(x - layerW / 2, layerY);
      ctx.lineTo(x + layerW / 2, layerY);
      ctx.lineTo(x, layerY - layerH);
      ctx.closePath();
      ctx.fill();
    }
  }

  /** 绘制草地 */
  function _drawGrass(ctx, w, h, y, color) {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(0, y);
    for (var i = 0; i <= w; i += 30) {
      ctx.lineTo(i, y - 3 - Math.sin(i * 0.05) * 5);
    }
    ctx.lineTo(w, h);
    ctx.lineTo(0, h);
    ctx.closePath();
    ctx.fill();
  }

  /** 绘制水面 */
  function _drawWater(ctx, w, h, y, color, t) {
    var grad = ctx.createLinearGradient(0, y, 0, h);
    grad.addColorStop(0, color);
    grad.addColorStop(1, 'rgba(0,50,80,0.9)');
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.moveTo(0, y);
    for (var i = 0; i <= w; i += 5) {
      ctx.lineTo(i, y + Math.sin(i * 0.03 + t * 0.002) * 4 + Math.sin(i * 0.07 + t * 0.003) * 2);
    }
    ctx.lineTo(w, h);
    ctx.lineTo(0, h);
    ctx.closePath();
    ctx.fill();
    // 水面反光
    ctx.strokeStyle = 'rgba(255,255,255,0.1)';
    ctx.lineWidth = 1;
    for (var j = 0; j < 5; j++) {
      var wy = y + 15 + j * 20;
      ctx.beginPath();
      ctx.moveTo(w * 0.2 + j * 30, wy);
      ctx.lineTo(w * 0.2 + j * 30 + 40 + Math.sin(t * 0.002 + j) * 10, wy);
      ctx.stroke();
    }
  }

  /** 绘制萤火虫/光点 */
  function _drawFireflies(ctx, w, h, count, t) {
    for (var i = 0; i < count; i++) {
      var seed = i * 97.3;
      var x = (seed * 5.7) % w;
      var y = (seed * 3.1) % h;
      x += Math.sin(t * 0.001 + seed) * 20;
      y += Math.cos(t * 0.0008 + seed * 0.5) * 15;
      var alpha = 0.2 + 0.6 * Math.abs(Math.sin(t * 0.002 + seed));
      var radius = 2 + Math.sin(t * 0.003 + seed) * 1;
      ctx.globalAlpha = alpha;
      var grd = ctx.createRadialGradient(x, y, 0, x, y, radius * 4);
      grd.addColorStop(0, 'rgba(255,255,150,0.8)');
      grd.addColorStop(1, 'rgba(255,255,100,0)');
      ctx.fillStyle = grd;
      ctx.fillRect(x - radius * 4, y - radius * 4, radius * 8, radius * 8);
    }
    ctx.globalAlpha = 1;
  }

  /** 绘制云朵 */
  function _drawCloud(ctx, x, y, size, alpha) {
    ctx.globalAlpha = alpha || 0.3;
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(x, y, size, 0, Math.PI * 2);
    ctx.arc(x + size * 0.8, y - size * 0.2, size * 0.7, 0, Math.PI * 2);
    ctx.arc(x + size * 1.5, y, size * 0.6, 0, Math.PI * 2);
    ctx.arc(x - size * 0.5, y + size * 0.1, size * 0.5, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;
  }

  return {
    /**
     * 绘制指定类型场景背景
     * @param {CanvasRenderingContext2D} ctx
     * @param {string} sceneType
     * @param {number} w - canvas宽
     * @param {number} h - canvas高
     * @param {number} t - 时间戳(ms)，用于动画
     */
    draw: function(ctx, sceneType, w, h, t) {
      t = t || Date.now();
      ctx.clearRect(0, 0, w, h);
      switch (sceneType) {
        case 'welcome': this.drawWelcomeForest(ctx, w, h, t); break;
        case 'forest_path': this.drawForestPath(ctx, w, h, t); break;
        case 'river_bridge': this.drawRiverBridge(ctx, w, h, t); break;
        case 'crystal_cave': this.drawCrystalCave(ctx, w, h, t); break;
        case 'starlight_meadow': this.drawStarlightMeadow(ctx, w, h, t); break;
        case 'ancient_tree': this.drawAncientTree(ctx, w, h, t); break;
        case 'rainbow_falls': this.drawRainbowFalls(ctx, w, h, t); break;
        case 'shadow_valley': this.drawShadowValley(ctx, w, h, t); break;
        case 'golden_peak': this.drawGoldenPeak(ctx, w, h, t); break;
        case 'dark_battle': this.drawDarkBattle(ctx, w, h, t); break;
        default: _drawSky(ctx, w, h, ['#0D253F', '#1A3C34']); break;
      }
    },

    drawWelcomeForest: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#0D1B2A', '#0D253F', '#1A3C34', '#2D5A4E']);
      _drawStars(ctx, w, h, 60, t);
      _drawMountains(ctx, w, h, h * 0.55, 'rgba(15,45,35,0.6)', h * 0.08, 8);
      _drawMountains(ctx, w, h, h * 0.65, 'rgba(20,55,40,0.7)', h * 0.06, 10);
      _drawTree(ctx, w * 0.08, h * 0.85, h * 0.35, w * 0.12);
      _drawTree(ctx, w * 0.92, h * 0.85, h * 0.4, w * 0.14);
      _drawTree(ctx, w * 0.18, h * 0.9, h * 0.25, w * 0.08);
      _drawTree(ctx, w * 0.85, h * 0.9, h * 0.28, w * 0.09);
      _drawGrass(ctx, w, h, h * 0.85, 'rgba(25,60,45,0.8)');
      _drawFireflies(ctx, w, h, 20, t);
    },

    drawForestPath: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#87CEEB', '#B8E6B8', '#2D5A4E']);
      _drawCloud(ctx, w * 0.2 + Math.sin(t * 0.0003) * 20, h * 0.1, 20, 0.5);
      _drawCloud(ctx, w * 0.7 + Math.sin(t * 0.0002) * 15, h * 0.15, 15, 0.4);
      _drawMountains(ctx, w, h, h * 0.4, '#5D8A66', h * 0.08, 8);
      _drawTree(ctx, w * 0.05, h * 0.75, h * 0.4, w * 0.15);
      _drawTree(ctx, w * 0.95, h * 0.75, h * 0.45, w * 0.16);
      _drawTree(ctx, w * 0.2, h * 0.78, h * 0.3, w * 0.1);
      _drawTree(ctx, w * 0.8, h * 0.78, h * 0.32, w * 0.11);
      // 小径
      ctx.fillStyle = '#C4A97D';
      ctx.beginPath();
      ctx.moveTo(w * 0.35, h);
      ctx.quadraticCurveTo(w * 0.4, h * 0.7, w * 0.5, h * 0.5);
      ctx.quadraticCurveTo(w * 0.6, h * 0.7, w * 0.65, h);
      ctx.closePath();
      ctx.fill();
      _drawGrass(ctx, w, h, h * 0.8, '#3D7A4A');
      _drawFireflies(ctx, w, h * 0.7, 8, t);
    },

    drawRiverBridge: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#64B5F6', '#90CAF9', '#E3F2FD']);
      _drawCloud(ctx, w * 0.3, h * 0.08, 18, 0.5);
      _drawCloud(ctx, w * 0.75, h * 0.12, 14, 0.4);
      _drawMountains(ctx, w, h, h * 0.35, '#7DA88A', h * 0.1, 6);
      _drawGrass(ctx, w, h, h * 0.5, '#4CAF50');
      _drawWater(ctx, w, h, h * 0.55, 'rgba(33,150,243,0.6)', t);
      // 断桥
      ctx.fillStyle = '#8D6E63';
      ctx.fillRect(w * 0.1, h * 0.48, w * 0.35, 8);
      ctx.fillRect(w * 0.6, h * 0.48, w * 0.32, 8);
      // 桥桩
      ctx.fillRect(w * 0.1, h * 0.48, 6, h * 0.15);
      ctx.fillRect(w * 0.43, h * 0.48, 6, h * 0.12);
      ctx.fillRect(w * 0.6, h * 0.48, 6, h * 0.12);
      ctx.fillRect(w * 0.9, h * 0.48, 6, h * 0.15);
    },

    drawCrystalCave: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#1A1A2E', '#16213E', '#0F3460']);
      // 洞壁
      ctx.fillStyle = '#2C2C3E';
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(w * 0.15, 0);
      ctx.quadraticCurveTo(w * 0.1, h * 0.3, 0, h * 0.5);
      ctx.closePath();
      ctx.fill();
      ctx.beginPath();
      ctx.moveTo(w, 0);
      ctx.lineTo(w * 0.85, 0);
      ctx.quadraticCurveTo(w * 0.9, h * 0.3, w, h * 0.5);
      ctx.closePath();
      ctx.fill();
      // 发光水晶
      var crystalColors = ['#E040FB', '#7C4DFF', '#00BCD4', '#FFD700', '#4CAF50'];
      for (var i = 0; i < 8; i++) {
        var cx = (i * 137 + 50) % w;
        var cy = h * 0.2 + (i * 97) % (h * 0.5);
        var cs = 8 + (i * 13) % 15;
        var cc = crystalColors[i % crystalColors.length];
        var alpha = 0.4 + 0.4 * Math.sin(t * 0.002 + i * 1.5);
        ctx.globalAlpha = alpha;
        var grd = ctx.createRadialGradient(cx, cy, 0, cx, cy, cs * 3);
        grd.addColorStop(0, cc);
        grd.addColorStop(1, 'transparent');
        ctx.fillStyle = grd;
        ctx.fillRect(cx - cs * 3, cy - cs * 3, cs * 6, cs * 6);
        // 水晶体
        ctx.fillStyle = cc;
        ctx.beginPath();
        ctx.moveTo(cx, cy - cs);
        ctx.lineTo(cx + cs * 0.4, cy);
        ctx.lineTo(cx, cy + cs * 0.3);
        ctx.lineTo(cx - cs * 0.4, cy);
        ctx.closePath();
        ctx.fill();
      }
      ctx.globalAlpha = 1;
      // 地面
      ctx.fillStyle = '#1A1A2E';
      ctx.fillRect(0, h * 0.8, w, h * 0.2);
    },

    drawStarlightMeadow: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#1A0533', '#2D1B69', '#4A2C8A', '#6B3FA0']);
      _drawStars(ctx, w, h, 100, t);
      _drawGrass(ctx, w, h, h * 0.65, '#2E7D32');
      _drawGrass(ctx, w, h, h * 0.7, '#388E3C');
      // 发光花朵
      var flowerColors = ['#FF4081', '#FFD700', '#E040FB', '#00BCD4', '#FF9800'];
      for (var i = 0; i < 12; i++) {
        var fx = (i * 67 + 30) % w;
        var fy = h * 0.68 + (i * 41) % (h * 0.25);
        var fc = flowerColors[i % flowerColors.length];
        var fa = 0.4 + 0.4 * Math.sin(t * 0.002 + i * 2);
        ctx.globalAlpha = fa;
        var fgrd = ctx.createRadialGradient(fx, fy, 0, fx, fy, 12);
        fgrd.addColorStop(0, fc);
        fgrd.addColorStop(1, 'transparent');
        ctx.fillStyle = fgrd;
        ctx.fillRect(fx - 12, fy - 12, 24, 24);
        ctx.fillStyle = fc;
        ctx.beginPath();
        ctx.arc(fx, fy, 3, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
    },

    drawAncientTree: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#1B5E20', '#2E7D32', '#4CAF50', '#81C784']);
      // 巨大树干
      ctx.fillStyle = '#5D4037';
      ctx.beginPath();
      ctx.moveTo(w * 0.35, h);
      ctx.quadraticCurveTo(w * 0.38, h * 0.5, w * 0.42, h * 0.3);
      ctx.lineTo(w * 0.58, h * 0.3);
      ctx.quadraticCurveTo(w * 0.62, h * 0.5, w * 0.65, h);
      ctx.closePath();
      ctx.fill();
      // 树冠
      ctx.fillStyle = '#2E7D32';
      ctx.beginPath();
      ctx.arc(w * 0.5, h * 0.25, w * 0.3, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = '#388E3C';
      ctx.beginPath();
      ctx.arc(w * 0.35, h * 0.22, w * 0.18, 0, Math.PI * 2);
      ctx.fill();
      ctx.beginPath();
      ctx.arc(w * 0.65, h * 0.22, w * 0.18, 0, Math.PI * 2);
      ctx.fill();
      // 树根
      ctx.fillStyle = '#4E342E';
      for (var i = 0; i < 5; i++) {
        var rx = w * 0.35 + i * w * 0.07;
        ctx.beginPath();
        ctx.moveTo(rx, h * 0.9);
        ctx.quadraticCurveTo(rx - 10, h * 0.95, rx - 20, h);
        ctx.lineTo(rx + 10, h);
        ctx.closePath();
        ctx.fill();
      }
      _drawGrass(ctx, w, h, h * 0.88, '#1B5E20');
      // 发光树叶粒子
      _drawFireflies(ctx, w * 0.8, h * 0.5, 15, t);
    },

    drawRainbowFalls: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#E3F2FD', '#BBDEFB', '#90CAF9']);
      // 两侧岩壁
      ctx.fillStyle = '#795548';
      ctx.fillRect(0, h * 0.1, w * 0.3, h * 0.9);
      ctx.fillRect(w * 0.7, h * 0.1, w * 0.3, h * 0.9);
      // 瀑布
      ctx.fillStyle = 'rgba(200, 230, 255, 0.7)';
      ctx.fillRect(w * 0.4, h * 0.08, w * 0.2, h * 0.6);
      // 水花
      for (var i = 0; i < 8; i++) {
        var sx = w * 0.35 + Math.random() * w * 0.3;
        var sy = h * 0.65 + (i * 7) % 30;
        ctx.globalAlpha = 0.3 + Math.sin(t * 0.003 + i) * 0.2;
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.arc(sx, sy, 3 + i % 3, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
      // 彩虹
      var rainbow = ['#FF0000', '#FF9800', '#FFEB3B', '#4CAF50', '#2196F3', '#9C27B0'];
      for (var r = 0; r < rainbow.length; r++) {
        ctx.strokeStyle = rainbow[r];
        ctx.globalAlpha = 0.3;
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.arc(w * 0.5, h * 0.55, w * 0.22 + r * 5, Math.PI, 0);
        ctx.stroke();
      }
      ctx.globalAlpha = 1;
      _drawWater(ctx, w, h, h * 0.72, 'rgba(33,150,243,0.5)', t);
    },

    drawShadowValley: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#1A0A2E', '#2D1053', '#0D0D1A']);
      // 紫色迷雾
      for (var i = 0; i < 6; i++) {
        var fx = (i * 113) % w;
        var fy = h * 0.3 + (i * 83) % (h * 0.4);
        var fs = 80 + (i * 37) % 60;
        ctx.globalAlpha = 0.1 + 0.1 * Math.sin(t * 0.001 + i);
        var fgrd = ctx.createRadialGradient(fx, fy, 0, fx, fy, fs);
        fgrd.addColorStop(0, 'rgba(128,0,255,0.3)');
        fgrd.addColorStop(1, 'transparent');
        ctx.fillStyle = fgrd;
        ctx.fillRect(fx - fs, fy - fs, fs * 2, fs * 2);
      }
      ctx.globalAlpha = 1;
      // 枯树剪影
      ctx.fillStyle = '#0D0D0D';
      _drawTree(ctx, w * 0.1, h * 0.85, h * 0.4, w * 0.1);
      _drawTree(ctx, w * 0.9, h * 0.85, h * 0.35, w * 0.09);
      // 远处光芒
      ctx.globalAlpha = 0.2 + 0.1 * Math.sin(t * 0.001);
      var lgrd = ctx.createRadialGradient(w * 0.5, h * 0.4, 0, w * 0.5, h * 0.4, w * 0.3);
      lgrd.addColorStop(0, 'rgba(255,215,0,0.3)');
      lgrd.addColorStop(1, 'transparent');
      ctx.fillStyle = lgrd;
      ctx.fillRect(0, 0, w, h);
      ctx.globalAlpha = 1;
      _drawGrass(ctx, w, h, h * 0.85, '#0D0D1A');
    },

    drawGoldenPeak: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#FF9800', '#FFB74D', '#FFE082', '#87CEEB']);
      _drawCloud(ctx, w * 0.15, h * 0.25, 25, 0.6);
      _drawCloud(ctx, w * 0.8, h * 0.2, 20, 0.5);
      // 云海
      for (var i = 0; i < 10; i++) {
        var cx = (i * 97) % w;
        var cy = h * 0.5 + (i * 31) % 60;
        _drawCloud(ctx, cx + Math.sin(t * 0.0003 + i) * 10, cy, 30 + i % 20, 0.3);
      }
      // 山峰
      ctx.fillStyle = '#5D4037';
      ctx.beginPath();
      ctx.moveTo(w * 0.2, h);
      ctx.lineTo(w * 0.5, h * 0.35);
      ctx.lineTo(w * 0.8, h);
      ctx.closePath();
      ctx.fill();
      // 山顶平台
      ctx.fillStyle = '#FFD700';
      ctx.fillRect(w * 0.4, h * 0.35, w * 0.2, 5);
      // 日出光芒
      ctx.globalAlpha = 0.3 + 0.1 * Math.sin(t * 0.001);
      var sgrd = ctx.createRadialGradient(w * 0.5, h * 0.3, 0, w * 0.5, h * 0.3, w * 0.4);
      sgrd.addColorStop(0, 'rgba(255,215,0,0.6)');
      sgrd.addColorStop(0.5, 'rgba(255,152,0,0.2)');
      sgrd.addColorStop(1, 'transparent');
      ctx.fillStyle = sgrd;
      ctx.fillRect(0, 0, w, h);
      ctx.globalAlpha = 1;
    },

    drawDarkBattle: function(ctx, w, h, t) {
      _drawSky(ctx, w, h, ['#0D0D1A', '#1A0A2E', '#0D0D1A']);
      // 旋转迷雾
      ctx.save();
      ctx.translate(w / 2, h / 2);
      ctx.rotate(t * 0.0005);
      for (var i = 0; i < 4; i++) {
        var angle = (Math.PI * 2 / 4) * i;
        var dist = 80 + Math.sin(t * 0.002 + i) * 30;
        var mx = Math.cos(angle) * dist;
        var my = Math.sin(angle) * dist;
        ctx.globalAlpha = 0.15;
        var mgrd = ctx.createRadialGradient(mx, my, 0, mx, my, 100);
        mgrd.addColorStop(0, 'rgba(100,0,200,0.4)');
        mgrd.addColorStop(1, 'transparent');
        ctx.fillStyle = mgrd;
        ctx.fillRect(mx - 100, my - 100, 200, 200);
      }
      ctx.restore();
      ctx.globalAlpha = 1;
      // 中心光芒（胜利时增强）
      var centerAlpha = 0.05 + 0.05 * Math.sin(t * 0.003);
      ctx.globalAlpha = centerAlpha;
      var cgrd = ctx.createRadialGradient(w / 2, h / 2, 0, w / 2, h / 2, w * 0.3);
      cgrd.addColorStop(0, 'rgba(255,215,0,0.5)');
      cgrd.addColorStop(1, 'transparent');
      ctx.fillStyle = cgrd;
      ctx.fillRect(0, 0, w, h);
      ctx.globalAlpha = 1;
    }
  };
})();
