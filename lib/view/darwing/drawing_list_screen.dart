
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base_url.dart';
import '../../utils/url_helper.dart';
import '../../utils/app_text_style.dart';
import '../../utils/res/colors.dart';
import '../../utils/res/spacing.dart';
import '../widgets/common_app_bar.dart';
import 'drawing_add_screen.dart';
import 'drawing_controller.dart';
import 'drawing_detail_screen.dart';

class DrawingListScreen extends StatefulWidget {
  const DrawingListScreen({super.key});

  @override
  State<DrawingListScreen> createState() => _DrawingListScreenState();
}

class _DrawingListScreenState extends State<DrawingListScreen> {

  final DrawingController controller = Get.put(DrawingController());


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: "Drawing",
          onTap: (){
            Get.back();

          }),
      floatingActionButton:

      controller.userDetails.data!.role!.toLowerCase() == 'admin' ?
      FloatingActionButton(onPressed: (){
        Get.to(() => DrawingAddScreen());

      },child: Icon(Icons.add),) : SizedBox(),
      body:
      Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<DrawingController>(
          builder: (controller) {
            final drawings = controller.drawingList;

          return  controller.isLoading.value ?
          Center(child:  CircularProgressIndicator() ):
          drawings.isEmpty ?
          Center(child: Text('No drawings available')) :

             GridView.builder(
              itemCount: drawings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // adjust for your layout
              ),
              itemBuilder: (context, index) {
                final data = drawings[index];

                return _buildGridItem(
                  context,
                  image: UrlHelper.getFullImageUrl(data.drawingViewUrl),
                  title: data.drawingName ??'',
                  onTap: () {
                    Get.to(() => DrawingDetailScreen(data:data
                    ));
                  },
                );
              },
            );
          },
        ),
      ),

    );
  }

  Widget _buildGridItem(
      BuildContext context, {
        required String image,
        required String title,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(
            color: AppColor.materialCategoryBorderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child:      Container(
                width: MediaQuery.sizeOf(context).width,
                height: 100,
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      debugPrint('Image load failed: $exception');
                    },
                  ),borderRadius:BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade100, width: 1,),
                ),
              ),
            ),
            VerticalSpacing.d10px(),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.materialTitleText,
              ),
            ),
            VerticalSpacing.d10px(),

          ],
        ),
      ),
    );

  }
}