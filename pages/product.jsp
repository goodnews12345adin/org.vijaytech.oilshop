<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.JSONArray, org.json.JSONObject" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Master Pro | Orbit ERP</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0/dist/css/select2.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --erp-primary: #4361ee;
            --erp-success: #2ec4b6;
            --erp-bg: #f8f9fd;
            --erp-card-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
        }

        body { 
            background-color: var(--erp-bg); 
            font-family: 'Inter', sans-serif;
            color: #2b2d42;
            overflow-x: hidden;
        }

        /* Responsive Container Adjustments */
        @media (max-width: 768px) {
            .container { padding: 10px; }
            .card-header-gradient { padding: 15px !important; }
            .h2 { font-size: 1.25rem; }
        }

        /* Progress Bar */
        .form-progress {
            height: 4px;
            background: #e9ecef;
            margin-bottom: 30px;
            border-radius: 2px;
        }
        #progress-inner {
            height: 100%;
            background: var(--erp-primary);
            width: 0%;
            transition: width 0.4s ease;
        }

        /* Glassmorphism Card */
        .main-content-card {
            border: none;
            border-radius: 20px;
            background: #ffffff;
            box-shadow: var(--erp-card-shadow);
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .card-header-gradient {
            background: linear-gradient(90deg, #ffffff, var(--erp-bg));
            padding: 25px 30px;
            border-bottom: 1px solid #f1f1f1;
        }

        /* Form Styling */
        .form-label {
            font-weight: 600;
            font-size: 0.85rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-control, .select2-container--default .select2-selection--single {
            border: 1.5px solid #edf2f7 !important;
            padding: 10px 15px !important;
            border-radius: 10px !important;
            height: auto !important;
            transition: all 0.2s;
        }

        /* Media Query for Mobile Form Spacing */
        @media (max-width: 576px) {
            .row.mb-5 { margin-bottom: 1.5rem !important; }
            .btn-erp-primary { width: 100%; margin-top: 10px; }
            .d-flex.justify-content-between { flex-direction: column; }
        }

        /* Pricing Box Responsive */
        .pricing-box {
            background: #f1f5ff;
            border-radius: 15px;
            padding: 20px;
            border: 1px solid rgba(67, 97, 238, 0.1);
        }

        .btn-erp-primary {
            background: var(--erp-primary);
            color: white;
            padding: 12px 30px;
            border-radius: 12px;
            font-weight: 700;
            border: none;
            transition: all 0.3s;
        }

        /* Preview Table Styling */
        .preview-label { color: #8898aa; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; }
        .preview-value { color: #32325d; font-weight: 600; font-size: 1rem; margin-bottom: 1rem; }

        /* Floating Alert */
        .erp-toast {
            position: fixed;
            top: 25px;
            right: 25px;
            z-index: 3000;
            display: none;
            min-width: 300px;
        }
    </style>
</head>
<body>

<%@ include file="header.jsp" %>
<%@ include file="sidebar.jsp" %>

<div id="erp-toast" class="erp-toast alert shadow-lg border-0 text-white p-3 rounded-4">
    <div class="d-flex align-items-center">
        <div id="toast-icon" class="me-3 fs-4"></div>
        <div id="toast-msg" class="fw-bold"></div>
    </div>
</div>

<div class="modal fade" id="responseModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 rounded-4">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-check2-circle text-success me-2"></i>Product Entry Confirmed</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <div class="container-fluid bg-light rounded-4 p-4">
                    <div class="row">
                        <div class="col-md-4">
                            <p class="preview-label">SKU/Value</p>
                            <p id="view-sku" class="preview-value">--</p>
                        </div>
                        <div class="col-md-8">
                            <p class="preview-label">Product Name</p>
                            <p id="view-name" class="preview-value">--</p>
                        </div>
                        <hr class="opacity-10">
                        <div class="col-md-4 col-6">
                            <p class="preview-label">Category</p>
                            <p id="view-cat" class="preview-value">--</p>
                        </div>
                        <div class="col-md-4 col-6">
                            <p class="preview-label">UOM</p>
                            <p id="view-uom" class="preview-value">--</p>
                        </div>
                        <div class="col-md-4">
                            <p class="preview-label">HSN Code</p>
                            <p id="view-hsn" class="preview-value">--</p>
                        </div>
                        <hr class="opacity-10">
                        <div class="col-md-6">
                            <p class="preview-label">Financial Breakdown</p>
                            <h4 class="fw-bold text-primary">₹ <span id="view-total">0.00</span></h4>
                            <small class="text-muted">Incl. <span id="view-tax">0</span>% Tax</small>
                        </div>
                        <div class="col-md-6">
                            <p class="preview-label">Description</p>
                            <p id="view-desc" class="preview-value small text-muted">No description provided.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-light rounded-3 fw-bold" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary rounded-3 fw-bold" onclick="window.print()">
                    <i class="bi bi-printer me-2"></i>Print Slip
                </button>
            </div>
        </div>
    </div>
</div>

<div class="container py-4 py-md-5">
    <div class="row justify-content-center">
        <div class="col-xl-10 col-lg-12">
            
            <div class="main-content-card">
               <%--  <div class="card-header-gradient d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                    <div>
                        <span class="badge bg-primary-subtle text-primary mb-2 px-3 py-2 rounded-pill fw-bold">CATALOG MANAGER</span>
                        <h2 class="mb-0 fw-bold"><%= request.getAttribute("orgName") != null ? request.getAttribute("orgName") : "Inventory Control" %></h2>
                    </div>
                    <div class="text-md-end">
                        <small class="text-muted d-none d-md-block mb-1">Shortcut: <strong>Ctrl + S</strong> to Save</small>
                        <button class="btn btn-sm btn-light border w-100 w-md-auto" onclick="location.reload()">
                            <i class="bi bi-arrow-repeat"></i> Reload
                        </button>
                    </div>
                </div> --%>

                <div class="form-progress">
                    <div id="progress-inner"></div>
                </div>

                <div class="p-3 p-md-5 pt-0">
                    <form id="productForm">
                        <input type="hidden" id="productId" value="0">

                        <div class="row g-3 mb-4 mb-md-5">
                            <div class="col-12 mb-2">
                                <h5 class="fw-bold text-dark"><i class="bi bi-1-circle-fill me-2 text-primary"></i> Essential Details</h5>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Search Key (SKU)</label>
                                <input class="form-control" id="Value" placeholder="e.g. PRD-102" required>
                            </div>
                            <div class="col-md-8">
                                <label class="form-label">Product Name</label>
                                <input class="form-control" id="Name" placeholder="Detailed product title..." required>
                            </div>
                        </div>

                        <div class="row g-3 mb-4 mb-md-5">
                            <div class="col-12 mb-2">
                                <h5 class="fw-bold text-dark"><i class="bi bi-2-circle-fill me-2 text-primary"></i> Categorization</h5>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Product Category</label>
                                <select id="M_Product_Category_ID" class="form-select select2-init" required></select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Unit of Measure (UOM)</label>
                                <select id="C_UOM_ID" class="form-select select2-init" required></select>
                            </div>
                            <!-- <div class="col-md-4">
                                <label class="form-label">Record Type</label>
                                <select id="EntryType" class="form-select" required>
                                    <option value="Both">General (Buy & Sell)</option>
                                    <option value="Purchase">Raw Material (Purchase Only)</option>
                                    <option value="Sales">Service (Sales Only)</option>
                                </select>
                            </div> -->
                        </div>

                        <div class="pricing-box mb-4 mb-md-5">
                            <div class="row g-3 align-items-end">
                                <div class="col-lg-3 col-md-6">
                                    <label class="form-label">HSN/SAC Code</label>
                                    <input id="HSNCode" class="form-control bg-white" placeholder="Code">
                                </div>
                                <div class="col-lg-3 col-md-6">
                                    <label class="form-label">Base Price</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-white">₹</span>
                                        <input id="BillPrice" type="number" class="form-control bg-white pricing-calc" step="0.01" value="0.00">
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-6">
                                    <label class="form-label">Tax (%)</label>
                                    <select id="TaxRate" class="form-select bg-white pricing-calc">
                                        <option value="0">0%</option>
                                        <option value="5" selected>5%</option>
                                        <option value="12">12%</option>
                                        <option value="18" >18%</option>
                                        <option value="28">28%</option>
                                    </select>
                                </div>
                               <!--  <div class="col-lg-4 col-md-6">
                                    <div class="p-3 bg-white rounded-3 border">
                                        <small class="text-muted d-block text-uppercase small">Inclusive Total</small>
                                        <span class="h4 mb-0 fw-bold text-primary">₹ <span id="displayTotal">0.00</span></span>
                                    </div>
                                </div> -->
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">Description</label>
                            <textarea id="Description" class="form-control" rows="3" placeholder="Additional specifications..."></textarea>
                        </div>

                        <div class="d-flex justify-content-between align-items-center flex-column flex-md-row gap-3">
                            <!-- <button type="button" class="btn btn-link text-danger text-decoration-none fw-bold" onclick="resetForm()">
                                <i class="bi bi-trash3 me-2"></i>Clear Draft
                            </button> -->
                            <button type="submit" id="saveBtn" class="btn btn-erp-primary">
                                <span id="btnText"><i class="bi bi-shield-check me-2"></i>Finalize & Save</span>
                                <span id="btnSpinner" class="spinner-border spinner-border-sm d-none"></span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0/dist/js/select2.min.js"></script>

<script>
    const cats = JSON.parse(<%= org.json.JSONObject.quote(request.getAttribute("productList") != null ? request.getAttribute("productList").toString() : "[]") %>);
    const uoms = JSON.parse(<%= org.json.JSONObject.quote(request.getAttribute("uom") != null ? request.getAttribute("uom").toString() : "[]") %>);

    function initDropdowns() {
        const catSel = $('#M_Product_Category_ID');
        const uomSel = $('#C_UOM_ID');
        
        catSel.append(new Option("Select Category", ""));
        cats.forEach(c => catSel.append(new Option(c.Name, c.M_Product_Category_ID)));

        uomSel.append(new Option("Select UOM", ""));
        uoms.forEach(u => uomSel.append(new Option(u.Name, u.C_UOM_ID)));

        $('.select2-init').select2({ width: '100%' });
    }

    $(document).ready(function() {
        initDropdowns();

        // 1. Pricing Engine
        $('.pricing-calc').on('input change', function() {
            const base = parseFloat($('#BillPrice').val()) || 0;
            const tax = parseFloat($('#TaxRate').val()) || 0;
            const total = base + (base * (tax/100));
            $('#displayTotal').text(total.toLocaleString('en-IN', {minimumFractionDigits: 2}));
        });

        // 2. Progress Tracker
        $('input, select, textarea').on('input change', function() {
            const totalFields = 5; 
            let filled = 0;
            if($('#Value').val()) filled++;
            if($('#Name').val()) filled++;
            if($('#M_Product_Category_ID').val()) filled++;
            if($('#C_UOM_ID').val()) filled++;
            if($('#BillPrice').val() > 0) filled++;
            
            const percentage = (filled / totalFields) * 100;
            $('#progress-inner').css('width', percentage + '%');
        });
        
        
        // 3. Form Submit with View Trigger
     // Form Submission Handler
        document.getElementById('productForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
             alert("working"); // Temporarily commented out, as requested in the initial code

            // Collect data into payload
            let payload = {
                productId: parseInt(document.getElementById('productId').value) || 0,
                Value: document.getElementById('Value').value,
                Name: document.getElementById('Name').value,
                M_Product_Category_ID: parseInt(document.getElementById('M_Product_Category_ID').value) || 0,
                C_UOM_ID: parseInt(document.getElementById('C_UOM_ID').value) || 0,
                Description: document.getElementById('Description').value,
                HSNCode: document.getElementById('HSNCode').value,
                Barcode: document.getElementById('Barcode').value,
                // Ensure BillPrice is parsed correctly, defaulting to 0 if empty
                BillPrice: parseFloat(document.getElementById('BillPrice').value || 0),
                EntryType: document.getElementById('EntryType').value
            };
            
            console.log("Submitting Payload:", payload);

            $.ajax({
                url: "<%= request.getContextPath() %>/Product",
                type: "POST",
                data: JSON.stringify(payload),
                contentType: "application/json; charset=utf-8",
                success: function(res) {
                  showAlert("Product saved successfully!", "success");
                  // Assuming the save is successful, reset the form for next entry
                  resetForm();
                  // NOTE: You might need to add logic here to refresh the product listing table
                },
                error: function(xhr) {
                  showAlert("Error saving product: " + xhr.responseText, "danger");
                  console.error("AJAX Error:", xhr);
                }
              });
        });

    });

    function showResponseInUserView(data) {
        $('#view-sku').text(data.Value);
        $('#view-name').text(data.Name);
        $('#view-cat').text(data.catName);
        $('#view-uom').text(data.uomName);
        $('#view-hsn').text(data.HSNCode);
        $('#view-tax').text(data.TaxRate);
        $('#view-desc').text(data.Description || "No description provided.");
        
        const base = parseFloat(data.BillPrice) || 0;
        const tax = parseFloat(data.TaxRate) || 0;
        const total = base + (base * (tax/100));
        $('#view-total').text(total.toLocaleString('en-IN', {minimumFractionDigits: 2}));

        const myModal = new bootstrap.Modal(document.getElementById('responseModal'));
        myModal.show();
    }

    function showERPToast(msg, type) {
        const toast = $('#erp-toast');
        toast.removeClass('bg-success bg-danger').addClass(type === 'success' ? 'bg-success' : 'bg-danger');
        $('#toast-icon').html(type === 'success' ? '<i class="bi bi-check-circle-fill"></i>' : '<i class="bi bi-exclamation-octagon-fill"></i>');
        $('#toast-msg').text(msg);
        toast.fadeIn().delay(3000).fadeOut();
    }

    function resetForm() {
        $('#productForm')[0].reset();
        $('.select2-init').val('').trigger('change');
        $('#progress-inner').css('width', '0%');
        $('#displayTotal').text('0.00');
    }
</script>

</body>
</html>