<!-- ===== Footer Section ===== -->
<footer class="footer mt-auto py-3 bg-white border-top shadow-sm">
  <div class="container text-center text-muted small">
    <span>&copy;<%--  <%= java.time.Year.now() %> --%> MyApp ERP Portal. All rights reserved.</span>
    <br>
    <span>Developed by <a href="#" class="text-decoration-none text-primary fw-semibold">Your Company</a></span>
  </div>
</footer>

<!-- ===== Include Bootstrap JS (if not already included) ===== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- ===== Optional Extra Styling ===== -->
<style>
  .footer {
    position: fixed;
    bottom: 0;
    left: 250px; /* aligns with sidebar width */
    right: 0;
    height: 60px;
    line-height: 1.6;
  }

  .footer a:hover {
    text-decoration: underline;
  }

  @media (max-width: 768px) {
    .footer {
      left: 0;
      font-size: 0.9rem;
    }
  }
</style>
