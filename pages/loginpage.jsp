<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Textile Billing Login</title>

    <!-- ✅ Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: linear-gradient(135deg, #f8f9fa, #dbeafe);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', sans-serif;
        }
        .login-card {
            width: 400px;
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            padding: 2rem;
        }
        .login-card h3 {
            font-weight: 600;
            color: #0d6efd;
            text-align: center;
            margin-bottom: 1.5rem;
        }
        .brand-logo {
            display: block;
            margin: 0 auto 15px;
            width: 80px;
        }
    </style>
</head>
<body>

    

    <div class="login-card">
        <img src="company_logo.png" alt="Company Logo" class="brand-logo">
        <h3>Sree Textiles Billing</h3>

        <%-- <% if (!error.isEmpty()) { %>
            <div class="alert alert-danger py-2 text-center">
                <%= error %>
            </div>
        <% } %> --%>

        <form method="post" action="${pageContext.request.contextPath}/UserLoginServlet" onsubmit="showLoading()" novalidate>
            <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <input type="text" id="username" name="username" class="form-control" placeholder="Enter username" required>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" id="password" name="password" class="form-control" placeholder="Enter password" required>
            </div>

            <div class="form-check mb-3">
                <input class="form-check-input" type="checkbox" id="remember">
                <label class="form-check-label" for="remember">Remember me</label>
            </div>

            <button type="submit" class="btn btn-primary w-100">Login</button>

            <div class="text-center mt-3">
                <small class="text-muted">© 2025 Sree Textiles</small>
            </div>
        </form>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
