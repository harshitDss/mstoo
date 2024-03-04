import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:mstoo/user/components/text_hover.dart';
import 'package:mstoo/user/feature/home/widget/feathered_category_view.dart';
import 'package:mstoo/user/feature/home/widget/home_create_post_view.dart';
import 'package:mstoo/user/feature/provider/controller/provider_booking_controller.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/components/paginated_list_view.dart';
import 'package:mstoo/user/components/service_view_vertical.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/feature/home/widget/category_view.dart';
import 'package:mstoo/user/feature/home/widget/random_campaign_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../profile/service/add.dart';
import 'service_filter.dart';
import 'web_home_screen.dart';

import 'dart:developer';

class HomeScreen extends StatefulWidget {
  static Future<void> loadData(bool reload) async {
    Get.find<BannerController>().getBannerList(reload);
    Get.find<CategoryController>().getCategoryList(1, reload);
    Get.find<ServiceController>().getPopularServiceList(1, reload);
    Get.find<ServiceController>().getTrendingServiceList(1, reload);
    Get.find<ProviderBookingController>().getProviderList(1, reload);
    Get.find<CampaignController>().getCampaignList(reload);
    Get.find<ServiceController>().getRecommendedServiceList(1, reload);
    Get.find<ServiceController>().getAllServiceList(1, reload);
 SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('demand_token');

                          (token != null )?
    Get.find<UserController>().getUserInfo(): [];

    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<ServiceController>().getRecentlyViewedServiceList(1, reload);
    }
    Get.find<ServiceController>().getFeatherCategoryList(reload);
  }

  HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  
  @override
  void initState() {
    super.initState();
    HomeScreen.loadData(false);
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<LocationController>().getAddressList();
    }
  }

  homeAppBar() {
    if (ResponsiveHelper.isDesktop(context)) {
      return const WebMenuBar();
    } else {
      return const AddressAppBar(backButton: false);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    bool isUserLoggedIn = Get.find<AuthController>().isLoggedIn();
    GlobalKey<ScaffoldState> _key = GlobalKey(); // add this
    String? baseUrl =
        Get.find<SplashController>().configModel.content!.imageBaseUrl;
       

   
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor:  Theme.of(context).primaryColor,
        title: Column(
          children: [
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.getAccessLocationRoute('address'));
              },
              child:
                  GetBuilder<LocationController>(builder: (locationController) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          log(prefs.getString('demand_token').toString());
                          var address =
                              locationController.getUserAddress()!.address;
                          print(address!.substring(13, address.indexOf(',')));
                          // log();
                        },
                        icon: Icon(Icons.location_on)),
                    if (locationController.getUserAddress() != null)
                      Flexible(
                        child: Text(
                          locationController.getUserAddress()!.address!,
                          style: ubuntuRegular.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeSmall),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 12),
                  ],
                );
              }),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // InkWell(
          //     hoverColor: Colors.transparent,
          //     onTap: () {
          //       Get.toNamed(RouteHelper.getCartRoute());
          //     },
          //     child: const Icon(Icons.shopping_cart,
          //         size: 25, color: Colors.white)),

          InkWell(
              hoverColor: Colors.transparent,
              onTap: () => Get.to(ServiceFilter()),
              child: const Icon(Icons.tune,
                  size: 25, color: Colors.white)),

          const SizedBox(width: 10),
          InkWell(
              hoverColor: Colors.transparent,
              onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
              child: const Icon(Icons.notifications,
                  size: 25, color: Colors.white)),

          

        ],
      ),
      //  floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Colors.yellow,
      //   onPressed: () {
      //       if (!isUserLoggedIn) {
      //                 Get.toNamed(
      //                     RouteHelper.getNotLoggedScreen("booking","my_bookings"));
      //               } else {
      //                 Get.to(AddService());
      //       }
      //   },
      //   label: const Text('Create Service'),
      //   icon: const Icon(Icons.add),
      // ),
      key: _key, // set it here
      // endDrawer: buildProfileDrawer(),
      drawer:  ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Drawer (
          child: ListView(
            children: <Widget> [
              // UserAccountsDrawerHeader(
              //   accountName: Text(
              //     // "Naresh"
              //     "Naresh",
              //   ),
              //   accountEmail: Text("naresh@design-street.com"),
              //   currentAccountPicture: CircleAvatar(
              //     backgroundImage: NetworkImage(
              //         "https://yt3.ggpht.com/yti/AJo0G0nD38ScwxafnOfkFhUktf_75xVGsl8wyO2hGwhq=s108-c-k-c0x00ffffff-no-rj"),
              //   ),
              // ),

    isUserLoggedIn?
              GetBuilder<UserController>(builder: (userController)  {
                return Container(
                  height: 200,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Image.network("https://yt3.ggpht.com/yti/AJo0G0nD38ScwxafnOfkFhUktf_75xVGsl8wyO2hGwhq=s108-c-k-c0x00ffffff-no-rj"),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            "${Get.find<SplashController>().configModel.content!.imageBaseUrl!}/user/profile_image/${userController.userInfoModel.image!}"),
                        radius: 50,
                      ),
                      Text(
                        userController.fName,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(userController.email,
                          style: TextStyle(color: Colors.white)),
                      Text(userController.phone,
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }): GetBuilder<UserController>(builder: (userController)  {
                return Container(
                  height: 200,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                     
                      CircleAvatar(
                       backgroundImage: NetworkImage('https://ohsobserver.com/wp-content/uploads/2022/12/Guest-user.png'),
                        radius: 50,
                      ),
                      Text(
                       'Guest'
                    ,
                          style: TextStyle(color: Colors.white)),
                      
                    ],
                  ),
                );}),
            
              ListTile(
                title: const Text("Profile"),
                leading: const Icon(Icons.person), //add icon

                onTap: () {
                  Navigator.pushNamed(context, RouteHelper.getProfileRoute());
                },
              ),
              ListTile(
                title: const Text("Settings"),
                leading: const Icon(Icons.settings), //add icon
                onTap: () {
                  Navigator.pushNamed(context, RouteHelper.getSettingRoute());
                },
              ),
              ListTile(
                title: const Text("About Us"),
                leading: const Icon(Icons.account_box_outlined), //add icon
                // childrenPadding: EdgeInsets.only(left: 60), //children padding
                onTap: () {
                  Navigator.pushNamed(
                      context, RouteHelper.getHtmlRoute('about_us'));
                },
              ),
              ListTile(
                title: const Text("Terms & Conditions"),
                leading: const Icon(Icons.support), //add icon
                onTap: () {
                  Navigator.pushNamed(
                      context, RouteHelper.getHtmlRoute('terms-and-condition'));
                },
              ),
              ListTile(
                title: const Text("Privacy Policy"),
                leading: const Icon(Icons.policy),
                onTap: () {
                  Navigator.pushNamed(
                      context, RouteHelper.getHtmlRoute('privacy-policy'));
                },
              ),
              ListTile(
                title: const Text("Help & Support"),
                leading: const Icon(Icons.support_agent),
                onTap: () {
                  Navigator.pushNamed(context, RouteHelper.getSupportRoute());
                },
              ),
              isUserLoggedIn?
              ListTile(
                title: const Text("Logout"),
                leading: const Icon(Icons.logout), //add icon
                onTap: () {
                  // Get.find<AuthController>().clearSharedData();
                  // Get.find<CartController>().clearCartList();
                  // Get.find<AuthController>().googleLogout();
                  // Get.find<AuthController>().signOutWithFacebook();

                  // Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                   if(
                            Get.find<AuthController>().isLoggedIn()) {
                              Get.dialog(ConfirmationDialog(
                                  icon: Images.logoutIcon, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: ()async {
                                Get.find<AuthController>().clearSharedData();
                                Get.find<CartController>().clearCartList();
                                Get.find<AuthController>().googleLogout();
                                Get.find<AuthController>().signOutWithFacebook();
                                Get.find<AuthController>().signOutWithFacebook();
                                // await FacebookAuth.instance.logOut();
                                Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                              }), useSafeArea: false);
                            }else {
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                            }
                },
              ): ListTile(
                title: const Text("SignIn"),
                leading: const Icon(Icons.login), //add icon
                onTap: () {
                  Get.find<AuthController>().clearSharedData();
                  Get.find<CartController>().clearCartList();
                  Get.find<AuthController>().googleLogout();
                  Get.find<AuthController>().signOutWithFacebook();

                  Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                },
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                  child: Text(
                "${'app_version'.tr} ${AppConstants.appVersion}",
                style: ubuntuMedium.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(.5)),
              )),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 70.0,
        height: 70.0,
        child: FloatingActionButton(
          onPressed: () {
            if (!isUserLoggedIn) {
              Get.toNamed(
                  RouteHelper.getNotLoggedScreen("booking", "my_bookings"));
            } else {
              Get.to(const AddService());
            }
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),

      // endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      body: ResponsiveHelper.isDesktop(context)
          ? WebHomeScreen(scrollController: scrollController)
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  Get.find<ProviderBookingController>()
                      .resetProviderFilterData();
                  await Get.find<BannerController>().getBannerList(true);
                  await Get.find<CategoryController>().getCategoryList(1, true);
                  await Get.find<ServiceController>()
                      .getRecommendedServiceList(1, true);
                  await Get.find<ProviderBookingController>()
                      .getProviderList(1, true);
                  await Get.find<ServiceController>().getPopularServiceList(
                    1,
                    true,
                  );
                  await Get.find<ServiceController>()
                      .getRecentlyViewedServiceList(
                    1,
                    true,
                  );
                  await Get.find<ServiceController>().getTrendingServiceList(
                    1,
                    true,
                  );
                  await Get.find<CampaignController>().getCampaignList(true);
                  await Get.find<ServiceController>()
                      .getFeatherCategoryList(true);
                  await Get.find<ServiceController>()
                      .getAllServiceList(1, true);
                  await Get.find<CartController>().getCartListFromServer();
                },
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: GetBuilder<ServiceController>(
                      builder: (serviceController) {
                    return CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // const SliverToBoxAdapter(
                        //     child:
                        //         SizedBox(height: Dimensions.paddingSizeSmall)),
                        // SliverPersistentHeader(
                        //   pinned: true,
                        //   delegate: SliverDelegate(
                        //     extentSize: 55,
                        //     child: InkWell(
                        //       onTap: () => Get.toNamed(
                        //           RouteHelper.getSearchResultRoute()),
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //           left: Dimensions.paddingSizeDefault,
                        //           right: Dimensions.paddingSizeDefault,
                        //           top: Dimensions.paddingSizeExtraSmall,
                        //         ),
                        //         child: Container(
                        //           padding: const EdgeInsets.only(
                        //               left: Dimensions.paddingSizeDefault,
                        //               right: Dimensions.paddingSizeExtraSmall),
                        //           alignment: Alignment.center,
                        //           decoration: BoxDecoration(
                        //               // border:Get.isDarkMode ? Border.all(color: Colors.grey.shade700):null,
                        //               boxShadow: Get.isDarkMode
                        //                   ? null
                        //                   : [
                        //                       BoxShadow(
                        //                           color: Theme.of(context)
                        //                               .shadowColor,
                        //                           blurRadius: 5,
                        //                           spreadRadius: 1)
                        //                     ],
                        //               borderRadius: BorderRadius.circular(22),
                        //               color: Theme.of(context).cardColor),
                        //           child: Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text('search_services'.tr,
                        //                     style: ubuntuRegular.copyWith(
                        //                         color: Theme.of(context)
                        //                             .hintColor)),
                        //                 Padding(
                        //                   padding: const EdgeInsets.only(
                        //                       right:
                        //                           Dimensions.paddingSizeEight),
                        //                   child: Container(
                        //                     height: 35,
                        //                     width: 35,
                        //                     decoration: BoxDecoration(
                        //                       color: Theme.of(context)
                        //                           .colorScheme
                        //                           .primary,
                        //                       borderRadius: const BorderRadius
                        //                               .all(
                        //                           Radius.circular(Dimensions
                        //                               .paddingSizeExtraLarge)),
                        //                     ),
                        //                     // child: Image.asset(Images.searchButton),
                        //                     child: Icon(
                        //                       Icons.search_rounded,
                        //                       color: Theme.of(context)
                        //                           .primaryColorLight,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ]),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SliverToBoxAdapter(
                          child: Center(
                              child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Column(children: [
                                    // Search banner custom added

                                    Stack(
                                      children: [
                                        CustomImage(
                                          image:
                                              '$baseUrl/banner/search_banner.png',
                                          fit: BoxFit.cover,
                                          placeholder: Images.placeholder,
                                        ),
                                        Positioned(
                                          bottom: 30,
                                          right: 5,
                                          left: 10,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: const EdgeInsets.only(
                                                  left: Dimensions
                                                      .paddingSizeDefault,
                                                  right: Dimensions
                                                      .paddingSizeExtraSmall),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  boxShadow: Get.isDarkMode
                                                      ? null
                                                      : [
                                                          BoxShadow(
                                                              color: Theme.of(
                                                                      context)
                                                                  .shadowColor,
                                                              blurRadius: 5,
                                                              spreadRadius: 1)
                                                        ],
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                  color: Theme.of(context)
                                                      .cardColor),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: InkWell(
                                                  onTap: () => Get.toNamed(
                                  RouteHelper.getSearchResultRoute()),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text('search_services'.tr,
                                                            style: ubuntuRegular
                                                                .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor)),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                                  .only(
                                                              right: Dimensions
                                                                  .paddingSizeEight),
                                                          child: Container(
                                                            height: 35,
                                                            width: 35,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              borderRadius: const BorderRadius
                                                                      .all(
                                                                  Radius.circular(
                                                                      Dimensions
                                                                          .paddingSizeExtraLarge)),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .search_rounded,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorLight,
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const BannerView(),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeDefault),
                                      child: CategoryView(),
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    const RandomCampaignView(),

                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    // const RecommendedServiceView(),

                                    if (Get.find<SplashController>()
                                            .configModel
                                            .content
                                            ?.directProviderBooking ==
                                        1)
                                      // const HomeRecommendProvider(),

                                      if (Get.find<SplashController>()
                                              .configModel
                                              .content!
                                              .biddingStatus ==
                                          1)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .paddingSizeDefault),
                                          child: HomeCreatePostView(),
                                        ),

                                    // HorizontalScrollServiceView(fromPage: 'popular_services',serviceList: serviceController.popularServiceList),
                                    if (Get.find<AuthController>().isLoggedIn())
                                      // HorizontalScrollServiceView(fromPage: 'recently_view_services',serviceList: serviceController.recentlyViewServiceList),
                                      //CampaignView(),
                                      HorizontalScrollServiceView(
                                          fromPage: 'trending_services',
                                          serviceList: serviceController
                                              .trendingServiceList),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    const FeatheredCategoryView(),

                                    (ResponsiveHelper.isMobile(context) ||
                                            ResponsiveHelper.isTab(context))
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              Dimensions.paddingSizeDefault,
                                              15,
                                              Dimensions.paddingSizeDefault,
                                              Dimensions.paddingSizeSmall,
                                            ),
                                            child: TitleWidget(
                                              title: 'all_service'.tr,
                                              onTap: () => Get.toNamed(
                                                  RouteHelper
                                                      .allServiceScreenRoute(
                                                          "all_service")),
                                            ),
                                          )
                                        : const SizedBox.shrink(),

                                    PaginatedListView(
                                      scrollController: scrollController,
                                      totalSize:
                                          serviceController.serviceContent !=
                                                  null
                                              ? serviceController
                                                  .serviceContent!.total!
                                              : null,
                                      offset:
                                          serviceController.serviceContent !=
                                                  null
                                              ? serviceController
                                                          .serviceContent!
                                                          .currentPage !=
                                                      null
                                                  ? serviceController
                                                      .serviceContent!
                                                      .currentPage!
                                                  : null
                                              : null,
                                      onPaginate: (int offset) async =>
                                          await serviceController
                                              .getAllServiceList(offset, false),
                                      showBottomSheet: true,
                                      itemView: ServiceViewVertical(
                                        service:
                                            serviceController.serviceContent !=
                                                    null
                                                ? serviceController.allService
                                                : null,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveHelper
                                                  .isDesktop(context)
                                              ? Dimensions.paddingSizeExtraSmall
                                              : Dimensions.paddingSizeDefault,
                                          vertical: ResponsiveHelper.isDesktop(
                                                  context)
                                              ? Dimensions.paddingSizeExtraSmall
                                              : 0,
                                        ),
                                        type: 'others',
                                        noDataType: NoDataType.home,
                                      ),
                                    ),
                                  ]))),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget? child;
  double? extentSize;

  SliverDelegate({@required this.child, @required this.extentSize});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child!;
  }

  @override
  double get maxExtent => extentSize!;

  @override
  double get minExtent => extentSize!;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != maxExtent ||
        child != oldDelegate.child;
  }
}

class FooterButton extends StatelessWidget {
  final String title;
  final String route;
  final bool url;
  const FooterButton(
      {super.key, required this.title, required this.route, this.url = false});

  @override
  Widget build(BuildContext context) {
    return TextHover(builder: (hovered) {
      return InkWell(
        hoverColor: Colors.transparent,
        onTap: route.isNotEmpty
            ? () async {
                if (url) {
                  if (await canLaunchUrlString(route)) {
                    launchUrlString(route,
                        mode: LaunchMode.externalApplication);
                  }
                } else {
                  Get.toNamed(route);
                }
              }
            : null,
        child: Text(title,
            style: hovered
                ? ubuntuMedium.copyWith(
                    color: Theme.of(context).colorScheme.error, fontSize: 100)
                : ubuntuRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.fontSizeExtraSmall)),
      );
    });
  }
}
