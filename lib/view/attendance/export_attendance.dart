import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/attendance/attendance_controller.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';

class ExportAttendance extends StatefulWidget {
  @override
  State<ExportAttendance> createState() => _ExportAttendanceState();
}

class _ExportAttendanceState extends State<ExportAttendance> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Export Attendance",
              style: AppTextStyle.textBold.copyWith(fontSize: 18),
            ),
            VerticalSpacing.d20px(),
            Text("From Date", style: AppTextStyle.textMedium),
            SizedBox(height: 8),
            TextFormField(
              controller: fromDateController,
              readOnly: true,
              decoration: textBoxDecoration(
                hint: "Select From Date",
                suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
              ),
              onTap: () => _selectDate(context, fromDateController),
            ),
            VerticalSpacing.d20px(),
            Text("To Date", style: AppTextStyle.textMedium),
            SizedBox(height: 8),
            TextFormField(
              controller: toDateController,
              readOnly: true,
              decoration: textBoxDecoration(
                hint: "Select To Date",
                suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
              ),
              onTap: () => _selectDate(context, toDateController),
            ),
            VerticalSpacing.d30px(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: AppColor.buttonBlue),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColor.buttonBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                HorizontalSpacing.d10px(),
                Expanded(
                  child: CommonButton(
                    onTap: () {
                      if (fromDateController.text.isNotEmpty && toDateController.text.isNotEmpty) {
                        Get.back();
                        controller.attendanceExcelDownload(context, fromDate: fromDateController.text, toDate: toDateController.text);
                      } else {
                        Get.snackbar("Error", "Please select dates");
                      }
                    },
                    text: "Download",
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController textController) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      textController.text = DateFormat("dd-MM-yyyy").format(picked);
    }
  }
}
