import 'dart:convert';

import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:mstoo/user/feature/service/widget/service_info_card.dart';
import 'package:mstoo/user/feature/service/widget/service_overview.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:share_plus/share_plus.dart';

import '../../../api/api.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceID;
  final String fromPage;
  const ServiceDetailsScreen(
      {Key? key, required this.serviceID, this.fromPage = "others"})
      : super(key: key);

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool isUserLoggedIn = Get.find<AuthController>().isLoggedIn();

  final ScrollController scrollController = ScrollController();
  final scaffoldState = GlobalKey<ScaffoldState>();

  bool liked = false;
  bool saved = false;
  bool isLoading = false;
  var dashboard;
  var dashboard2;
  var thumbnails;
  var serviceContent;
  List ids = [];

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        int pageSize = Get.find<ServiceTabController>().pageSize ?? 0;
        if (Get.find<ServiceTabController>().offset! < pageSize) {
          Get.find<ServiceTabController>().getServiceReview(
              widget.serviceID, Get.find<ServiceTabController>().offset! + 1);
        }
      }
    });
    Get.find<ServiceController>().getRecentlyViewedServiceList(
      1,
      true,
    );
    checkIfSaved();
    getRenter();
    getThumbnails();
    super.initState();
  }

  void getRenter() async {
    var res = await CallApi().getGuestDataById(
        '/api/v1/customer/service/getrenter/', widget.serviceID);
    var body = json.decode(res.body);
    setState(() {
      dashboard = body['content'];
    });
  }

  void getThumbnails() async {
    var res = await CallApi().getGuestDataById(
        '/api/v1/customer/service/getthumbnails/', widget.serviceID);
    var body = json.decode(res.body);

    setState(() {
      thumbnails = body['content'];
      serviceContent = body['content']['service_content'];
    });
  }

  void checkIfSaved() async {
    isLoading = true;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var res = await CallApi()
        .tokenData(token, '/api/v1/customer/service/liked_services');
    if (res.statusCode == 200) {
      var body = json.decode(res.body);
      isLoading = false;
      print(body);
      setState(() {
        dashboard2 = body['content'];
        for (var key in dashboard2) {
          ids.add(key['id']);

          // print('ids are $ids');
          // print('ids contain ${ids.contains(widget.serviceID)}');
        }
        if (ids.contains(widget.serviceID) == true) {
          saved = true;
        }
        print('hello hello hello');
        print('saved: $saved');
        print('ids contain ${ids.contains(widget.serviceID)}');
      });
    }
  }

  void saveForLater() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var data = {
      'service_id': widget.serviceID.toString(),
    };
    var res = await CallApi()
        .postData(token, data, '/api/v1/customer/service/save_for_later');
    if (res.statusCode == 200) {
      print(res.body);
      setState(() {
        saved = true;
      });
      customSnackBar("Saved", isError: false);
    }
  }

  void removeSaveForLater() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var data = {
      'service_id': widget.serviceID.toString(),
    };
    var res = await CallApi().postData(
        token, data, '/api/v1/customer/service/remove_save_for_later');
    if (res.statusCode == 200) {
      setState(() {
        saved = false;
      });
      customSnackBar("Removed from saved", isError: false);
    }
  }

  void likeService() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var data = {
      'service_id': widget.serviceID.toString(),
    };
    var res = await CallApi()
        .postData(token, data, '/api/v1/customer/service/like_service');
    if (res.statusCode == 200) {
      setState(() {
        liked = true;
      });
      customSnackBar("Added to liked services", isError: false);
    }
  }

  void dislikeService() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var data = {
      'service_id': widget.serviceID.toString(),
    };
    var res = await CallApi()
        .postData(token, data, '/api/v1/customer/service/dislike_service');
    if (res.statusCode == 200) {
      setState(() {
        liked = false;
      });
      customSnackBar("Removed from liked", isError: false);
    }
  }

  void reportService() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');
    var data = {
      'service_id': widget.serviceID.toString(),
    };
    var res = await CallApi()
        .postData(token, data, '/api/v1/customer/service/report_service');
    if (res.statusCode == 200) {
      customSnackBar("Service reported", isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      endDrawer:
          ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      appBar: CustomAppBar(
        centerTitle: false,
        title: 'service_details'.tr,
        showCart: true,
      ),
      body: dashboard != null
          ? GetBuilder<ServiceDetailsController>(initState: (state) {
              if (widget.fromPage == "search_page") {
                Get.find<ServiceDetailsController>().getServiceDetails(
                    widget.serviceID,
                    fromPage: "search_page");
              } else {
                Get.find<ServiceDetailsController>()
                    .getServiceDetails(widget.serviceID);
              }
            }, builder: (serviceController) {
              if (serviceController.service != null) {
                if (serviceController.service!.id != null) {
                  Service? service = serviceController.service;
                  Discount discount =
                      PriceConverter.discountCalculation(service!);
                  double lowestPrice = 0.0;
                  if (service.variationsAppFormat!.zoneWiseVariations != null) {
                    lowestPrice = service
                        .variationsAppFormat!.zoneWiseVariations![0].price!
                        .toDouble();
                    for (var i = 0;
                        i <
                            service.variationsAppFormat!.zoneWiseVariations!
                                .length;
                        i++) {
                      if (service.variationsAppFormat!.zoneWiseVariations![i]
                              .price! <
                          lowestPrice) {
                        lowestPrice = service
                            .variationsAppFormat!.zoneWiseVariations![i].price!
                            .toDouble();
                      }
                    }
                  }

                  return FooterBaseView(
                    isScrollView:
                        ResponsiveHelper.isMobile(context) ? true : true,
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: DefaultTabController(
                        length: Get.find<ServiceDetailsController>()
                                .service!
                                .faqs!
                                .isNotEmpty
                            ? 3
                            : 2,
                        child: Column(
                          children: [
                            if (!ResponsiveHelper.isMobile(context) &&
                                !ResponsiveHelper.isTab(context))
                              const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),
                            Stack(
                              children: [
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          (!ResponsiveHelper.isMobile(
                                                      context) &&
                                                  !ResponsiveHelper.isTab(
                                                      context))
                                              ? const Radius.circular(8)
                                              : const Radius.circular(0.0)),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              width: Dimensions.webMaxWidth,
                                              height:
                                                  ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? 280
                                                      : 150,
                                              child: CustomImage(
                                                image:
                                                    '${Get.find<SplashController>().configModel.content!.imageBaseUrl!}/service/${service.coverImage}',
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              width: Dimensions.webMaxWidth,
                                              height:
                                                  ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? 280
                                                      : 150,
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                          Container(
                                            width: Dimensions.webMaxWidth,
                                            height: ResponsiveHelper.isDesktop(
                                                    context)
                                                ? 280
                                                : 150,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeLarge),
                                            child: Center(
                                                child: Text(service.name ?? '',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: ubuntuMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeExtraLarge,
                                                        color: Colors.white))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   height: 120,
                                    // )
                                  ],
                                ),
                                thumbnails != null
                                    ? CarouselSlider(
                                        options: CarouselOptions(),
                                        items: thumbnails['thumbnails']
                                            .map<Widget>((item) => InkWell(
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return ImageDetailScreen(
                                                          imageUrl: item);
                                                    }));
                                                  },
                                                  child: Container(
                                                    child: Center(
                                                        child: Image.network(
                                                            item,
                                                            fit: BoxFit.cover,
                                                            width: 1000)),
                                                  ),
                                                ))
                                            .toList())
                                    : const SizedBox(),
                              ],
                            ),

                            ServiceInformationCard(
                                discount: discount,
                                service: service,
                                lowestPrice: lowestPrice),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Share.share(service.name.toString());
                                    },
                                    child: const Text(
                                      "Share",
                                      style: TextStyle(fontSize: 12),
                                    )),
                                // liked == false
                                //     ? ElevatedButton(
                                //         onPressed: () {
                                //           if (!isUserLoggedIn) {
                                //             Get.toNamed(
                                //                 RouteHelper.getNotLoggedScreen(
                                //                     "booking", "my_bookings"));
                                //           } else {
                                //             likeService();
                                //           }
                                //         },
                                //         child: const Text("Like"))
                                //     : ElevatedButton(
                                //         onPressed: () {
                                //           if (!isUserLoggedIn) {
                                //             Get.toNamed(
                                //                 RouteHelper.getNotLoggedScreen(
                                //                     "booking", "my_bookings"));
                                //           } else {
                                //             dislikeService();
                                //           }
                                //         },
                                //         child: const Text("Dislike")),
                                (ids.contains(widget.serviceID) == false)
                                    ? saved == false
                                        ? ElevatedButton(
                                            onPressed: () {
                                              if (!isUserLoggedIn) {
                                                Get.toNamed(RouteHelper
                                                    .getNotLoggedScreen(
                                                        "save for later",
                                                        "Saved "));
                                              } else {
                                                saveForLater();
                                              }
                                            },
                                            child: const Text("Save for later"))
                                        : ElevatedButton(
                                            onPressed: () {
                                              removeSaveForLater();
                                            },
                                            child:
                                                const Text("Remove from saved"))
                                    : saved == true
                                        ? ElevatedButton(
                                            onPressed: () {
                                              removeSaveForLater();
                                            },
                                            child:
                                                const Text("Remove from saved"))
                                        : ElevatedButton(
                                            onPressed: () {
                                              if (!isUserLoggedIn) {
                                                Get.toNamed(RouteHelper
                                                    .getNotLoggedScreen(
                                                        "save for later",
                                                        "Saved "));
                                              } else {
                                                saveForLater();
                                              }
                                            },
                                            child:
                                                const Text("Save for later")),

                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!isUserLoggedIn) {
                                        Get.toNamed(
                                            RouteHelper.getNotLoggedScreen(
                                                "booking", "my_bookings"));
                                      } else {
                                        reportService();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red, // Background color
                                    ),
                                    child: const Text("Report"),
                                  ),
                                ),
                              ],
                            ),
                            // service detail info
                            SingleChildScrollView(
                                child: Container(
                              margin: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: Column(
                                children: [
                                  ServiceOverview(
                                      description: service.description!),

                                  // new fields added

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        // Vehicle
                                        service.category!.id ==
                                                "74218494-1abb-4dea-81cb-30db33ff6d06"
                                            ? Column(
                                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['vehicle_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Brand : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['vehicle_brand']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Model : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['model_year']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Mileage : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['mileage']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Price : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text("$lowestPrice"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Fuel Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['fuel_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Transmission : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['transmission']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Condition : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['condition']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Location : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['location']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Available on : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['availability_date']}"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),

                                        //services
                                        service.category!.id ==
                                                "79588df9-f646-4cd3-94ce-36377264a400"
                                            ? Column(
                                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['service_type']}"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),

                                        //equipment
                                        service.category!.id ==
                                                "8bbeed15-6cc4-4f97-8f50-d84961c9764a"
                                            ? Column(
                                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['equipment_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Brand : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['equipment_brand']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Condition : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['condition']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Power source : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['power_source']}"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),

                                        //clothes
                                        service.category!.id ==
                                                "ba3d6a4e-bb6f-4bfe-b945-f608e34dab6f"
                                            ? Column(
                                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['cloth_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Size : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['cloth_size']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Brand : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['cloth_brand']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Price : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text("$lowestPrice"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),

                                        //property
                                        service.category!.id ==
                                                "d7402613-2a5d-4eb8-863b-c2da1e9a8cf0"
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['property_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Bedrooms : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['bedrooms']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Bathrooms : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['bathrooms']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Price : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text("$lowestPrice"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),

                                        //furniture
                                        service.category!.id ==
                                                "ee1618f3-90ae-475d-b98c-0af47dde4c45"
                                            ? Column(
                                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['furniture_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Brand : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['furniture_brand']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Price : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text("$lowestPrice"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Condition : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['condition']}"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),

                                        //electronics
                                        service.category!.id ==
                                                "ef086e8c-e7ec-4493-b9fa-d35774ebe9e8"
                                            ? Column(
                                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Category : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${service.category!.name}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Date : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['created_at']}"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Type : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['electronic_type']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Brand : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${serviceContent['electronic_brand']}"),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Price : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text("$lowestPrice"),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(),
                                      ],
                                    ),
                                  ),
                                  // closed

                                  // Common fields
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Contact information : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "${serviceContent['contact_info']}"),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text(
                                              "Deposits and security : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "${serviceContent['deposits']}"),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text(
                                              "Documents required : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                "${serviceContent['doc_required']}"),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text(
                                              "Additional info : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Flexible(
                                              child: Text(
                                                  "${serviceContent['additional_info']}"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text(
                                              "Safety guidelines : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${serviceContent['safety']}")),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text(
                                              "Terms and conditions : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${serviceContent['t_and_c']}")),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // closed
                                ],
                              ),
                            )),

                            dashboard != null
                                ? Container(
                                    margin: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Renter Information : ",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            CircleAvatar(
                                              radius: 50, // Image radius
                                              backgroundImage: NetworkImage(
                                                  dashboard['image']),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Name : ${dashboard['renter']['contact_person_name']}",
                                                  textAlign: TextAlign.left,
                                                ),
                                                Text(
                                                    "Description : ${dashboard['renter']['renter_type']}"),
                                                Text(
                                                  "Per day rate : ${dashboard['price'].toString()}",
                                                  textAlign: TextAlign.left,
                                                ),
                                                Text(
                                                  "Reviews count: ${dashboard['reviews'].toString()}",
                                                  textAlign: TextAlign.left,
                                                ),
                                                Text(
                                                  "Overall Rating: ${dashboard['reviews'].toString()}",
                                                  textAlign: TextAlign.left,
                                                ),
                                                // Text(
                                                //   "Available on: ${dashboard['availability']['date'].toString()}",textAlign: TextAlign.left,
                                                // ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(),

                            // closed

                            GetBuilder<ServiceTabController>(
                                initState: (state) {
                              Get.find<ServiceTabController>().getServiceReview(
                                  serviceController.service!.id!, 1);
                            }, builder: (controller) {
                              if (controller.reviewList != null) {
                                return SingleChildScrollView(
                                  child: ServiceDetailsReview(
                                    serviceID: serviceController.service!.id!,
                                    reviewList: controller.reviewList!,
                                    rating: controller.rating,
                                  ),
                                );
                              } else {
                                return const EmptyReviewWidget();
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return NoDataScreen(
                    text: 'no_service_available'.tr,
                    type: NoDataType.service,
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;
  const ImageDetailScreen({super.key, required this.imageUrl});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: GestureDetector(
  //       onTap: () {
  //         Navigator.pop(context);
  //       },
  //       child: Center(
  //         child: Hero(
  //           tag: 'imageHero',
  //           child: InteractiveViewer(
  //             child: Image.network(
  //               imageUrl,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: InteractiveViewer(
        child: Image.network(
          imageUrl,
        ),
      ),
    );
  }
}
