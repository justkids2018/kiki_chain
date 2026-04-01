/**
 * CharacterRenderer - 四位守护者角色Canvas程序化绘制器
 * 使用简笔画+卡通风格绘制勇勇(老虎)、彩彩(孔雀)、暖暖(考拉)、慧慧(猫头鹰)
 */
window.CharacterRenderer = (function() {
  'use strict';

  /** 守护者绘制参数 */
  const characters = {
    tiger: {
      name: '勇勇',
      primaryColor: '#FF6B35',
      secondaryColor: '#FFD700',
      glowColor: 'rgba(255,107,53,0.3)',
      stripeColor: '#C14600',
      bellyColor: '#FFF3E0',
    },
    peacock: {
      name: '彩彩',
      primaryColor: '#7C4DFF',
      secondaryColor: '#E040FB',
      glowColor: 'rgba(124,77,255,0.3)',
      tailColors: ['#7C4DFF', '#E040FB', '#00BCD4', '#FFD700', '#4CAF50'],
      crownColor: '#FFD700',
    },
    koala: {
      name: '暖暖',
      primaryColor: '#4CAF50',
      secondaryColor: '#81C784',
      glowColor: 'rgba(76,175,80,0.3)',
      earInner: '#E8F5E9',
      noseColor: '#333333',
      leafColor: '#2E7D32',
    },
    owl: {
      name: '慧慧',
      primaryColor: '#2196F3',
      secondaryColor: '#64B5F6',
      glowColor: 'rgba(33,150,243,0.3)',
      glassColor: '#90CAF9',
      hatColor: '#1A237E',
      beakColor: '#FF9800',
    },
  };

  /** 动画帧配置 */
  const animFrames = {
    blink: 3,
    wave: 5,
    jump: 6,
    glow: 1, // 持续效果
  };

  // ========== 辅助绘制函数 ==========

  /**
   * 绘制圆角矩形身体
   * @param {CanvasRenderingContext2D} ctx
   */
  function _drawRoundedBody(ctx, x, y, w, h, color, strokeColor) {
    const r = Math.min(w, h) * 0.3;
    ctx.save();
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
    ctx.fillStyle = color;
    ctx.fill();
    if (strokeColor) {
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth = 2;
      ctx.stroke();
    }
    ctx.restore();
  }

  /**
   * 绘制眼睛（支持多种表情）
   * @param {string} emotion - happy, worried, excited, calm, brave
   */
  function _drawEyes(ctx, x, y, size, emotion, frame) {
    const eyeSpacing = size * 0.22;
    const eyeSize = size * 0.12;
    const lx = x - eyeSpacing;
    const rx = x + eyeSpacing;

    ctx.save();

    // 眨眼处理
    const blinkFrame = frame !== undefined ? frame % 30 : -1;
    const isBlinking = blinkFrame >= 0 && blinkFrame < 3;

    if (isBlinking) {
      // 眨眼：画线
      ctx.strokeStyle = '#333';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(lx - eyeSize, y);
      ctx.lineTo(lx + eyeSize, y);
      ctx.moveTo(rx - eyeSize, y);
      ctx.lineTo(rx + eyeSize, y);
      ctx.stroke();
      ctx.restore();
      return;
    }

    switch (emotion) {
      case 'happy':
        // 笑眼 - 弯弯的弧线
        ctx.strokeStyle = '#333';
        ctx.lineWidth = 2.5;
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.arc(lx, y + eyeSize * 0.3, eyeSize, Math.PI * 0.1, Math.PI * 0.9);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(rx, y + eyeSize * 0.3, eyeSize, Math.PI * 0.1, Math.PI * 0.9);
        ctx.stroke();
        break;

      case 'worried':
        // 八字眉 + 圆眼
        _drawRoundEye(ctx, lx, y, eyeSize);
        _drawRoundEye(ctx, rx, y, eyeSize);
        // 八字眉
        ctx.strokeStyle = '#333';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(lx - eyeSize, y - eyeSize * 1.4);
        ctx.lineTo(lx + eyeSize * 0.5, y - eyeSize * 1.8);
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(rx + eyeSize, y - eyeSize * 1.4);
        ctx.lineTo(rx - eyeSize * 0.5, y - eyeSize * 1.8);
        ctx.stroke();
        break;

      case 'excited':
        // 星星眼
        _drawStarEye(ctx, lx, y, eyeSize * 1.2);
        _drawStarEye(ctx, rx, y, eyeSize * 1.2);
        break;

      case 'brave':
        // 坚定眼神 - 粗眉+锐利眼
        _drawRoundEye(ctx, lx, y, eyeSize);
        _drawRoundEye(ctx, rx, y, eyeSize);
        // 粗平眉
        ctx.strokeStyle = '#333';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(lx - eyeSize * 1.1, y - eyeSize * 1.5);
        ctx.lineTo(lx + eyeSize * 1.1, y - eyeSize * 1.5);
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(rx - eyeSize * 1.1, y - eyeSize * 1.5);
        ctx.lineTo(rx + eyeSize * 1.1, y - eyeSize * 1.5);
        ctx.stroke();
        break;

      case 'calm':
      default:
        // 正常圆眼
        _drawRoundEye(ctx, lx, y, eyeSize);
        _drawRoundEye(ctx, rx, y, eyeSize);
        break;
    }
    ctx.restore();
  }

  /** 绘制圆形眼睛 */
  function _drawRoundEye(ctx, cx, cy, r) {
    // 白色眼白
    ctx.fillStyle = '#FFF';
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = '#333';
    ctx.lineWidth = 1.5;
    ctx.stroke();
    // 黑色瞳孔
    ctx.fillStyle = '#333';
    ctx.beginPath();
    ctx.arc(cx, cy + r * 0.1, r * 0.55, 0, Math.PI * 2);
    ctx.fill();
    // 高光
    ctx.fillStyle = '#FFF';
    ctx.beginPath();
    ctx.arc(cx + r * 0.25, cy - r * 0.2, r * 0.2, 0, Math.PI * 2);
    ctx.fill();
  }

  /** 绘制星星眼 */
  function _drawStarEye(ctx, cx, cy, r) {
    ctx.save();
    ctx.fillStyle = '#FFD700';
    ctx.strokeStyle = '#FF9800';
    ctx.lineWidth = 1.5;
    _drawStar(ctx, cx, cy, r * 0.4, r, 5);
    ctx.fill();
    ctx.stroke();
    // 中心高光
    ctx.fillStyle = '#FFF';
    ctx.beginPath();
    ctx.arc(cx, cy, r * 0.2, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  /** 绘制五角星路径 */
  function _drawStar(ctx, cx, cy, innerR, outerR, points) {
    ctx.beginPath();
    for (let i = 0; i < points * 2; i++) {
      const angle = (i * Math.PI) / points - Math.PI / 2;
      const r = i % 2 === 0 ? outerR : innerR;
      const px = cx + Math.cos(angle) * r;
      const py = cy + Math.sin(angle) * r;
      if (i === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
  }

  /**
   * 绘制嘴巴（支持多种表情）
   */
  function _drawMouth(ctx, x, y, size, emotion) {
    const mouthW = size * 0.15;
    ctx.save();
    ctx.strokeStyle = '#333';
    ctx.fillStyle = '#FF6B6B';
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';

    switch (emotion) {
      case 'happy':
      case 'excited':
        // 大大的笑嘴
        ctx.beginPath();
        ctx.arc(x, y - mouthW * 0.3, mouthW, 0.1 * Math.PI, 0.9 * Math.PI);
        ctx.stroke();
        // 填充微笑
        ctx.beginPath();
        ctx.arc(x, y - mouthW * 0.3, mouthW * 0.8, 0, Math.PI);
        ctx.fillStyle = '#FF8A80';
        ctx.fill();
        break;

      case 'worried':
        // 波浪嘴
        ctx.beginPath();
        ctx.moveTo(x - mouthW, y);
        ctx.quadraticCurveTo(x - mouthW * 0.3, y + mouthW * 0.5, x, y);
        ctx.quadraticCurveTo(x + mouthW * 0.3, y - mouthW * 0.5, x + mouthW, y);
        ctx.stroke();
        break;

      case 'brave':
        // 坚定的一字嘴
        ctx.beginPath();
        ctx.moveTo(x - mouthW * 0.7, y);
        ctx.lineTo(x + mouthW * 0.7, y);
        ctx.stroke();
        break;

      case 'calm':
      default:
        // 微笑
        ctx.beginPath();
        ctx.arc(x, y - mouthW * 0.2, mouthW * 0.7, 0.1 * Math.PI, 0.9 * Math.PI);
        ctx.stroke();
        break;
    }
    ctx.restore();
  }

  /**
   * 绘制光晕效果
   */
  function _drawGlowEffect(ctx, x, y, radius, color) {
    ctx.save();
    const grad = ctx.createRadialGradient(x, y, radius * 0.2, x, y, radius);
    grad.addColorStop(0, color);
    grad.addColorStop(1, 'rgba(255,255,255,0)');
    ctx.fillStyle = grad;
    ctx.globalAlpha = 0.5;
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  /** 绘制腮红 */
  function _drawBlush(ctx, x, y, r) {
    ctx.save();
    ctx.globalAlpha = 0.3;
    ctx.fillStyle = '#FF8A80';
    ctx.beginPath();
    ctx.ellipse(x, y, r, r * 0.6, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  // ========== 角色具体绘制 ==========

  /**
   * 绘制老虎 - 勇勇
   * 圆圆的橙色脸，三角耳朵，黑色条纹，大眼睛，小红鼻，微笑嘴巴
   */
  function _drawTiger(ctx, x, y, size, emotion, frame) {
    const s = size;
    const cfg = characters.tiger;

    ctx.save();
    ctx.translate(x, y);

    // 跳跃动画偏移
    let jumpOffset = 0;
    if (frame !== undefined) {
      const jumpFrame = frame % 60;
      if (jumpFrame < 6) {
        jumpOffset = -Math.sin((jumpFrame / 6) * Math.PI) * s * 0.15;
      }
    }

    // 光晕
    _drawGlowEffect(ctx, 0, jumpOffset, s * 0.7, cfg.glowColor);

    // 尾巴
    ctx.save();
    ctx.translate(0, jumpOffset);
    ctx.strokeStyle = cfg.primaryColor;
    ctx.lineWidth = s * 0.06;
    ctx.lineCap = 'round';
    const tailWave = frame ? Math.sin(frame * 0.1) * s * 0.05 : 0;
    ctx.beginPath();
    ctx.moveTo(s * 0.2, s * 0.15);
    ctx.quadraticCurveTo(s * 0.4, s * 0.05 + tailWave, s * 0.35, -s * 0.1);
    ctx.quadraticCurveTo(s * 0.38, -s * 0.2, s * 0.28, -s * 0.15);
    ctx.stroke();

    // 身体
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.ellipse(0, s * 0.18, s * 0.22, s * 0.2, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = cfg.stripeColor;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // 肚皮
    ctx.fillStyle = cfg.bellyColor;
    ctx.beginPath();
    ctx.ellipse(0, s * 0.2, s * 0.14, s * 0.14, 0, 0, Math.PI * 2);
    ctx.fill();

    // 四肢（短粗）
    ctx.fillStyle = cfg.primaryColor;
    const limbW = s * 0.07;
    const limbH = s * 0.1;
    // 左前腿
    _drawRoundedBody(ctx, -s * 0.18, s * 0.28, limbW, limbH, cfg.primaryColor);
    // 右前腿
    _drawRoundedBody(ctx, s * 0.11, s * 0.28, limbW, limbH, cfg.primaryColor);
    // 左后腿
    _drawRoundedBody(ctx, -s * 0.16, s * 0.32, limbW * 1.1, limbH * 0.8, cfg.primaryColor);
    // 右后腿
    _drawRoundedBody(ctx, s * 0.08, s * 0.32, limbW * 1.1, limbH * 0.8, cfg.primaryColor);

    // 头部
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.arc(0, -s * 0.1, s * 0.25, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = cfg.stripeColor;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // 耳朵（三角形）
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.moveTo(-s * 0.2, -s * 0.28);
    ctx.lineTo(-s * 0.28, -s * 0.42);
    ctx.lineTo(-s * 0.1, -s * 0.3);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    // 耳朵内部
    ctx.fillStyle = '#FFAB91';
    ctx.beginPath();
    ctx.moveTo(-s * 0.18, -s * 0.29);
    ctx.lineTo(-s * 0.25, -s * 0.38);
    ctx.lineTo(-s * 0.12, -s * 0.3);
    ctx.closePath();
    ctx.fill();

    // 右耳
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.moveTo(s * 0.2, -s * 0.28);
    ctx.lineTo(s * 0.28, -s * 0.42);
    ctx.lineTo(s * 0.1, -s * 0.3);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    ctx.fillStyle = '#FFAB91';
    ctx.beginPath();
    ctx.moveTo(s * 0.18, -s * 0.29);
    ctx.lineTo(s * 0.25, -s * 0.38);
    ctx.lineTo(s * 0.12, -s * 0.3);
    ctx.closePath();
    ctx.fill();

    // 黑色条纹（额头）
    ctx.strokeStyle = cfg.stripeColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(-s * 0.06, -s * 0.3);
    ctx.lineTo(-s * 0.08, -s * 0.22);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(0, -s * 0.32);
    ctx.lineTo(0, -s * 0.23);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(s * 0.06, -s * 0.3);
    ctx.lineTo(s * 0.08, -s * 0.22);
    ctx.stroke();

    // 脸颊白色区域
    ctx.fillStyle = cfg.bellyColor;
    ctx.beginPath();
    ctx.ellipse(-s * 0.1, -s * 0.04, s * 0.09, s * 0.07, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.ellipse(s * 0.1, -s * 0.04, s * 0.09, s * 0.07, 0, 0, Math.PI * 2);
    ctx.fill();

    // 眼睛
    _drawEyes(ctx, 0, -s * 0.12, s, emotion, frame);

    // 鼻子（红色小三角）
    ctx.fillStyle = '#E57373';
    ctx.beginPath();
    ctx.moveTo(0, -s * 0.03);
    ctx.lineTo(-s * 0.035, -s * 0.06);
    ctx.lineTo(s * 0.035, -s * 0.06);
    ctx.closePath();
    ctx.fill();

    // 嘴巴
    _drawMouth(ctx, 0, s * 0.04, s, emotion);

    // 腮红
    _drawBlush(ctx, -s * 0.17, -s * 0.02, s * 0.05);
    _drawBlush(ctx, s * 0.17, -s * 0.02, s * 0.05);

    // 胡须
    ctx.strokeStyle = '#555';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(-s * 0.12, -s * 0.02);
    ctx.lineTo(-s * 0.25, -s * 0.04);
    ctx.moveTo(-s * 0.12, 0);
    ctx.lineTo(-s * 0.25, 0.01);
    ctx.moveTo(s * 0.12, -s * 0.02);
    ctx.lineTo(s * 0.25, -s * 0.04);
    ctx.moveTo(s * 0.12, 0);
    ctx.lineTo(s * 0.25, 0.01);
    ctx.stroke();

    ctx.restore(); // jumpOffset
    ctx.restore(); // translate
  }

  /**
   * 绘制孔雀 - 彩彩
   * 紫色圆脸，小皇冠/羽冠，大眼睛带睫毛，粉色小嘴，展开彩色尾羽
   */
  function _drawPeacock(ctx, x, y, size, emotion, frame) {
    const s = size;
    const cfg = characters.peacock;

    ctx.save();
    ctx.translate(x, y);

    // 光晕
    _drawGlowEffect(ctx, 0, 0, s * 0.75, cfg.glowColor);

    // 尾羽（扇形展开）
    const tailSpread = frame ? 0.8 + Math.sin(frame * 0.03) * 0.1 : 0.85;
    const featherCount = 7;
    const fanAngle = Math.PI * tailSpread;
    const startAngle = -Math.PI / 2 - fanAngle / 2;

    for (let i = 0; i < featherCount; i++) {
      const angle = startAngle + (fanAngle / (featherCount - 1)) * i;
      const featherLen = s * 0.5;
      const tipX = Math.cos(angle) * featherLen;
      const tipY = Math.sin(angle) * featherLen + s * 0.05;
      const color = cfg.tailColors[i % cfg.tailColors.length];

      ctx.save();
      // 羽毛柄
      ctx.strokeStyle = color;
      ctx.lineWidth = s * 0.02;
      ctx.beginPath();
      ctx.moveTo(0, s * 0.05);
      ctx.lineTo(tipX, tipY);
      ctx.stroke();

      // 羽毛眼睛图案
      const eyeR = s * 0.055;
      ctx.fillStyle = color;
      ctx.beginPath();
      ctx.arc(tipX, tipY, eyeR, 0, Math.PI * 2);
      ctx.fill();
      // 内圈
      ctx.fillStyle = '#FFD700';
      ctx.beginPath();
      ctx.arc(tipX, tipY, eyeR * 0.6, 0, Math.PI * 2);
      ctx.fill();
      // 中心
      ctx.fillStyle = '#1A237E';
      ctx.beginPath();
      ctx.arc(tipX, tipY, eyeR * 0.3, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }

    // 身体
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.ellipse(0, s * 0.18, s * 0.16, s * 0.18, 0, 0, Math.PI * 2);
    ctx.fill();

    // 身体高光
    ctx.fillStyle = 'rgba(255,255,255,0.15)';
    ctx.beginPath();
    ctx.ellipse(-s * 0.04, s * 0.12, s * 0.08, s * 0.12, -0.2, 0, Math.PI * 2);
    ctx.fill();

    // 小脚
    ctx.fillStyle = '#FF9800';
    ctx.beginPath();
    ctx.ellipse(-s * 0.06, s * 0.36, s * 0.03, s * 0.02, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.ellipse(s * 0.06, s * 0.36, s * 0.03, s * 0.02, 0, 0, Math.PI * 2);
    ctx.fill();

    // 头部
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.arc(0, -s * 0.08, s * 0.2, 0, Math.PI * 2);
    ctx.fill();

    // 皇冠/羽冠
    const crownY = -s * 0.28;
    ctx.fillStyle = cfg.crownColor;
    for (let i = -1; i <= 1; i++) {
      ctx.beginPath();
      ctx.arc(i * s * 0.05, crownY - s * 0.04, s * 0.02, 0, Math.PI * 2);
      ctx.fill();
      // 冠柄
      ctx.strokeStyle = cfg.crownColor;
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(i * s * 0.03, -s * 0.22);
      ctx.lineTo(i * s * 0.05, crownY - s * 0.02);
      ctx.stroke();
    }

    // 眼睛（带睫毛）
    _drawEyes(ctx, 0, -s * 0.1, s, emotion, frame);
    // 睫毛
    ctx.strokeStyle = '#333';
    ctx.lineWidth = 1.5;
    const eyeSpacing = s * 0.22;
    for (let side = -1; side <= 1; side += 2) {
      const ex = side * eyeSpacing * 0.5; // 调整到眼睛中心附近
      for (let j = -1; j <= 1; j++) {
        ctx.beginPath();
        const angle = (side === -1 ? Math.PI * 0.7 : Math.PI * 0.3) + j * 0.2;
        ctx.moveTo(ex + side * s * 0.06, -s * 0.14);
        ctx.lineTo(
          ex + side * s * 0.06 + Math.cos(angle) * s * 0.04,
          -s * 0.14 + Math.sin(angle) * s * 0.04 - s * 0.03
        );
        ctx.stroke();
      }
    }

    // 嘴巴（小粉嘴）
    ctx.fillStyle = '#FF80AB';
    ctx.beginPath();
    ctx.moveTo(0, -s * 0.01);
    ctx.lineTo(-s * 0.025, -s * 0.04);
    ctx.lineTo(s * 0.025, -s * 0.04);
    ctx.closePath();
    ctx.fill();

    _drawMouth(ctx, 0, s * 0.04, s * 0.7, emotion);

    // 腮红
    _drawBlush(ctx, -s * 0.15, -s * 0.02, s * 0.04);
    _drawBlush(ctx, s * 0.15, -s * 0.02, s * 0.04);

    ctx.restore();
  }

  /**
   * 绘制考拉 - 暖暖
   * 绿色/灰色圆脸，大圆耳朵(毛茸茸)，温柔大眼，黑色小鼻，微笑嘴，拿着小树叶
   */
  function _drawKoala(ctx, x, y, size, emotion, frame) {
    const s = size;
    const cfg = characters.koala;

    ctx.save();
    ctx.translate(x, y);

    // 光晕
    _drawGlowEffect(ctx, 0, 0, s * 0.65, cfg.glowColor);

    // 身体
    ctx.fillStyle = cfg.secondaryColor;
    ctx.beginPath();
    ctx.ellipse(0, s * 0.2, s * 0.2, s * 0.22, 0, 0, Math.PI * 2);
    ctx.fill();

    // 肚皮
    ctx.fillStyle = cfg.earInner;
    ctx.beginPath();
    ctx.ellipse(0, s * 0.22, s * 0.13, s * 0.15, 0, 0, Math.PI * 2);
    ctx.fill();

    // 四肢
    ctx.fillStyle = cfg.secondaryColor;
    // 左臂
    ctx.beginPath();
    ctx.ellipse(-s * 0.22, s * 0.15, s * 0.06, s * 0.12, 0.3, 0, Math.PI * 2);
    ctx.fill();
    // 右臂（拿树叶的手）
    ctx.beginPath();
    ctx.ellipse(s * 0.22, s * 0.15, s * 0.06, s * 0.12, -0.3, 0, Math.PI * 2);
    ctx.fill();
    // 左腿
    ctx.beginPath();
    ctx.ellipse(-s * 0.1, s * 0.38, s * 0.06, s * 0.05, 0, 0, Math.PI * 2);
    ctx.fill();
    // 右腿
    ctx.beginPath();
    ctx.ellipse(s * 0.1, s * 0.38, s * 0.06, s * 0.05, 0, 0, Math.PI * 2);
    ctx.fill();

    // 树叶（右手拿）
    const leafAngle = frame ? Math.sin(frame * 0.05) * 0.15 : 0;
    ctx.save();
    ctx.translate(s * 0.28, s * 0.06);
    ctx.rotate(leafAngle - 0.3);
    ctx.fillStyle = cfg.leafColor;
    ctx.beginPath();
    ctx.ellipse(0, 0, s * 0.03, s * 0.08, 0, 0, Math.PI * 2);
    ctx.fill();
    // 叶脉
    ctx.strokeStyle = '#1B5E20';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, -s * 0.07);
    ctx.lineTo(0, s * 0.07);
    ctx.stroke();
    ctx.restore();

    // 耳朵（大圆毛茸茸）
    // 左耳外圈
    ctx.fillStyle = cfg.secondaryColor;
    ctx.beginPath();
    ctx.arc(-s * 0.22, -s * 0.22, s * 0.12, 0, Math.PI * 2);
    ctx.fill();
    // 左耳内圈（毛茸茸效果用浅色）
    ctx.fillStyle = cfg.earInner;
    ctx.beginPath();
    ctx.arc(-s * 0.22, -s * 0.22, s * 0.08, 0, Math.PI * 2);
    ctx.fill();

    // 右耳
    ctx.fillStyle = cfg.secondaryColor;
    ctx.beginPath();
    ctx.arc(s * 0.22, -s * 0.22, s * 0.12, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = cfg.earInner;
    ctx.beginPath();
    ctx.arc(s * 0.22, -s * 0.22, s * 0.08, 0, Math.PI * 2);
    ctx.fill();

    // 头部
    ctx.fillStyle = cfg.secondaryColor;
    ctx.beginPath();
    ctx.arc(0, -s * 0.08, s * 0.22, 0, Math.PI * 2);
    ctx.fill();

    // 眼睛（温柔大眼）
    _drawEyes(ctx, 0, -s * 0.1, s * 0.9, emotion, frame);

    // 鼻子（黑色椭圆）
    ctx.fillStyle = cfg.noseColor;
    ctx.beginPath();
    ctx.ellipse(0, -s * 0.02, s * 0.035, s * 0.025, 0, 0, Math.PI * 2);
    ctx.fill();

    // 嘴巴
    _drawMouth(ctx, 0, s * 0.05, s * 0.8, emotion || 'happy');

    // 腮红（温暖的粉色）
    _drawBlush(ctx, -s * 0.14, 0.01, s * 0.05);
    _drawBlush(ctx, s * 0.14, 0.01, s * 0.05);

    ctx.restore();
  }

  /**
   * 绘制猫头鹰 - 慧慧
   * 蓝色圆脸，大圆眼(眼镜效果)，小尖嘴，蓬松身体，学士帽
   */
  function _drawOwl(ctx, x, y, size, emotion, frame) {
    const s = size;
    const cfg = characters.owl;

    ctx.save();
    ctx.translate(x, y);

    // 光晕
    _drawGlowEffect(ctx, 0, 0, s * 0.65, cfg.glowColor);

    // 翅膀
    const wingFlap = frame ? Math.sin(frame * 0.08) * 0.15 : 0;
    ctx.fillStyle = cfg.secondaryColor;
    // 左翅
    ctx.save();
    ctx.translate(-s * 0.2, s * 0.05);
    ctx.rotate(-0.3 + wingFlap);
    ctx.beginPath();
    ctx.ellipse(0, 0, s * 0.08, s * 0.18, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
    // 右翅
    ctx.save();
    ctx.translate(s * 0.2, s * 0.05);
    ctx.rotate(0.3 - wingFlap);
    ctx.beginPath();
    ctx.ellipse(0, 0, s * 0.08, s * 0.18, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();

    // 身体（蓬松椭圆）
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.ellipse(0, s * 0.15, s * 0.2, s * 0.22, 0, 0, Math.PI * 2);
    ctx.fill();

    // 胸前羽毛纹理（浅色V字）
    ctx.strokeStyle = cfg.secondaryColor;
    ctx.lineWidth = 1.5;
    for (let i = 0; i < 4; i++) {
      const cy = s * 0.06 + i * s * 0.06;
      ctx.beginPath();
      ctx.moveTo(-s * 0.08, cy);
      ctx.lineTo(0, cy + s * 0.03);
      ctx.lineTo(s * 0.08, cy);
      ctx.stroke();
    }

    // 小脚爪
    ctx.fillStyle = '#FF9800';
    ctx.beginPath();
    ctx.moveTo(-s * 0.07, s * 0.35);
    ctx.lineTo(-s * 0.1, s * 0.39);
    ctx.lineTo(-s * 0.06, s * 0.39);
    ctx.lineTo(-s * 0.04, s * 0.35);
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(s * 0.04, s * 0.35);
    ctx.lineTo(s * 0.06, s * 0.39);
    ctx.lineTo(s * 0.1, s * 0.39);
    ctx.lineTo(s * 0.07, s * 0.35);
    ctx.fill();

    // 头部
    ctx.fillStyle = cfg.primaryColor;
    ctx.beginPath();
    ctx.arc(0, -s * 0.1, s * 0.22, 0, Math.PI * 2);
    ctx.fill();

    // 面盘（浅色圆）
    ctx.fillStyle = cfg.glassColor;
    ctx.globalAlpha = 0.3;
    ctx.beginPath();
    ctx.arc(0, -s * 0.08, s * 0.18, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;

    // 眼镜效果
    const glassR = s * 0.1;
    const glassSpacing = s * 0.11;
    // 镜框
    ctx.strokeStyle = '#333';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(-glassSpacing, -s * 0.1, glassR, 0, Math.PI * 2);
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(glassSpacing, -s * 0.1, glassR, 0, Math.PI * 2);
    ctx.stroke();
    // 鼻梁
    ctx.beginPath();
    ctx.moveTo(-glassSpacing + glassR, -s * 0.1);
    ctx.lineTo(glassSpacing - glassR, -s * 0.1);
    ctx.stroke();

    // 眼睛（在眼镜内）
    _drawEyes(ctx, 0, -s * 0.1, s * 0.85, emotion, frame);

    // 嘴巴（小尖嘴）
    ctx.fillStyle = cfg.beakColor;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(-s * 0.03, -s * 0.04);
    ctx.lineTo(s * 0.03, -s * 0.04);
    ctx.closePath();
    ctx.fill();
    ctx.strokeStyle = '#E65100';
    ctx.lineWidth = 1;
    ctx.stroke();

    // 学士帽
    const hatY = -s * 0.3;
    ctx.fillStyle = cfg.hatColor;
    // 帽板（菱形）
    ctx.beginPath();
    ctx.moveTo(0, hatY - s * 0.06);
    ctx.lineTo(s * 0.2, hatY);
    ctx.lineTo(0, hatY + s * 0.03);
    ctx.lineTo(-s * 0.2, hatY);
    ctx.closePath();
    ctx.fill();
    // 帽身（方形）
    ctx.fillStyle = cfg.hatColor;
    ctx.fillRect(-s * 0.08, hatY, s * 0.16, s * 0.07);
    // 帽穗
    ctx.strokeStyle = '#FFD700';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(s * 0.1, hatY);
    ctx.quadraticCurveTo(s * 0.2, hatY + s * 0.05, s * 0.15, hatY + s * 0.12);
    ctx.stroke();
    // 穗尾小球
    ctx.fillStyle = '#FFD700';
    ctx.beginPath();
    ctx.arc(s * 0.15, hatY + s * 0.12, s * 0.02, 0, Math.PI * 2);
    ctx.fill();

    // 角色眉毛（体现智慧感）
    if (emotion !== 'worried') {
      ctx.strokeStyle = '#1A237E';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(-glassSpacing, -s * 0.18, glassR * 0.7, Math.PI * 1.15, Math.PI * 1.85);
      ctx.stroke();
      ctx.beginPath();
      ctx.arc(glassSpacing, -s * 0.18, glassR * 0.7, Math.PI * 1.15, Math.PI * 1.85);
      ctx.stroke();
    }

    ctx.restore();
  }

  // ========== 公开API ==========

  return {
    /** 获取角色配置 */
    getCharacter(id) {
      return characters[id] || null;
    },

    /**
     * 绘制完整角色
     * @param {CanvasRenderingContext2D} ctx - Canvas上下文
     * @param {string} characterId - 角色ID：tiger/peacock/koala/owl
     * @param {number} x - 中心X坐标
     * @param {number} y - 中心Y坐标
     * @param {number} size - 角色尺寸
     * @param {Object} [options] - 绘制选项
     * @param {string} [options.emotion='calm'] - 表情状态
     * @param {string} [options.action='idle'] - 动作状态
     * @param {number} [options.frame=0] - 动画帧序号
     * @param {string} [options.facing='front'] - 朝向
     */
    draw(ctx, characterId, x, y, size, options) {
      const opts = Object.assign(
        { emotion: 'calm', action: 'idle', frame: 0, facing: 'front' },
        options
      );

      ctx.save();

      // 朝向翻转
      if (opts.facing === 'left') {
        ctx.translate(x, 0);
        ctx.scale(-1, 1);
        ctx.translate(-x, 0);
      }

      switch (characterId) {
        case 'tiger':
          _drawTiger(ctx, x, y, size, opts.emotion, opts.frame);
          break;
        case 'peacock':
          _drawPeacock(ctx, x, y, size, opts.emotion, opts.frame);
          break;
        case 'koala':
          _drawKoala(ctx, x, y, size, opts.emotion, opts.frame);
          break;
        case 'owl':
          _drawOwl(ctx, x, y, size, opts.emotion, opts.frame);
          break;
        default:
          console.warn('CharacterRenderer: unknown character', characterId);
      }
      ctx.restore();
    },

    /**
     * 绘制角色头像（圆形，用于对话框）
     * @param {CanvasRenderingContext2D} ctx
     * @param {string} characterId
     * @param {number} x - 圆心X
     * @param {number} y - 圆心Y
     * @param {number} radius - 半径
     */
    drawAvatar(ctx, characterId, x, y, radius) {
      const cfg = characters[characterId];
      if (!cfg) return;

      ctx.save();
      // 圆形裁切
      ctx.beginPath();
      ctx.arc(x, y, radius, 0, Math.PI * 2);
      ctx.clip();

      // 背景
      const grad = ctx.createRadialGradient(x, y, 0, x, y, radius);
      grad.addColorStop(0, cfg.secondaryColor);
      grad.addColorStop(1, cfg.primaryColor);
      ctx.fillStyle = grad;
      ctx.fillRect(x - radius, y - radius, radius * 2, radius * 2);

      // 绘制角色（只显示头部区域）
      this.draw(ctx, characterId, x, y + radius * 0.3, radius * 2.2, {
        emotion: 'happy',
        frame: 0,
      });

      ctx.restore();

      // 头像边框
      ctx.strokeStyle = cfg.primaryColor;
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.arc(x, y, radius, 0, Math.PI * 2);
      ctx.stroke();
    },

    /**
     * 绘制小头像（用于欢迎页角色预览）
     * @param {CanvasRenderingContext2D} ctx
     * @param {string} characterId
     * @param {number} x
     * @param {number} y
     * @param {number} size
     */
    drawMiniAvatar(ctx, characterId, x, y, size) {
      const cfg = characters[characterId];
      if (!cfg) return;

      ctx.save();
      // 圆形背景
      const grad = ctx.createRadialGradient(x, y, 0, x, y, size / 2);
      grad.addColorStop(0, 'rgba(255,255,255,0.3)');
      grad.addColorStop(1, cfg.primaryColor + '44');
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(x, y, size / 2, 0, Math.PI * 2);
      ctx.fill();

      // 绘制简化角色
      this.draw(ctx, characterId, x, y + size * 0.1, size * 0.85, {
        emotion: 'happy',
        frame: 0,
      });
      ctx.restore();
    },

    /**
     * 获取动画帧信息
     * @param {string} characterId
     * @param {string} action - blink/wave/jump/glow
     * @param {number} frameIndex
     * @returns {Object} 帧信息
     */
    getFrame(characterId, action, frameIndex) {
      const totalFrames = animFrames[action] || 1;
      return {
        characterId,
        action,
        frame: frameIndex % totalFrames,
        totalFrames,
        loop: action === 'glow',
      };
    },

    // 暴露内部绘制方法以便扩展
    _drawTiger,
    _drawPeacock,
    _drawKoala,
    _drawOwl,
    _drawRoundedBody,
    _drawEyes,
    _drawMouth,
    _drawGlowEffect,
  };
})();
