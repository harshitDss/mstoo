import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/components/web_shadow_wrap.dart';
import 'package:mstoo/user/feature/profile/model/profile_cart_item_model.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/feature/profile/service/liked.dart';
import '../../booking_request/view/booking_screen.dart';
import '../service/add.dart';
import '../service/all.dart';

class ProfileScreen extends GetView<UserController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final profileCartModelList = [
      ProfileCardItemModel(
        'my_address'.tr, Images.address,Get.find<AuthController>().isLoggedIn() ?
      RouteHelper.getAddressRoute('fromProfileScreen') : RouteHelper.getNotLoggedScreen(RouteHelper.profile,"profile"),
      ),
      ProfileCardItemModel(
        'notifications'.tr, Images.notification, RouteHelper.getNotificationRoute(),
      ),
      if(!Get.find<AuthController>().isLoggedIn() )
      ProfileCardItemModel(
        'sign_in'.tr, Images.logout, RouteHelper.getSignInRoute(RouteHelper.profile),
      ),

      // if(Get.find<AuthController>().isLoggedIn() && Get.find<UserController>().referCode!="" && Get.find<SplashController>().configModel.content?.referEarnStatus==1)
      //   ProfileCardItemModel(
      //     'refer_and_earn'.tr, Images.shareIcon, RouteHelper.getReferAndEarnScreen(),
      //   ),

      // if(Get.find<AuthController>().isLoggedIn() )
      //   ProfileCardItemModel(
      //     'suggest_new_service'.tr, Images.suggestServiceIcon,RouteHelper.getNewSuggestedServiceScreen() ,
      //   ),

      // if(Get.find<AuthController>().isLoggedIn() )
      //   ProfileCardItemModel(
      //     'delete_account'.tr, Images.accountDelete, 'delete_account',
      //   ),

      if(Get.find<AuthController>().isLoggedIn() )
        ProfileCardItemModel(
        'logout'.tr, Images.logout, 'sign_out',
      ),

    ];
  bool isUserLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      appBar: CustomAppBar(
        title: 'profile'.tr,
        centerTitle: true,
        bgColor: Theme.of(context).primaryColor,
        isBackButtonExist: true,
        onBackPressed: (){
          if(Navigator.canPop(context)){
            Get.back();
          }else{
            Get.offAllNamed(RouteHelper.getMainRoute("home"));
          }
        },
      ),

      body: GetBuilder<UserController>(
        initState: (state){
          if(isLoggedIn){
            Get.find<UserController>().getUserInfo();
          }
        },

        builder: (userController) {
          return userController.isLoading ?
          const Center(child: CircularProgressIndicator()) :
          FooterBaseView(
            child: WebShadowWrap(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfileHeader(userInfoModel: userController.userInfoModel,),
                  const SizedBox(height: Dimensions.paddingSizeLarge),


                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                    child: GestureDetector(
                       
                         onTap: () { if (!isUserLoggedIn){ Get.toNamed(
                                          RouteHelper.getNotLoggedScreen(
                                              " my service", "My Service "));}else{Get.to(AllServices());}},
                        child: ProfileCardItem(title: "My Services", leadingIcon: Images.suggestServiceIcon,)
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                    child: GestureDetector(
                        onTap: () { if (!isUserLoggedIn){ Get.toNamed(
                                          RouteHelper.getNotLoggedScreen(
                                              "add new service", "Add New Service "));}else{Get.to(AddService());}},
                        
                        child: ProfileCardItem(title: "Add New Service", leadingIcon: Images.suggestServiceIcon,)
                    ),
                  ),


                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                    child: GestureDetector(
                       
                           onTap: () { if (!isUserLoggedIn){ Get.toNamed(
                                          RouteHelper.getNotLoggedScreen(
                                              "my bookings", "My Bookings "));}else{ Get.to(BookingRequestScreen());}},
                        child: ProfileCardItem(title: "My Bookings", leadingIcon: Images.suggestServiceIcon,)
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                    child: GestureDetector(
                        onTap: () => Get.to(AllLikedServices()),
                        child: ProfileCardItem(title: "Saved Services", leadingIcon: Images.suggestServiceIcon,)
                    ),
                  ),
                  
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                      childAspectRatio: 6,
                      crossAxisSpacing: Dimensions.paddingSizeExtraLarge,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                    ),
                    itemCount: profileCartModelList.length,
                    itemBuilder: (context, index) {
                      return ProfileCardItem(
                        title: profileCartModelList[index].title,
                        leadingIcon: profileCartModelList[index].loadingIcon,
                        onTap: () {
                          if(profileCartModelList[index].routeName == 'sign_out'){
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
                          }else if(profileCartModelList[index].routeName == 'delete_account'){
                            Get.dialog(
                                ConfirmationDialog(
                                    icon: Images.deleteProfile,
                                    title: 'are_you_sure_to_delete_your_account'.tr,
                                    description: 'it_will_remove_your_all_information'.tr,
                                    isLogOut: true,
                                    yesText: 'delete',
                                    noText: 'cancel',
                                    descriptionTextColor: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5),
                                    onYesPressed: () => userController.removeUser()),
                                useSafeArea: false
                            );
                          }
                          else{
                            Get.toNamed(profileCartModelList[index].routeName);
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height:Dimensions.paddingSizeDefault,)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

