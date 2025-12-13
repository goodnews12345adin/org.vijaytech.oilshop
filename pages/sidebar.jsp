<%@ page session="true" %>
<%-- 
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        username = "Guest";
    }
%>
--%>

<!-- ===== Responsive Sidebar (Glass Neon Style) ===== -->
<!-- Toggle button for small screens -->
<button id="sidebarToggle" class="sb-toggle" aria-label="Toggle navigation" aria-expanded="true">
  <i class="bi bi-list"></i>
</button>

<div class="sidebar-overlay" id="sidebarOverlay" tabindex="-1" aria-hidden="true"></div>

<div class="sidebar glass-erp d-flex flex-column flex-shrink-0 p-3 text-white shadow-lg" id="mainSidebar" role="navigation" aria-label="Main sidebar">
  <a href="${pageContext.request.contextPath}/pages/dashboard.jsp"
     class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-white text-decoration-none sb-brand">
    <i class="bi bi-speedometer2 fs-4 me-2 text-glow" aria-hidden="true"></i>
    <span class="fs-5 fw-bold text-gradient">Sree Textiles</span>
  </a>

  <hr class="border-light opacity-25">

  <ul class="nav nav-pills flex-column mb-auto sb-nav" id="sidebarNav">
    <li class="nav-item">
      <a href="${pageContext.request.contextPath}/pages/dashboard.jsp" class="nav-link active text-white" tabindex="0">
        <i class="bi bi-house-door me-2" aria-hidden="true"></i> Dashboard
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/SalesServlet" class="nav-link text-white">
        <i class="bi bi-cart-check me-2" aria-hidden="true"></i> Sales
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/PurchaseServlet" class="nav-link text-white">
        <i class="bi bi-basket me-2" aria-hidden="true"></i> Purchase
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/pages/productCategory.jsp" class="nav-link text-white">
        <i class="bi bi-box-seam me-2" aria-hidden="true"></i> Product category
      </a>
    </li>

    <li>
      <a href="${pageContext.request.contextPath}/Product" class="nav-link text-white">
        <i class="bi bi-box-seam me-2" aria-hidden="true"></i> Products
      </a>
    </li>
	 <li>
      <a href="${pageContext.request.contextPath}/ExpenseEntryServlet" class="nav-link text-white">
        <i class="bi bi-box-seam me-2" aria-hidden="true"></i> Expense Entry
      </a>
    </li>
    <li class="nav-item">
      <a class="nav-link text-white d-flex justify-content-between align-items-center"
         data-bs-toggle="collapse" href="#reportsMenu" role="button"
         aria-expanded="false" aria-controls="reportsMenu">
        <span><i class="bi bi-bar-chart me-2" aria-hidden="true"></i> Reports</span>
        <i class="bi bi-chevron-down"></i>
      </a>
      <div class="collapse ps-3" id="reportsMenu">
        <ul class="nav flex-column">
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/PrintPurchaseReportServlet" class="nav-link text-white small">Purchase Report</a>
          </li>
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/ProfitAndLossReport" class="nav-link text-white small">Profit-Loss Report</a>
          </li>
          <li class="nav-item">
            <a href="${pageContext.request.contextPath}/CashBookReport" class="nav-link text-white small">Expense Report</a>
          </li>
        </ul>
      </div>
    </li>

  </ul>
</div>

<!-- ===== Styles & Responsive Media Queries ===== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/pages/css/style.css" rel="stylesheet">

