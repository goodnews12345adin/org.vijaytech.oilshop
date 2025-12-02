(() => {
  // CONFIG - tweak as needed
  const CFG = {
    grid: 48,
    speed: 0.08,
    amp: 10,
    shimmerSpeed: 0.004,
    particleCount: 140,
    particleSpeed: 0.08,
    parallax: 18,
    dprCap: 2
  };

  // Respect reduced motion preference
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReduced) return;

  const stage = document.querySelector('.bg-stage');
  if (!stage) return;

  // create canvas
  const canvas = document.createElement('canvas');
  canvas.setAttribute('aria-hidden', 'true');
  stage.appendChild(canvas);
  const ctx = canvas.getContext('2d');

  let w = 0, h = 0;
  const dpr = Math.min(window.devicePixelRatio || 1, CFG.dprCap);

  function resize() {
    w = stage.clientWidth;
    h = stage.clientHeight;
    canvas.width = Math.floor(w * dpr);
    canvas.height = Math.floor(h * dpr);
    canvas.style.width = w + 'px';
    canvas.style.height = h + 'px';
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  resize();
  window.addEventListener('resize', resize, { passive: true });

  // helper to read CSS variables
  function getVars() {
    const cs = getComputedStyle(document.documentElement);
    return {
      thread: cs.getPropertyValue('--thread').trim() || 'rgba(255,160,190,0.75)',
      thread2: cs.getPropertyValue('--thread2').trim() || 'rgba(255,230,180,0.55)',
      spark: cs.getPropertyValue('--spark').trim() || 'rgba(255,255,255,0.9)'
    };
  }

  // particles
  const parts = [];
  function resetParticle(p) {
    p.x = Math.random() * w;
    p.y = Math.random() * h;
    p.r = Math.random() * 1.6 + 0.3;
    p.vx = (Math.random() - 0.5) * CFG.particleSpeed;
    p.vy = (Math.random() - 0.5) * CFG.particleSpeed;
    p.a = Math.random() * 0.7 + 0.2;
  }
  for (let i = 0; i < CFG.particleCount; i++) {
    const p = {};
    resetParticle(p);
    parts.push(p);
  }

  // mouse parallax
  let mx = 0, my = 0, tx = 0, ty = 0;
  window.addEventListener('mousemove', e => {
    const r = stage.getBoundingClientRect();
    mx = ((e.clientX - r.left) / r.width - 0.5) * 2;
    my = ((e.clientY - r.top) / r.height - 0.5) * 2;
  }, { passive: true });

  // ensure fallback when page hidden
  let t = 0;
  function draw() {
    const vars = getVars();
    ctx.clearRect(0, 0, w, h);
    tx += (mx * CFG.parallax - tx) * 0.04;
    ty += (my * CFG.parallax - ty) * 0.04;
    t += CFG.speed;
    const g = CFG.grid;

    // Horizontal threads
    ctx.lineWidth = 1.25;
    ctx.strokeStyle = vars.thread;
    for (let y = -g; y <= h + g; y += g) {
      const phase = (y / Math.max(h,1)) * Math.PI * 2 + t * 0.8;
      ctx.beginPath();
      for (let x = -g; x <= w + g; x += 8) {
        const yy = y + Math.sin(x * 0.03 + phase) * CFG.amp + ty;
        if (x === -g) ctx.moveTo(x + tx, yy);
        else ctx.lineTo(x + tx, yy);
      }
      ctx.stroke();
    }

    // Vertical threads
    ctx.lineWidth = 1.0;
    ctx.strokeStyle = vars.thread2;
    for (let x = -g; x <= w + g; x += g) {
      const phase = (x / Math.max(w,1)) * Math.PI * 2 + t * 0.9;
      ctx.beginPath();
      for (let y = -g; y <= h + g; y += 8) {
        const xx = x + Math.cos(y * 0.03 + phase) * CFG.amp + tx;
        if (y === -g) ctx.moveTo(xx, y + ty);
        else ctx.lineTo(xx, y + ty);
      }
      ctx.stroke();
    }

    // Light shimmer overlay
    const grad = ctx.createLinearGradient(0, 0, w, h);
    const p = (Math.sin(t * CFG.shimmerSpeed * 500) + 1) / 2;
    const a = 0.06 + p * 0.06;
    grad.addColorStop(0, 'rgba(255,255,255,0)');
    grad.addColorStop(0.5, `rgba(255,255,255,${a})`);
    grad.addColorStop(1, 'rgba(255,255,255,0)');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, w, h);

    // Particles
    ctx.fillStyle = vars.spark;
    for (const s of parts) {
      s.x += s.vx;
      s.y += s.vy;
      if (s.x < -10 || s.x > w + 10 || s.y < -10 || s.y > h + 10) resetParticle(s);
      ctx.globalAlpha = s.a;
      ctx.beginPath();
      ctx.arc(s.x + tx * 0.2, s.y + ty * 0.2, s.r, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }

  function loop() {
    if (!document.hidden) draw();
    requestAnimationFrame(loop);
  }
  requestAnimationFrame(loop);

})();
