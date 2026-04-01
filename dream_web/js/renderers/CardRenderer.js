/**
 * PDP魔法森林大冒险 - 结果卡片渲染器
 * Canvas生成可分享的性格结果卡片图片
 */
window.CardRenderer = (function() {
  'use strict';

  var CARD_W = 640;
  var CARD_H = 960;

  function _getDPR() {
    return Math.min(window.devicePixelRatio || 1, 3);
  }

  function _wrapText(ctx, text, maxWidth) {
    var lines = [];
    var words = text.split('');
    var line = '';
    for (var i = 0; i < words.length; i++) {
      var testLine = line + words[i];
      if (ctx.measureText(testLine).width > maxWidth && line.length > 0) {
        lines.push(line);
        line = words[i];
      } else {
        line = testLine;
      }
    }
    if (line) lines.push(line);
    return lines;
  }

  function _drawRoundedRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  function _drawBackground(ctx, primaryColor) {
    // 渐变背景
    var grad = ctx.createLinearGradient(0, 0, 0, CARD_H);
    grad.addColorStop(0, '#0D253F');
    grad.addColorStop(0.4, primaryColor + '33');
    grad.addColorStop(1, '#1A3C34');
    ctx.fillStyle = grad;
    _drawRoundedRect(ctx, 0, 0, CARD_W, CARD_H, 32);
    ctx.fill();

    // 星星装饰
    ctx.fillStyle = '#FFFFFF';
    for (var i = 0; i < 30; i++) {
      var sx = (i * 137.5) % CARD_W;
      var sy = (i * 97.3) % (CARD_H * 0.3);
      var ss = 1 + (i % 3);
      ctx.globalAlpha = 0.2 + (i % 5) * 0.1;
      ctx.beginPath();
      ctx.arc(sx, sy, ss, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;

    // 装饰边框
    ctx.strokeStyle = 'rgba(255, 215, 0, 0.3)';
    ctx.lineWidth = 2;
    _drawRoundedRect(ctx, 16, 16, CARD_W - 32, CARD_H - 32, 24);
    ctx.stroke();

    // 角落装饰
    ctx.strokeStyle = 'rgba(255, 215, 0, 0.4)';
    ctx.lineWidth = 2;
    var cs = 30;
    // 左上
    ctx.beginPath(); ctx.moveTo(24, 24 + cs); ctx.lineTo(24, 24); ctx.lineTo(24 + cs, 24); ctx.stroke();
    // 右上
    ctx.beginPath(); ctx.moveTo(CARD_W - 24 - cs, 24); ctx.lineTo(CARD_W - 24, 24); ctx.lineTo(CARD_W - 24, 24 + cs); ctx.stroke();
    // 左下
    ctx.beginPath(); ctx.moveTo(24, CARD_H - 24 - cs); ctx.lineTo(24, CARD_H - 24); ctx.lineTo(24 + cs, CARD_H - 24); ctx.stroke();
    // 右下
    ctx.beginPath(); ctx.moveTo(CARD_W - 24 - cs, CARD_H - 24); ctx.lineTo(CARD_W - 24, CARD_H - 24); ctx.lineTo(CARD_W - 24, CARD_H - 24 - cs); ctx.stroke();
  }

  function _drawCharacterArea(ctx, result) {
    // 角色光环
    var cx = CARD_W / 2;
    var cy = 200;
    var colors = {
      tiger: '#FF6B35', peacock: '#7C4DFF',
      koala: '#4CAF50', owl: '#2196F3'
    };
    var color = colors[result.primary] || '#FFD700';

    ctx.globalAlpha = 0.2;
    var grd = ctx.createRadialGradient(cx, cy, 20, cx, cy, 120);
    grd.addColorStop(0, color);
    grd.addColorStop(1, 'transparent');
    ctx.fillStyle = grd;
    ctx.fillRect(cx - 120, cy - 120, 240, 240);
    ctx.globalAlpha = 1;

    // 绘制角色
    if (window.CharacterRenderer) {
      CharacterRenderer.draw(ctx, result.primary, cx, cy, 120, { emotion: 'happy' });
    } else {
      // Fallback: 绘制简单圆形占位
      ctx.fillStyle = color;
      ctx.beginPath();
      ctx.arc(cx, cy, 60, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  function _drawTitle(ctx, title, subtitle) {
    // 主标题
    ctx.font = 'bold 42px "PingFang SC", sans-serif';
    ctx.fillStyle = '#FFD700';
    ctx.textAlign = 'center';
    ctx.shadowColor = 'rgba(255,215,0,0.5)';
    ctx.shadowBlur = 15;
    ctx.fillText(title, CARD_W / 2, 340);
    ctx.shadowBlur = 0;

    // 副标题
    ctx.font = '20px "PingFang SC", sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.6)';
    ctx.fillText(subtitle || '', CARD_W / 2, 375);
  }

  function _drawTraits(ctx, traits, primaryColor) {
    var colors = {
      tiger: '#FF6B35', peacock: '#7C4DFF',
      koala: '#4CAF50', owl: '#2196F3'
    };
    var color = colors[primaryColor] || '#FFD700';
    var startY = 410;
    var tagH = 36;
    var gap = 12;
    var totalWidth = 0;
    var widths = [];

    ctx.font = '18px "PingFang SC", sans-serif';
    for (var i = 0; i < traits.length; i++) {
      var tw = ctx.measureText(traits[i]).width + 32;
      widths.push(tw);
      totalWidth += tw + gap;
    }
    totalWidth -= gap;

    var sx = (CARD_W - totalWidth) / 2;
    for (var j = 0; j < traits.length; j++) {
      ctx.fillStyle = color + '33';
      _drawRoundedRect(ctx, sx, startY, widths[j], tagH, tagH / 2);
      ctx.fill();
      ctx.strokeStyle = color + '66';
      ctx.lineWidth = 1;
      ctx.stroke();

      ctx.fillStyle = '#FFFFFF';
      ctx.textAlign = 'center';
      ctx.fillText(traits[j], sx + widths[j] / 2, startY + tagH / 2 + 6);
      sx += widths[j] + gap;
    }
  }

  function _drawDescription(ctx, result) {
    var y = 480;
    ctx.textAlign = 'left';

    // "你的超能力" 卡片
    ctx.fillStyle = 'rgba(255,255,255,0.08)';
    _drawRoundedRect(ctx, 40, y, CARD_W - 80, 120, 16);
    ctx.fill();

    ctx.font = 'bold 18px "PingFang SC", sans-serif';
    ctx.fillStyle = '#FFE082';
    ctx.fillText('✨ 你的超能力', 60, y + 30);

    ctx.font = '15px "PingFang SC", sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.85)';
    var lines = _wrapText(ctx, result.strength || result.strengths || '', CARD_W - 120);
    for (var i = 0; i < Math.min(lines.length, 3); i++) {
      ctx.fillText(lines[i], 60, y + 55 + i * 24);
    }

    // "成长小秘密" 卡片
    y += 140;
    ctx.fillStyle = 'rgba(255,255,255,0.08)';
    _drawRoundedRect(ctx, 40, y, CARD_W - 80, 120, 16);
    ctx.fill();

    ctx.font = 'bold 18px "PingFang SC", sans-serif';
    ctx.fillStyle = '#FFE082';
    ctx.fillText('🌱 成长小秘密', 60, y + 30);

    ctx.font = '15px "PingFang SC", sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.85)';
    var lines2 = _wrapText(ctx, result.growth || '', CARD_W - 120);
    for (var j = 0; j < Math.min(lines2.length, 3); j++) {
      ctx.fillText(lines2[j], 60, y + 55 + j * 24);
    }
  }

  function _drawBlessing(ctx, blessing) {
    var y = 770;
    ctx.fillStyle = 'rgba(255,215,0,0.1)';
    _drawRoundedRect(ctx, 40, y, CARD_W - 80, 60, 30);
    ctx.fill();
    ctx.strokeStyle = 'rgba(255,215,0,0.2)';
    ctx.lineWidth = 1;
    ctx.stroke();

    ctx.font = 'italic 16px "PingFang SC", sans-serif';
    ctx.fillStyle = '#FFE082';
    ctx.textAlign = 'center';
    ctx.fillText('"' + (blessing || '') + '"', CARD_W / 2, y + 37);
  }

  function _drawFooter(ctx) {
    ctx.font = '14px "PingFang SC", sans-serif';
    ctx.fillStyle = 'rgba(255,255,255,0.4)';
    ctx.textAlign = 'center';
    ctx.fillText('魔法森林大冒险 · PDP动物性格测试', CARD_W / 2, CARD_H - 50);
    ctx.font = '12px "PingFang SC", sans-serif';
    ctx.fillText('扫码测测你的动物守护者', CARD_W / 2, CARD_H - 30);
  }

  return {
    /**
     * 生成结果卡片
     * @param {object} result - 结果数据对象
     * @returns {Promise<{canvas, dataUrl}>}
     */
    render: function(result) {
      return new Promise(function(resolve) {
        var dpr = _getDPR();
        var canvas = document.createElement('canvas');
        canvas.width = CARD_W * dpr;
        canvas.height = CARD_H * dpr;
        canvas.style.width = CARD_W + 'px';
        canvas.style.height = CARD_H + 'px';

        var ctx = canvas.getContext('2d');
        ctx.scale(dpr, dpr);

        // 依次绘制各层
        _drawBackground(ctx, result.color || '#FFD700');
        _drawCharacterArea(ctx, result);
        _drawTitle(ctx, result.title || '神秘守护者', result.subtitle || '');
        _drawTraits(ctx, result.traits || [], result.primary);
        _drawDescription(ctx, result);
        _drawBlessing(ctx, result.blessing || '');
        _drawFooter(ctx);

        var dataUrl = canvas.toDataURL('image/png', 0.9);
        resolve({ canvas: canvas, dataUrl: dataUrl });
      });
    },

    /** 导出为DataURL */
    toDataURL: function(canvas) {
      return canvas.toDataURL('image/png', 0.9);
    },

    /** 导出为Blob */
    toBlob: function(canvas) {
      return new Promise(function(resolve) {
        canvas.toBlob(function(blob) {
          resolve(blob);
        }, 'image/png', 0.9);
      });
    }
  };
})();
