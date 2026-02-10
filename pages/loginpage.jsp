<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
<title>Vijaytechorbitsolutions — Login (Stylish)</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&family=Playfair+Display:wght@600;700;900&display=swap" rel="stylesheet">
<style>
  /* --------- DARK-PANELS FORMAT (outer light frame + inner dark navy panels) --------- */
  :root{
    --outer-frame:#c7c6dc;
    --bg-1: #f3f4f6;
    --bg-2: #eef2f6;
    --panel-dark: #08143a;
    --panel-dark-2: #09184b;
    --accent-a: #19b6b0;
    --accent-b: #15a0c6;
    --accent-c: #3bd0c3;
    --muted-light: rgba(255,255,255,0.76);
    --muted: #9aa6c3;
    --card-radius: 14px;
    --outer-radius: 18px;
    --success: #16a34a;
    --danger: #ef4444;
    --focus-shadow: 0 10px 30px rgba(0,0,0,0.35);
    --panel-border: rgba(255,255,255,0.03);
  }

  *{box-sizing:border-box}
  html,body{
    height:100%;
    margin:0;
    font-family:Inter,system-ui,-apple-system,"Segoe UI",Roboto,Arial;
    -webkit-font-smoothing:antialiased;
    color:#0f172a;
    background: linear-gradient(180deg,var(--bg-1),var(--bg-2));
  }

  .outer-frame {
    width:100%;
    /* Responsive width for different screens */
    max-width: 1400px; /* Increased slightly for Large TVs */
    margin:36px auto;
    padding:20px;
    border-radius:var(--outer-radius);
    background: linear-gradient(180deg, #cfcfe0, #bfbfd8);
    box-shadow: 0 10px 40px rgba(14,20,45,0.06);
  }

  .wrap {
    border-radius:12px;
    padding:18px;
    background: linear-gradient(180deg, rgba(255,255,255,0.95), rgba(255,255,255,0.95));
  }

  .back-pattern {
    position:fixed;
    inset:0;
    z-index:0;
    pointer-events:none;
    opacity:0.45;
    background-image:
      linear-gradient(120deg, rgba(148,163,184,0.16) 0.5px, transparent 0.5px),
      linear-gradient(60deg, rgba(148,163,184,0.12) 0.5px, transparent 0.5px);
    background-size: 20px 20px;
    filter: blur(30px);
  }

  .card {
    position:relative;
    z-index:2;
    width:100%;
    margin:0 auto;
    display:grid;
    grid-template-columns: 360px 1fr; /* Default Desktop layout */
    gap:22px;
    padding:22px;
    border-radius:12px;
    background: transparent;
    overflow:hidden;
    /* Glassmorphism effect for the card itself */
    background: rgba(255, 255, 255, 0.7);
    backdrop-filter: blur(10px);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  }

  .left, .right {
    padding:22px;
    border-radius:12px;
    min-height:380px; /* Slightly increased height */
    background: linear-gradient(180deg, var(--panel-dark), var(--panel-dark-2));
    border: 1px solid rgba(255,255,255,0.02);
    color: var(--muted-light);
    box-shadow: 0 18px 50px rgba(2,6,23,0.25);
  }

  .left {
    display:flex;
    flex-direction:column;
    gap:18px;
    align-items:flex-start;
    justify-content: center; /* Center content vertically for better look */
  }

  .logo-frame {
    width:96px;
    height:96px;
    border-radius:14px;
    overflow:hidden;
    display:grid;
    place-items:center;
    background:#ffffff;
    box-shadow: 0 10px 24px rgba(2,6,23,0.18);
    flex-shrink:0;
  }
  .logo-frame img{
    width:88%;
    height:88%;
    object-fit:contain;
    display:block;
  }
  .logo-fallback {
    width:100%;
    height:100%;
    display:grid;
    place-items:center;
    font-weight:900;
    color:#0b1b3e;
    font-size:20px;
    letter-spacing:0.6px;
  }

  /* --- PROFESSIONAL BRANDING TITLE --- */
  .brand-title {
    /* Dynamic font size for responsiveness */
    font-size: 22px; 
    font-weight: 900;
    margin:0;
    line-height: 1.3;
    color:#e6eefc;
    font-family:'Playfair Display', serif;
    cursor:pointer;
    display:inline-block;
    padding:4px 8px;
    border-radius:6px;
    transition: all 0.3s ease;
    
    /* Gradient Text for "Wonderful" look */
    background: linear-gradient(90deg, #ffffff 0%, #2dd4bf 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    
    /* Text Shadow for depth */
    text-shadow: 0 2px 4px rgba(0,0,0,0.3);
    
    /* Allow wrapping on very small screens */
    white-space: normal; 
    word-break: break-word;
  }

  .brand-title:hover { 
    transform: scale(1.02); 
    filter: drop-shadow(0 4px 8px rgba(45, 212, 191, 0.5)); 
    background: linear-gradient(90deg, #ffffff 0%, #19b6b0 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .brand-sub { color: rgba(230,238,252,0.9); font-size:13px; margin-top:8px; letter-spacing: 1px; text-transform: uppercase; font-weight: 600;}

  .feature-chips { display:flex; gap:8px; flex-wrap:wrap; margin-top:12px }
  .chip {
    padding:8px 12px;
    border-radius:999px;
    background: rgba(255,255,255,0.1);
    backdrop-filter: blur(4px);
    border: 1px solid rgba(255,255,255,0.1);
    color:#ffffff;
    font-weight:700;
    font-size:12px;
    box-shadow: 0 6px 16px rgba(2,6,23,0.14);
  }

  .muted-note { color: rgba(230,238,252,0.58); font-size:13px; line-height:1.5 }

  /* Software company details block */
  .company-details {
    width:100%;
    background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
    border: 1px solid rgba(255,255,255,0.03);
    padding:12px;
    border-radius:10px;
    margin-top:6px;
  }
  .company-details h4 {
    margin:0 0 6px 0;
    color:var(--muted-light);
    font-size:15px;
    font-weight:800;
  }
  .company-details p {
    margin:0 0 8px 0;
    color: rgba(230,238,252,0.62);
    font-size:13px;
    line-height:1.4;
  }
  .services-list { display:flex; flex-wrap:wrap; gap:8px; margin-top:6px }
  .service-item {
    padding:6px 10px;
    border-radius:10px;
    background: rgba(255,255,255,0.06);
    color: var(--muted-light);
    font-weight:600;
    font-size:12px;
    border:1px solid rgba(255,255,255,0.03);
  }

  /* RIGHT panel (form) */
  .right {
    display:flex;
    flex-direction:column;
    gap:12px;
    justify-content: center; /* Center form vertically */
  }

  .form-head { display:flex; justify-content:space-between; align-items:center; flex-wrap: wrap; gap: 10px; }
  .form-head h3 { margin:0; font-size:18px; font-weight:800; color:#e6eefc }
  .form-desc { color: rgba(230,238,252,0.6); font-size:13px }

  form { display:flex; flex-direction:column; gap:12px; margin-top:6px; width: 100%; }

  label { display:block; color: rgba(230,238,252,0.7); font-size:13px; margin-bottom:6px; font-weight: 600; }

  .input {
    display:flex; align-items:center; gap:10px;
    background: #ffffff;
    border-radius:14px; padding:12px 14px; /* Slightly larger for touch */
    box-shadow: 0 8px 22px rgba(2,6,23,0.12), inset 0 -6px 12px rgba(0,0,0,0.06);
    border:1px solid rgba(2,6,23,0.06);
    transition: box-shadow 0.2s ease;
  }
  .input:focus-within {
    box-shadow: 0 8px 30px rgba(2,6,23,0.2), inset 0 -6px 12px rgba(0,0,0,0.06);
    border-color: rgba(45, 212, 191, 0.3);
  }
  .input input { border:none; outline:none; background:transparent; font-size:15px; color:#08143a; width:100%; font-weight:600; }
  .input .icon { width:40px; height:40px; border-radius:10px; display:grid; place-items:center; background:linear-gradient(90deg, rgba(3,10,35,0.06), rgba(3,10,35,0.02)); color:#08143a; font-weight:800; }

  .pw-toggle {
    cursor:pointer; color:rgba(230,238,252,0.85); font-size:13px; padding:10px 14px; border-radius:10px;
    background: rgba(255,255,255,0.06); border:1px solid rgba(255,255,255,0.04); display:inline-flex; gap:8px; align-items:center; white-space: nowrap;
  }

  .pw-toggle:hover { transform:translateY(-1px) }

  .actions { display:flex; gap:12px; margin-top:6px; align-items:center }

  .btn { padding:14px 16px; border-radius:12px; cursor:pointer; font-weight:800; border:none; font-size:15px; transition: transform 0.1s ease; }
  .btn:active { transform: scale(0.98); }
  .btn:disabled { opacity: 0.5; cursor: not-allowed; filter: grayscale(1); }

  .btn-primary {
    background: linear-gradient(90deg, #2fa7b2, #18a9d1);
    color:#fff; flex:1; box-shadow: 0 14px 36px rgba(10,20,40,0.22);
  }
  .btn-primary:hover { filter:brightness(1.1); transform: translateY(-2px); }

  .btn-secondary {
    background:#ffffff; color:#08143a; padding:10px 12px; border-radius:10px; min-width:110px; box-shadow: 0 6px 18px rgba(2,6,23,0.12);
  }

  .small-row { display:flex; justify-content:space-between; align-items:center; margin-top:8px; color: rgba(230,238,252,0.6); font-size:13px; flex-wrap: wrap; gap: 5px; }

  .pw-strength { height:8px; border-radius:8px; background: rgba(255,255,255,0.08); overflow:hidden; margin-top:6px; }
  .pw-strength > i { display:block; height:100%; width:0%; transition: width .35s ease; background: linear-gradient(90deg,#18a9d1,#2fa7b2); }

  .pw-note { font-size:12px; color: rgba(230,238,252,0.6); margin-top:6px; display:flex; justify-content:space-between; align-items:center }

  /* --- ENHANCED SHOP BADGE --- */
  .shop-badge { display:flex; gap:12px; align-items:center; color: rgba(230,238,252,0.6); font-size:13px; cursor: pointer; padding: 8px 12px; border-radius: 12px; transition: background 0.2s; background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.05); }
  .shop-badge:hover { background: rgba(255,255,255,0.08); }
  .shop-badge .shop-tooltip { font-size:11px; opacity: 0; transition: opacity 0.2s; margin-left: 8px; color: var(--accent-c); }
  .shop-badge:hover .shop-tooltip { opacity: 1; }

  .shop-logo { width:48px; height:48px; border-radius:10px; overflow:hidden; display:grid; place-items:center; background:#0b1b3e; box-shadow: 0 10px 30px rgba(2,6,23,0.12); flex-shrink:0; border: 1px solid rgba(255,255,255,0.1); }
  .shop-logo img{ width:92%; height:92%; object-fit:contain; display:block; }
  .shop-name { font-weight:900; color: #ffffff; font-size: 16px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:220px; text-shadow: 0 2px 4px rgba(0,0,0,0.5); }

  .dropzone { flex:1; border-radius:12px; padding:10px; border:1px dashed rgba(255,255,255,0.06); text-align:center; color: rgba(230,238,252,0.6); font-size:13px; background: transparent; }
  .dropzone.dragover { border-color: rgba(60,200,200,0.6); background: rgba(255,255,255,0.02); color:#fff; }

  .error { color: #ffc1c1; font-size:13px; margin-top:6px }
  .hidden { display:none }

  /* Spinner */
  .spinner { width:16px; height:16px; border-radius:50%; border:2px solid rgba(255,255,255,0.28); border-top-color:#fff; animation: spin .9s linear infinite; }
  @keyframes spin { to { transform: rotate(360deg) } }
  .sr-only { position:absolute !important; height:1px; width:1px; overflow:hidden; clip:rect(1px,1px,1px,1px); white-space:nowrap; }

  /* Modal Styles */
  .modal-backdrop { position:fixed; inset:0; background:rgba(2,6,23,0.6); display:none; z-index:60; align-items:center; justify-content:center; padding:20px; backdrop-filter: blur(4px); }
  .modal { background:#ffffff; border-radius:12px; padding:24px; width:720px; max-width:96%; color:#0f172a; box-shadow: 0 30px 120px rgba(2,6,23,0.45); border:1px solid rgba(2,6,23,0.06); max-height: 90vh; overflow-y: auto; }
  .modal h4 { margin:0 0 16px 0; font-size:20px; color:#0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 10px; }
  .modal-row { display:flex; gap:16px; align-items:flex-start; margin-bottom:20px; flex-wrap: wrap; }
  .modal .preview { width:80px; height:80px; border-radius:10px; overflow:hidden; display:grid; place-items:center; background:#f8fafc; border:1px solid rgba(209,213,219,0.9); flex-shrink: 0; }
  .modal .controls { flex:1; min-width: 200px; }
  .modal .inline-file { display:flex; gap:10px; align-items:center; flex-wrap: wrap; }
  .modal .modal-actions { display:flex; gap:10px; justify-content:flex-end; margin-top:20px; border-top: 1px solid #e2e8f0; padding-top: 16px; }
  .modal .text-input { width:100%; padding:10px 12px; border-radius:8px; border:1px solid #cbd5e1; background:#ffffff; color:#0f172a; font-size: 15px; transition: border-color 0.2s; }
  .modal .text-input:focus { border-color: #15a0c6; outline: none; }
  .modal input[type="file"] { font-size: 13px; color: #475569; }
  .modal input[type="file"]:disabled { opacity: 0.5; cursor: not-allowed; }
  .modal-section-title { font-size: 14px; font-weight: 700; color: #334155; margin-bottom: 8px; display: block; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; }
  
  /* Lock State Styling */
  .controls-locked { opacity: 0.6; pointer-events: none; position: relative; }
  .controls-locked::after { content: "LOCKED"; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); font-weight: bold; font-size: 24px; color: rgba(0,0,0,0.1); border: 2px solid rgba(0,0,0,0.1); padding: 5px 10px; border-radius: 4px; letter-spacing: 2px; pointer-events: none; }
  .locked-badge { display:inline-block; background:#ef4444; color:#fff; font-size:10px; padding:2px 6px; border-radius:4px; margin-left:8px; text-transform:uppercase; font-weight:700; vertical-align: middle; }

  /* =========================================
     RESPONSIVE MEDIA QUERIES (ALL DEVICES)
     ========================================= */

  /* Mobile Devices (Small S, S, L) */
  @media (max-width: 600px) {
    html, body { font-size: 14px; }
    
    .outer-frame {
      width: 100%;
      max-width: 100%;
      margin: 0;
      border-radius: 0;
      padding: 0;
      background: #f3f4f6;
      box-shadow: none;
      height: 100vh;
      display: flex;
      flex-direction: column;
    }

    .wrap {
      flex: 1;
      border-radius: 0;
      padding: 10px;
      display: flex;
      flex-direction: column;
      background: transparent;
    }

    .card {
      display: flex;
      flex-direction: column;
      padding: 20px; /* More breathing room */
      border-radius: 16px;
      height: 100%;
      overflow-y: auto;
      background: rgba(255,255,255,0.85); /* Slightly more opaque for readability */
      box-shadow: 0 0 0 100vmax rgba(255,255,255,0.5); 
    }

    .left, .right {
      background: var(--panel-dark); 
      padding: 20px;
      width: 100%;
      align-items: center; /* Center horizontally */
      text-align: center; /* Center text */
    }
    
    /* Ensure Layout works vertically on mobile */
    .left { order: 2; /* Move branding below form or keep above based on preference. Here keeping above */ order: 1; }
    .right { order: 2; }

    /* Larger touch targets */
    .input { padding: 16px; border-radius: 12px; }
    .input input { font-size: 16px; } /* Prevent iOS zoom */
    .btn { padding: 16px; font-size: 16px; border-radius: 12px; width: 100%; }
    .pw-toggle { padding: 14px 16px; justify-content: center; }
    
    /* Adjustments for small screens */
    .logo-frame { width: 80px; height: 80px; margin-bottom: 16px; }
    .logo-fallback { font-size: 18px; }
    
    .brand-title { 
      font-size: 20px; 
      line-height: 1.4;
      /* FIX: Removed margin: -85px */
      margin-bottom: 4px;
      margin-left: 0; margin-right: 0;
    }
    
    .company-details { display: none; } 
    
    .modal-row { flex-direction: column; }
    .modal .preview { width: 60px; height: 60px; margin-bottom: 10px; }
  }

  /* Tablets (Portrait & Small Laptops) */
  @media (min-width: 601px) and (max-width: 900px) {
    .card { 
      grid-template-columns: 1fr; 
      width:96%; 
      padding:24px; 
      gap: 24px; 
    }
    .left, .right { min-height: auto; align-items: flex-start; text-align: left; }
    .logo-frame { width: 90px; height: 90px; }
    .actions { flex-direction: column-reverse; gap:12px; width: 100%; }
    .btn { width: 100%; }
    .shop-badge { margin-top:10px; width: 100%; justify-content: flex-start; }
    .brand-title { font-size: 22px; }
    .modal { width: 90%; padding: 16px; }
  }

  /* Laptops (Standard) */
  @media (min-width: 901px) and (max-width: 1200px) {
    .card { max-width: 900px; } /* Slightly tighter on laptops */
    .brand-title { font-size: 24px; }
  }

  /* Large Screens (Desktops / Large TVs) */
  @media (min-width: 1201px) {
    .card { 
      max-width: 1100px; /* Keep it focused */
    }
    .brand-title { 
      font-size: 28px; /* Big and bold for TV */
      letter-spacing: -0.5px; 
    }
    .input input, .btn { font-size: 16px; } /* Slightly larger UI elements */
  }

</style>
</head>
<body>
  <div class="back-pattern" aria-hidden="true"></div>

  <!-- outer frame (light rounded) -->
  <div class="outer-frame">
    <div class="wrap">
      <main class="card" role="main" aria-labelledby="title" aria-describedby="card-desc">
        <!-- LEFT: Branding + Company Details -->
        <section class="left" aria-label="Branding panel">
          <div style="display:flex;gap:16px;align-items:center;flex-direction:column;width:100%; text-align: center;">
            <div class="logo-frame" id="logoFrame" aria-hidden="false" title="Vijaytechorbitsolutions logo">
              <img id="logoImg" src="logo.png" alt="Vijaytechorbitsolutions logo" onerror="this.style.display='none'; document.getElementById('logoFallback').style.display='grid'; document.getElementById('logoMissing').style.display='block'">
              <div id="logoFallback" class="logo-fallback" style="display:none">VT</div>
            </div>

            <div style="width:100%">
              <div id="title" class="brand-title" role="button" tabindex="0" aria-pressed="false" title="Click to manage logos (Company & Customer)">VIJAY TECH ORBIT SOLUTIONS</div>
              <div class="brand-sub">Billing · Inventory · POS</div>

              <div class="feature-chips" role="list" aria-hidden="false" aria-label="quick features" style="justify-content:center;">
                <div class="chip">Secure</div>
                <div class="chip">2FA Ready</div>
                <div class="chip">Fast</div>
                <div class="chip" title="Audit logs">Audit</div>
              </div>
            </div>
          </div>

          <div id="logoMissing" class="logo-missing" role="alert" aria-live="polite" style="display:none">Logo missing — add <code>logo.png</code> or upload via the manager.</div>

          <!-- SOFTWARE COMPANY DETAILS -->
          <div class="company-details" aria-label="Company details">
            <h4>About Vijaytech Orbit Solutions</h4>
            <p>
              Vijaytech Orbit Solutions is a software company specializing in enterprise-grade solutions for retail,
              textile, and small-to-medium businesses. We deliver end-to-end products and services — from design and
              development to deployment and support — to help businesses digitize operations and scale efficiently.
            </p>

            <p style="margin-top:8px;font-size:14px;color:rgba(230,238,252,0.9)"><strong>Contact:</strong> 9597908804</p>

            <p class="muted-note" style="margin-top:8px;font-size:12px">
              Contact us to build tailored solutions — we focus on reliability, security, and long-term support.
            </p>
          </div>

          <!-- Left uploader (Company Logo Only) -->
          <div class="logo-uploader" id="logoUploaderContainer" aria-hidden="false">
            <div id="dz" class="dropzone" tabindex="0">Drop logo.png here or <button id="chooseFileBtn" class="btn-secondary" type="button" aria-haspopup="dialog">Choose file</button></div>
            <input id="logoFileInput" type="file" accept="image/*" class="hidden" aria-hidden="true">
          </div>
          <div class="muted-note" style="font-size:12px">Tip: use a square PNG with transparent background for best appearance.</div>
        </section>

        <!-- RIGHT: Sign-in -->
        <section class="right" aria-label="Sign-in panel">
          <div class="form-head">
            <div style="width: 100%; text-align: center; margin-bottom: 15px;">
                            <h1 style="margin:0; font-size: 24px; color: #e6eefc;">THIRU SENTHILATHIPATHI OIL STORE</h1>
            <br>
                <h3 style="margin:0; font-size: 24px; color: #e6eefc;">Sign in</h3><br>
                <div class="form-desc" id="card-desc">Enter your credentials to access dashboard</div>
            </div>

            <!-- Shop Badge (Clickable to manage Customer Logo) -->
          <!--   <div class="shop-badge" id="shopBadgeTrigger" aria-hidden="false" title="Click to manage Customer Logo">
              <div class="shop-logo" title="Textile Shop Logo">
                <img id="shopLogoImg" src="shop-logo.png" alt="Shop logo" onerror="this.style.display='none'; document.getElementById('shopLogoFallback').style.display='grid'">
                <div id="shopLogoFallback" class="logo-fallback" style="display:none;font-size:12px;padding:6px">Textile</div>
              </div>
              <div style="display:flex; flex-direction:column; justify-content:center;">
                <div id="shopName" class="shop-name" title="Textile Shop">TSA OilStore</div>
                <span class="shop-tooltip">Edit Logo</span>
              </div>
            </div> -->
          </div>

          <!-- NOTE: form action uses a relative path to avoid server-side EL errors -->
          <form id="loginForm" action="${pageContext.request.contextPath}/UserLoginServlet" method="post" autocomplete="on" novalidate>
            <div>
              <label for="username">Username</label>
              <div class="input" role="group" aria-label="username input">
                <div class="icon" aria-hidden="true">U</div>
                <input id="username" name="username" type="text" value="SuperUser" required autocomplete="username" aria-required="true" />
              </div>
            </div>

            <div>
              <label for="password">Password</label>
              <div style="display:flex; gap:10px; align-items:center">
                <div class="input" style="flex:1" role="group" aria-label="password input">
                  <div class="icon" aria-hidden="true">🔒</div>
                  <input id="password" name="password" type="password" value="12345" required autocomplete="current-password" aria-required="true" />
                </div>
                <button type="button" id="pwToggle" class="pw-toggle" aria-pressed="false" aria-label="Toggle password visibility">
                  <svg id="eyeIcon" width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true" focusable="false"><path d="M12 5c5 0 9.27 3.11 11 7-1.73 3.89-6 7-11 7S2.73 15.89 1 12c1.73-3.89 6-7 11-7z" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.2"/></svg>
                  <span class="sr-only">Show password</span>
                </button>
              </div>
            </div>

            <div class="pw-note" id="pwNote" style="margin-top:6px">
              <div id="pwStrengthLabel" class="muted">Strength: weak</div>
              <a href="#" style="font-size:13px;color:rgba(230,238,252,0.7)" id="forgotLink">Forgot?</a>
            </div>

            <div class="pw-strength" aria-hidden="true" style="margin-top:6px"><i id="pwBar"></i></div>

            <div style="display:flex; align-items:center; justify-content:space-between; gap:12px; margin-top:6px">
              <label style="display:inline-flex; gap:8px; align-items:center; font-size:13px; color:rgba(230,238,252,0.7)">
                <input id="remember" name="remember" type="checkbox" aria-checked="false" /> Remember me
              </label>
              <div style="font-size:12px;color:rgba(230,238,252,0.6)">2FA: OTP supported</div>
            </div>

            <div class="actions" role="group" aria-label="actions">
              <button type="submit" class="btn btn-primary" id="signinBtn" aria-live="polite">
                <span id="signinText">Sign in</span>
                <span id="signinLoader" class="hidden" style="margin-left:8px"><span class="spinner" role="status" aria-hidden="true"></span></span>
              </button>
              <button type="button" class="btn btn-secondary" id="resetBtn">Reset</button>
            </div>

            <div id="formError" class="error hidden" role="alert" aria-live="assertive"></div>

            <div class="small-row">
              <div class="muted">Auto-save · Audit logs</div>
              <div style="color:rgba(230,238,252,0.6);font-size:13px">© 2026 Vijaytechorbitsolutions</div>
            </div>
          </form>
        </section>
      </main>
    </div>
  </div>

  <!-- Modal (Manage Both Logos & Name) -->
  <div id="modalBackdrop" class="modal-backdrop" role="dialog" aria-modal="true" aria-hidden="true">
    <div class="modal" role="document" aria-labelledby="modalTitle">
      <h4 id="modalTitle">Manage Logos & Shop Name</h4>

      <!-- PART 1: COMPANY LOGO (Vijaytech) - LOCKABLE -->
      <span class="modal-section-title">1. Software Company Logo (Ours) <span id="compLockBadge" class="locked-badge hidden">LOCKED</span></span>
      <div class="modal-row">
        <div class="preview" id="modalCompanyPreview"><img id="modalCompanyImg" style="width:100%;height:100%;object-fit:contain;display:block" src="" alt="Company preview" /></div>
        <div class="controls" id="modalCompanyControls">
          <div style="font-size:13px;margin-bottom:6px; color:#64748b;">Upload the Vijaytech Orbit Solutions logo.</div>
          <div class="inline-file">
            <input id="modalCompanyFile" type="file" accept="image/*">
            <button id="modalCompanyClear" class="btn-secondary" type="button">Clear</button>
          </div>
          <div style="font-size:12px;color:#94a3b8;margin-top:8px">Saved in browser (localStorage). Recommended: Square PNG.</div>
        </div>
      </div>

      <!-- PART 2: CUSTOMER LOGO (TSA OilStore) -->
      <span class="modal-section-title" style="margin-top: 10px;">2. Customer / Shop Logo (TSA OilStore)</span>
      <div class="modal-row">
        <div class="preview" id="modalShopPreview"><img id="modalShopImg" style="width:100%;height:100%;object-fit:contain;display:block" src="" alt="Shop preview" /></div>
        <div class="controls">
          <div style="font-size:13px;margin-bottom:6px; color:#64748b;">Upload the Customer's Shop logo.</div>
          <div class="inline-file">
            <input id="modalShopFile" type="file" accept="image/*">
            <button id="modalShopClear" class="btn-secondary" type="button">Clear</button>
          </div>
          <div style="font-size:12px;color:#94a3b8;margin-top:8px">This will appear on the right-hand badge.</div>
        </div>
      </div>

      <!-- PART 3: SHOP NAME -->
      <div style="margin-bottom:6px">
        <span class="modal-section-title">3. Shop Name</span>
        <input id="modalShopName" class="text-input" type="text" placeholder="e.g. Sree Textiles">
      </div>

      <div class="modal-actions">
        <button id="modalCancel" class="btn-secondary" type="button">Cancel</button>
        <button id="modalSave" class="btn btn-primary" type="button">Save Changes</button>
      </div>
    </div>
  </div>

<script>
/* --------- Full functionality for Two Logos (Company + Shop) --------- */

const LS_COMP_SET = 'vt_logo_set';
const LS_COMP_SRC = 'vt_logo_src';
const LS_SHOP_SET = 'vt_shop_set';
const LS_SHOP_SRC = 'vt_shop_src';
const LS_SHOP_NAME = 'vt_shop_name';

function trySetLS(key, val){ try { localStorage.setItem(key, val); } catch(e){ console.warn('ls set', e); } }
function tryRemoveLS(key){ try { localStorage.removeItem(key); } catch(e){ console.warn('ls remove', e); } }

// Initialize Saved State for Both Logos
(function initSaved(){
  // 1. Load Company Logo
  const compSet = localStorage.getItem(LS_COMP_SET);
  const logoImg = document.getElementById('logoImg');
  const logoFallback = document.getElementById('logoFallback');
  const logoMissing = document.getElementById('logoMissing');
  const uploader = document.getElementById('logoUploaderContainer');

  if(compSet === 'true'){
    const src = localStorage.getItem(LS_COMP_SRC);
    if(src) { logoImg.src = src; logoImg.style.display = 'block'; logoFallback.style.display = 'none'; logoMissing.style.display = 'none'; }
    else { logoImg.style.display = 'none'; logoFallback.style.display = 'grid'; logoMissing.style.display = 'block'; }
    if(uploader) uploader.style.display = 'none';
  } else {
    if(uploader) uploader.style.display = '';
  }

  // 2. Load Shop Logo
  const shopSet = localStorage.getItem(LS_SHOP_SET);
  const shopImg = document.getElementById('shopLogoImg');
  const shopFallback = document.getElementById('shopLogoFallback');
  const shopNameEl = document.getElementById('shopName');
  if(shopSet === 'true'){
    const ssrc = localStorage.getItem(LS_SHOP_SRC);
    if(ssrc){ shopImg.src = ssrc; shopImg.style.display = 'block'; shopFallback.style.display = 'none'; }
    else { shopImg.style.display = 'none'; shopFallback.style.display = 'grid'; }
  }

  // 3. Load Shop Name
  const savedName = localStorage.getItem(LS_SHOP_NAME);
  if(savedName && savedName.trim().length) shopNameEl.textContent = savedName;
})();

// Password Toggle Logic
(function(){
  const pw = document.getElementById('password');
  const btn = document.getElementById('pwToggle');
  btn.addEventListener('click', function(){
    const shown = pw.type === 'text';
    pw.type = shown ? 'password' : 'text';
    btn.setAttribute('aria-pressed', String(!shown));
    const sr = btn.querySelector('.sr-only'); if (sr) sr.textContent = shown ? 'Show password' : 'Hide password';
    btn.style.transform = shown ? '' : 'rotate(12deg)';
  });
})();

// Reset Button Logic
document.getElementById('resetBtn').addEventListener('click', function(){
  document.getElementById('username').value = '';
  document.getElementById('password').value = '';
  const bar = document.getElementById('pwBar'); if (bar) bar.style.width = '0%';
  const label = document.getElementById('pwStrengthLabel'); if (label) label.textContent = 'Strength: weak';
  document.getElementById('formError').classList.add('hidden');
});

// Image Error Handling on Load
window.addEventListener('load', function(){
  const img = document.getElementById('logoImg'), fallback = document.getElementById('logoFallback'), missing = document.getElementById('logoMissing');
  setTimeout(()=> {
    if (img && (img.naturalWidth === 0 || img.complete === false || img.style.display === 'none')) { img.style.display = 'none'; fallback.style.display = 'grid'; missing.style.display = 'block'; }
    else { missing.style.display = 'none'; }
  }, 50);
});

// Password Strength Logic
(function(){
  const pw = document.getElementById('password'), bar = document.getElementById('pwBar'), label = document.getElementById('pwStrengthLabel');
  function evaluate(v){
    let score = 0;
    if(!v) return {score:0, text:'weak'};
    if(v.length >= 6) score += 1;
    if(/[A-Z]/.test(v)) score += 1;
    if(/[0-9]/.test(v)) score += 1;
    if(/[^A-Za-z0-9]/.test(v)) score += 1;
    if(v.length >= 12) score += 1;
    const percent = Math.min(100, score * 20);
    let text = 'weak';
    if(percent >= 80) text = 'very strong';
    else if(percent >= 60) text = 'strong';
    else if(percent >= 40) text = 'medium';
    return {score:percent, text};
  }
  pw.addEventListener('input', function(){
    const res = evaluate(pw.value);
    if (bar) bar.style.width = res.score + '%';
    if (label) label.textContent = 'Strength: ' + res.text;
    if(res.score >= 80) bar.style.background = 'linear-gradient(90deg, var(--success), var(--accent-c))';
    else if(res.score >= 60) bar.style.background = 'linear-gradient(90deg, var(--accent-b), var(--accent-c))';
    else bar.style.background = 'linear-gradient(90deg, var(--accent-a), var(--accent-b))';
  });
})();

// Form Submission Logic
(function(){
  const form = document.getElementById('loginForm'), user = document.getElementById('username'), pw = document.getElementById('password'), error = document.getElementById('formError'), signinBtn = document.getElementById('signinBtn'), signinText = document.getElementById('signinText'), signinLoader = document.getElementById('signinLoader');
  form.addEventListener('submit', function(ev){
    error.classList.add('hidden'); error.textContent = '';
    if(!user.value || user.value.trim().length < 2){ ev.preventDefault(); error.textContent = 'Please enter a valid username.'; error.classList.remove('hidden'); user.focus(); return; }
    if(!pw.value || pw.value.length < 4){ ev.preventDefault(); error.textContent = 'Please enter a valid password (min 4 chars).'; error.classList.remove('hidden'); pw.focus(); return; }
    signinText.style.opacity = '0'; signinLoader.classList.remove('hidden'); signinBtn.disabled = true;
    // allow native submit to continue
    setTimeout(()=> { /* no-op */ }, 120);
  });
})();

/* Left uploader (Company Logo Only - One-time) */
(function(){
  const dz = document.getElementById('dz'), input = document.getElementById('logoFileInput'), chooseBtn = document.getElementById('chooseFileBtn'), logoImg = document.getElementById('logoImg'), logoFallback = document.getElementById('logoFallback'), logoMissing = document.getElementById('logoMissing'), uploaderContainer = document.getElementById('logoUploaderContainer');
  function showPreviewAndPersist(file){
    const reader = new FileReader();
    reader.onload = function(e){
      const dataUrl = e.target.result;
      if(!logoImg) return;
      logoImg.src = dataUrl; logoImg.style.display = 'block'; logoFallback.style.display = 'none'; logoMissing.style.display = 'none';
      trySetLS(LS_COMP_SRC, dataUrl); trySetLS(LS_COMP_SET, 'true');
      if (uploaderContainer) uploaderContainer.style.display = 'none';
    };
    reader.readAsDataURL(file);
  }
  if(!dz || !input || !chooseBtn) return;
  ['dragenter','dragover'].forEach(ev => dz.addEventListener(ev, function(e){ e.preventDefault(); e.stopPropagation(); dz.classList.add('dragover'); }));
  ['dragleave','drop'].forEach(ev => dz.addEventListener(ev, function(e){ e.preventDefault(); e.stopPropagation(); dz.classList.remove('dragover'); }));
  dz.addEventListener('drop', function(e){ const dt = e.dataTransfer; if(dt && dt.files && dt.files.length){ const file = dt.files[0]; if(file.type.startsWith('image/')) { if (localStorage.getItem(LS_COMP_SET) === 'true') return; showPreviewAndPersist(file); } } });
  chooseBtn.addEventListener('click', function(){ if (localStorage.getItem(LS_COMP_SET) === 'true') return; input.click(); });
  input.addEventListener('change', function(){ if(this.files && this.files[0]){ if (localStorage.getItem(LS_COMP_SET) === 'true') return; const f = this.files[0]; if(f.type.startsWith('image/')) showPreviewAndPersist(f); } });
})();

/* Modal logic (Edit BOTH Logos & Shop Name) */
(function(){
  const title = document.getElementById('title');
  const shopBadge = document.getElementById('shopBadgeTrigger');
  const modalBackdrop = document.getElementById('modalBackdrop');
  const modalCompanyFile = document.getElementById('modalCompanyFile');
  const modalShopFile = document.getElementById('modalShopFile');
  const modalCompanyImg = document.getElementById('modalCompanyImg');
  const modalShopImg = document.getElementById('modalShopImg');
  const modalCompanyClear = document.getElementById('modalCompanyClear');
  const modalShopClear = document.getElementById('modalShopClear');
  const modalShopNameInput = document.getElementById('modalShopName');
  const modalSave = document.getElementById('modalSave');
  const modalCancel = document.getElementById('modalCancel');
  const modalCompanyControls = document.getElementById('modalCompanyControls');
  const compLockBadge = document.getElementById('compLockBadge');

  function openModal(){
    // Load Company Data
    const compSrc = localStorage.getItem(LS_COMP_SRC) || document.getElementById('logoImg').src || '';
    modalCompanyImg.src = compSrc && (compSrc.startsWith('data:') || compSrc.indexOf('http') !== -1) ? compSrc : '';
    
    // Load Shop Data
    const shopSrc = localStorage.getItem(LS_SHOP_SRC) || document.getElementById('shopLogoImg').src || '';
    modalShopImg.src = shopSrc && (shopSrc.startsWith('data:') || shopSrc.indexOf('http') !== -1) ? shopSrc : '';
    
    // Load Name
    modalShopNameInput.value = localStorage.getItem(LS_SHOP_NAME) || document.getElementById('shopName').textContent || '';
    
    // --- CRITICAL LOCK LOGIC FOR COMPANY LOGO ---
    const isCompanyLocked = localStorage.getItem(LS_COMP_SET) === 'true';
    if(isCompanyLocked){
      modalCompanyFile.disabled = true;
      modalCompanyClear.disabled = true;
      modalCompanyControls.classList.add('controls-locked');
      compLockBadge.classList.remove('hidden');
    } else {
      modalCompanyFile.disabled = false;
      modalCompanyClear.disabled = false;
      modalCompanyControls.classList.remove('controls-locked');
      compLockBadge.classList.add('hidden');
    }

    modalBackdrop.style.display = 'flex';
    modalBackdrop.setAttribute('aria-hidden', 'false');
    if(!isCompanyLocked) modalCompanyFile.focus();
    else modalShopNameInput.focus();
  }

  function closeModal(){
    modalBackdrop.style.display = 'none';
    modalBackdrop.setAttribute('aria-hidden', 'true');
  }

  // Triggers
  title.addEventListener('click', openModal);
  if(shopBadge) shopBadge.addEventListener('click', openModal);
  
  title.addEventListener('keydown', function(e){ if(e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openModal(); } });

  function fileToDataUrl(file, cb){
    const reader = new FileReader();
    reader.onload = function(e){ cb(e.target.result); };
    reader.readAsDataURL(file);
  }

  modalCompanyFile.addEventListener('change', function(){
    if(this.files && this.files[0]) fileToDataUrl(this.files[0], dataUrl => modalCompanyImg.src = dataUrl);
  });
  modalShopFile.addEventListener('change', function(){
    if(this.files && this.files[0]) fileToDataUrl(this.files[0], dataUrl => modalShopImg.src = dataUrl);
  });

  modalCompanyClear.addEventListener('click', function(){ modalCompanyFile.value = ''; modalCompanyImg.src = ''; });
  modalShopClear.addEventListener('click', function(){ modalShopFile.value = ''; modalShopImg.src = ''; });

  modalSave.addEventListener('click', function(){
    // 1. Save Company Logo (ONLY IF NOT LOCKED)
    if(localStorage.getItem(LS_COMP_SET) !== 'true'){
      const compSrc = modalCompanyImg.src || '';
      if(compSrc && (compSrc.startsWith('data:') || compSrc.indexOf('blob:') === 0 || compSrc.indexOf('http') === 0)){
        trySetLS(LS_COMP_SRC, compSrc); trySetLS(LS_COMP_SET, 'true');
        document.getElementById('logoImg').src = compSrc; document.getElementById('logoImg').style.display = 'block'; document.getElementById('logoFallback').style.display = 'none'; document.getElementById('logoMissing').style.display = 'none';
        const uploader = document.getElementById('logoUploaderContainer'); if (uploader) uploader.style.display = 'none';
      } else if(compSrc === ''){
        tryRemoveLS(LS_COMP_SRC); tryRemoveLS(LS_COMP_SET);
        const imgEl = document.getElementById('logoImg'); if(imgEl) imgEl.style.display = 'none'; document.getElementById('logoFallback').style.display = 'grid'; document.getElementById('logoMissing').style.display = 'block';
        const uploader = document.getElementById('logoUploaderContainer'); if (uploader) uploader.style.display = '';
      }
    }

    // 2. Save Shop Logo (ALWAYS ALLOWED)
    const shopSrc = modalShopImg.src || '';
    if(shopSrc && (shopSrc.startsWith('data:') || shopSrc.indexOf('blob:') === 0 || shopSrc.indexOf('http') === 0)){
      trySetLS(LS_SHOP_SRC, shopSrc); trySetLS(LS_SHOP_SET, 'true');
      document.getElementById('shopLogoImg').src = shopSrc; document.getElementById('shopLogoImg').style.display = 'block'; document.getElementById('shopLogoFallback').style.display = 'none';
    } else if(shopSrc === ''){
      tryRemoveLS(LS_SHOP_SRC); tryRemoveLS(LS_SHOP_SET);
      document.getElementById('shopLogoImg').style.display = 'none'; document.getElementById('shopLogoFallback').style.display = 'grid';
    }

    // 3. Save Shop Name (ALWAYS ALLOWED)
    const shopNameVal = modalShopNameInput.value.trim();
    if(shopNameVal.length){
      trySetLS(LS_SHOP_NAME, shopNameVal);
      document.getElementById('shopName').textContent = shopNameVal;
    } else {
      tryRemoveLS(LS_SHOP_NAME);
    }

    closeModal();
  });

  modalCancel.addEventListener('click', closeModal);
  document.getElementById('modalBackdrop').addEventListener('click', function(e){ if(e.target === this) closeModal(); });
})();

// Accessibility for Dropzone
(function(){
  const dz = document.getElementById('dz');
  if (!dz) return;
  dz.addEventListener('keydown', function(e){
    if(e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      if (localStorage.getItem(LS_COMP_SET) !== 'true') document.getElementById('logoFileInput').click();
    }
  });
})();

// Forgot Password Placeholder
(function(){
  const fl = document.getElementById('forgotLink');
  if (!fl) return;
  fl.addEventListener('click', function(e){
    e.preventDefault();
    alert('Forgot password flow — implement server-side recovery.');
  });
})();
</script>
</body>
</html>