/// Top-level response model
class SupervisorPermissionsModel {
  int? responseCode;
  bool? status;
  String? message;
  int? supervisorId;
  String? supervisor;
  PermissionsData? permissions;

  SupervisorPermissionsModel({
    this.responseCode,
    this.status,
    this.message,
    this.supervisorId,
    this.supervisor,
    this.permissions,
  });

  SupervisorPermissionsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    status       = json['status'];
    message      = json['message'];
    supervisorId = json['supervisor_id'];
    supervisor   = json['supervisor'];
    permissions  = json['permissions'] != null
        ? PermissionsData.fromJson(json['permissions'])
        : null;
  }

  Map<String, dynamic> toJson() => {
        'response_code':  responseCode,
        'status':         status,
        'message':        message,
        'supervisor_id':  supervisorId,
        'supervisor':     supervisor,
        'permissions':    permissions?.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
/// Container for all permission groups
class PermissionsData {
  SiteManagementPerms? siteManagement;
  QuotationPerms?      quotation;
  CustomerPerms?       customerManagement;
  VendorPerms?         vendorManagement;
  SubcontractorPerms?  subcontractorManagement;

  PermissionsData({
    this.siteManagement,
    this.quotation,
    this.customerManagement,
    this.vendorManagement,
    this.subcontractorManagement,
  });

  PermissionsData.fromJson(Map<String, dynamic> json) {
    siteManagement = json['site_management'] != null
        ? SiteManagementPerms.fromJson(json['site_management'])
        : null;
    quotation = json['quotation'] != null
        ? QuotationPerms.fromJson(json['quotation'])
        : null;
    customerManagement = json['customer_management'] != null
        ? CustomerPerms.fromJson(json['customer_management'])
        : null;
    vendorManagement = json['vendor_management'] != null
        ? VendorPerms.fromJson(json['vendor_management'])
        : null;
    subcontractorManagement = json['subcontractor_management'] != null
        ? SubcontractorPerms.fromJson(json['subcontractor_management'])
        : null;
  }

  Map<String, dynamic> toJson() => {
        'site_management':          siteManagement?.toJson(),
        'quotation':                quotation?.toJson(),
        'customer_management':      customerManagement?.toJson(),
        'vendor_management':        vendorManagement?.toJson(),
        'subcontractor_management': subcontractorManagement?.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
/// site_management permissions
class SiteManagementPerms {
  int? addSite;
  int? viewSite;
  int? viewTodayAttendance;
  int? viewMaterials;
  int? viewSubcontractor;
  int? viewPaymentStatus;
  int? viewChecklist;
  int? viewTickets;
  int? viewDrawing;
  int? editSite;
  int? deleteSite;

  SiteManagementPerms({
    this.addSite,
    this.viewSite,
    this.viewTodayAttendance,
    this.viewMaterials,
    this.viewSubcontractor,
    this.viewPaymentStatus,
    this.viewChecklist,
    this.viewTickets,
    this.viewDrawing,
    this.editSite,
    this.deleteSite,
  });

  SiteManagementPerms.fromJson(Map<String, dynamic> json) {
    addSite              = json['add_site'];
    viewSite             = json['view_site'];
    viewTodayAttendance  = json['view_today_attendance'];
    viewMaterials        = json['view_materials'];
    viewSubcontractor    = json['view_subcontractor'];
    viewPaymentStatus    = json['view_payment_status'];
    viewChecklist        = json['view_checklist'];
    viewTickets          = json['view_tickets'];
    viewDrawing          = json['view_drawing'];
    editSite             = json['edit_site'];
    deleteSite           = json['delete_site'];
  }

  // ── Convenience bool getters (1 = visible, 0 = hidden) ───────────────────
  bool get canViewAttendance    => viewTodayAttendance == 1;
  bool get canViewMaterials     => viewMaterials       == 1;
  bool get canViewSubcontractor => viewSubcontractor   == 1;
  bool get canViewPaymentStatus => viewPaymentStatus   == 1;
  bool get canViewChecklist     => viewChecklist       == 1;
  bool get canViewTickets       => viewTickets         == 1;
  bool get canViewDrawing       => viewDrawing         == 1;

  Map<String, dynamic> toJson() => {
        'add_site':               addSite,
        'view_site':              viewSite,
        'view_today_attendance':  viewTodayAttendance,
        'view_materials':         viewMaterials,
        'view_subcontractor':     viewSubcontractor,
        'view_payment_status':    viewPaymentStatus,
        'view_checklist':         viewChecklist,
        'view_tickets':           viewTickets,
        'view_drawing':           viewDrawing,
        'edit_site':              editSite,
        'delete_site':            deleteSite,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
/// quotation permissions
class QuotationPerms {
  int? addQuotation;
  int? editQuotation;
  int? deleteQuotation;

  QuotationPerms({this.addQuotation, this.editQuotation, this.deleteQuotation});

  QuotationPerms.fromJson(Map<String, dynamic> json) {
    addQuotation    = json['add_quotation'];
    editQuotation   = json['edit_quotation'];
    deleteQuotation = json['delete_quotation'];
  }

  /// Show Quotation menu if at least one permission is granted
  bool get canAccessQuotation =>
      addQuotation == 1 || editQuotation == 1 || deleteQuotation == 1;

  Map<String, dynamic> toJson() => {
        'add_quotation':    addQuotation,
        'edit_quotation':   editQuotation,
        'delete_quotation': deleteQuotation,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
/// customer_management permissions
class CustomerPerms {
  int? addCustomer;
  int? editCustomer;
  int? deleteCustomer;

  CustomerPerms({this.addCustomer, this.editCustomer, this.deleteCustomer});

  CustomerPerms.fromJson(Map<String, dynamic> json) {
    addCustomer    = json['add_customer'];
    editCustomer   = json['edit_customer'];
    deleteCustomer = json['delete_customer'];
  }

  /// Show Customer menu if at least one permission is granted
  bool get canAccessCustomer =>
      addCustomer == 1 || editCustomer == 1 || deleteCustomer == 1;

  Map<String, dynamic> toJson() => {
        'add_customer':    addCustomer,
        'edit_customer':   editCustomer,
        'delete_customer': deleteCustomer,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
/// vendor_management permissions
class VendorPerms {
  int? addVendor;
  int? editVendor;
  int? deleteVendor;
  int? viewAmount;
  int? addPayment;
  int? paymentHistory;

  VendorPerms({
    this.addVendor,
    this.editVendor,
    this.deleteVendor,
    this.viewAmount,
    this.addPayment,
    this.paymentHistory,
  });

  VendorPerms.fromJson(Map<String, dynamic> json) {
    addVendor      = json['add_vendor'];
    editVendor     = json['edit_vendor'];
    deleteVendor   = json['delete_vendor'];
    viewAmount     = json['view_amount'];
    addPayment     = json['add_payment'];
    paymentHistory = json['payment_history'];
  }

  /// Show Vendor menu if at least one permission is granted
  bool get canAccessVendor =>
      addVendor == 1 ||
      editVendor == 1 ||
      deleteVendor == 1 ||
      viewAmount == 1 ||
      addPayment == 1 ||
      paymentHistory == 1;

  Map<String, dynamic> toJson() => {
        'add_vendor':       addVendor,
        'edit_vendor':      editVendor,
        'delete_vendor':    deleteVendor,
        'view_amount':      viewAmount,
        'add_payment':      addPayment,
        'payment_history':  paymentHistory,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
/// subcontractor_management permissions
class SubcontractorPerms {
  int? addSubcontractor;
  int? editSubcontractor;
  int? deleteSubcontractor;
  int? viewAmount;
  int? addPayment;
  int? paymentHistory;

  SubcontractorPerms({
    this.addSubcontractor,
    this.editSubcontractor,
    this.deleteSubcontractor,
    this.viewAmount,
    this.addPayment,
    this.paymentHistory,
  });

  SubcontractorPerms.fromJson(Map<String, dynamic> json) {
    addSubcontractor    = json['add_subcontractor'];
    editSubcontractor   = json['edit_subcontractor'];
    deleteSubcontractor = json['delete_subcontractor'];
    viewAmount          = json['view_amount'];
    addPayment          = json['add_payment'];
    paymentHistory      = json['payment_history'];
  }

  /// Show SubContractor menu if at least one permission is granted
  bool get canAccessSubcontractor =>
      addSubcontractor == 1 ||
      editSubcontractor == 1 ||
      deleteSubcontractor == 1 ||
      viewAmount == 1 ||
      addPayment == 1 ||
      paymentHistory == 1;

  Map<String, dynamic> toJson() => {
        'add_subcontractor':    addSubcontractor,
        'edit_subcontractor':   editSubcontractor,
        'delete_subcontractor': deleteSubcontractor,
        'view_amount':          viewAmount,
        'add_payment':          addPayment,
        'payment_history':      paymentHistory,
      };
}
