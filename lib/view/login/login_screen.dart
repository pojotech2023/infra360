import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/utils/text_form_style.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

import 'login_controller.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController loginEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginController loginController = Get.put(LoginController());


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:  SingleChildScrollView(child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Center(child: Image.asset(Images.appLogo,width: 250,height:250,),),
                VerticalSpacing.d5px(),
          Center(child: Image.asset(Images.appName,width: 300,height: 80,),),
                VerticalSpacing.d40px(),
                Center(child: Text("Login",style: AppTextStyle.appBarTextStyle,)),

                VerticalSpacing.d30px(),

                Text("Mobile Number",style: AppTextStyle.textFieldHeadingStyle,),
               VerticalSpacing.d5px(),
                TextFormField(
                  controller: loginEditingController,
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
                Text("Password",style: AppTextStyle.textFieldHeadingStyle,),
                VerticalSpacing.d5px(),
                TextFormField(
                  controller: passwordEditingController,
                  decoration:textBoxDecoration(hint: "Enter your Password"),
                  validator: (text){
                    if (text == null || text.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },



                ),

                VerticalSpacing.d20px(),
                Obx(() => loginController.isLoading.value
                 ? Center(child: CommonLoader()): CommonButton(
                  onTap: (){
                   if (_formKey.currentState!.validate()) {
                     loginController.onLoginSubmit(
                       loginEditingController.text,
                       passwordEditingController.text,
                     );

                   }

                  }, text: 'Submit',
                )),
              ],
            ),),
          ),
        ),
      ),
    );
  }
}