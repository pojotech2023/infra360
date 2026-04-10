import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/supervisor_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/supervisor_management/supervisor_management_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class AddSuperVisorManagementScreen extends StatefulWidget{
  const AddSuperVisorManagementScreen({super.key});

  @override
  State<AddSuperVisorManagementScreen> createState() => _AddSuperVisorManagementScreenState();
}

class _AddSuperVisorManagementScreenState extends State<AddSuperVisorManagementScreen> {

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController confirmPasswordEditingController = TextEditingController();

  SuperVisorManagementController controller = Get.find<SuperVisorManagementController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    if(Get.arguments!=null){
      SuperVisorData ?superVisorData = Get.arguments;
      nameEditingController.text = superVisorData!.name??"";
      mobileNumberEditingController.text = superVisorData!.mobileNo??"";
        emailEditingController.text = superVisorData!.email??"";
      passwordEditingController.text = superVisorData!.password??"";
      confirmPasswordEditingController.text = superVisorData!.password??"";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     appBar: CommonAppBar.appBar(
         title: "Add Supervisor",
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
               // validator: (text){
               //   if (text == null || text.isEmpty) {
               //     return 'Required';
               //   }
               //   return null;
               // },
             ),
             VerticalSpacing.d15px(),
             Text("Password",style: AppTextStyle.textFieldHeadingStyle,),

             TextFormField(
               controller: passwordEditingController,
               decoration:textBoxDecoration(hint:"Enter Password"),
               validator: (text){
                 if (text == null || text.isEmpty) {
                   return 'Required';
                 }

                 return null;
               },



             ),
             VerticalSpacing.d15px(),
             Text("Confirm Password",style: AppTextStyle.textFieldHeadingStyle,),

         TextFormField(
           controller: confirmPasswordEditingController,
           decoration:textBoxDecoration(hint:"Enter  confirm Password"),
           validator: (text){
             if (text == null || text.isEmpty) {
               return 'Required';
             }
             if (text != passwordEditingController.text) {
               return 'Passwords do not match';
             }
             return null;

             return null;
           },
         ),


           VerticalSpacing.d30px(),

             Obx((){

               return
                 controller.isSaveLoading.value?Center(child: CommonLoader()):CommonButton(onTap: (){

                 if(_formKey.currentState!.validate()){
                   if(Get.arguments==null){
                   controller.addSupervisor(nameEditingController.text, mobileNumberEditingController.text,
                       emailEditingController.text,passwordEditingController.text,confirmPasswordEditingController.text);
                   }
                   else{
                     SuperVisorData ?superVisorData = Get.arguments;

                     controller.updateSupervisor(
                         superVisorData!.id!,
                         nameEditingController.text, mobileNumberEditingController.text,
                         emailEditingController.text,passwordEditingController.text,confirmPasswordEditingController.text);
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