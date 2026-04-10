import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/attendance_list_model.dart';
import '../../utils/app_text_style.dart';
import '../../utils/text_form_style.dart';
import 'attendance_controller.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../widgets/common_button.dart';
import '../widgets/common_loader.dart';

class AddWages extends StatefulWidget {
  AddWages({super.key, required this.types, this.attendanceDatas, this.scrollController});

  final ScrollController? scrollController;

  /// type = "1" → Add Wages
  /// type = "2" → Add Attendance
  /// type = "3" → Prefilled Both
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

  @override
  void initState() {


    dateRanger.text = DateFormat("dd-MM-yyyy").format(DateTime.now());


    type = widget.types;
    attendanceData = widget.attendanceDatas ??[];
    if (type == "3") {
      if (attendanceData.isNotEmpty && attendanceData[0].date != null) {
        dateRanger.text = DateFormat("dd-MM-yyyy")
            .format(DateTime.parse(attendanceData[0].date!));
      }

      _prefillCounts();
      _prefillAmount();
    }

    super.initState();
  }

  void _prefillCounts() {
    String getCount(String cat) {
      final item = attendanceData.firstWhere(
            (e) => e.category?.toLowerCase() == cat.toLowerCase(),
        orElse: () => Attendances(),
      );

      return item.count?.toString() ?? "0";
    }

    controller.masonCountController.text = getCount("Mason");
    controller.helperCountController.text = getCount("Helper");
    controller.fitterCountController.text = getCount("Fitter");
    controller.centringHelperCountController.text = getCount("Centring Helper");
  }


  void _prefillAmount() {
    String getCount(String cat) {
      final item = attendanceData.firstWhere(
            (e) => e.category?.toLowerCase() == cat.toLowerCase(),
        orElse: () => Attendances(),
      );

      return item.amount?.toString() ?? "0";
    }

    controller.masonAmountController.text = getCount("Mason");
    controller.helperAmountController.text = getCount("Helper");
    controller.fitterAmountController.text = getCount("Fitter");
    controller.centringHelperAmountController.text = getCount("Centring Helper");
  }




  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              padding: EdgeInsets.all(10),
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
            ),
          ),

          VerticalSpacing.d15px(),

          Text(
            _getTitle(),
            style:
            AppTextStyle.textBold.copyWith(color: AppColor.textGreen),
          ),

          Center(
            child: Container(
              width: 83,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.textGreen,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          VerticalSpacing.d20px(),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: TextFormField(
                  controller: dateRanger,
                  readOnly: true,
                  decoration: textBoxDecoration(
                    hint: "dd-MM-yyyy",
                    suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
                  ),
                  validator: (text) =>
                  (text == null || text.isEmpty) ? "Required" : null,
                  onTap: () => selectDate(context),
                ),
              ),
            ],
          ),

          VerticalSpacing.d20px(),

          _buildTable(),

          VerticalSpacing.d20px(),

          Obx(
                () => controller.attendanceSave.value
                ? Center(child: CommonLoader())
                : SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: CommonButton(
                onTap: () {
                  controller.attendanceAddWages(dateRanger.text, type);
                },
                text: "Save",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  String _getTitle() {
    if (type == "1") return "Add Wages";
    if (type == "2") return "Add Attendance";
    return "Edit Wages & Attendance";
  }

  // ------------------------------------------------------------
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffF8F9FE),
        border: Border.all(color: Color(0xffEDEEF1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildHeader(),

          _row("Mason", controller.masonCountController,
              controller.masonAmountController),

          _row("Helper", controller.helperCountController,
              controller.helperAmountController),

          _row("Fitter", controller.fitterCountController,
              controller.fitterAmountController),

          _row("Centring Helper", controller.centringHelperCountController,
              controller.centringHelperAmountController),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xffC8D6FF),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          _headerItem("Category"),
          if (type== "2" || type == "3") _headerItem("Count"),
          if (type == "1" ||type == "3") _headerItem("Amount"),
        ],
      ),
    );
  }

  Widget _headerItem(String title) {
    return Expanded(
      child: Center(
        child: Text(title, style: AppTextStyle.textMedium),
      ),
    );
  }

  // ------------------------------------------------------------
  Widget _row(
      String title,
      TextEditingController countController,
      TextEditingController amountController) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // CATEGORY NAME
          Expanded(
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColor.wagesBoxBorder),
              ),
              child: Text(title, style: AppTextStyle.textMedium),
            ),
          ),

          HorizontalSpacing.d10px(),

          // COUNT FIELD (if allowed)
          if (type == "2" || type == "3") _boxField(countController),

          if (type == "3") HorizontalSpacing.d10px(),

          // AMOUNT FIELD (if allowed)
          if (type == "1" || type == "3") _boxField(amountController),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  Widget _boxField(TextEditingController controllerX) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: TextFormField(
          controller: controllerX,
          keyboardType: TextInputType.number,
          decoration: textBoxDecoration(
            hint: "",
            myColor: AppColor.wagesBoxBorder,
          ),
          validator: (text) =>
          (text == null || text.isEmpty) ? "Required" : null,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  Future<void> selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateRanger.text = DateFormat("dd-MM-yyyy").format(picked);
    }
  }
}



