// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';


import '../../api/api.dart';

class ServiceFilter extends StatefulWidget {
  const ServiceFilter({Key? key}) : super(key: key);

  @override
  State<ServiceFilter> createState() => _ServiceFilterState();
}

class _ServiceFilterState extends State<ServiceFilter> {

  var _formKey = GlobalKey<FormState>();

  TextEditingController serviceNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();


  var catName;
  var catType;

  var data;
  var dashboard;
  String catId = "74218494-1abb-4dea-81cb-30db33ff6d06";
  var subCatId;

  var orderId;

  var serviceImgUrl;
  var thumbnailImgUrl;

  bool loadingImages = false;

  XFile? serviceImg;
  XFile? thumbnailImg;

  final ImagePicker picker = ImagePicker();

  List<File> selectedImages = [];

  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;

  @override
  void initState() {
    getAllCat();

    super.initState();
  }

  List categoryItemlist = [];
  List subCategoryItemlist = [];

  List<String> dropdownData = [];

  bool isLoading = false;


  Future getAllCat() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi().getData(token, '/api/v1/getallcat');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        categoryItemlist = jsonData['content'];
        getFieldsById();
        getAllSubCat();

        addressController.text = Get.find<LocationController>().getUserAddress()!.address.toString();
      });
    }
  }

  Future getFieldsById() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi()
        .getDataById(token, '/api/v1/getfieldsbyid/', catId.toString());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print(data);
      setState(() {
        isLoading = false;
        catName = data['category_name'];
      });
    } else {
      // Handle errors
      print('Failed to fetch data');
    }
  }

  Future getAllSubCat() async {
    print("get all sub cat");
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var response = await CallApi()
        .getDataById(token, '/api/v1/getallsubcatbyid/', catId.toString());

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      setState(() {
        subCategoryItemlist = jsonData['content'];
      });
    }
  }

  bool _isLoading = false;



  String? gender; //no radio button will be selected on initial

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2)
        ],
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight,
            ]),
      ),
      child: InkWell(
        onTap: () => {
          if (_formKey.currentState!.validate())
            {
              Get.toNamed(
                  RouteHelper.allServiceScreenRoute(subCatId.toString())),
            }
          else
            {}
        },
        child: Text(
          _isLoading ? 'Loading...' : 'Filter Service',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget formWidget() {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Select category",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      DropdownButtonFormField(
                        hint: const Text('Select Category'),
                        items: categoryItemlist.map((item) {
                          return DropdownMenuItem(
                            value: item['id'].toString(),
                            child: Text(item['name'].toString(),
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          print(newVal);
                          setState(() {
                            catId = newVal!;
                            isLoading = true;
                            print(catId);
                          });
                          getAllSubCat();
                          getFieldsById();
                        },
                        value: catId,
                        validator: (value) {
                          if (value == null) {
                            return 'Please select category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // _submitButton(),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                isLoading == false
                    ? SingleChildScrollView(
                        child: Column(children: [
                          Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  "Select sub category",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                DropdownButtonFormField(
                                  hint: const Text('Select sub category'),
                                  items: subCategoryItemlist.map((item) {
                                    return DropdownMenuItem(
                                      value: item['id'].toString(),
                                      child: Text(item['name'].toString(),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black)),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) {
                                    setState(() {
                                      subCatId = newVal;
                                      // print(cat_id);
                                    });
                                  },
                                  value: subCatId,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select sub category';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // _submitButton(),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Title",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                  controller: serviceNameController,
                                ),
                              ],
                            ),
                          ),


                          Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Address",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                TextFormField(
                                  controller: addressController,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),


                          // Column(
                          //   children: [
                          //     InkWell(
                          //       onTap: () {
                          //         Get.toNamed(
                          //             RouteHelper.getAccessLocationRoute(
                          //                 'address'));
                          //       },
                          //       child: GetBuilder<LocationController>(
                          //           builder: (locationController) {
                          //         return Row(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.center,
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           children: [
                          //             IconButton(
                          //                 onPressed: () async {
                          //                   final prefs =
                          //                       await SharedPreferences
                          //                           .getInstance();
                          //                   log(prefs
                          //                       .getString('demand_token')
                          //                       .toString());
                          //                   var address = locationController
                          //                       .getUserAddress()!
                          //                       .address;
                          //                   print(address!.substring(
                          //                       13, address.indexOf(',')));
                          //                   // log();
                          //                 },
                          //                 icon: Icon(Icons.location_on)),
                          //             if (locationController.getUserAddress() !=
                          //                 null)
                          //               Flexible(
                          //                 child: 
                          //                 Text(
                          //                   locationController
                          //                       .getUserAddress()!
                          //                       .address.toString(),
                          //                   style: ubuntuRegular.copyWith(
                          //                       color: const Color.fromARGB(255, 0, 0, 0),
                          //                       fontSize:
                          //                           Dimensions.fontSizeSmall),
                          //                   maxLines: 1,
                          //                   overflow: TextOverflow.ellipsis,
                          //                 ),
                          //               ),
                          //             const Icon(
                          //                 Icons.arrow_forward_ios_rounded,
                          //                 color: Color.fromARGB(255, 0, 0, 0),
                          //                 size: 12),
                          //           ],
                          //         );
                          //       }),
                          //     ),
                          //   ],
                          // ),
                        ]),
                      )
                    : const Center(child: CircularProgressIndicator())
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Filter service"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 15,
              ),
              formWidget(),
              const SizedBox(
                height: 15,
              ),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
