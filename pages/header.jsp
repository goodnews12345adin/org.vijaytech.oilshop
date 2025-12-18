<%-- <%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        username = "Guest";
    }
%>

<!-- ===========================
     Premium Bootstrap Header
=========================== -->
<nav class="navbar navbar-expand-lg navbar-dark fixed-top shadow-lg app-navbar">
    <div class="container-fluid px-3 px-lg-4">

        <!-- Brand -->
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="dashboard.jsp">
            <span class="brand-icon">
                <i class="bi bi-speedometer2"></i>
            </span>
            <span class="brand-text">MyApp</span>
        </a>

        <!-- Mobile Toggle -->
        <button class="navbar-toggler"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarMenu"
                aria-controls="navbarMenu"
                aria-expanded="false"
                aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Menu -->
        <div class="collapse navbar-collapse" id="navbarMenu">

            <!-- Left Links -->
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 gap-lg-2">
               <!--  <li class="nav-item">
                    <a class="nav-link active" href="dashboard.jsp">
                        <i class="bi bi-house-door"></i>
                        <span>Dashboard</span>
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="sales.jsp">
                        <i class="bi bi-cart3"></i>
                        <span>Sales</span>
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="reports.jsp">
                        <i class="bi bi-bar-chart"></i>
                        <span>Reports</span>
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="settings.jsp">
                        <i class="bi bi-gear"></i>
                        <span>Settings</span>
                    </a>
                </li> -->
            </ul>

            <!-- Right Side -->
            <div class="d-flex align-items-center gap-3 ms-lg-3">

                <!-- Welcome -->
                <div class="welcome-text d-none d-sm-block">
                    Welcome,
                    <strong><%= username %></strong>
                </div>

                <!-- Logout -->
                <a href="logout.jsp" class="btn btn-sm btn-gradient">
                    <i class="bi bi-box-arrow-right"></i>
                    Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- ===========================
     Required CSS
=========================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* Header Styles */
:root {
    --nav-bg-1: #08143a;
    --nav-bg-2: #0b1f5a;
    --accent-a: #19b6b0;
    --accent-b: #15a0c6;
    --text-light: rgba(255,255,255,0.92);
}

body { padding-top: 72px; }

.app-navbar {
    background: linear-gradient(180deg, var(--nav-bg-1), var(--nav-bg-2));
    border-bottom: 1px solid rgba(255,255,255,0.04);
}

.brand-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    background: linear-gradient(135deg, var(--accent-a), var(--accent-b));
    display: grid;
    place-items: center;
    color: #fff;
    box-shadow: 0 6px 18px rgba(0,0,0,0.25);
}

.brand-text {
    background: linear-gradient(90deg, var(--accent-a), var(--accent-b));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 1.05rem;
}

.navbar-dark .nav-link {
    color: var(--text-light);
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 12px;
    border-radius: 8px;
}

.navbar-dark .nav-link:hover,
.navbar-dark .nav-link.active {
    background: rgba(255,255,255,0.06);
    color: #fff;
}

.welcome-text { color: rgba(255,255,255,0.85); font-size: 0.9rem; }

.btn-gradient {
    background: linear-gradient(90deg, var(--accent-a), var(--accent-b));
    color: #fff;
    border-radius: 999px;
    padding: 6px 14px;
    border: none;
    font-weight: 600;
    box-shadow: 0 8px 22px rgba(0,0,0,0.25);
}

.btn-gradient:hover { filter: brightness(1.05); transform: translateY(-1px); }

.navbar-toggler { border-color: rgba(255,255,255,0.15); }
.navbar-toggler-icon { filter: brightness(1.2); }

@media (max-width: 576px) { body { padding-top: 68px; } }
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
 --%>