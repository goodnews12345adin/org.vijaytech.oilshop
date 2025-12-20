<%@ page pageEncoding="UTF-8" session="true" %><%
    // Server-side retrieval of session username
    String username = (String) session.getAttribute("username");
    if (username == null || username.trim().isEmpty()) {
        username = "Guest";
    }
    String orgNamee = "SKV"; 
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= orgNamee %> ERP - Dashboard v44.1</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        :root {
            --panel-bg: #08143a;
            --panel-bg-glass: rgba(8, 20, 58, 0.98);
            --accent-primary: #19b6b0;
            --accent-secondary: #15a0c6;
            --sidebar-width: 280px;
            --sidebar-collapsed: 85px;
            --header-height: 75px;
            --footer-height: 60px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #f4f7fe;
            margin: 0;
            padding-top: var(--header-height);
            padding-bottom: var(--footer-height);
            transition: var(--transition);
            overflow-x: hidden;
            min-height: 100vh;
        }

        /* === SIDEBAR === */
        .sidebar-wrapper {
            width: var(--sidebar-width);
            height: 100vh;
            background: var(--panel-bg);
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1060;
            transition: var(--transition);
            box-shadow: 10px 0 30px rgba(0,0,0,0.15);
            overflow-y: auto;
            overflow-x: hidden;
            scrollbar-width: thin;
            scrollbar-color: var(--accent-primary) transparent;
        }

        .sidebar-header {
            height: var(--header-height);
            padding: 0 25px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            position: sticky;
            top: 0;
            background: var(--panel-bg);
            z-index: 10;
        }

        .mobile-close-btn {
            display: none;
            background: rgba(255, 255, 255, 0.1);
            border: none;
            color: white;
            border-radius: 8px;
            padding: 5px 10px;
            font-size: 1.2rem;
            transition: 0.2s;
        }
        
        .mobile-close-btn:hover { background: rgba(255, 255, 255, 0.2); }

        .sidebar-link {
            display: flex;
            align-items: center;
            padding: 12px 18px;
            color: rgba(255, 255, 255, 0.6);
            text-decoration: none !important;
            margin: 4px 15px;
            border-radius: 10px;
            font-weight: 500;
            transition: var(--transition);
            cursor: pointer;
            border: none;
            background: transparent;
            width: calc(100% - 30px);
            text-align: left;
        }

        .sidebar-link i:first-child { font-size: 1.2rem; margin-right: 15px; min-width: 25px; }

        .sidebar-link:hover, .sidebar-link.active {
            background: rgba(255, 255, 255, 0.1);
            color: #fff !important;
        }

        .sidebar-link.active {
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            box-shadow: 0 4px 15px rgba(25, 182, 176, 0.3);
        }

        /* === SUBMENU === */
        .submenu-container {
            list-style: none;
            padding: 5px 0;
            margin: 0 15px 10px 15px;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 10px;
            border-left: 2px solid var(--accent-primary);
        }
        
        .submenu-link {
            padding: 8px 15px 8px 20px !important;
            font-size: 0.82rem !important;
            margin: 2px 0 !important;
            display: flex !important;
            align-items: center;
            color: rgba(255, 255, 255, 0.5) !important;
            text-decoration: none !important;
            width: 100% !important;
        }

        .submenu-link:hover {
            color: #fff !important;
            background: rgba(255, 255, 255, 0.05);
        }

        .submenu-link i { color: var(--accent-primary); margin-right: 12px; font-size: 1rem; }

        .bi-chevron-down {
            transition: transform 0.3s ease;
            font-size: 0.8rem;
        }
        .sidebar-link:not(.collapsed) .bi-chevron-down {
            transform: rotate(180deg);
        }

        /* === HEADER === */
        .app-header {
            height: var(--header-height);
            background: var(--panel-bg-glass);
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            position: fixed;
            top: 0;
            right: 0;
            left: var(--sidebar-width);
            z-index: 1040;
            transition: var(--transition);
            display: flex;
            align-items: center;
        }

        /* === FOOTER === */
        .app-footer {
            height: var(--footer-height);
            background: var(--panel-bg-glass);
            backdrop-filter: blur(15px);
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            position: fixed;
            bottom: 0;
            right: 0;
            left: var(--sidebar-width);
            z-index: 1030;
            transition: var(--transition);
            display: flex;
            align-items: center;
            color: rgba(255, 255, 255, 0.7);
        }

        /* === STAT CARDS === */
        .stat-card {
            background: #fff;
            border-radius: 15px;
            padding: 20px;
            border: none;
            box-shadow: var(--card-shadow);
            height: 100%;
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-label { font-size: 0.75rem; font-weight: 700; color: #444; text-transform: uppercase; margin-bottom: 10px; display: block; }
        .stat-value { font-size: 1.8rem; font-weight: 800; display: block; }
        .stat-desc { font-size: 0.7rem; color: #888; }

        .main-content { padding: 25px; transition: var(--transition); }

        /* === MEDIA QUERIES & SIDEBAR ACTIONS === */
        @media (min-width: 992px) {
            body { padding-left: var(--sidebar-width); }
            body.collapsed-sidebar { padding-left: var(--sidebar-collapsed); }
            
            body.collapsed-sidebar .sidebar-wrapper { width: var(--sidebar-collapsed); }
            body.collapsed-sidebar .app-header, 
            body.collapsed-sidebar .app-footer { left: var(--sidebar-collapsed); }
            
            body.collapsed-sidebar .sidebar-link span, 
            body.collapsed-sidebar .brand-text, 
            body.collapsed-sidebar .bi-chevron-down, 
            body.collapsed-sidebar .analytics-label { 
                display: none !important; 
            }
            body.collapsed-sidebar .collapse.show { display: none !important; }
        }

        @media (max-width: 991px) {
            .app-header, .app-footer { left: 0 !important; }
            .sidebar-wrapper { transform: translateX(-100%); width: 280px; }
            body.mobile-open .sidebar-wrapper { transform: translateX(0); }
            body { padding-left: 0 !important; }
            .mobile-close-btn { display: block; }
            .mobile-overlay {
                position: fixed; inset: 0; background: rgba(0,0,0,0.5);
                z-index: 1055; display: none; backdrop-filter: blur(4px);
            }
            body.mobile-open .mobile-overlay { display: block; }
        }

        .brand-text {
            background: linear-gradient(90deg, #fff, var(--accent-primary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 800;
        }

        .btn-logout {
            background: linear-gradient(135deg, #ff4b2b, #ff416c);
            border: none; color: white; border-radius: 10px;
            padding: 8px 16px; font-weight: 600; text-decoration: none; font-size: 0.9rem;
        }
        
        .version-badge {
            background: rgba(25, 182, 176, 0.2);
            color: var(--accent-primary);
            padding: 1px 8px; border-radius: 20px;
            font-size: 0.65rem; font-weight: 700; border: 1px solid var(--accent-primary);
        }
    </style>
</head>
<body>

<div class="mobile-overlay" id="mobileOverlay"></div>

<aside class="sidebar-wrapper" id="sidebar">
    <div class="sidebar-header">
        <div class="d-flex align-items-center">
            <i class="bi bi-intersect text-info fs-3 me-2"></i>
            <span class="brand-text fs-4"><%= orgNamee %></span>
        </div>
        <button class="mobile-close-btn" id="mobileClose"><i class="bi bi-x-lg"></i></button>
    </div>
    
    <nav class="mt-3">
       
        <a href="${pageContext.request.contextPath}/pages/dashboard.jsp" class="sidebar-link">
            <i class="bi bi-speedometer2"></i><span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/SalesServlet" class="sidebar-link">
            <i class="bi bi-cart3"></i><span>Sales</span>
        </a>
        <a href="${pageContext.request.contextPath}/PurchaseServlet" class="sidebar-link">
            <i class="bi bi-bag-check"></i><span>Purchase</span>
        </a>
        <a href="${pageContext.request.contextPath}/pages/productCategory.jsp" class="sidebar-link">
            <i class="bi bi-collection"></i><span>Categories</span>
        </a>
        <a href="${pageContext.request.contextPath}/Product" class="sidebar-link">
            <i class="bi bi-box-seam"></i><span>Products</span>
        </a>
        <a href="${pageContext.request.contextPath}/ExpenseEntryServlet" class="sidebar-link">
            <i class="bi bi-wallet2"></i><span>Expenses</span>
        </a>

        <div class="mt-4 px-4 small text-uppercase text-muted fw-bold analytics-label" style="font-size: 0.65rem; letter-spacing: 1px; margin-bottom: 5px;">Data & Analytics</div>
        
        <button class="sidebar-link d-flex justify-content-between align-items-center collapsed" 
                type="button" data-bs-toggle="collapse" data-bs-target="#reportMenu">
            <div class="d-flex align-items-center">
                <i class="bi bi-bar-chart-line-fill"></i><span>Reports Center</span>
            </div>
            <i class="bi bi-chevron-down"></i>
        </button>
        
        <div class="collapse" id="reportMenu">
            <div class="submenu-container">
                <a href="${pageContext.request.contextPath}/PrintPurchaseReportServlet" class="submenu-link">
                    <i class="bi bi-file-earmark-bar-graph me-2"></i>Sales & Purchase
                </a>
                <a href="${pageContext.request.contextPath}/ProfitAndLossReport" class="submenu-link">
                    <i class="bi bi-graph-up-arrow me-2"></i>Profit & Loss
                </a>
                <a href="${pageContext.request.contextPath}/CashBookReport" class="submenu-link">
                    <i class="bi bi-journal-check me-2"></i>Expense Summary
                </a>
            </div>
        </div>
    </nav>
</aside>

<header class="app-header">
    <div class="container-fluid d-flex align-items-center justify-content-between">
        <div class="d-flex align-items-center">
            <button class="btn text-white fs-2 p-0 me-3" id="sidebarToggle" type="button">
                <i class="bi bi-list"></i>
            </button>
            <div class="d-none d-sm-block">
                <h5 class="m-0 text-white fw-bold" id="greeting">Welcome, <%= username %></h5>
                <small class="text-info" id="liveClock" style="font-size: 0.75rem;"></small>
            </div>
        </div>
        
        <div class="d-flex align-items-center gap-2 gap-md-3">
            <div class="text-end d-none d-sm-block">
                <span class="version-badge">v44.1</span>
                <span class="text-white fw-bold d-block" style="font-size: 0.9rem;"><%= username %></span>
                <small class="text-muted opacity-75" style="font-size: 0.65rem;">Status: Online</small>
            </div>
            <a href="${pageContext.request.contextPath}/pages/loginpage.jsp" class="btn btn-logout d-flex align-items-center">
                <i class="bi bi-power me-md-2"></i><span>Logout</span>
            </a>
        </div>
    </div>
</header>



<footer class="app-footer">
    <div class="container-fluid d-flex flex-column flex-md-row justify-content-between align-items-center px-4 small">
        <div class="mb-1 mb-md-0 text-white">
            &copy; <span id="year"></span> <strong><%= orgNamee %></strong> | System v44.1
        </div>
        <div class="text-center text-md-end">
            Design & Developed by 
            <a href="https://VijayTechOrbitSolutions.com" target="_blank" class="text-info text-decoration-none fw-bold">
                VijayTechOrbitSolutions.com
            </a>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const sidebarToggle = document.getElementById('sidebarToggle');
    const mobileClose = document.getElementById('mobileClose');
    const mobileOverlay = document.getElementById('mobileOverlay');
    const body = document.body;

    // Corrected Sidebar Action Logic
    sidebarToggle.addEventListener('click', function(e) {
        e.preventDefault();
        if (window.innerWidth < 992) {
            // Logic for Mobile: Slide sidebar in
            body.classList.toggle('mobile-open');
        } else {
            // Logic for Desktop: Collapse sidebar to icons only
            body.classList.toggle('collapsed-sidebar');
            
            // Auto-collapse open menus if sidebar is shrunk
            const reportMenu = document.getElementById('reportMenu');
            if (body.classList.contains('collapsed-sidebar')) {
                const bsCollapse = bootstrap.Collapse.getInstance(reportMenu);
                if (bsCollapse) bsCollapse.hide();
            }
        }
    });

    // Close mobile sidebar when clicking "X" or the blurred overlay
    [mobileClose, mobileOverlay].forEach(el => {
        el.addEventListener('click', () => {
            body.classList.remove('mobile-open');
        });
    });

    // Reset mobile state if window is resized to desktop width
    window.addEventListener('resize', () => {
        if (window.innerWidth >= 992) {
            body.classList.remove('mobile-open');
        }
    });

    // UI Updates (Time & Username Greeting)
    function updateUI() {
        const now = new Date();
        const hrs = now.getHours();
        
        // Update clock and year
        const liveClockEl = document.getElementById('liveClock');
        const yearEl = document.getElementById('year');
        if(liveClockEl) liveClockEl.innerText = now.toDateString() + " | " + now.toLocaleTimeString();
        if(yearEl) yearEl.innerText = now.getFullYear();

        // Inject Username correctly
        const serverUser = "<%= username %>";
        let greetText = (hrs < 12) ? "Good Morning" : (hrs < 17) ? "Good Afternoon" : "Good Evening";
        
        const greetingEl = document.getElementById('greeting');
        if(greetingEl) {
            greetingEl.innerHTML = greetText + `, <span class="text-info">${serverUser}</span>`;
        }
    }
    
    // Refresh every second
    setInterval(updateUI, 1000);
    updateUI();
</script>

</body>
</html>