/**
 * PDP魔法森林大冒险 - 粒子系统
 * 支持多种预设粒子效果：萤火虫、星光、落叶、魔法、彩纸、迷雾等
 */
window.ParticleSystem = (function() {
  'use strict';

  var systems = {};
  var sysId = 0;

  function Particle(config) {
    this.x = config.x || 0;
    this.y = config.y || 0;
    this.vx = config.vx || 0;
    this.vy = config.vy || 0;
    this.life = config.life || 2;
    this.maxLife = this.life;
    this.size = config.size || 3;
    this.color = config.color || '#FFD700';
    this.alpha = config.alpha || 1;
    this.rotation = config.rotation || 0;
    this.rotationSpeed = config.rotationSpeed || 0;
    this.shape = config.shape || 'circle';
    this.gravity = config.gravity || 0;
    this.friction = config.friction || 1;
    this.shrink = config.shrink || false;
  }

  Particle.prototype.update = function(dt) {
    this.life -= dt;
    this.vy += this.gravity * dt;
    this.vx *= this.friction;
    this.vy *= this.friction;
    this.x += this.vx * dt;
    this.y += this.vy * dt;
    this.rotation += this.rotationSpeed * dt;
    var lifeRatio = Math.max(0, this.life / this.maxLife);
    this.alpha = lifeRatio;
    if (this.shrink) this.size *= (0.98 + 0.02 * lifeRatio);
    return this.life > 0;
  };

  Particle.prototype.draw = function(ctx) {
    ctx.save();
    ctx.globalAlpha = this.alpha;
    ctx.translate(this.x, this.y);
    ctx.rotate(this.rotation);
    ctx.fillStyle = this.color;

    switch (this.shape) {
      case 'circle':
        ctx.beginPath();
        ctx.arc(0, 0, this.size, 0, Math.PI * 2);
        ctx.fill();
        break;
      case 'star':
        this._drawStar(ctx, this.size);
        break;
      case 'leaf':
        this._drawLeaf(ctx, this.size);
        break;
      case 'sparkle':
        this._drawSparkle(ctx, this.size);
        break;
      case 'square':
        ctx.fillRect(-this.size / 2, -this.size / 2, this.size, this.size);
        break;
      default:
        ctx.beginPath();
        ctx.arc(0, 0, this.size, 0, Math.PI * 2);
        ctx.fill();
    }
    ctx.restore();
  };

  Particle.prototype._drawStar = function(ctx, size) {
    ctx.beginPath();
    for (var i = 0; i < 5; i++) {
      var angle = (i * 4 * Math.PI / 5) - Math.PI / 2;
      var x = Math.cos(angle) * size;
      var y = Math.sin(angle) * size;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.fill();
  };

  Particle.prototype._drawLeaf = function(ctx, size) {
    ctx.beginPath();
    ctx.ellipse(0, 0, size, size * 0.4, 0, 0, Math.PI * 2);
    ctx.fill();
  };

  Particle.prototype._drawSparkle = function(ctx, size) {
    ctx.beginPath();
    ctx.moveTo(0, -size);
    ctx.lineTo(size * 0.3, -size * 0.3);
    ctx.lineTo(size, 0);
    ctx.lineTo(size * 0.3, size * 0.3);
    ctx.lineTo(0, size);
    ctx.lineTo(-size * 0.3, size * 0.3);
    ctx.lineTo(-size, 0);
    ctx.lineTo(-size * 0.3, -size * 0.3);
    ctx.closePath();
    ctx.fill();
  };

  // 预设配置
  var presets = {
    firefly: {
      count: 15, shape: 'circle', size: [2, 4], life: [3, 6],
      speed: [5, 15], colors: ['#FFD700', '#FFEB3B', '#FFF176'],
      gravity: 0, friction: 0.99, spread: 'area'
    },
    sparkle: {
      count: 20, shape: 'sparkle', size: [2, 5], life: [0.5, 1.5],
      speed: [30, 80], colors: ['#FFFFFF', '#FFD700', '#FFF9C4'],
      gravity: 0, friction: 0.96, spread: 'burst'
    },
    leaves: {
      count: 10, shape: 'leaf', size: [3, 6], life: [4, 8],
      speed: [5, 15], colors: ['#4CAF50', '#8BC34A', '#A5D6A7', '#795548'],
      gravity: 15, friction: 0.99, spread: 'top'
    },
    magic: {
      count: 25, shape: 'circle', size: [1, 4], life: [1, 3],
      speed: [20, 50], colors: ['#7C4DFF', '#E040FB', '#FF4081', '#FFD700'],
      gravity: -10, friction: 0.97, spread: 'burst'
    },
    confetti: {
      count: 40, shape: 'square', size: [3, 7], life: [2, 4],
      speed: [50, 120], colors: ['#FF4081', '#FFD700', '#4CAF50', '#2196F3', '#FF9800', '#7C4DFF'],
      gravity: 80, friction: 0.98, spread: 'burst'
    },
    fog: {
      count: 8, shape: 'circle', size: [30, 60], life: [5, 10],
      speed: [3, 8], colors: ['rgba(100,0,200,0.15)', 'rgba(50,0,100,0.1)'],
      gravity: 0, friction: 1, spread: 'area'
    },
    energy: {
      count: 30, shape: 'circle', size: [2, 5], life: [1, 2],
      speed: [40, 80], colors: ['#FFD700', '#FF9800'],
      gravity: 0, friction: 0.95, spread: 'converge'
    },
    snow: {
      count: 30, shape: 'circle', size: [1, 3], life: [5, 10],
      speed: [3, 10], colors: ['#FFFFFF', '#E3F2FD'],
      gravity: 10, friction: 0.99, spread: 'top'
    }
  };

  function _rand(min, max) {
    return min + Math.random() * (max - min);
  }

  function _randColor(colors) {
    return colors[Math.floor(Math.random() * colors.length)];
  }

  function _createParticle(preset, cx, cy, w, h) {
    var p = presets[preset];
    if (!p) p = presets.sparkle;
    var config = {
      size: _rand(p.size[0], p.size[1]),
      life: _rand(p.life[0], p.life[1]),
      color: _randColor(p.colors),
      shape: p.shape,
      gravity: p.gravity,
      friction: p.friction,
      rotation: Math.random() * Math.PI * 2,
      rotationSpeed: _rand(-2, 2),
      shrink: p.shape !== 'circle'
    };

    var speed = _rand(p.speed[0], p.speed[1]);
    var angle = Math.random() * Math.PI * 2;

    switch (p.spread) {
      case 'burst':
        config.x = cx;
        config.y = cy;
        config.vx = Math.cos(angle) * speed;
        config.vy = Math.sin(angle) * speed;
        break;
      case 'area':
        config.x = Math.random() * (w || 400);
        config.y = Math.random() * (h || 600);
        config.vx = Math.cos(angle) * speed * 0.3;
        config.vy = Math.sin(angle) * speed * 0.3;
        break;
      case 'top':
        config.x = Math.random() * (w || 400);
        config.y = -10;
        config.vx = _rand(-speed * 0.3, speed * 0.3);
        config.vy = _rand(speed * 0.2, speed);
        break;
      case 'converge':
        var dist = _rand(80, 150);
        config.x = cx + Math.cos(angle) * dist;
        config.y = cy + Math.sin(angle) * dist;
        config.vx = (cx - config.x) * 0.5;
        config.vy = (cy - config.y) * 0.5;
        break;
    }

    return new Particle(config);
  }

  return {
    /**
     * 创建持续粒子效果
     * @param {CanvasRenderingContext2D} ctx
     * @param {string} preset - 预设类型
     * @param {object} config - {x, y, width, height, count}
     * @returns {number} 系统ID
     */
    create: function(ctx, preset, config) {
      config = config || {};
      var id = ++sysId;
      var p = presets[preset] || presets.sparkle;
      var particles = [];
      var count = config.count || p.count;
      var cx = config.x || 0;
      var cy = config.y || 0;
      var w = config.width || 400;
      var h = config.height || 600;

      for (var i = 0; i < count; i++) {
        particles.push(_createParticle(preset, cx, cy, w, h));
      }

      systems[id] = {
        ctx: ctx,
        preset: preset,
        particles: particles,
        config: config,
        cx: cx, cy: cy, w: w, h: h,
        continuous: config.continuous !== false,
        maxCount: count
      };
      return id;
    },

    /** 更新粒子系统 */
    update: function(id, dt) {
      var sys = systems[id];
      if (!sys) return;
      dt = dt || 0.016;

      for (var i = sys.particles.length - 1; i >= 0; i--) {
        if (!sys.particles[i].update(dt)) {
          sys.particles.splice(i, 1);
        }
      }

      // 持续模式补充粒子
      if (sys.continuous && sys.particles.length < sys.maxCount) {
        sys.particles.push(_createParticle(sys.preset, sys.cx, sys.cy, sys.w, sys.h));
      }
    },

    /** 绘制粒子系统 */
    draw: function(id) {
      var sys = systems[id];
      if (!sys) return;
      for (var i = 0; i < sys.particles.length; i++) {
        sys.particles[i].draw(sys.ctx);
      }
    },

    /** 销毁粒子系统 */
    destroy: function(id) {
      delete systems[id];
    },

    /** 销毁全部 */
    destroyAll: function() {
      systems = {};
    },

    /**
     * 一次性爆发效果
     * @param {CanvasRenderingContext2D} ctx
     * @param {number} x
     * @param {number} y
     * @param {string} preset
     * @param {object} config
     */
    burst: function(ctx, x, y, preset, config) {
      config = config || {};
      config.continuous = false;
      config.x = x;
      config.y = y;
      return this.create(ctx, preset, config);
    },

    /** 获取系统粒子数 */
    getCount: function(id) {
      var sys = systems[id];
      return sys ? sys.particles.length : 0;
    }
  };
})();
