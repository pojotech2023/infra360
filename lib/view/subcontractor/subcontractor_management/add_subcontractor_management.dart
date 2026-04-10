import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/subcontractor_list_model.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/subcontractor/subcontractor_management/subcontractor_management_controller.dart';
import 'package:raptor_pro/view/supervisor_management/supervisor_management_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class AddSubcontractorManagementScreen extends StatefulWidget{
  const AddSubcontractorManagementScreen({super.key});

  @override
  State<AddSubcontractorManagementScreen> createState() => _AddSubcontractorManagementScreenState();
}

class _AddSubcontractorManagementScreenState extends State<AddSubcontractorManagementScreen> {

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController addressEditingController = TextEditingController();
  TextEditingController gstEditingController = TextEditingController();

  SubcontractorManagementController controller = Get.find<SubcontractorManagementController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    if(Get.arguments!=null){
      Subcontractor ?subcontractorData = Get.arguments;
      nameEditingController.text = subcontractorData!.name??"";
      mobileNumberEditingController.text = subcontractorData!.mobileNo??"";
      emailEditingController.text = subcontractorData!.email??"";
      addressEditingController.text = subcontractorData!.address??"";
      gstEditingController.text = subcontractorData!.gst??"";
     controller.selectedSiteUtilities.value = subcontractorData!.subcontractors ??"";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     appBar: CommonAppBar.appBar(
         title: Get.arguments==null? "Add Subcontractor" : "Edit Subcontractor",
         onTap: (){
           Get.back();

         }),
     body:  Form(
       key: _formKey,
       child: SingleChildScrollView(
         padding: EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [

             Text("Name",style: AppTextStyle.textFieldHeadingStyle,),
             VerticalSpacing.d5px(),
             TextFormField(
               controller: nameEditingController,
               decoration:textBoxDecoration(hint:"Enter your name"),
               validator: (text){
                 if (text == null || text.isEmpty) {
                   return 'Required';
                 }
                 return null;
               },



             ),
             VerticalSpacing.d15px(),
             Text("Subcontractors",style: AppTextStyle.textFieldHeadingStyle,),
             DropdownButtonFormField2<String>(
               isExpanded: true,
               value: controller.selectedSiteUtilities.value.isEmpty
                   ? null
                   : controller.selectedSiteUtilities.value,
               decoration: dropDownBoxDecoration(),
               hint: Text(
                 'Subcontractors',
                 style: AppTextStyle.textHintText,
               ),
               items: ConstantData.allSubcontractorKeys
                   .map((item) => DropdownMenuItem<String>(
                 value: item, // keep same as in list
                 child: Text(
                   item, // display item directly
                   style: AppTextStyle.textFieldHeadingStyle,
                 ),
               ))
                   .toList(),
               validator: (value) {
                 if (value == null) {
                   return 'Select Subcontractors';
                 }
                 return null;
               },
               onChanged: (value) {
                 controller.selectedSiteUtilities.value = value!;
               },
               dropdownStyleData: DropdownStyleData(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(10),
                 ),
               ),
             ),



             VerticalSpacing.d15px(),
             Text("Mobile Number",style: AppTextStyle.textFieldHeadingStyle,),

             TextFormField(
               controller: mobileNumberEditingController,
               keyboardType: TextInputType.number,
               autovalidateMode: AutovalidateMode.onUserInteraction,
               inputFormatters:tenDigitPhoneFormatter(),

               decoration:textBoxDecoration(hint:"Enter your mobile number"),
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
             Text("Email Id",style: AppTextStyle.textFieldHeadingStyle,),

             TextFormField(
               controller: emailEditingController,
               decoration:textBoxDecoration(hint:"Enter your email"),
               validator: (text){
                 if (text == null || text.isEmpty) {
                   return 'Required';
                 }
                 return null;
               },
             ),
             VerticalSpacing.d15px(),
             Text("Address",style: AppTextStyle.textFieldHeadingStyle,),

             TextFormField(
               controller: addressEditingController,
               minLines: 3,
               maxLines: 5,
               decoration:textBoxDecoration(hint:"Enter your Address"),
               validator: (text){
                 if (text == null || text.isEmpty) {
                   return 'Required';
                 }
                 return null;
               },
             ),

             VerticalSpacing.d15px(),
             Text("Gst",style: AppTextStyle.textFieldHeadingStyle,),

             TextFormField(
               controller: gstEditingController,
               decoration:textBoxDecoration(hint:"Enter your Gst"),
               validator: (text){
                 if (text == null || text.isEmpty) {
                   return 'Required';
                 }
                 return null;
               },
             ),
             VerticalSpacing.d30px(),

             Obx((){

               return
                 controller.isSaveLoading.value?Center(child: CommonLoader()):CommonButton(onTap: (){

                 if(_formKey.currentState!.validate()){
                   if(Get.arguments==null){
                   controller.addSubcontractor(
                       name:nameEditingController.text,
                       mobileNo:mobileNumberEditingController.text,
                       emailId:emailEditingController.text,
                       contractor: controller.selectedSiteUtilities.value,
                       address: addressEditingController.text,
                       gst: gstEditingController.text);
                   }
                   else{
                     Subcontractor ?subcontractorData = Get.arguments;

                     controller.updateSupervisor(
                        id:  subcontractorData!.id!,
                       name:  nameEditingController.text,
                         mobileNo:mobileNumberEditingController.text,
                         emailId: emailEditingController.text,
                         contractor: controller.selectedSiteUtilities.value,
                         address: addressEditingController.text,
                         gst: gstEditingController.text);
                   }
                 }





               }, text: Get.arguments==null?"Save":"Update");
             }
             ),
           ],
         ),
       ),
     ),

   );
  }
}