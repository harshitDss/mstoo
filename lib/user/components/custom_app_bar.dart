import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isBackButtonExist;
  final Function()? onBackPressed;
  final bool? showCart;
  final bool? centerTitle;
  final Color? bgColor;
  final Widget? actionWidget;
  const CustomAppBar({super.key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.showCart = false,this.centerTitle = true,this.bgColor, this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
      // title: Text(title!, style: ubuntuMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color:  Theme.of(context).primaryColorLight),),
      title: Text(title!, style: ubuntuMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color:  Colors.white),),

      flexibleSpace: Container(
         decoration: BoxDecoration(
            //  color: Get.isDarkMode?Theme.of(context).colorScheme.background:Theme.of(context).primaryColor,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorLight,
              ]
              ),
             boxShadow:[
               BoxShadow(
                 offset: Offset(0, 1),
                 blurRadius: 5,
                 color: Theme.of(context).primaryColor.withOpacity(0.5),
               )]
            ),  
     ),     
      centerTitle: centerTitle,
      leading: isBackButtonExist! ? IconButton(

        hoverColor:Colors.transparent,
        // icon: Icon(Icons.arrow_back_ios,color:Theme.of(context).primaryColorLight),
        icon: Icon(Icons.arrow_back_ios,color:Colors.white),
        // color: Theme.of(context).textTheme.bodyLarge!.color,
        color: Colors.white,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : const SizedBox(),
      // backgroundColor:Get.isDarkMode ? Theme.of(context).cardColor.withOpacity(.2):Theme.of(context).primaryColor,
      backgroundColor:Get.isDarkMode ? Theme.of(context).cardColor.withOpacity(.2):Colors.transparent,
      shape: Border(bottom: BorderSide(
          width: .4,
          color: Theme.of(context).primaryColorLight.withOpacity(.2))),
      elevation: 0,
      actions: showCart! ? [
        IconButton(onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
          icon:  CartWidget(
              color: Get.isDarkMode
                  ? Theme.of(context).primaryColorLight
                  : Colors.white,
              size: Dimensions.cartWidgetSize),
        )]:actionWidget!=null?[actionWidget!]: null,
    );
  }
  @override
  Size get preferredSize => Size(Dimensions.webMaxWidth, ResponsiveHelper.isDesktop(Get.context) ? Dimensions.preferredSizeWhenDesktop : Dimensions.preferredSize );
}