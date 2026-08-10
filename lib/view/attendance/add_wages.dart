import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import '../../model/attendance_list_model.dart';
import '../../utils/app_text_style.dart';
import 'attendance_controller.dart';
import '../../utils/res/spacing.dart';
import '../widgets/common_loader.dart';
import '../../api/api_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a row in the Add Wages table
// ─────────────────────────────────────────────────────────────────────────────
class _WageRow {
  int? id;
  final TextEditingController categoryController;
  final TextEditingController amountController;
  final TextEditingController countController;
  final FocusNode amountFocus;
  final FocusNode categoryFocus;
  bool isCategoryEditable;
  final bool isFixed;
  /// The category name as originally loaded from the server (for fixed rows).
  /// Used to detect renames so the old record can be removed on submit.
  final String? originalCategory;

  _WageRow({
    this.id,
    required this.categoryController,
    required this.amountController,
    required this.countController,
    required this.amountFocus,
    required this.categoryFocus,
    this.isCategoryEditable = false,
    this.isFixed = false,
    this.originalCategory,
  });

  /// Returns true when the user has changed this fixed row's category label.
  bool get wasRenamed =>
      isFixed &&
      originalCategory != null &&
      categoryController.text.trim().toLowerCase() !=
          originalCategory!.toLowerCase();

  void clear() {
    amountController.clear();
    countController.clear();
  }

