<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Purchase / Sales HTML Report</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
  <div class="row justify-content-center">
    <div class="col-lg-9">
      <div class="card shadow-sm">
        <div class="card-body">
          <h5 class="card-title">Purchase & Sales Report (Direct SQL → HTML)</h5>
          <form class="row g-3" action="<%=request.getContextPath()%>/ps-report" method="get">
            <div class="col-md-3">
              <label class="form-label">From Date</label>
              <input type="date" class="form-control" name="from" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">To Date</label>
              <input type="date" class="form-control" name="to" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">Type</label>
              <select class="form-select" name="type" required>
                <option value="sales">Sales</option>
                <option value="purchase">Purchase</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">AD_Org_ID (optional)</label>
              <input type="number" class="form-control" name="org">
            </div>

            <div class="col-md-3">
              <label class="form-label">Summary</label>
              <select class="form-select" name="summary">
                <option value="N">Detail</option>
                <option value="Y">Summary</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">BPartner (optional, ID)</label>
              <input type="number" class="form-control" name="bp">
            </div>
            <div class="col-md-3">
              <label class="form-label">Page (optional)</label>
              <input type="number" class="form-control" name="page" min="1" placeholder="1">
            </div>
            <div class="col-md-3 d-flex align-items-end">
              <button type="submit" class="btn btn-primary w-100">Show Report</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>