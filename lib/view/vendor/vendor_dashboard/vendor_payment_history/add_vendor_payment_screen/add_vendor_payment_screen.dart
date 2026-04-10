import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

import 'add_vendor_payment_controller.dart';

class AddVendorPaymentScreen extends StatefulWidget{
  @override
  State<AddVendorPaymentScreen> createState() => _AddVendorPaymentScreenState();
}

class _AddVendorPaymentScreenState extends State<AddVendorPaymentScreen> {

  AddVendorPaymentController controller = Get.put(AddVendorPaymentController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
        appBar: CommonAppBar.appBar(
            title: "Add Vendor Payment",
            onTap: (){
              Get.back();

            }),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child:
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  VerticalSpacing.d5px(),
                  Text("Date",style: AppTextStyle.textFieldHeadingStyle,),
                  TextFormField(
                    controller: controller.datePickerController,
                    decoration:textBoxDecoration(hint:"dd-MM-yyyy",
                        suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
                    readOnly: true,

                    onTap: _selectDate,
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },



                  ),

                  VerticalSpacing.d15px(),
                  Text("Payment",style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.paymentController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    decoration:textBoxDecoration(hint:"Payment"),
                    onChanged: (value){
                      print("value");
                    },
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }

                      return null;
                    },



                  ),


                  VerticalSpacing.d15px(),
                  Text("Payment Mode",style: AppTextStyle.textFieldHeadingStyle,),

                  DropdownButtonFormField2<String>(
                    isExpanded: true,

                    decoration: dropDownBoxDecoration(
                    ),
                    hint:  Text(
                      'Select Payment Mode',
                      style: AppTextStyle.textHintText,
                    ),
                    items: ConstantData.paymentMode
                        .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                          capitalize(item),
                          style: AppTextStyle.textFieldHeadingStyle
                      ),
                    ))
                        .toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Select Payment Mode';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      controller.selectedPayment!.value=value;

                      //Do something when selected item is changed.
                    },
                    onSaved: (value) {
                      // selectedValue = value.toString();
                    },


                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                  ),



              VerticalSpacing.d20px(),

                  Obx(() =>

                  controller.isLoading.value?Center(child: CommonLoader()):
                  CommonButton(onTap: () {
                    if(_formKey.currentState!.validate()){

                      controller.addPayment();


                    }

                  }, text: "Submit"))

                ],

          )),
        ));



  }
  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate:DateTime.now(),
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      controller.datePickerController.text = formattedDate;
    }
  }
}