<style>
  /* === Base color variables (kept canonical) === */
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
    --sidebar-width: 250px;    /* default full width */
    --sidebar-collapsed: 80px; /* collapsed width for icon-only */
    --transition-speed: 0.32s;
  }

  /* === Global layout === */
  body {
    margin-left: var(--sidebar-width);
    font-family: 'Poppins', sans-serif;
    color: #000;
    background: radial-gradient(ellipse at center, rgba(8,20,58,0.6), rgba(3,10,28,0.9)),
                url('${pageContext.request.contextPath}/pages/img/bg-textile.jpg') center/cover no-repeat fixed;
    overflow-x: hidden;
    transition: margin-left var(--transition-speed) ease;
  }

  /* Sidebar base */
  .sidebar.glass-erp {
    width: var(--sidebar-width);
    height: 100vh;
    background: linear-gradient(180deg, rgba(8,20,58,0.88), rgba(9,24,75,0.85));
    backdrop-filter: blur(14px);
    border-right: 1px solid rgba(255,255,255,0.04);
    box-shadow: inset -1px 0 0 rgba(255,255,255,0.02), 0 0 25px rgba(27,184,169,0.12);
    position: fixed;
    top: 0;
    left: 0;
    overflow-y: auto;
    transition: transform var(--transition-speed) ease, width var(--transition-speed) ease, box-shadow var(--transition-speed) ease;
    z-index: 1040;
  }

  /* Brand text + icon */
  .sb-brand { color: var(--muted-light) !important; text-shadow: 0 0 8px rgba(25,182,176,0.18); }
  .sb-nav .nav-link { border-radius: 10px; margin: 4px 0; padding: 10px 12px; font-weight: 500; transition: all 0.2s ease; color: var(--muted-light) !important; display:flex; align-items:center; }
  .sb-nav .nav-link:hover { background: rgba(255,255,255,0.03); box-shadow: inset 4px 0 0 var(--accent-a); text-decoration:none; }
  .sb-nav .nav-link.active { background: rgba(255,255,255,0.04); box-shadow: inset 4px 0 0 var(--accent-a); color: #fff !important; }

  .text-gradient { background: linear-gradient(90deg, var(--accent-a), var(--accent-b)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
  .text-glow { color: var(--accent-a); text-shadow: 0 0 12px rgba(25,182,176,0.22); }

  /* Toggle button (for small/mobile) */
  .sb-toggle {
    position: fixed;
    top: 12px;
    left: 12px;
    z-index: 1060;
    background: rgba(255,255,255,0.06);
    border: 0;
    color: var(--muted-light);
    padding: 8px 10px;
    border-radius: 10px;
    display: none; /* default hidden; shown on small screens */
    backdrop-filter: blur(6px);
  }
  .sb-toggle:focus { outline: 2px solid rgba(25,182,176,0.24); }

  /* Overlay for small screens when sidebar open */
  .sidebar-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.45);
    z-index: 1035;
    display: none;
    opacity: 0;
    transition: opacity var(--transition-speed) ease;
  }

  /* Collapsed (icon-only) sidebar */
  .sidebar.collapsed {
    width: var(--sidebar-collapsed);
  }
  .sidebar.collapsed .sb-brand span { display: none; }
  .sidebar.collapsed .sb-nav .nav-link { justify-content: center; padding-left: 0; padding-right: 0; }
  .sidebar.collapsed .sb-nav .nav-link .bi { font-size: 1.25rem; }

  /* When sidebar is hidden on small screens, slide left */
  .sidebar.hidden {
    transform: translateX(-110%);
  }

  /* Content area shift behavior for different sidebar sizes */
  .body-with-collapsed-sidebar { margin-left: var(--sidebar-collapsed); }
  .body-with-full-sidebar { margin-left: var(--sidebar-width); }

  /* Smooth scroll for sidebar contents */
  .sidebar .sb-nav { scroll-behavior: smooth; padding-bottom: 48px; }

  /* === Media queries === */

  /* Very small phones (portrait) - up to 420px */
  @media (max-width: 420px) {
    .sb-toggle { display: inline-flex; align-items: center; justify-content: center; }
    .sidebar { width: 85%; max-width: 300px; transform: translateX(-110%); } /* hidden by default */
    .sidebar.visible { transform: translateX(0%); } /* visible on toggle */
    body { margin-left: 0; }
    /* Make links bigger/tappable */
    .sb-nav .nav-link { padding: 14px 16px; font-size: 1rem; }
    .sidebar-overlay { display: block; } /* visible when toggled by JS */
  }

  /* Small devices / large phones (<= 768px) */
  @media (max-width: 768px) {
    .sb-toggle { display: inline-flex; }
    .sidebar { width: 78%; max-width: 340px; transform: translateX(-110%); } /* default hidden */
    .sidebar.visible { transform: translateX(0%); box-shadow: 0 20px 40px rgba(2,6,23,0.6); }
    body { margin-left: 0; }
    .sidebar-overlay { display: block; } /* will be shown/hidden via JS by toggling opacity/aria-hidden */
  }

  /* Medium devices (tablets / small laptops) 769px - 991px */
  @media (min-width: 769px) and (max-width: 991px) {
    /* Use collapsed icon-only sidebar for medium screens to maximize content space */
    .sidebar { width: var(--sidebar-collapsed); }
    body { margin-left: var(--sidebar-collapsed); }
    .sb-brand span { display: none; }
    .sb-toggle { display: none; } /* desktop-tablet doesn't need overlay toggle */
    .sidebar { box-shadow: none; }
  }

  /* Large devices (desktops) 992px - 1199px */
  @media (min-width: 992px) and (max-width: 1199px) {
    .sidebar { width: 220px; }
    body { margin-left: 220px; }
  }

  /* Extra large (>= 1200px) - default full size */
  @media (min-width: 1200px) {
    .sidebar { width: var(--sidebar-width); }
    body { margin-left: var(--sidebar-width); }
    .sb-toggle { display: none; }
  }

  /* Landscape phones / high-res narrow screens */
  @media (min-width: 421px) and (max-width: 768px) and (orientation: landscape) {
    .sidebar { width: 60%; }
    .sb-nav .nav-link { padding: 12px 14px; }
  }

  /* Retina & high DPI tweaks (increase icon clarity) */
  @media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
    .text-glow { text-shadow: 0 0 14px rgba(25,182,176,0.26); }
  }

  /* Print: hide background and show simple stacked nav */
  @media print {
    body { margin: 0; background: #fff !important; color: #000 !important; }
    .sidebar { position: static; width: auto; height: auto; box-shadow: none; background: transparent; border: none; }
    .sb-toggle, .sidebar-overlay { display: none !important; }
    .sb-nav .nav-link { color: #000 !important; background: transparent !important; box-shadow: none !important; }
  }

  /* Respect user reduced motion preferences */
  @media (prefers-reduced-motion: reduce) {
    :root { --transition-speed: 0.001s; }
    .sidebar, .sidebar-overlay, body { transition: none !important; }
  }

  /* Dark mode adaptation */
  @media (prefers-color-scheme: dark) {
    :root { --muted-light: rgba(255,255,255,0.86); }
    .sidebar { background: linear-gradient(180deg, rgba(6,12,30,0.95), rgba(7,14,38,0.95)); }
  }

  /* small utility tweaks */
  .sb-nav .nav-link .bi { margin-right: 10px; }
  .sb-nav .nav-link .me-2 { margin-right: 10px; }

</style>

<!-- ===== JS: Toggle & accessibility (no external deps required) ===== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  (function () {
    const sidebar = document.getElementById('mainSidebar');
    const toggleBtn = document.getElementById('sidebarToggle');
    const overlay = document.getElementById('sidebarOverlay');
    const bodyEl = document.body;

    // Utility to set aria-expanded on toggle button
    function setToggleExpanded(expanded) {
      if (toggleBtn) toggleBtn.setAttribute('aria-expanded', String(expanded));
    }

    // Show/Hide for small screens
    function openSidebar() {
      sidebar.classList.add('visible');
      sidebar.classList.remove('hidden');
      overlay.style.display = 'block';
      // allow CSS transition to fade in
      requestAnimationFrame(() => overlay.style.opacity = '1');
      overlay.setAttribute('aria-hidden', 'false');
      setToggleExpanded(true);
      // trap focus (very lightweight)
      try { sidebar.querySelector('a,button, [tabindex]')?.focus(); } catch(e){}
    }

    function closeSidebar() {
      sidebar.classList.remove('visible');
      sidebar.classList.add('hidden');
      overlay.style.opacity = '0';
      overlay.setAttribute('aria-hidden', 'true');
      setToggleExpanded(false);
      // hide overlay after transition
      setTimeout(() => {
        if (!sidebar.classList.contains('visible')) overlay.style.display = 'none';
      }, 320);
      // return focus to toggle button for accessibility
      if (toggleBtn) toggleBtn.focus();
    }

    // Toggle handler
    function toggleSidebar() {
      if (sidebar.classList.contains('visible')) closeSidebar(); else openSidebar();
    }

    // Click outside closes sidebar
    overlay.addEventListener('click', closeSidebar);
    overlay.addEventListener('touchstart', closeSidebar);

    // Toggle button
    toggleBtn.addEventListener('click', function (e) {
      e.preventDefault();
      toggleSidebar();
    });

    // Close on ESC key
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' || e.key === 'Esc') {
        // only close if overlay is visible (i.e. small-screen)
        if (sidebar.classList.contains('visible')) closeSidebar();
      }
    });

    // Initialize sidebar visibility depending on viewport (so server-side margin doesn't mismatch)
    function initSidebarState() {
      const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0);
      if (vw <= 768) {
        sidebar.classList.add('hidden');
        sidebar.classList.remove('collapsed');
        bodyEl.classList.remove('body-with-collapsed-sidebar');
        bodyEl.classList.remove('body-with-full-sidebar');
        bodyEl.style.marginLeft = '0';
      } else if (vw >= 769 && vw <= 991) {
        sidebar.classList.remove('hidden');
        sidebar.classList.add('collapsed');
        bodyEl.classList.add('body-with-collapsed-sidebar');
        bodyEl.style.marginLeft = getComputedStyle(document.documentElement).getPropertyValue('--sidebar-collapsed').trim();
      } else if (vw >= 992 && vw <= 1199) {
        sidebar.classList.remove('hidden');
        sidebar.classList.remove('collapsed');
        bodyEl.classList.add('body-with-full-sidebar');
        bodyEl.style.marginLeft = '220px';
      } else {
        sidebar.classList.remove('hidden');
        sidebar.classList.remove('collapsed');
        bodyEl.classList.add('body-with-full-sidebar');
        bodyEl.style.marginLeft = getComputedStyle(document.documentElement).getPropertyValue('--sidebar-width').trim();
      }
      setToggleExpanded(!sidebar.classList.contains('hidden'));
    }

    // On load and on resize adjust initial state
    window.addEventListener('load', initSidebarState);
    window.addEventListener('resize', initSidebarState);

    // Keyboard accessibility: focus trap hint (optional)
    // Note: for a full focus trap, integrate a focus-trap library; this is a lightweight approach.
  })();
</script>
