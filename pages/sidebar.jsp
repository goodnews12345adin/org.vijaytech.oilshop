<%@ page pageEncoding="UTF-8" session="true" %><%
/* ===========================
   SESSION & ROLE VALIDATION
   =========================== */
String username = (String) session.getAttribute("username");
Integer roleIdObj = (Integer) session.getAttribute("AD_Role_ID");

if (roleIdObj == null) {
    response.sendRedirect(request.getContextPath() + "/pages/loginpage.jsp");
    return;
}

int roleId = roleIdObj.intValue();

if (username == null || username.trim().isEmpty()) {
    username = "Guest";
}

/* ===========================
   ROLE CONSTANTS
   =========================== */
Integer ROLE_ADMIN1  = (Integer) session.getAttribute("ROLE_ADMIN");
Integer ROLE_CASHIERObj = (Integer) session.getAttribute("ROLE_CASHIER");

final int ROLE_ADMIN  = ROLE_ADMIN1.intValue();
final int ROLE_CASHIER = ROLE_CASHIERObj.intValue();
String orgNamee = " TSA OIL STORE";

// Helper for Avatar Initials
String userInitials = username.length() >= 2 ? username.substring(0, 2).toUpperCase() : "GU";
%>

<!DOCTYPE html>
<html lang="en" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><%= orgNamee %> ERP - Dashboard</title>
    
    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        /* === CSS VARIABLES & THEMES === */
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
            
            /* Light Theme Defaults */
            --bg-body: #f4f7fe;
            --text-main: #333;
            --card-bg: #ffffff;
        }

        /* Dark Theme Overrides */
        [data-bs-theme="dark"] {
            --bg-body: #0b1120;
            --text-main: #e2e8f0;
            --card-bg: #1e293b;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-main);
            margin: 0;
            padding-top: var(--header-height);
            padding-bottom: var(--footer-height);
            transition: background-color 0.3s, color 0.3s;
            overflow-x: hidden;
            min-height: 100vh;
        }

        /* === SIDEBAR STYLING === */
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
            display: flex;
            flex-direction: column;
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
            flex-shrink: 0;
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

        /* === SUBMENU STYLING === */
        .submenu-container {
            list-style: none;
            padding: 5px 0;
            margin: 0 15px 10px 15px;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 10px;
            display: none; 
        }
        
        .submenu-container.show { display: block; animation: fadeIn 0.3s ease; }

        .submenu-link {
            padding: 8px 15px 8px 45px !important;
            font-size: 0.82rem !important;
            margin: 2px 0 !important;
            display: flex !important;
            align-items: center;
            color: rgba(255, 255, 255, 0.5) !important;
            text-decoration: none !important;
            width: 100% !important;
            border-radius: 8px !important;
        }

        .submenu-link:hover {
            color: #fff !important;
            background: rgba(255, 255, 255, 0.05);
        }

        .submenu-link i { color: var(--accent-primary); margin-right: 12px; font-size: 1rem; }
        
        .submenu-arrow { transition: transform 0.3s ease; font-size: 0.8rem; margin-left: auto; }
        .sidebar-link.expanded .submenu-arrow { transform: rotate(180deg); }

        /* Mobile Logout in Sidebar Footer */
        .sidebar-footer-logout {
            margin-top: auto;
            padding: 15px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        /* === HEADER STYLING === */
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

        .search-bar {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            color: white;
            padding: 8px 15px;
            width: 250px;
            transition: var(--transition);
        }
        .search-bar:focus {
            background: rgba(255, 255, 255, 0.1);
            box-shadow: 0 0 0 2px var(--accent-primary);
            color: white;
        }
        .search-bar::placeholder { color: rgba(255,255,255,0.5); }

        .icon-btn {
            width: 40px; height: 40px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: white;
            background: rgba(255,255,255,0.05);
            transition: 0.2s;
            cursor: pointer;
            text-decoration: none;
            position: relative;
        }
        .icon-btn:hover { background: rgba(255,255,255,0.15); color: var(--accent-primary); }
        
        /* Logout Button Styling */
        .btn-logout-header {
            background: rgba(220, 53, 69, 0.15);
            border: 1px solid rgba(220, 53, 69, 0.4);
            color: #ff6b6b;
            border-radius: 10px;
            padding: 8px 16px;
            font-size: 0.85rem;
            font-weight: 600;
            transition: var(--transition);
            display: flex; align-items: center; gap: 8px;
            text-decoration: none;
        }
        .btn-logout-header:hover {
            background: #dc3545;
            color: white;
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
        }

        /* === USER AVATAR === */
        .user-avatar-circle {
            width: 40px; height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: white;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 0.9rem;
            box-shadow: 0 4px 10px rgba(25, 182, 176, 0.3);
            cursor: pointer;
        }

        /* === FOOTER STYLING === */
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

        /* === DASHBOARD WIDGETS === */
        .stat-card {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 20px;
            border: 1px solid rgba(0,0,0,0.05);
            box-shadow: var(--card-shadow);
            height: 100%;
            transition: transform 0.2s, background-color 0.3s;
            position: relative;
            overflow: hidden;
        }
        [data-bs-theme="dark"] .stat-card { border: 1px solid rgba(255,255,255,0.05); }

        .stat-card:hover { transform: translateY(-5px); }
        .stat-card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%;
            background: var(--accent-primary);
        }
        .stat-label { font-size: 0.75rem; font-weight: 700; color: #888; text-transform: uppercase; margin-bottom: 10px; display: block; }
        .stat-value { font-size: 1.8rem; font-weight: 800; display: block; color: var(--text-main); }
        
        /* Quick Action Buttons */
        .quick-action-card {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            border: 1px dashed var(--accent-primary);
            cursor: pointer;
            transition: 0.3s;
            height: 100%;
        }
        .quick-action-card:hover {
            background: rgba(25, 182, 176, 0.05);
            transform: scale(1.02);
        }
        .quick-icon {
            font-size: 2rem;
            color: var(--accent-primary);
            margin-bottom: 10px;
            display: inline-block;
        }

        /* === FLOATING ACTION BUTTON (FAB) === */
        .fab {
            position: fixed;
            bottom: 80px;
            right: 30px;
            width: 56px;
            height: 56px;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: white;
            font-size: 1.5rem;
            box-shadow: 0 10px 25px rgba(25, 182, 176, 0.4);
            cursor: pointer;
            z-index: 900;
            transition: 0.3s;
        }
        .fab:hover { transform: rotate(90deg) scale(1.1); }

        /* === TOAST NOTIFICATIONS === */
        .toast-custom {
            backdrop-filter: blur(10px);
            background: rgba(30, 41, 59, 0.9) !important;
            color: #fff !important;
            border: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .toast-header-custom {
            background: transparent;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            color: white;
        }

        /* === ANIMATIONS === */
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

        /* Main Content */
        .main-content { padding: 25px; transition: var(--transition); }

        /* === RESPONSIVE MEDIA QUERIES (ALL DEVICES) === */
        
        /* Desktop Large (Collapsed Sidebar Logic) */
        @media (min-width: 992px) {
            body { padding-left: var(--sidebar-width); }
            body.collapsed-sidebar { padding-left: var(--sidebar-collapsed); }
            
            body.collapsed-sidebar .sidebar-wrapper { width: var(--sidebar-collapsed); }
            body.collapsed-sidebar .app-header, 
            body.collapsed-sidebar .app-footer { left: var(--sidebar-collapsed); }
            
            body.collapsed-sidebar .sidebar-link span, 
            body.collapsed-sidebar .brand-text, 
            body.collapsed-sidebar .submenu-arrow,
            body.collapsed-sidebar .submenu-container { 
                display: none !important; 
            }
        }

        /* Tablet & Mobile Landscape (< 992px) */
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
            .search-bar { width: 150px; }
            .fab { bottom: 20px; right: 20px; }
            .sidebar-footer-logout { display: block; } /* Ensure logout visible on mobile sidebar */
            
            /* Hide Desktop Logout in Header on Tablet/Mobile */
            .btn-logout-header { display: none !important; }
        }

        /* Small Mobile (< 576px) */
        @media (max-width: 576px) {
            /* Hide detailed user text in header to save space */
            .text-end.d-none.d-sm-block { display: none !important; }
            /* Show avatar only */
            .user-avatar-circle { margin: 0; }
            
            .header-greeting-text { display: none; } /* Hide "Welcome User" text */
            
            .fab { width: 50px; height: 50px; font-size: 1.2rem; bottom: 15px; right: 15px; }
            .main-content { padding: 15px; }
            
            /* Adjust Quick Actions to stack nicely */
            .quick-action-card { padding: 15px; }
            .quick-icon { font-size: 1.5rem; }
        }

        .brand-text {
            background: linear-gradient(90deg, #fff, var(--accent-primary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 800;
        }
    </style>
</head>
<body>

<!-- Mobile Overlay (Backdrop) -->
<div class="mobile-overlay" id="mobileOverlay"></div>

<!-- Floating Action Button -->
<% if (roleId == ROLE_ADMIN || roleId == ROLE_CASHIER) { %>
<div class="fab" onclick="showToast('Creating new sale invoice...', 'success')" title="New Sale">
    <i class="bi bi-plus-lg"></i>
</div>
<% } %>

<!-- Keyboard Shortcuts Modal -->
<div class="modal fade" id="shortcutsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="background: var(--card-bg); color: var(--text-main); border:none;">
            <div class="modal-header border-bottom-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-keyboard me-2 text-info"></i>Keyboard Shortcuts</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <ul class="list-group list-group-flush">
                    <li class="list-group-item d-flex justify-content-between align-items-center bg-transparent">
                        <span><i class="bi bi-search me-2"></i>Global Search</span>
                        <kbd class="bg-dark text-white rounded px-2 py-1 small">Ctrl + K</kbd>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center bg-transparent">
                        <span><i class="bi bi-cart3 me-2"></i>New Sale</span>
                        <kbd class="bg-dark text-white rounded px-2 py-1 small">Alt + S</kbd>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center bg-transparent">
                        <span><i class="bi bi-lightbulb me-2"></i>Toggle Theme</span>
                        <kbd class="bg-dark text-white rounded px-2 py-1 small">Alt + D</kbd>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</div>

<!-- Sidebar -->
<aside class="sidebar-wrapper" id="sidebar">
    <div class="sidebar-header">
        <div class="d-flex align-items-center">
            <i class="bi bi-intersect text-info fs-3 me-2"></i>
            <span class="brand-text fs-4"><%= orgNamee %></span>
        </div>
        <button class="mobile-close-btn" id="mobileClose"><i class="bi bi-x-lg"></i></button>
    </div>

    <div class="d-flex flex-column py-3" style="flex-grow:1;">
        <!-- Dashboard -->
        <% if (roleId == ROLE_ADMIN) { %>
        <a href="<%=request.getContextPath()%>/pages/dashboard.jsp" class="sidebar-link active" id="nav-dashboard">
            <i class="bi bi-speedometer2 me-2"></i> <span>Dashboard</span>
        </a>
        <% } %>

        <!-- Operations (Grouped) -->
        <div class="nav-item mt-2">
            <a href="#" class="sidebar-link" onclick="toggleSubmenu('opsMenu', this)">
                <i class="bi bi-grid-fill me-2"></i> 
                <span>Operations</span>
                <i class="bi bi-chevron-down submenu-arrow"></i>
            </a>
            <ul class="submenu-container" id="opsMenu">
                <% if (roleId == ROLE_ADMIN || roleId == ROLE_CASHIER) { %>
                <li><a href="<%=request.getContextPath()%>/SalesServlet" class="sidebar-link submenu-link">
                    <i class="bi bi-cart3"></i> Sales
                </a></li>
                <li><a href="<%=request.getContextPath()%>/PurchaseServlet" class="sidebar-link submenu-link">
                    <i class="bi bi-bag-check"></i> Purchase
                </a></li>
                <% } %>
                <!-- BPManageServlet PART -->
                <% if (roleId == ROLE_ADMIN) { %>
                <li><a href="<%=request.getContextPath()%>/BPManageServlet" class="sidebar-link submenu-link">
                    <i class="bi bi-people"></i> Partners (Cust/Vend)
                </a></li>
                <% } %>
            </ul>
        </div>

        <!-- Inventory (Grouped) -->
        <% if (roleId == ROLE_ADMIN) { %>
        <div class="nav-item mt-2">
            <a href="#" class="sidebar-link" onclick="toggleSubmenu('invMenu', this)">
                <i class="bi bi-box-seam me-2"></i> 
                <span>Inventory</span>
                <i class="bi bi-chevron-down submenu-arrow"></i>
            </a>
            <ul class="submenu-container" id="invMenu">
                <li><a href="<%=request.getContextPath()%>/pages/productCategory.jsp" class="sidebar-link submenu-link">
                    <i class="bi bi-collection"></i> Categories
                </a></li>
                <li><a href="<%=request.getContextPath()%>/Product" class="sidebar-link submenu-link">
                    <i class="bi bi-box-seam"></i> Products
                </a></li>
            </ul>
        </div>
        <% } %>

        <!-- Finance -->
        <% if (roleId == ROLE_ADMIN ) { %>
        <a href="<%=request.getContextPath()%>/ExpenseEntryServlet" class="sidebar-link mt-2">
            <i class="bi bi-wallet2 me-2"></i> <span>Expenses</span>
        </a>
        <% } %>
        
        <hr class="text-secondary mx-3 my-2">
        
        <div class="nav-item mt-2">
            <a href="#" class="sidebar-link" onclick="toggleSubmenu('reportMenu', this)">
                <i class="bi bi-bar-chart-line me-2"></i> 
                <span>Reports</span>
                <i class="bi bi-chevron-down submenu-arrow"></i>
            </a>
            <% if (roleId == ROLE_ADMIN ) { %>
            <ul class="submenu-container" id="reportMenu">
                <li><a href="<%=request.getContextPath()%>/PrintPurchaseReportServlet" class="sidebar-link submenu-link">
                    <i class="bi bi-file-earmark-bar-graph"></i> Sales & Purchase
                </a></li>
                <li><a href="<%=request.getContextPath()%>/ProfitAndLossReport" class="sidebar-link submenu-link">
                    <i class="bi bi-graph-up"></i> Profit & Loss
                </a></li>
                <% } %>
                <% if (roleId == ROLE_ADMIN || roleId == ROLE_CASHIER) { %>
                <li><a href="<%=request.getContextPath()%>/StockReport" class="sidebar-link submenu-link">
                    <i class="bi bi-box-seam"></i> Stock Report
                </a></li>
                <% } %>
                <% if (roleId == ROLE_ADMIN) { %>
                <li><a href="<%=request.getContextPath()%>/CashBookReport" class="sidebar-link submenu-link">
                    <i class="bi bi-journal-check"></i> Expense Summary
                </a></li>
            </ul>
        </div>
        <% } %>
    </div>

    <!-- Mobile Sidebar Footer (Visible on mobile only) -->
    <div class="sidebar-footer-logout d-lg-none">
        <a href="${pageContext.request.contextPath}/pages/loginpage.jsp" class="btn btn-danger w-100 text-white">
            <i class="bi bi-box-arrow-right"></i> Logout
        </a>
    </div>
</aside>

<!-- Header -->
<header class="app-header">
    <div class="container-fluid d-flex align-items-center justify-content-between px-4">
        <div class="d-flex align-items-center">
            <button class="btn text-white fs-2 p-0 me-3" id="sidebarToggle" type="button">
                <i class="bi bi-list"></i>
            </button>
            <div class="d-none d-sm-block header-greeting-text">
                <h5 class="m-0 text-white fw-bold" id="greeting">Welcome, <%= username %></h5>
                <small class="text-info" id="liveClock" style="font-size: 0.75rem;"></small>
            </div>
        </div>
        
        <div class="d-flex align-items-center gap-2 gap-md-3 ms-md-3">
            
            <!-- THEME TOGGLE BUTTON (Added as it was missing) -->
            <a href="#" class="icon-btn" id="themeIcon" onclick="toggleTheme()" title="Toggle Theme">
                <i class="bi bi-moon-stars-fill"></i>
            </a>

            <!-- User Profile Dropdown -->
            <div class="dropdown">
                <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" data-bs-toggle="dropdown">
                    <div class="user-avatar-circle me-2"><%= userInitials %></div>
                    <div class="text-end d-none d-sm-block">
                        <span class="d-block text-white fw-bold" style="font-size: 0.85rem; line-height: 1;"><%= username %></span>
                        <small class="text-success" style="font-size: 0.65rem;">● Online</small>
                    </div>
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="min-width: 200px;">
                    <li><a class="dropdown-item small" href="#"><i class="bi bi-person me-2"></i> My Profile</a></li>
                    <li><a class="dropdown-item small" href="#"><i class="bi bi-gear me-2"></i> Settings</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a href="${pageContext.request.contextPath}/pages/loginpage.jsp" class="dropdown-item small text-danger"><i class="bi bi-box-arrow-right me-2"></i> Logout</a></li>
                </ul>
            </div>

            <!-- EXPLICIT LOGOUT BUTTON (Visible on Desktop/Tablet) -->
            <a href="${pageContext.request.contextPath}/pages/loginpage.jsp" class="btn-logout-header d-none d-md-flex" title="Logout">
                <i class="bi bi-power"></i> <span>Logout</span>
            </a>
        </div>
    </div>
</header>

<!-- Main Content -->
<main class="main-content">
    <% if (roleId == ROLE_ADMIN) { %>
    
    <!-- Quick Actions Row -->
    <div class="row g-3 mb-4">
        <div class="col-12">
            <h6 class="fw-bold text-uppercase text-muted mb-3" style="font-size: 0.75rem; letter-spacing: 1px;">Quick Actions</h6>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="quick-action-card" onclick="window.location.href='<%=request.getContextPath()%>/SalesServlet'">
                <div class="quick-icon"><i class="bi bi-cart-plus"></i></div>
                <h6 class="fw-bold mb-0">New Sale</h6>
                <small class="text-muted">Create POS Invoice</small>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="quick-action-card" onclick="window.location.href='<%=request.getContextPath()%>/BPManageServlet'">
                <div class="quick-icon"><i class="bi bi-person-plus"></i></div>
                <h6 class="fw-bold mb-0">New Partner</h6>
                <small class="text-muted">Add Customer/Vendor</small>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="quick-action-card" onclick="window.location.href='<%=request.getContextPath()%>/PurchaseServlet'">
                <div class="quick-icon"><i class="bi bi-bag-plus"></i></div>
                <h6 class="fw-bold mb-0">Purchase</h6>
                <small class="text-muted">Stock Entry</small>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="quick-action-card" onclick="window.location.href='<%=request.getContextPath()%>/PrintPurchaseReportServlet'">
                <div class="quick-icon"><i class="bi bi-printer"></i></div>
                <h6 class="fw-bold mb-0">Reports</h6>
                <small class="text-muted">View Analytics</small>
            </div>
        </div>
    </div>

    <% } else { %>
        <!-- Cashier View -->
        <div class="text-center mt-5">
            <div class="user-avatar-circle mx-auto mb-3" style="width: 80px; height: 80px; font-size: 2rem;"><%= userInitials %></div>
            <h3>Welcome, <%= username %></h3>
            <p class="text-muted">Ready to process transactions.</p>
            <a href="<%=request.getContextPath()%>/SalesServlet" class="btn btn-lg btn-info text-white mt-3 shadow px-5">Start New Sale <i class="bi bi-arrow-right"></i></a>
        </div>
    <% } %>
</main>

<footer class="app-footer">
    <div class="container-fluid d-flex flex-column flex-md-row justify-content-between align-items-center px-4 small">
        <div class="mb-1 mb-md-0 text-white">
            &copy; <span id="year"></span> <strong><%= orgNamee %></strong> | System v44.1 (Trending)
        </div>
        <div class="text-center text-md-end">
            Design & Developed by 
            <a href="https://VijayTechOrbitSolutions.com" target="_blank" class="text-info text-decoration-none fw-bold">
                VijayTechOrbitSolutions.com
            </a>
        </div>
    </div>
</footer>

<!-- Container for Toasts -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastPlacement"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // === UI REFERENCES ===
    const sidebarToggle = document.getElementById('sidebarToggle');
    const mobileClose = document.getElementById('mobileClose');
    const mobileOverlay = document.getElementById('mobileOverlay');
    const body = document.body;

    // === SIDEBAR TOGGLE LOGIC ===
    sidebarToggle.addEventListener('click', function(e) {
        e.preventDefault();
        if (window.innerWidth < 992) {
            // Mobile: Slide in/out
            body.classList.toggle('mobile-open');
        } else {
            // Desktop: Collapse to icons
            body.classList.toggle('collapsed-sidebar');
            
            // Close submenus when collapsing
            document.querySelectorAll('.submenu-container').forEach(menu => {
                menu.classList.remove('show');
            });
            document.querySelectorAll('.sidebar-link.expanded').forEach(link => {
                link.classList.remove('expanded');
            });
        }
    });

    // Close mobile sidebar via overlay or 'X' button
    [mobileClose, mobileOverlay].forEach(el => {
        el.addEventListener('click', () => {
            body.classList.remove('mobile-open');
        });
    });

    // Reset mobile state on resize
    window.addEventListener('resize', () => {
        if (window.innerWidth >= 992) {
            body.classList.remove('mobile-open');
        }
    });

    // === SUBMENU TOGGLE LOGIC ===
    function toggleSubmenu(menuId, triggerElement) {
        if(triggerElement.getAttribute('href') === '#') {
            event.preventDefault();
        }
        const menu = document.getElementById(menuId);
        menu.classList.toggle('show');
        triggerElement.classList.toggle('expanded');
    }

    // === DARK MODE LOGIC ===
    function toggleTheme() {
        const html = document.documentElement;
        const currentTheme = html.getAttribute('data-bs-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        
        html.setAttribute('data-bs-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        
        // Update Icon
        const icon = document.getElementById('themeIcon');
        if(icon) {
            const iconEl = icon.querySelector('i');
            if(newTheme === 'dark') {
                iconEl.classList.remove('bi-moon-stars-fill');
                iconEl.classList.add('bi-sun-fill');
            } else {
                iconEl.classList.remove('bi-sun-fill');
                iconEl.classList.add('bi-moon-stars-fill');
            }
        }
    }

    // Initialize Theme from LocalStorage
    const savedTheme = localStorage.getItem('theme');
    if(savedTheme) {
        document.documentElement.setAttribute('data-bs-theme', savedTheme);
        const icon = document.getElementById('themeIcon');
        if(icon && savedTheme === 'dark') {
            const iconEl = icon.querySelector('i');
            iconEl.classList.remove('bi-moon-stars-fill');
            iconEl.classList.add('bi-sun-fill');
        }
    }

    // === TOAST NOTIFICATION LOGIC ===
    function showToast(message, type = 'success') {
        const toastContainer = document.getElementById('toastPlacement');
        
        // Select Icon and Color based on type
        let iconClass = 'bi-check-circle-fill';
        if(type === 'danger') { iconClass = 'bi-exclamation-triangle-fill'; }
        if(type === 'info') { iconClass = 'bi-info-circle-fill'; }

        // Create Toast HTML
        const toastEl = document.createElement('div');
        toastEl.className = `toast toast-custom align-items-center border-0 mb-2`;
        toastEl.setAttribute('role', 'alert');
        toastEl.setAttribute('aria-live', 'assertive');
        toastEl.setAttribute('aria-atomic', 'true');
        
        toastEl.innerHTML = `
            <div class="d-flex">
                <div class="toast-body d-flex align-items-center">
                    <i class="bi ${iconClass} fs-5 me-2"></i>
                    <span class="fw-medium">${message}</span>
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        `;

        toastContainer.appendChild(toastEl);
        
        // Initialize and Show Bootstrap Toast
        const bsToast = new bootstrap.Toast(toastEl, { delay: 3000 });
        bsToast.show();

        // Clean up DOM after hide
        toastEl.addEventListener('hidden.bs.toast', () => {
            toastEl.remove();
        });
    }

    // === KEYBOARD SHORTCUTS ===
    document.addEventListener('keydown', (e) => {
        // Alt + D for Dark Mode
        if (e.altKey && e.key === 'd') {
            e.preventDefault();
            toggleTheme();
        }
        // Alt + S for Sale
        if (e.altKey && e.key === 's') {
            e.preventDefault();
            window.location.href = '<%=request.getContextPath()%>/SalesServlet';
        }
    });

    // === CLOCK & GREETING ===
    function updateUI() {
        const now = new Date();
        const hrs = now.getHours();
        
        const liveClockEl = document.getElementById('liveClock');
        const yearEl = document.getElementById('year');
        if(liveClockEl) liveClockEl.innerText = now.toDateString() + " | " + now.toLocaleTimeString();
        if(yearEl) yearEl.innerText = now.getFullYear();

        const serverUser = "<%= username %>";
        let greetText = (hrs < 12) ? "Good Morning" : (hrs < 17) ? "Good Afternoon" : "Good Evening";
        
        const greetingEl = document.getElementById('greeting');
        if(greetingEl) {
            greetingEl.innerHTML = greetText + `, <span class="text-info">${serverUser}</span>`;
        }
    }

    // Highlight Active Link (Includes BPManageServlet Fix)
    function setActiveLink() {
        const currentPath = window.location.pathname;
        const links = document.querySelectorAll('.sidebar-link');
        links.forEach(link => {
            const href = link.getAttribute('href');
            if(href && currentPath.includes(href)) {
                link.classList.add('active');
                const parentMenu = link.closest('.submenu-container');
                if(parentMenu) {
                    parentMenu.classList.add('show');
                    // Find the trigger link (sibling of the ul) and expand it
                    const trigger = parentMenu.previousElementSibling;
                    if(trigger && trigger.classList.contains('sidebar-link')) {
                        trigger.classList.add('expanded');
                    }
                }
            }
        });
    }

    // Start Intervals
    setInterval(updateUI, 1000);
    updateUI();
    setActiveLink();
</script>

</body>
</html>