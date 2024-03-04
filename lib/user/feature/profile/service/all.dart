import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:get/get.dart';

import '../../../api/api.dart';
import 'edit.dart';

class AllServices extends StatefulWidget {
  const AllServices({Key? key}) : super(key: key);

  @override
  State<AllServices> createState() => _AllServicesState();
}

class _AllServicesState extends State<AllServices> {
  var userData;
  var dashboard;
  bool isLoading = false;


  @override
  void initState() {
    getServices();
    super.initState();
  }

  void getServices() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var res = await CallApi().tokenData(token, '/api/v1/provider/myservices');
    print(res.statusCode);
    if (res.statusCode == 200 ){ var body = json.decode(res.body);

    // print(body);
    setState(() {
      isLoading = false;
      
      dashboard = body['content'];
    
    });}
   
     
    
   
  
    // print(body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Services"),
      backgroundColor: Colors.white,
      body: isLoading 
          ? Center(child: CircularProgressIndicator()):
          //  1 First Page

          //  2 Second Screen

dashboard != null ?
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
                              InkWell(onTap: (){ Get.toNamed(RouteHelper.getServiceRoute(dashboard[index]['id']));},
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        Text(
                                          "Service Name: ${dashboard[index]['name']}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        Text(
                                          "Price : ${dashboard[index]['price']}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        Text(
                                          "Added on: ${dashboard[index]['created_at']}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      
                                         Row(
                                                children: [
                                                  // IconButton(
                                                  //   icon: const Icon(Icons.edit),
                                                  //   tooltip: 'Edit',
                                                  //   color: Colors.green,
                                                  //   onPressed: () {
                                                  //     Get.to(EditService(id : dashboard[index]['id']));
                                                  //   },
                                                  // ),
                                                ElevatedButton.icon(
                                                    icon: const Icon(Icons.delete),
                                                    // tooltip: 'Delete',
                                                    // color: Colors.red,
                                                    onPressed: () {
                                                      rejectOrder(context,
                                                          dashboard[index]['id']);
                                                    },label: Text('Delete Service'),
                                                    
                                                  ),
                                                ],
                                              )
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
          : 
              // Text('no data'),
           Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [Image.asset('assets/images/noitems.png'),
                SizedBox(height: 30,),
              Text('No Services',style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),)],),
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
