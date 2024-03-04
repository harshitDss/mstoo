import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:mstoo/user/components/web_shadow_wrap.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';

class OrderSuccessfulScreen extends StatelessWidget {
  final int? status;

  const OrderSuccessfulScreen({Key? key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      body: FooterBaseView(
        isCenter: true,
        child: WebShadowWrap(
          child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            Image.asset(status == 1 ? Images.successIcon : Images.warning, width: 100, height: 100),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(status == 1 ? 'you_placed_the_booking_successfully'.tr : 'your_bookings_is_failed_to_place'.tr, style: ubuntuMedium.copyWith(fontSize: Dimensions.fontSizeLarge),),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
              child: Text(
                status == 1 ? 'your_order_is_placed_successfully'.tr : 'you_can_try_again_later'.tr,
                style: ubuntuMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // buy from us forums
            const Row(
              children: <Widget>[
                 Flexible(
                    child:  Text("Customers choose to buy from specific businesses for a variety of reasons. ")),
                    Text("Product or Service Quality: Customers often prioritize quality. If your products or services are of high quality and meet their needs, they are more likely to buy from you."),
                    Text("Price: Competitive pricing can be a significant factor. Customers often seek the best value for their money, so offering reasonable prices or discounts can attract them."),
                    Text("Brand Reputation: A strong and trustworthy brand reputation can be a key reason customers choose to buy from you. Positive reviews, testimonials, and a history of reliable products or services can build trust.")
                     ],
             ),
             // closed

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(buttonText: 'back_to_home'.tr, width: Dimensions.webMaxWidth/5, onPressed: () {
                Get.offAllNamed(RouteHelper.getMainRoute("home"));
              }),
            ),
          ]))),
        ),
      ),
    );
  }
}
