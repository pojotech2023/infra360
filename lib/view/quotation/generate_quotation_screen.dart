
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/quotation_model.dart';
import '../../utils/app_text_style.dart';
import '../../utils/const_data.dart';
import '../../utils/res/date_picker.dart';
import '../../utils/res/spacing.dart';
import '../../utils/text_form_style.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import 'generate_quotation_controller.dart';


class GenerateQuotationScreen extends StatelessWidget {
   GenerateQuotationScreen({super.key});

  GenerateQuotationController controller = Get.put(GenerateQuotationController());
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title:  "Generate Quotation",
          onTap: (){
            Get.back();


          }),
      body: SafeArea(
        child: GetBuilder<GenerateQuotationController>(builder: (controller)=> Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Extra bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Site Detail",style: AppTextStyle.textFieldHeadingStyle.copyWith(fontSize: 18),),
              VerticalSpacing.d20px(),


              Text("Name",style: AppTextStyle.textFieldHeadingStyle,),

              TextFormField(
                controller: controller.nameEditingController,
                decoration:textBoxDecoration(hint:"Enter Customer name"),
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },



              ),

              VerticalSpacing.d15px(),
              Text("Mobile Number",style: AppTextStyle.textFieldHeadingStyle,),

              TextFormField(
                controller: controller.mobileNumberEditingController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters:tenDigitPhoneFormatter(),

                decoration:textBoxDecoration(hint:"Enter Customer Mobile Number"),
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  if (text.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },



              ),


              VerticalSpacing.d15px(),
              Text("Contractor",style: AppTextStyle.textFieldHeadingStyle,),

              TextFormField(
                controller: controller.contractorEditingController,
                decoration:textBoxDecoration(hint:"Enter Contractor"),
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              VerticalSpacing.d15px(),

              Text("Subject",style: AppTextStyle.textFieldHeadingStyle,),

              TextFormField(
                controller: controller.subjectEditingController,
                decoration:textBoxDecoration(hint:"Enter Subject of Quotation"),
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },



              ),

              VerticalSpacing.d15px(),

              Text("Date",style: AppTextStyle.textFieldHeadingStyle,),
              TextFormField(
                controller: controller.datePickerController,
                decoration:textBoxDecoration(hint:"dd-MM-yyyy",
                    suffixIcon: Icon(Icons.calendar_month,color: Colors.grey,)),
                readOnly: true,

                onTap: () async {
                  String pickedDate = await selectDate(context);
                  if (pickedDate.isNotEmpty) {
                    controller.datePickerController.text = pickedDate;
                  }
                },
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },



              ),


              VerticalSpacing.d10px(),
              Text("Location",style: AppTextStyle.textFieldHeadingStyle,),

              TextFormField(
                controller: controller.locationEditingController,
                minLines: 3,
                maxLines: 5,
                decoration:textBoxDecoration(hint:"Enter Location"),
                validator: (text){
                  if (text == null || text.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),



              VerticalSpacing.d30px(),

             GetBuilder<GenerateQuotationController>(builder: (controller)=>
                Column(
                  children: [

                    controller.isLoading.value ?Center(
                      child: CircularProgressIndicator(),
                    ): ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: controller.quotationList.value.length,itemBuilder: (context,index){

                      var data = controller.quotationList.value[index];

                      controller.totalAmt.value =  controller.totalAmt.value + (int.tryParse(data.total?.text ?? '0') ?? 0);
                      
                      
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2), // Shadow color
                                spreadRadius: 1, // How far the shadow spreads
                                blurRadius: 6, // How soft the shadow looks
                                offset: const Offset(2, 3), // X and Y position of the shadow
                              ),
                            ],
                          ),

                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(onPressed: (){
                                  controller.quotationList.remove(data);
                                  controller.calculateTotal();
                                  controller.update();

                                  controller.update();
                                  print("LENGTH OF QUOTATION ${ controller.quotationList.value.length}");
                                  controller.update();

                                }, icon: Icon(Icons.cancel,color: Colors.red,)),
                              ),
                              TextFormField(
                                controller: data.particular,
                                decoration:textBoxDecoration(hint:"Enter Customer Address"),
                                validator: (text){
                                  if (text == null || text.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8,),
                              Row(
                                children: [


                                  Expanded(child:  TextFormField(
                                    controller: data.sqFt,
                                    decoration:textBoxDecoration(hint:"Enter Customer Address"),
                                    onChanged: (value){
                                      final sqFt = double.tryParse(value) ?? 0;
                                      final rate = double.tryParse(data.rate?.text ?? '0') ?? 0;
                                      data.total?.text = (rate * sqFt).toStringAsFixed(2);
                                      controller.calculateTotal();
                                    },
                                    validator: (text){
                                      if (text == null || text.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),),
                                  SizedBox(width: 8,),
                                Expanded(child:  DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: dropDownBoxDecoration(hint: "Select Unit"),
                                  hint: Text('Select Unit', style: AppTextStyle.textHintText),
                                  value: ConstantData.area.contains(data.unit) ? data.unit : null, // Keep this
                                  items: ConstantData.area
                                      .map((item) => DropdownMenuItem<String>(
                                    value: item, // ✅ FIXED HERE
                                    child: Text(item, style: AppTextStyle.textFieldHeadingStyle),
                                  ))
                                      .toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select Unit';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    data.unit = value;
                                  },
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),),

                                  SizedBox(width: 8,),


                                  Expanded(child:  TextFormField(
                                    controller: data.rate,
                                    decoration:textBoxDecoration(hint:"Enter Customer Address"),
                                    onChanged: (value){
                                      final rate = double.tryParse(value) ?? 0;
                                      final sqFt = double.tryParse(data.sqFt?.text ?? '0') ?? 0;
                                      data.total?.text = (rate * sqFt).toStringAsFixed(2);
                                      controller.calculateTotal();
                                    },
                                    validator: (text){
                                      if (text == null || text.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),),
                                   SizedBox(width: 8,),
                                  Expanded(child:  TextFormField(
                                    controller: data.total,
                                    readOnly: true,
                                    decoration:textBoxDecoration(hint:"Enter Customer Address"),
                                    validator: (text){
                                      if (text == null || text.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),),
                                ],
                              ),
                            ],
                          )
                      );
                    }) ,               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 8),
                 child: Wrap(
                   alignment: WrapAlignment.spaceBetween,
                   crossAxisAlignment: WrapCrossAlignment.center,
                   spacing: 12,
                   runSpacing: 12,
                   children: [
                     SizedBox(
                       width: 180,
                       child: CommonButton(
                         customColor: Colors.green,
                         onTap: () {
                           controller.quotationList.add(
                             QuotationData(
                               particular: TextEditingController(),
                               rate: TextEditingController(),
                               sqFt: TextEditingController(),
                               total: TextEditingController(),
                             ),
                           );
                           controller.calculateTotal();
                           controller.update();
                         },
                         text: 'Add Particulars',
                       ),
                     ),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Theme.of(context).primaryColor,
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(
                             width: 1,
                             color: Theme.of(context).primaryColor.withOpacity(0.4)),
                       ),
                       child: Text(
                         controller.totalAmt.value.toString(),
                         textAlign: TextAlign.end,
                         style: const TextStyle(
                             fontWeight: FontWeight.bold, color: Colors.white),
                       ),
                     ),
                   ],
                 ),
               ),


                    SizedBox(height: 8,),

                    GetBuilder<GenerateQuotationController>(builder: (controller){
                      return  controller.issubmitLoading.value ? CircularProgressIndicator()  :
                      CommonButton(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            if (controller.quotationList.isEmpty) {
                              Get.snackbar(
                                "Add Particulars",
                                "Please add at least one quotation item.",
                                backgroundColor: Colors.orangeAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            _formKey.currentState!.save();
                            controller.genrateQuotationApi();
                          } else {
                            Get.snackbar(
                              "Validation Error",
                              "Please fill all required fields before submitting.",
                              backgroundColor: Colors.redAccent.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          }
                        },
                        text: 'Submit',
                      );
                    })

                  ],
                ))

              // Obx((){
              //
              //   return
              //     CommonButton(onTap: (){
              //
              //
              //
              //
              //
              //
              //
              //     }, text: Get.arguments==null?"Save":"Update");
              // }
            //  ),
            ],
          ),
        ),
      )),
    ),
    );
  }
}
