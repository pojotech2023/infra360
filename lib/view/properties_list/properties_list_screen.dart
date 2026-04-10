import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/utils/url_helper.dart';
import 'package:raptor_pro/model/property_list_model.dart';
import 'package:raptor_pro/utils/app_text_style.dart';
import 'package:raptor_pro/utils/res/colors.dart';
import 'package:raptor_pro/utils/res/images.dart';
import 'package:raptor_pro/utils/res/spacing.dart';
import 'package:raptor_pro/view/properties_list/add_property/add_property_screen.dart';
import 'package:raptor_pro/view/properties_list/properties_list_controller.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';

class PropertiesListScreen extends StatefulWidget {
  @override
  _PropertiesListScreenState createState() => _PropertiesListScreenState();
}

class _PropertiesListScreenState extends State<PropertiesListScreen> {

  PropertiesController controller = Get.put(PropertiesController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Property Details",

          onTap: (){
            Get.back();

          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          onPressed: (){

            Get.to(AddPropertyScreen());

          }),
      body:    Obx((){
        return controller.isLoading.value?
        Center(child: CommonLoader()): SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [


              GridView.builder(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.only(top: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // number of columns
                  crossAxisSpacing: 20, // space between columns
                  mainAxisSpacing: 20,  // space between rows
                  childAspectRatio: 0.72,  // width/height ratio
                ),
                itemCount: controller.propertiesList.length,
                itemBuilder: (context, index) {
                  PropertyListData propertyListData=   controller.propertiesList[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 8), // vertical offset for soft shadow
                        ),
                      ],
                      borderRadius:BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),

                          ),
                          child: Container(
                            color: AppColor.materialCategoryBGColor,
                            child: Image.network(UrlHelper.getFullImageUrl(propertyListData.image),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.17,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height*0.17,
                                    alignment: Alignment.center,
                                    color: Colors.grey[300],
                                    child:Text("No Image Preview",
                                      style: AppTextStyle.textRegularSmall,)
                                );
                              },
                            ),
                          ),
                        ),


                        VerticalSpacing.d10px(),

                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${propertyListData.name}",
                                textAlign: TextAlign.center,
                                style: AppTextStyle.textMedium.
                                copyWith(fontSize: 14,fontWeight: FontWeight.w600),),

                              VerticalSpacing.d5px(),

                              Text("Amount:${propertyListData.amount}",
                                textAlign: TextAlign.center,
                                style: AppTextStyle.textSubHeading.
                                copyWith(color: Colors.blue),),
                              VerticalSpacing.d2px(),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_outlined,
                                    color: Color(0xFFB9B9B9),size: 20,),
                                  Expanded(
                                    child: Text("${propertyListData.location}",
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      style: AppTextStyle.textSubHeading.
                                      copyWith(color: Color(0xFFB9B9B9)),),
                                  ),

                                ],
                              ),
                              VerticalSpacing.d2px(),
                            ],
                          ),
                        )


                      ],
                    ),
                  );
                },
              )
            ],
          ),
        );
        }),


    );
  }
}
