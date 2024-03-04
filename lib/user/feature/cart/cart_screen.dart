import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:mstoo/user/components/web_shadow_wrap.dart';
import 'package:mstoo/user/feature/cart/widget/available_provider_widgets.dart';
import 'package:mstoo/user/feature/cart/widget/selected_provider_widget.dart';
import 'package:mstoo/user/feature/cart/widget/unselected_provider_widget.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/feature/cart/widget/cart_product_widget.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  void initState() {
    super.initState();
    if(Get.find<AuthController>().isLoggedIn()){
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      appBar: CustomAppBar(
        title: 'cart'.tr,
        isBackButtonExist: (ResponsiveHelper.isDesktop(context) || !widget.fromNav),
        onBackPressed: (){
            if(Navigator.canPop(context)){
              Get.back();
            }else{
              Get.offAllNamed(RouteHelper.getMainRoute("home"));
            }
        },
      ),
      body: SafeArea(
        child: GetBuilder<CartController>(
          initState: (state) async {
            if(Get.find<AuthController>().isLoggedIn()){
              await Get.find<CartController>().getCartListFromServer();
              Get.find<CartController>().cartList.forEach((cart) async {
                if (cart.service == null) {
                  await Get.find<CartController>().removeCartFromServer(cart.id);
                }
              });
            }
          },
          builder: (cartController){
            return Column(
              children: [
                Expanded(
                  child: FooterBaseView(
                    isCenter: (cartController.cartList.isEmpty),
                    child: WebShadowWrap(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: GetBuilder<CartController>(
                          builder: (cartController) {

                            if (cartController.isLoading) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height*0.85,
                                  child: const Center(child: CustomLoader())
                              );
                            } else {
                              if (cartController.cartList.isNotEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${cartController.cartList.length} ${'services_in_cart'.tr}",
                                                  style: ubuntuMedium.copyWith(fontSize: Dimensions.fontSizeDefault,),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GridView.builder(
                                            key: UniqueKey(),
                                            gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: Dimensions.paddingSizeLarge,
                                              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ?
                                              Dimensions.paddingSizeLarge :
                                              Dimensions.paddingSizeMini,
                                              childAspectRatio: ResponsiveHelper.isMobile(context) ?  5 : 6 ,
                                              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 :cartController.cartList.length > 1 ? 2:1,
                                              mainAxisExtent:ResponsiveHelper.isMobile(context) ? 115 : 125,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: cartController.cartList.length,
                                            itemBuilder: (context, index) {
                                              return cartController.cartList[index].service != null
                                                  ? CartServiceWidget(cart: cartController.cartList[index], cartIndex: index)
                                                  : const SizedBox();
                                            },
                                          ),
                                          const SizedBox(height: Dimensions.paddingSizeSmall),
                                        ]),
                                    if(ResponsiveHelper.isWeb() && !ResponsiveHelper.isTab(context) && !ResponsiveHelper.isMobile(context))
                                      cartController.cartList.isNotEmpty ?
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,),
                                        child: Column(
                                          children: [
                                          const Divider(),
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Row(mainAxisAlignment: MainAxisAlignment.center,children:[

                                                Text('${"total_price".tr} ',
                                                  style: ubuntuRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeLarge,
                                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                                  ),
                                                ),
                                                Directionality(
                                                  textDirection: TextDirection.ltr,
                                                  child: Text(PriceConverter.convertPrice(Get.find<CartController>().totalPrice),
                                                    style: ubuntuBold.copyWith(
                                                      color: Theme.of(context).colorScheme.error,
                                                      fontSize: Dimensions.fontSizeLarge,
                                                    ),
                                                  ),
                                                )]),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if(Get.find<SplashController>().configModel.content?.directProviderBooking==1)
                                              cartController.preSelectedProvider?
                                              GestureDetector(
                                                onTap: (){
                                                  showModalBottomSheet(
                                                      useRootNavigator: true,
                                                      isScrollControlled: true,
                                                      backgroundColor: Colors.transparent,
                                                      context: context, builder: (context) => const AvailableProviderWidget()
                                                  );
                                                },
                                                child: const SelectedProductWidget(),
                                              ): GestureDetector(
                                                onTap: (){
                                                  showModalBottomSheet(
                                                      useRootNavigator: true,
                                                      isScrollControlled: true,
                                                      backgroundColor: Colors.transparent,
                                                      context: context, builder: (context) => const AvailableProviderWidget()
                                                  );
                                                },
                                                child: const UnselectedProductWidget(),
                                              ),
                                              if(Get.find<SplashController>().configModel.content?.directProviderBooking==1)
                                              const SizedBox(width: Dimensions.paddingSizeSmall,),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: Dimensions.paddingSizeSmall,
                                                  ),
                                                  child: CustomButton(
                                                    height: 50,
                                                    width: Get.width,
                                                    radius: Dimensions.radiusDefault,
                                                    buttonText: 'proceed_to_checkout'.tr,
                                                    onPressed: () {
                                                      if (Get.find<AuthController>().isLoggedIn()) {
                                                        Get.find<CheckOutController>().updateState(PageState.orderDetails);
                                                        Get.toNamed(RouteHelper.getCheckoutRoute(RouteHelper.checkout,'orderDetails','null'));

                                                      } else {
                                                        Get.toNamed(RouteHelper.getNotLoggedScreen(RouteHelper.cart,"cart"));
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        ),
                                      ):
                                      const SizedBox(),
                                  ],
                                );
                              } else {
                                return NoDataScreen(
                                  text: "cart_is_empty".tr,
                                  type: NoDataType.cart,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if((ResponsiveHelper.isTab(context) || ResponsiveHelper.isMobile(context))&& cartController.cartList.isNotEmpty )
                Column(children: [
                  Divider(height: 2,color: Theme.of(context).shadowColor,),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor,),
                    child: Center(
                      child:Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('total_price'.tr,
                            style: ubuntuRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.6),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(' ${PriceConverter.convertPrice(cartController.totalPrice,isShowLongPrice: true)} ',
                              style: ubuntuBold.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      children: [

                        // if(Get.find<SplashController>().configModel.content?.directProviderBooking==1)
                        // cartController.preSelectedProvider?
                        // GestureDetector(
                        //   onTap: (){
                        //     showModalBottomSheet(
                        //         useRootNavigator: true,
                        //         isScrollControlled: true,
                        //         backgroundColor: Colors.transparent,
                        //         context: context, builder: (context) => const AvailableProviderWidget()
                        //     );
                        //   },
                        //   child: const SelectedProductWidget(),
                        // ): GestureDetector(
                        //   onTap: (){
                        //     showModalBottomSheet(
                        //         useRootNavigator: true,
                        //         isScrollControlled: true,
                        //         backgroundColor: Colors.transparent,
                        //         context: context, builder: (context) => const AvailableProviderWidget()
                        //     );
                        //   },
                        //   child: const UnselectedProductWidget(),
                        // ),
                        if(Get.find<SplashController>().configModel.content?.directProviderBooking==1)
                        const SizedBox(width: Dimensions.paddingSizeEight,),


                        Expanded(
                          child: CustomButton(
                            width: Get.width,
                            height:  ResponsiveHelper.isDesktop(context)? 50 : 45,
                            radius: Dimensions.radiusDefault,
                            buttonText: 'proceed_to_checkout'.tr,
                            onPressed: () {
                              if (Get.find<AuthController>().isLoggedIn()) {
                                Get.find<CheckOutController>().updateState(PageState.orderDetails);
                                Get.toNamed(RouteHelper.getCheckoutRoute('cart','orderDetails','null'));
                              } else {
                                Get.toNamed(RouteHelper.getNotLoggedScreen(RouteHelper.cart,"cart"));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                )
              ],
            );
          },
        ),
      ),
      // bottomSheet: FooterView(),
    );
  }
}
