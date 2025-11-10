<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Textile Billing Login</title>

    <!-- ✅ Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ✅ External Theme CSS (from your /pages/css folder) -->
    <link href="${pageContext.request.contextPath}/pages/css/style.css" rel="stylesheet" />

    <!-- ✅ Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
</head>

<body class="bg-textile">

  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-11 col-sm-8 col-md-6 col-lg-5">

        <div class="auth-card glass neon-border p-4 p-md-5 text-center">

          <h5 class="text-soft mb-3">Login</h5>

          <!-- ✅ FIXED: Changed to POST and added name attributes -->
          <form class="text-start" action="${pageContext.request.contextPath}/UserLoginServlet" method="post">
            <div class="mb-3">
              <label class="form-label">Username</label>
              <input type="text" 
                     class="form-control form-control-lg soft-input" 
                     id="username" 
                     name="username"
                     placeholder="Enter username"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label">Password</label>
              <input type="password" 
                     class="form-control form-control-lg soft-input" 
                     id="password" 
                     name="password"
                     placeholder="Enter password"
                     required>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" value="" id="remember">
                <label class="form-check-label" for="remember">
                  Remember me
                </label>
              </div>
              <button type="button" class="btn btn-outline-light btn-sm rounded-3" id="themeToggle" title="Toggle theme">☀️</button>
            </div>

            <!-- ✅ FIXED: type=submit -->
            <button type="submit" class="btn btn-primary-gradient w-100 btn-lg">Login</button>
          </form>

          <div class="small mt-3 opacity-75">© 2024 Sree Textiles</div>
        </div>

      </div>
    </div>
  </div>

  <!-- ✅ Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- ✅ External Theme JS -->
  <script src="${pageContext.request.contextPath}/pages/js/style.js"></script>

</body>
</html>
