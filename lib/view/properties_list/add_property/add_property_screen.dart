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
import 'package:raptor_pro/view/properties_list/add_property/add_property_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';


class AddPropertyScreen extends StatefulWidget{
  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {

  AddPropertyController controller = Get.put(AddPropertyController());

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

                  Text("Name",style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.nameController,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    decoration:textBoxDecoration(hint:"Enter name"),
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



                  Text("Property Location",style: AppTextStyle.textFieldHeadingStyle,),
                  VerticalSpacing.d5px(),
                  TextFormField(
                    controller: controller.locationController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,//Normal textInputField will be displayed
                    decoration:textBoxDecoration(hint:"Enter location"),
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },



                  ),
                  VerticalSpacing.d15px(),

                  Text("Property Type",style: AppTextStyle.textFieldHeadingStyle,),

                  DropdownButtonFormField2<String>(
                    isExpanded: true,

                    decoration: dropDownBoxDecoration(
                    ),
                    hint:  Text(
                      'Select Property Type',
                      style: AppTextStyle.textHintText,
                    ),
                    items: ["Plot","Land"]
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
                        return 'Select Property Type';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      controller.propertyType.value=value!;

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

                  Text("Amount",style: AppTextStyle.textFieldHeadingStyle,),

                  TextFormField(
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,

                    decoration:textBoxDecoration(hint:"Enter amount"),
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


                  Text("Remarks",style: AppTextStyle.textFieldHeadingStyle,),
                  VerticalSpacing.d5px(),
                  TextFormField(
                    controller: controller.remarksController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,//Normal textInputField will be displayed
                    decoration:textBoxDecoration(hint:"Enter remarks"),
                    validator: (text){
                      if (text == null || text.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },



                  ),

                  VerticalSpacing.d15px(),

                  Text("Image",style: AppTextStyle.textFieldHeadingStyle,),
                  Obx(() {
                    final file = controller.propertyImage.value;
                    return InkWell(
                      onTap: () {
                        controller.getImage();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: file != null
                            ? Image.file(file, fit: BoxFit.cover)
                            : Icon(Icons.upload_file),
                      ),
                    );
                  }),


                  VerticalSpacing.d20px(),

                  Obx(() =>

                  controller.isLoading.value?Center(child: CommonLoader()):
                  CommonButton(onTap: () {
                    if(_formKey.currentState!.validate()){

                      controller.addProperty();


                    }

                  }, text: "Submit"))

                ],

              )),
        ));



  }
}