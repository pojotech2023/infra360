import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/attendance_list_model.dart';
import '../../utils/app_text_style.dart';
import 'attendance_controller.dart';
import '../../utils/res/spacing.dart';
import '../widgets/common_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a row in the Add Wages table
// ─────────────────────────────────────────────────────────────────────────────
class _WageRow {
  final String? fixedCategory; // null for dynamic rows
  final TextEditingController categoryController;
  final TextEditingController amountController;
  final TextEditingController countController;
  final FocusNode amountFocus;
  final bool isFixed;

  _WageRow({
    this.fixedCategory,
    required this.categoryController,
    required this.amountController,
    required this.countController,
    required this.amountFocus,
    this.isFixed = true,
  });

  void clear() {
    amountController.clear();
    countController.clear();
  }

  void dispose() {
    categoryController.dispose();
    amountController.dispose();
    countController.dispose();
    amountFocus.dispose();
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
  });

  final ScrollController? scrollController;

  /// type = "1" → Add Wages only
  /// type = "2" → Add Attendance only
  /// type = "3" → Edit existing (Wages + Attendance) for a given date
  final String types;
  final List<Attendances>? attendanceDatas;

  @override
  State<AddWages> createState() => _AddWagesState();
}

class _AddWagesState extends State<AddWages> {
  final AttendanceController controller = Get.find<AttendanceController>();
  final TextEditingController dateRanger = TextEditingController();

  late final String type;
  late final List<Attendances> attendanceData;

  // Fixed rows always correspond to the 4 known categories linked to the controller
  late final _WageRow _masonRow;
  late final _WageRow _helperRow;
  late final _WageRow _fitterRow;
  late final _WageRow _centringHelperRow;

  // Dynamic rows (custom, not saved to backend separately)
  final List<_WageRow> _dynamicRows = [];

  List<_WageRow> get _allRows => [_masonRow, _helperRow, _fitterRow, _centringHelperRow, ..._dynamicRows];

  @override
  void initState() {
    super.initState();

    dateRanger.text = DateFormat("dd-MM-yyyy").format(DateTime.now());
    type = widget.types;
    attendanceData = widget.attendanceDatas ?? [];

    // Pre-fill date from attendance data if available
    if (attendanceData.isNotEmpty && attendanceData[0].date != null) {
      try {
        dateRanger.text = DateFormat("dd-MM-yyyy").format(DateTime.parse(attendanceData[0].date!));
      } catch (_) {}
    }

    // Build the fixed rows linked to the controller
    _masonRow = _WageRow(
      fixedCategory: "Mason",
      categoryController: TextEditingController(text: "Mason"),
      amountController: controller.masonAmountController,
      countController: controller.masonCountController,
      amountFocus: FocusNode(),
    );
    _helperRow = _WageRow(
      fixedCategory: "Helper",
      categoryController: TextEditingController(text: "Helper"),
      amountController: controller.helperAmountController,
      countController: controller.helperCountController,
      amountFocus: FocusNode(),
    );
    _fitterRow = _WageRow(
      fixedCategory: "Fitter",
      categoryController: TextEditingController(text: "Fitter"),
      amountController: controller.fitterAmountController,
      countController: controller.fitterCountController,
      amountFocus: FocusNode(),
    );
    _centringHelperRow = _WageRow(
      fixedCategory: "Centring Helper",
      categoryController: TextEditingController(text: "Centring Helper"),
      amountController: controller.centringHelperAmountController,
      countController: controller.centringHelperCountController,
      amountFocus: FocusNode(),
    );

    // Pre-fill values from existing attendance data (for Edit mode)
    if (attendanceData.isNotEmpty) {
      _prefillCounts();
      _prefillAmounts();
    }
  }

  @override
  void dispose() {
    // Only dispose focus nodes — controllers for fixed rows belong to the controller
    _masonRow.amountFocus.dispose();
    _helperRow.amountFocus.dispose();
    _fitterRow.amountFocus.dispose();
    _centringHelperRow.amountFocus.dispose();
    for (final row in _dynamicRows) {
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

  // ── Add Row: adds a new editable row with empty Category ──────────────────
  void _addRow() {
    setState(() {
      _dynamicRows.add(_WageRow(
        fixedCategory: null,
        categoryController: TextEditingController(), // empty by default
        amountController: TextEditingController(),
        countController: TextEditingController(),
        amountFocus: FocusNode(),
        isFixed: false,
      ));
    });
  }

  // ── Clear / remove a row ───────────────────────────────────────────────────
  void _deleteRow(_WageRow row) {
    if (row.isFixed) {
      setState(() => row.clear());
    } else {
      setState(() {
        _dynamicRows.remove(row);
        row.dispose();
      });
    }
  }

  // ── Focus the amount field for editing ────────────────────────────────────
  void _focusEdit(_WageRow row) {
    Future.microtask(() => FocusScope.of(context).requestFocus(row.amountFocus));
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
              Text("Add Wages", style: AppTextStyle.textBold.copyWith(fontSize: 20, color: const Color(0xFF1E293B))),
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
                        onPressed: () => controller.attendanceAddWages(dateRanger.text, "3"),
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
          // Category (read-only for fixed, editable for dynamic)
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 36,
              child: row.isFixed
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(row.fixedCategory!, style: TextStyle(fontSize: 13, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis),
                    )
                  : TextFormField(
                      controller: row.categoryController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Category",
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.blue.shade400)),
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
          _editRow("Mason", controller.masonCountController),
          _editRow("Helper", controller.helperCountController),
          _editRow("Fitter", controller.fitterCountController),
          _editRow("Centring Helper", controller.centringHelperCountController),
          const SizedBox(height: 12),
          if (_dynamicRows.isNotEmpty) ...[
            const Text("Additional Custom Rows", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  _buildTableHeader(),
                  ..._dynamicRows.asMap().entries.map((e) => _buildTableRow(e.value, isLast: e.key == _dynamicRows.length - 1)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 2),
          const Divider(height: 32),

          // ── Update Wages section ───────────────────────────────
          Text("Update Wages", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _editRow("Mason", controller.masonAmountController),
          _editRow("Helper", controller.helperAmountController),
          _editRow("Fitter", controller.fitterAmountController),
          _editRow("Centring Helper", controller.centringHelperAmountController),
          const SizedBox(height: 20),

          // ── Single Update Button ───────────────────────────────
          Obx(
            () => controller.attendanceSave.value
                ? const Center(child: CommonLoader())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.attendanceAddWages(dateRanger.text, "3"),
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
  Widget _editRow(String label, TextEditingController textController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          Expanded(
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
}
