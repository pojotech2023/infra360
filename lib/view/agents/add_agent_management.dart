import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/model/agent_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/const_data.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/agents/agent_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class AddAgentManagementScreen extends StatefulWidget{
  const AddAgentManagementScreen({super.key});

  @override
  State<AddAgentManagementScreen> createState() => _AddAgentManagementScreenState();
}

class _AddAgentManagementScreenState extends State<AddAgentManagementScreen> {

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController companyEditingController = TextEditingController();

  AgentManagementController controller = Get.find<AgentManagementController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    if(Get.arguments!=null){
      AgentListData ?superVisorData = Get.arguments;
      nameEditingController.text = superVisorData!.name??"";
      mobileNumberEditingController.text = superVisorData!.mobileNo??"";
      companyEditingController.text = superVisorData!.companyName??"";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     appBar: CommonAppBar.appBar(
         title: "Add Agent",
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
             Text("Company Name",style: AppTextStyle.textFieldHeadingStyle,),

             TextFormField(
               controller: companyEditingController,
               decoration:textBoxDecoration(hint:"Enter the company name"),
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





             VerticalSpacing.d30px(),

             Obx((){

               return
                 controller.isSaveLoading.value?Center(child: CommonLoader()):CommonButton(onTap: (){

                 if(_formKey.currentState!.validate()){
                   if(Get.arguments==null){
                   controller.addAgent(nameEditingController.text, mobileNumberEditingController.text,
                       companyEditingController.text);
                   }
                   else{
                     AgentListData ?agentData = Get.arguments;

                     controller.updateAgent(
                         agentData!.id!,
                         nameEditingController.text, mobileNumberEditingController.text,
                         companyEditingController.text);
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