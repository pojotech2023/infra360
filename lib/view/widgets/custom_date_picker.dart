import 'package:flutter/material.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';

Future<String?> showCustomMonthPicker(BuildContext context, int selectedYear,
{ int? initialMonth,}) async {
  int selectedMonth = initialMonth ?? DateTime.now().month;
  int currentYear = selectedYear;

  return  await showDialog(
    context: context,
    builder: (context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text("Select Month"),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DropdownButton<int>(
              //   value: currentYear,
              //   onChanged: (value) {
              //     if (value != null) {
              //       setState(() => currentYear = value);
              //     }
              //   },
              //   items: List.generate(10, (index) {
              //     int year = DateTime.now().year - 5 + index;
              //     return DropdownMenuItem(
              //       value: year,
              //       child: Text('$year'),
              //     );
              //   }),
              // ),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                primary: false,
                children: List.generate(12, (index) {
                  int month = index + 1;
                  bool isSelected = selectedMonth == month;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                      // Navigator.of(context).pop();
                      // onMonthSelected(index + 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blueAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          monthNames[index],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              VerticalSpacing.d20px(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text("Cancel",
                        style: AppTextStyle.textMedium.
                        copyWith(color: Colors.redAccent),),
                    ),
                  ),
                  HorizontalSpacing.d20px(),
                  InkWell(
                    onTap: (){
                      final formatted = "${selectedYear.toString()}-${selectedMonth.toString().padLeft(2, '0')}";
                      Navigator.of(context).pop(formatted);

                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text("OK",
                      style: AppTextStyle.textMedium
                        .copyWith(color: AppColor.buttonBlue),),
                    ),
                  )


                ],
              ),
            ],
          ),
        )
      );});
    },
  );
  return null;
}

const List<String> monthNames = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
];