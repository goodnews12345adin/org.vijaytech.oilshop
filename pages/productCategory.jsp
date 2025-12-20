<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Product Category | Vijay Tech Orbit</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    :root {
      --accent-color: #15a0c6;
      --accent-hover: #0e7d9b;
      --bg-slate: #f1f5f9;
      --glass-bg: rgba(255, 255, 255, 0.95);
    }

    body {
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: var(--bg-slate);
      color: #1e293b;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }

    /* Form Container Styling */
    .category-wrapper {
      padding: 60px 20px;
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .category-card {
      background: var(--glass-bg);
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 24px;
      padding: 40px;
      width: 100%;
      max-width: 550px;
      box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    }

    .card-header-custom {
      margin-bottom: 30px;
      text-align: center;
    }

    .card-header-custom h2 {
      font-weight: 800;
      font-size: 1.75rem;
      letter-spacing: -0.5px;
      color: #0f172a;
    }

    .icon-box {
      width: 60px;
      height: 60px;
      background: rgba(21, 160, 198, 0.1);
      color: var(--accent-color);
      border-radius: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
      margin: 0 auto 15px;
    }

    /* Form Controls */
    .form-label {
      font-weight: 600;
      font-size: 0.875rem;
      color: #475569;
      margin-bottom: 8px;
    }

    .form-control {
      border-radius: 12px;
      padding: 12px 16px;
      border: 1px solid #e2e8f0;
      transition: all 0.2s ease;
    }

    .form-control:focus {
      border-color: var(--accent-color);
      box-shadow: 0 0 0 4px rgba(21, 160, 198, 0.15);
    }

    /* Buttons */
    .btn-save {
      background-color: var(--accent-color);
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: 12px;
      font-weight: 700;
      width: 100%;
      transition: all 0.3s ease;
    }

    .btn-save:hover {
      background-color: var(--accent-hover);
      transform: translateY(-1px);
      box-shadow: 0 4px 12px rgba(21, 160, 198, 0.25);
    }

    .btn-reset {
      background-color: #f8fafc;
      color: #64748b;
      border: 1px solid #e2e8f0;
      padding: 12px 24px;
      border-radius: 12px;
      font-weight: 600;
      width: 100%;
    }

    .btn-reset:hover {
      background-color: #f1f5f9;
      color: #1e293b;
    }

    /* Toasts */
    .toast-container {
      z-index: 5000;
    }
  </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="category-wrapper">
  <div class="category-card">
    <div class="card-header-custom">
      <div class="icon-box">
        <i class="bi bi-grid-3x3-gap-fill"></i>
      </div>
      <h2>New Category</h2>
      <p class="text-muted small">Fill in the details to organize your inventory</p>
    </div>

    <form id="catForm" class="needs-validation" novalidate>
      <div class="mb-4">
        <label for="Name" class="form-label">Category Name <span class="text-danger">*</span></label>
        <input type="text" id="Name" class="form-control" placeholder="e.g. Textiles, Electronics" required>
        <div class="invalid-feedback">Please provide a valid category name.</div>
      </div>

      <div class="mb-4">
        <label for="Value" class="form-label">Search Key / Value</label>
        <input type="text" id="Value" class="form-control" placeholder="Short code (optional)">
      </div>

      <div class="mb-4">
        <label for="Description" class="form-label">Description</label>
        <textarea id="Description" class="form-control" rows="3" placeholder="Describe this category..."></textarea>
      </div>

      <div class="row g-3">
        <div class="col-6">
          <button type="button" id="resetBtn" class="btn btn-reset">
            <i class="bi bi-x-circle me-2"></i>Reset
          </button>
        </div>
        <div class="col-6">
          <button type="button" id="send-btn" class="btn btn-save">
            <span id="btnText"><i class="bi bi-cloud-arrow-up-fill me-2"></i>Save</span>
            <span id="btnLoader" class="spinner-border spinner-border-sm d-none"></span>
          </button>
        </div>
      </div>
    </form>
  </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
  <div id="statusToast" class="toast hide" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="toast-header">
      <i class="bi bi-info-circle-fill me-2 text-info" id="toastIcon"></i>
      <strong class="me-auto">System Update</strong>
      <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
    <div class="toast-body" id="toastMessage"></div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
$(document).ready(function() {
    const $form = $('#catForm');
    const $saveBtn = $('#send-btn');
    const $btnText = $('#btnText');
    const $btnLoader = $('#btnLoader');

    // =============================
    // SAVE CATEGORY LOGIC
    // =============================
    $saveBtn.click(function() {
        // Reset validation UI
        $form.removeClass('was-validated');

        // Basic validation check
        if ($form[0].checkValidity() === false) {
            $form.addClass('was-validated');
            return;
        }

        const data = {
            Name: $("#Name").val().trim(),
            Value: $("#Value").val().trim(),
            Description: $("#Description").val().trim()
        };

        // Loading state
        toggleLoading(true);

        $.ajax({
            type: "POST",
            url: "<%= request.getContextPath() %>/ProductCategory",
            data: JSON.stringify(data),
            contentType: "application/json",
            success: function (response) {
                showNotification("Success! Product category has been created.", "success");
                $form[0].reset();
                $form.removeClass('was-validated');
            },
            error: function(xhr) {
                const errorMsg = xhr.responseText || "Could not save category. Please try again.";
                showNotification("Error: " + errorMsg, "danger");
                console.error(xhr);
            },
            complete: function() {
                toggleLoading(false);
            }
        });
    });

    // =============================
    // UI HELPERS
    // =============================
    function toggleLoading(isLoading) {
        if (isLoading) {
            $saveBtn.prop('disabled', true);
            $btnText.addClass('d-none');
            $btnLoader.removeClass('d-none');
        } else {
            $saveBtn.prop('disabled', false);
            $btnText.removeClass('d-none');
            $btnLoader.addClass('d-none');
        }
    }

    function showNotification(message, type) {
        const $toast = $('#statusToast');
        const $icon = $('#toastIcon');
        
        // Dynamic styling
        if (type === 'success') {
            $icon.attr('class', 'bi bi-check-circle-fill me-2 text-success');
        } else {
            $icon.attr('class', 'bi bi-exclamation-triangle-fill me-2 text-danger');
        }

        $('#toastMessage').text(message);
        const toast = new bootstrap.Toast($toast[0]);
        toast.show();
    }

    $("#resetBtn").click(() => {
        $form[0].reset();
        $form.removeClass('was-validated');
    });
});
</script>

</body>
</html>