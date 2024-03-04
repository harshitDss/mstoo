import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';

class AddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  const AddressAppBar({super.key, this.backButton = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Get.isDarkMode
          ? Theme.of(context).cardColor.withOpacity(.2)
          : Theme.of(context).primaryColor,
      shape: Border(
          bottom: BorderSide(
              width: .4,
              color: Theme.of(context).primaryColorLight.withOpacity(.2))),
      elevation: 0,
      leadingWidth: backButton! ? Dimensions.paddingSizeLarge : 0,
      leading: backButton!
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).cardColor,
              onPressed: () => Navigator.pop(context),
            )
          : const SizedBox(),
      title: Row(children: [
        Expanded(
          child: InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              Get.toNamed(RouteHelper.getAccessLocationRoute('address'));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('services_in'.tr,
                Text("Location",
                    style: ubuntuRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraSmall)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeSmall
                        : 0,
                  ),
                  child: GetBuilder<LocationController>(
                      builder: (locationController) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
              // children: [
              // Image.network("https://mstooapp.design-street.com.au/storage/app/public/business/2023-08-17-64ddb38a0d8ed.png", width: 50,)
              // Image.asset("assets/images/logo.png", width: 50),
              // ],
            ),
          ),
        ),
        InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
                Get.toNamed(RouteHelper.getCartRoute());
            },
            child:
                const Icon(Icons.shopping_cart, size: 25, color: Colors.white)),
        SizedBox(width: 10),
        InkWell(
            hoverColor: Colors.transparent,
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            child:
                const Icon(Icons.notifications, size: 25, color: Colors.white)),
      ]),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            //  color: Get.isDarkMode?Theme.of(context).colorScheme.background:Theme.of(context).primaryColor,
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColor,
                ]),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 5,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              )
            ]),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 70 : 56);
}
