import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:get/get.dart';

import '../../../api/api.dart';

class AllLikedServices extends StatefulWidget {
  const AllLikedServices({Key? key}) : super(key: key);

  @override
  State<AllLikedServices> createState() => _AllLikedServicesState();
}

class _AllLikedServicesState extends State<AllLikedServices> {
  var userData;
  var dashboard;
  List ids = [];
  bool isLoading = false;


  @override
  void initState() {
    getServices();
    super.initState();
  }

  void getServices() async {
  isLoading = true;
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  var token = localStorage.getString('demand_token');
  var res = await CallApi().tokenData(token, '/api/v1/customer/service/liked_services');
  if (res.statusCode == 200) {
    var body = json.decode(res.body);
    isLoading = false;
    print(body);
    setState(() {
      dashboard = body['content'];     
      // print(dashboard);
      // log(dashboard.toString());
      
      // Extracting only the IDs from the dashboard list
      // var ids = dashboard.map((service) => service['id']).toList();
      // print('ids are $ids');

//     for (var key in dashboard) {
//   ids.add(key['id']);
// }
// print(ids);

    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Saved Services"),
      backgroundColor: Colors.white,
      body: isLoading ? Center(child: CircularProgressIndicator()):
      dashboard != null
          ?
          //  1 First Page

          //  2 Second Screen
          ListView.builder(
              itemCount: dashboard.length,
              itemBuilder: (BuildContext context, int index) => Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                  Get.toNamed(RouteHelper.getServiceRoute(dashboard[index]['id']));
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        width: 30.0,
                                        height: 55.0,
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text((index + 1).toString()),
                                          ],
                                        )),
                                    const SizedBox(width: 5.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        CircleAvatar(
                                                  radius: 50, // Image radius
                                                  backgroundImage: NetworkImage(
                                                      '${Get.find<SplashController>().configModel.content!.imageBaseUrl!}/service/${dashboard[index]['cover_image']}'),
                                                ),
                                        Text(
                                                        "Name: ${dashboard[index]['name']}",),
                                                    // Text(
                                                    //     "Description : ${dashboard[index]['description']}"),
                                        
                                        // Text(
                                          
                                        //   "Vehicle Type: ${dashboard[index]['type_vehicle']}",
                                        //   style: const TextStyle(
                                        //     color: Colors.black,
                                        //     fontSize: 16.0,
                                        //   ),
                                        // ),
                                        // Text(
                                        //   dashboard[index]['type_vehicle'].toString() == "1" ? 
                                        //   "Vehicle Type: Private Car" :
                                        //   dashboard[index]['type_vehicle'].toString() == "2" ? 
                                        //   "Vehicle Type: Commercial Vehicle" :
                                        //   "Vehicle Type: Two Wheeler",
                                        //   style: const TextStyle(
                                        //     color: Colors.black,
                                        //     fontSize: 16.0,
                                        //   ),
                                        // ),
                                        //  Row(
                                        //         children: [
                                        //           IconButton(
                                        //             icon: const Icon(Icons.edit),
                                        //             tooltip: 'Edit',
                                        //             color: Colors.green,
                                        //             onPressed: () {
                                        //               Get.to(EditService(id : dashboard[index]['id']));
                                        //             },
                                        //           ),
                                        //           IconButton(
                                        //             icon: const Icon(Icons.close),
                                        //             tooltip: 'Delete',
                                        //             color: Colors.red,
                                        //             onPressed: () {
                                        //               rejectOrder(context,
                                        //                   dashboard[index]['id']);
                                        //             },
                                        //           ),
                                        //         ],
                                        //       )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))
          : Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [Image.asset('assets/images/noitems.png'),
                SizedBox(height: 30,),
              Text('No Saved Services',style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),)],),
            ],
          )
      // ],
    );
    // );
  }


  // void rejectOrder(BuildContext context, id) {
  //   AwesomeDialog(
  //     context: context,
  //     dialogType: DialogType.WARNING,
  //     headerAnimationLoop: true,
  //     animType: AnimType.BOTTOMSLIDE,
  //     title: 'Are you sure?',
  //     // reverseBtnOrder: true,
  //     btnOkOnPress: () {
  //       print("ok");
  //       deleteOrder(id);
  //     },
  //     btnCancelOnPress: () {
  //       print("cancel");
  //     },
  //     desc: 'Are you sure want to delete this order?',
  //   ).show();
  // }

  void rejectOrder(BuildContext context, id) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: true,
      animType: AnimType.bottomSlide,
      title: 'Are you sure?',
      // reverseBtnOrder: true,
      btnOkOnPress: () {
        print("ok");
        deleteOrder(id);
      },
      btnCancelOnPress: () {
        print("cancel");
      },
      desc: 'Are you sure want to delete this service?',
    ).show();
  }

  void deleteOrder(id) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');

    var data = {};
    // var res = await CallApi().postData(token, data, 'add_driver');
    var res =
        await CallApi().updateData(token, data, '/api/v1/provider/delete_service/', id.toString());

    var body = json.decode(res.body);
    print(body);
    if (res.statusCode == 200) {
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: false,
        dialogType: DialogType.success,
        showCloseIcon: true,
        title: 'Succes',
        desc: body['message'],
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        },
      ).show();
    }

    setState(() {
      getServices();
    });
  }
}