  void dispose() {
    categoryController.dispose();
    if (!isFixed) {
      amountController.dispose();
      countController.dispose();
    }
    amountFocus.dispose();
    categoryFocus.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main AddWages widget — used for both Add (type 1) and Edit (type 3)
// ─────────────────────────────────────────────────────────────────────────────
class AddWages extends StatefulWidget {
  const AddWages({
    super.key,
    required this.types,
    this.attendanceDatas,
    this.scrollController,
    this.initialDate,
  });

  final ScrollController? scrollController;

  /// type = "1" → Add Wages only
  /// type = "2" → Add Attendance only
  /// type = "3" → Edit existing (Wages + Attendance) for a given date
  final String types;
  final List<Attendances>? attendanceDatas;

  /// Optional pre-selected date in YYYY-MM-DD format (e.g. from the calendar).
  /// When provided, the date field is pre-filled with this date instead of today.
  final String? initialDate;

  @override
  State<AddWages> createState() => _AddWagesState();
}

class _AddWagesState extends State<AddWages> {
  final AttendanceController controller = Get.find<AttendanceController>();
  final TextEditingController dateRanger = TextEditingController();

  late final String type;
  late final List<Attendances> attendanceData;

  // Unified list of all rows
  final List<_WageRow> _allRows = [];

  // Getter for dynamic rows (used in Edit Mode to separate custom rows from fixed UI fields)
  List<_WageRow> get _dynamicRows => _allRows.where((row) => 
      row.amountController != controller.masonAmountController &&
      row.amountController != controller.helperAmountController &&
      row.amountController != controller.fitterAmountController &&
      row.amountController != controller.centringHelperAmountController).toList();

  String _getAttendanceRowsJson() {
    List<Map<String, dynamic>> rows = [];
    // Include ALL rows (fixed + dynamic) so that any edited category name is captured.
    // Fixed rows use the shared controller fields but their categoryController holds
    // the (possibly-edited) display name that must be sent to the backend.
    for (var row in _allRows) {
      String cat = row.categoryController.text.trim();
      String count = row.countController.text.trim();
      String amount = row.amountController.text.trim();
      // Only include the row if at least one of count or amount has a value,
      // or if it's a dynamic (custom) row with a category entered.
      if (cat.isNotEmpty && (count.isNotEmpty || amount.isNotEmpty)) {
        rows.add({
          "category": cat,
          "count": count,
          "amount": amount,
        });
      }
    }
    return jsonEncode(rows);
  }

  @override
  void initState() {
    super.initState();

    // Default to today; may be overridden below by initialDate or attendanceData.
    dateRanger.text = DateFormat("dd-MM-yyyy").format(DateTime.now());
    type = widget.types;
    attendanceData = widget.attendanceDatas ?? [];

    // If a specific date was selected in the calendar, use it (for Add mode).
    if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
      try {
        dateRanger.text = DateFormat("dd-MM-yyyy").format(DateTime.parse(widget.initialDate!));
      } catch (_) {}
    }

    // Pre-fill date from attendance data if available (overrides initialDate in Edit mode).
    if (attendanceData.isNotEmpty && attendanceData[0].date != null) {
      try {
        dateRanger.text = DateFormat("dd-MM-yyyy").format(DateTime.parse(attendanceData[0].date!));
      } catch (_) {}
    }

    // Build the initial rows linked to the controller.
    // originalCategory is set so wasRenamed can detect when the user renames a fixed row.
    _allRows.add(_WageRow(
      categoryController: TextEditingController(text: "Mason"),
      amountController: controller.masonAmountController,
      countController: controller.masonCountController,
      amountFocus: FocusNode(),
      categoryFocus: FocusNode(),
      isFixed: true,
      originalCategory: "Mason",
    ));
    _allRows.add(_WageRow(
      categoryController: TextEditingController(text: "Helper"),
      amountController: controller.helperAmountController,
      countController: controller.helperCountController,
      amountFocus: FocusNode(),
      categoryFocus: FocusNode(),
      isFixed: true,
      originalCategory: "Helper",
    ));
    _allRows.add(_WageRow(
      categoryController: TextEditingController(text: "Fitter"),
      amountController: controller.fitterAmountController,
      countController: controller.fitterCountController,
      amountFocus: FocusNode(),
      categoryFocus: FocusNode(),
      isFixed: true,
      originalCategory: "Fitter",
    ));
    _allRows.add(_WageRow(
      categoryController: TextEditingController(text: "Centring Helper"),
      amountController: controller.centringHelperAmountController,
      countController: controller.centringHelperCountController,
      amountFocus: FocusNode(),
      categoryFocus: FocusNode(),
      isFixed: true,
      originalCategory: "Centring Helper",
    ));

    // Pre-fill values from existing attendance data (for Edit mode)
    if (attendanceData.isNotEmpty) {
      _prefillCounts();
      _prefillAmounts();

      if (attendanceData[0].time != null) controller.checkInTime.value = attendanceData[0].time;
      if (attendanceData[0].checkOutTime != null) controller.checkOutTime.value = attendanceData[0].checkOutTime;
      if (attendanceData[0].imageUrl != null) controller.checkInImageUrl.value = attendanceData[0].imageUrl;
      if (attendanceData[0].checkOutPhoto != null) controller.checkOutImageUrl.value = attendanceData[0].checkOutPhoto;

      final fixedCategories = ["Mason", "Helper", "Fitter", "Centring Helper"];
      for (final item in attendanceData) {
        if (item.category != null && item.category!.trim().isNotEmpty) {
          bool isFixed = fixedCategories.any((c) => c.toLowerCase() == item.category!.trim().toLowerCase());
          if (!isFixed) {
            _allRows.add(_WageRow(
              id: item.id,
              categoryController: TextEditingController(text: item.category),
              amountController: TextEditingController(text: item.amount?.toString() ?? ""),
              countController: TextEditingController(text: item.count?.toString() ?? ""),
              amountFocus: FocusNode(),
              categoryFocus: FocusNode(),
              isCategoryEditable: true,
            ));
          } else {
             for (var row in _allRows) {
               if (row.isFixed && row.categoryController.text.toLowerCase() == item.category!.trim().toLowerCase()) {
                 row.id = item.id;
                 break;
               }
             }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    for (final row in _allRows) {
      row.dispose();
    }
    dateRanger.dispose();
    super.dispose();
  }

  void _prefillCounts() {
    String getCount(String cat) {
      final item = attendanceData.firstWhere(
        (e) => e.category?.toLowerCase() == cat.toLowerCase(),
        orElse: () => Attendances(),
      );
      return item.count?.toString() ?? "";
    }
    controller.masonCountController.text = getCount("Mason");
    controller.helperCountController.text = getCount("Helper");
    controller.fitterCountController.text = getCount("Fitter");
    controller.centringHelperCountController.text = getCount("Centring Helper");
  }

  void _prefillAmounts() {
    String getAmount(String cat) {
      final item = attendanceData.firstWhere(
        (e) => e.category?.toLowerCase() == cat.toLowerCase(),
        orElse: () => Attendances(),
      );
      return item.amount?.toString() ?? "";
    }
    controller.masonAmountController.text = getAmount("Mason");
    controller.helperAmountController.text = getAmount("Helper");
    controller.fitterAmountController.text = getAmount("Fitter");
    controller.centringHelperAmountController.text = getAmount("Centring Helper");
  }

  void _addRow() {
    setState(() {
      _allRows.add(_WageRow(
        categoryController: TextEditingController(), // empty by default
        amountController: TextEditingController(),
        countController: TextEditingController(),
        amountFocus: FocusNode(),
        categoryFocus: FocusNode(),
        isCategoryEditable: true,
      ));
    });
  }

  // ── Clear / remove a row ───────────────────────────────────────────────────
  void _deleteRow(_WageRow row) async {
    if (row.id != null) {
      await controller.deleteAttendance(row.id!);
      try {
        final rawDate = DateFormat("yyyy-MM-dd").format(DateFormat("dd-MM-yyyy").parse(dateRanger.text));
        await ApiData().deleteWagesRowApi({
          "site_id": controller.siteId.value,
          "date": rawDate,
          "category": row.categoryController.text.trim(),
        });
      } catch (e) {
        print("Error deleting wages: $e");
      }
    }
    setState(() {
      if (row.isFixed) {
        row.clear();
        row.id = null;
      } else {
        _allRows.remove(row);
      }
    });
  }

  // ── Focus the amount field for editing ────────────────────────────────────
  void _focusEdit(_WageRow row) {
    setState(() {
      row.isCategoryEditable = true;
    });
    Future.microtask(() => FocusScope.of(context).requestFocus(row.categoryFocus));
  }

  bool _validateForm() {
    bool hasData = false;
    for (var row in _allRows) {
      if (row.amountController.text.trim().isNotEmpty || row.countController.text.trim().isNotEmpty) {
        hasData = true;
        break;
      }
    }

    if (!hasData) {
      Get.snackbar(
        "Validation Error",
        "Please enter Amount or Count for at least one row.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  /// Handles submit with correct rename semantics:
  ///
  /// When a fixed row (Mason / Helper / Fitter / Centring Helper) is renamed
  /// (e.g. Mason → Fitter) we must:
  ///   1. Build the attendance_rows JSON **before** touching any controller
  ///      (so the new name + existing count/amount are captured correctly).
  ///   2. Delete the old server-side record (by ID) so it doesn't linger.
  ///   3. Zero-out the shared controller for the old fixed category so the
  ///      hardcoded `count_Mason` / `amount_Mason` fields sent by
  ///      `attendanceAddWages()` carry an empty value — the backend then
  ///      treats that as "no Mason entry" and won't recreate it.
  ///   4. Call `attendanceAddWages()` with the already-captured JSON.
  Future<void> _submitWithRenameHandling() async {
    if (!_validateForm()) return;

    // Step 1: capture JSON while all controllers still hold their values.
    final String rowsJson = _getAttendanceRowsJson();

    // Step 2 & 3: for every renamed fixed row, delete the old DB record and
    // zero the shared controller so the old hardcoded field is empty.
    for (final row in _allRows) {
      if (row.wasRenamed) {
        // Delete old DB record so it doesn't persist.
        if (row.id != null) {
          await controller.deleteAttendance(row.id!);
        }
        // Zero the shared controllers — attendanceAddWages() will now send
        // count_<OldCat>="" and amount_<OldCat>="", telling the backend
        // the old category has no workers.
        row.amountController.clear();
        row.countController.clear();
      }
    }

    // Step 4: submit (controllers for renamed rows are now empty).
    controller.attendanceAddWages(dateRanger.text, "3", attendanceRowsJson: rowsJson);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // type == "3" → show the Update page UI (Edit mode)
    if (type == "3") return _buildEditMode(context);

    // type == "1" or "2" → show the Add Wages UI
    return _buildAddMode(context);
  }

  // ── ADD MODE ──────────────────────────────────────────────────────────────
  Widget _buildAddMode(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Add Attendance", style: AppTextStyle.textBold.copyWith(fontSize: 20, color: const Color(0xFF1E293B))),
              Row(
                children: [
                  Text("Date", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 130,
                    height: 38,
                    child: TextFormField(
                      controller: dateRanger,
                      readOnly: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "dd-MM-yyyy",
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.blue.shade400)),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Subtitle + Add Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Enter category, amount and count", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ElevatedButton(
                onPressed: _addRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(80, 34),
                  elevation: 0,
                ),
                child: const Text("Add Row", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Table
          _buildAddTable(),
          const SizedBox(height: 20),

          // Time and Photo
          _buildTimeAndPhotoSection(true),
          const SizedBox(height: 20),

          // Submit button
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => controller.attendanceSave.value
                  ? const CommonLoader()
                  : SizedBox(
                      width: 120,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _submitWithRenameHandling,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ..._allRows.asMap().entries.map((e) => _buildTableRow(e.value, isLast: e.key == _allRows.length - 1)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text("CATEGORY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4))),
          Expanded(flex: 3, child: Text("AMOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4))),
          Expanded(flex: 3, child: Text("COUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4))),
          Expanded(flex: 2, child: Center(child: Text("ACTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4)))),
        ],
      ),
    );
  }

  Widget _buildTableRow(_WageRow row, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category (editable when edit is clicked)
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                controller: row.categoryController,
                focusNode: row.categoryFocus,
                readOnly: !row.isCategoryEditable,
                style: TextStyle(fontSize: 13, color: row.isCategoryEditable ? Colors.black87 : Colors.grey.shade800),
                decoration: InputDecoration(
                  hintText: "Category",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.blue.shade400)),
                  filled: !row.isCategoryEditable,
                  fillColor: !row.isCategoryEditable ? Colors.grey.shade50 : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Amount
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                controller: row.amountController,
                focusNode: row.amountFocus,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.blue.shade400)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Count
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                controller: row.countController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.blue.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.blue.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.blue.shade600)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Action
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _focusEdit(row),
                  child: Icon(Icons.edit_square, color: Colors.blue.shade600, size: 18),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _deleteRow(row),
                  child: Icon(Icons.close, color: Colors.red.shade400, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EDIT MODE (type == "3") ───────────────────────────────────────────────
  Widget _buildEditMode(BuildContext context) {
    final String dateStr = dateRanger.text;
    _WageRow? getFixed(String cat) {
      try { return _allRows.firstWhere((r) => r.isFixed && r.categoryController.text.toLowerCase() == cat.toLowerCase()); } catch (_) { return null; }
    }
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Text(
              "Update Attendance & Wages",
              style: TextStyle(fontSize: 17, color: Colors.indigo.shade900, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),

          // ── Update Attendance section ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Update Attendance", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
              ElevatedButton(
                onPressed: _addRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 0,
                ),
                child: const Text("Add Row", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.masonCountController.text.isNotEmpty) _editRow("Mason", controller.masonCountController, row: getFixed("Mason")),
          if (controller.helperCountController.text.isNotEmpty) _editRow("Helper", controller.helperCountController, row: getFixed("Helper")),
          if (controller.fitterCountController.text.isNotEmpty) _editRow("Fitter", controller.fitterCountController, row: getFixed("Fitter")),
          if (controller.centringHelperCountController.text.isNotEmpty) _editRow("Centring Helper", controller.centringHelperCountController, row: getFixed("Centring Helper")),
          ..._dynamicRows.map((row) => _editRow(row.categoryController.text, row.countController, isCustom: true, row: row)),

          const SizedBox(height: 2),
          const Divider(height: 32),

          // ── Update Wages section ───────────────────────────────
          const Text("Update Wages", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          if (controller.masonAmountController.text.isNotEmpty) _editRow("Mason", controller.masonAmountController, row: getFixed("Mason")),
          if (controller.helperAmountController.text.isNotEmpty) _editRow("Helper", controller.helperAmountController, row: getFixed("Helper")),
          if (controller.fitterAmountController.text.isNotEmpty) _editRow("Fitter", controller.fitterAmountController, row: getFixed("Fitter")),
          if (controller.centringHelperAmountController.text.isNotEmpty) _editRow("Centring Helper", controller.centringHelperAmountController, row: getFixed("Centring Helper")),
          ..._dynamicRows.map((row) => _editRow(row.categoryController.text, row.amountController, isCustom: true, row: row)),
          const SizedBox(height: 20),

          // Time and Photo
          _buildTimeAndPhotoSection(true),
          const SizedBox(height: 12),
          _buildTimeAndPhotoSection(false),
          const SizedBox(height: 20),

          // ── Single Update Button ───────────────────────────────
          Obx(
            () => controller.attendanceSave.value
                ? const Center(child: CommonLoader())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitWithRenameHandling,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text("Update Attendance & Wages", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Single label + text field row used in edit mode
  Widget _editRow(String label, TextEditingController textController, {bool isCustom = false, _WageRow? row}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: isCustom && row != null
                ? SizedBox(
                    height: 42,
                    child: TextFormField(
                      controller: row.categoryController,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.blue.shade400)),
                      ),
                    ),
                  )
                : Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 42,
              child: TextFormField(
                controller: textController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                style: const TextStyle(fontSize: 14, color: Colors.blue),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.blue.shade400)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32, // Fixed width for the action button to maintain alignment
            child: (row != null)
                ? InkWell(
                    onTap: () => _deleteRow(row),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.close, color: Colors.red, size: 16),
                    ),
                  )
                : const SizedBox(), // Empty placeholder so fields don't shift
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => dateRanger.text = DateFormat("dd-MM-yyyy").format(picked));
    }
  }

  Widget _buildTimeAndPhotoSection(bool isCheckIn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Picker
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          children: [
            Text("Time (${isCheckIn ? 'Check-in' : 'Check-out'})", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            InkWell(
              onTap: () => controller.pickTime(context, isCheckIn),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                child: Obx(() => Text(
                      (isCheckIn ? controller.checkInTime.value : controller.checkOutTime.value) ?? "Select Time",
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Photo Picker
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          children: [
            Text("Upload Photo (${isCheckIn ? 'Check-in' : 'Check-out'})", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _showImagePickerBottomsheet(isCheckIn),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade200, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                    child: const Text("Choose File", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final file = isCheckIn ? controller.checkInImage.value : controller.checkOutImage.value;
                  final url = isCheckIn ? controller.checkInImageUrl.value : controller.checkOutImageUrl.value;
                  
                  String displayText = "No file chosen";
                  if (file != null) {
                    displayText = file.path.split('/').last;
                  } else if (url != null && url.isNotEmpty) {
                    displayText = "Saved Photo";
                  }

                  return SizedBox(
                    width: 90,
                    child: Text(
                      displayText,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showImagePickerBottomsheet(bool isCheckIn) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Camera"),
              onTap: () {
                Get.back();
                controller.pickImage(isCheckIn, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                controller.pickImage(isCheckIn, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

