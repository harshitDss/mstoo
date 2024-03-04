import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:mstoo/user/components/paginated_list_view.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/feature/booking_request/model/service_booking_model.dart';
import 'package:mstoo/user/feature/booking_request/widget/booking_item_card.dart';
import 'package:mstoo/user/feature/booking_request/widget/booking_screen_shimmer.dart';
import 'package:mstoo/user/feature/booking_request/widget/booking_status_tabs.dart';

import '../controller/service_booking_controller.dart';

class BookingRequestScreen extends StatefulWidget {
  final bool isFromMenu;
  const BookingRequestScreen({Key? key, this.isFromMenu = false}) : super(key: key);

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  @override
  void initState() {
    // Get.find<ServiceBookingController>().getAllBookingService(offset: 1,bookingStatus: "all",isFromPagination:false);
    // Get.find<ServiceBookingController>().getAllBookingService(offset: 1,bookingStatus: "accepted",isFromPagination:false);
    Get.find<ServiceRequestBookingController>().getAllBookingRequest(offset: 1,bookingStatus: "all",isFromPagination:false);

    // Get.find<ServiceBookingController>().updateBookingStatusTabs(BookingStatusTabs.all, firstTimeCall: false);
    Get.find<ServiceRequestBookingController>().updateBookingStatusTabs(BookingRequestStatusTabs.all, firstTimeCall: true);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final ScrollController bookingScreenScrollController = ScrollController();

    return Scaffold(
        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        appBar: CustomAppBar(
            isBackButtonExist: widget.isFromMenu? true : false,
            onBackPressed: () => Get.back(),
            title: "my_bookings".tr),
        body: GetBuilder<ServiceRequestBookingController>(
          builder: (serviceRequestBookingController){
            List<BookingRequestModel>? bookingRequestList = serviceRequestBookingController.bookingRequestList;
            return _buildBody(
              sliversItems:serviceRequestBookingController.bookingRequestList != null? [
                if(ResponsiveHelper.isDesktop(context))
                  const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeExtraLarge,),),
                SliverPersistentHeader(
                  delegate: ServiceRequestSectionMenu(),
                  pinned: true,
                  floating: false,
                ),
                if(ResponsiveHelper.isDesktop(context))
                  const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeExtraLarge,),),
                if(ResponsiveHelper.isMobile(context))
                  const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeSmall,),),
                if(bookingRequestList!.isNotEmpty)
                  SliverToBoxAdapter(
                      child: PaginatedListView(
                        scrollController:  bookingScreenScrollController,
                        totalSize: serviceRequestBookingController.bookingContent!.total!,
                        onPaginate: (int offset) async => await serviceRequestBookingController.getAllBookingRequest(
                            offset: offset,
                            bookingStatus: serviceRequestBookingController.selectedBookingStatus.name.toLowerCase(),
                            isFromPagination: true
                        ),

                        offset: serviceRequestBookingController.bookingContent != null ?
                        serviceRequestBookingController.bookingContent!.currentPage:null,
                        itemView: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: bookingRequestList.length,
                          itemBuilder: (context, index) {
                            return  BookingItemCard(bookingModel: bookingRequestList.elementAt(index),);
                          },
                        ),
                      )),
                if(bookingRequestList.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),),
                if(bookingRequestList.isEmpty)
                  SliverToBoxAdapter(
                      child: Center(
                        child: SizedBox(height: Get.height * 0.7,
                          child: NoDataScreen(
                              text: 'no_booking_request_available'.tr,
                              type: NoDataType.bookings
                          ),
                        ),
                      )
                  )
              ] : [
                SliverPersistentHeader(
                  delegate: ServiceRequestSectionMenu(),
                  pinned: true,
                  floating: false,
                ),
                const SliverToBoxAdapter(child: BookingScreenShimmer())],
              controller: bookingScreenScrollController,
            );
          },
        ));
  }
  Widget _buildBody({required List<Widget> sliversItems, required ScrollController controller}){
    if(ResponsiveHelper.isWeb()){
      return FooterBaseView(
        // isCenter: true,
        scrollController: controller,
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: CustomScrollView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            slivers: sliversItems,
          ),
        ),
      );
    }else{
      return CustomScrollView(
        controller: controller,
        slivers: sliversItems,
      );
    }
  }
}
