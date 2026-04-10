
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/view/widgets/common_button.dart';
import '../../base_url.dart';
import '../../utils/url_helper.dart';
import '../../model/drawing_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/log_out.dart';
import 'drawing_controller.dart';


class DrawingDetailScreen extends StatefulWidget {
  const DrawingDetailScreen({super.key, required this.data,});
  final DrawingData data;
  @override
  State<DrawingDetailScreen> createState() => _DrawingDetailScreenState();
}

class _DrawingDetailScreenState extends State<DrawingDetailScreen> {

  DrawingController controller = Get.find<DrawingController>();



  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: CommonAppBar.appBar(
          title: widget.data.drawingName!,
          onTap: (){
            Get.back();

          }),
      body:

          Column(
            children: [
              Expanded(child: Image.network(
                UrlHelper.getFullImageUrl(widget.data.drawingViewUrl),
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey),
              )
              ),
GetBuilder<DrawingController>(builder: (controller)=>Padding(padding: EdgeInsets.symmetric(vertical: 4,horizontal: 4),child: Row(

  children: [

    Expanded(child: CommonButton(onTap: (){
      controller.downloadDrawing(widget.data,context);


    }, text: "Download",customColor: Colors.green,)),SizedBox(width: 8,), Expanded(child: CommonButton(onTap: (){

        deleteDialog(context,(){
          controller.deleteDrawing(widget.data.drawingId.toString());


                             });



    }, text: "Delete",customColor: Colors.red,)),
  ],
),)),SizedBox(height: 4,),
            ],
          )


    );
  }

}