/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/app_text_style.dart';
import '../../utils/text_form_style.dart';
import 'attendance_controller.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../widgets/common_button.dart';




import '../widgets/common_loader.dart';

class AddWages extends StatelessWidget {
   AddWages({super.key,required this.type});

   String type;

  AttendanceController controller = Get.find<AttendanceController>();
  TextEditingController dateRanger= TextEditingController();





  @override
  Widget build(BuildContext context) {
    // ✅ Return a widget (for example, a button to open the sheet)

    dateRanger.text=DateFormat("dd-MM-yyyy").format(DateTime.now());
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  visualDensity: VisualDensity.comfortable,
                  padding: EdgeInsets.all(10),
                  onPressed: (){
                    Navigator.pop(context);

                  }, icon: Icon(Icons.close)),
            ),

            VerticalSpacing.d15px(),
            Text(
              type !="1" ?  "Add Attendance":"Add Wages",
                style: AppTextStyle.textBold.
                copyWith(color: AppColor.textGreen)
            ),
            Center(
              child: Container(
                width: 83,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColor.textGreen

                ),
              ),
            ),
            VerticalSpacing.d15px(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 160,
                  child: TextFormField(
                    controller: dateRanger,
                    decoration:textBoxDecoration(hint:"dd-MM-yyyy",
                        suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
                    readOnly: true,

                    onTap:()=> selectDate(context),
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },



                  ),
                ),
              ],
            ),

            VerticalSpacing.d15px(),

            Container(
              decoration: BoxDecoration(
                  color: Color(0xffF8F9FE),
                  border: Border.all(color: Color(0xffEDEEF1)),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Container(

                    decoration: BoxDecoration(
                        color: Color(0xffC8D6FF),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)
                        )
                    ),
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Text("Category",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.textMedium,),
                        ),
                        HorizontalSpacing.d10px(),
                      type !="1"?  Expanded(
                          child: Text("Count",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.textMedium,),
                        ) :
                         Expanded(
                          child: Text("Amount",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.textMedium,),
                        )
                      ],
                    ),
                  ),
                  VerticalSpacing.d10px(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        containerWidget("Mason"),
                        HorizontalSpacing.d10px(),


                        type !="1"?    Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.masonCountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ):
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.masonAmountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        containerWidget("Helper"),
                        HorizontalSpacing.d10px(),
                        type !="1"?   Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.helperCountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ) :Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.helperAmountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        containerWidget("Fitter"),
                        HorizontalSpacing.d10px(),
                        type !="1"?    Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.fitterCountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ):
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.fitterAmountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        containerWidget("Centring Helper"),
                        HorizontalSpacing.d10px(),
                        type !="1"?   Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.centringHelperCountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ):
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: controller.centringHelperAmountController,
                              keyboardType: TextInputType.number,
                              decoration:textBoxDecoration(hint:"",myColor: AppColor.wagesBoxBorder),
                              validator: (text){
                                if (text == null || text.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },



                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  VerticalSpacing.d20px(),

                  Obx(() =>
                  controller.attendanceSave.value?Center(child: CommonLoader(),):
                  SizedBox(
                      width:  MediaQuery.of(context).size.width /1.5,
                      child: CommonButton(onTap: (){
                        controller.attendanceAddWages(dateRanger.text,type);
                      }, text: "Save"))),


                ],
              ),
            ),
            VerticalSpacing.d15px(),
          ],
        )
    );
  }

  containerWidget(String title){
    return Expanded(

      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColor.wagesBoxBorder)
        ),
        child: Text(title,style: AppTextStyle.textMedium,),
      ),
    );
  }

   Future<void> selectDate(BuildContext context) async {
     DateTime now = DateTime.now();
     DateTime? picked = await showDatePicker(
       context: context,
       initialDate:DateTime.now(),
       firstDate: now.subtract(Duration(days: 365)),
       lastDate: DateTime(2100),
     );

     if (picked != null) {
       String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
       dateRanger.text = formattedDate;
     }
   }
}
*/
