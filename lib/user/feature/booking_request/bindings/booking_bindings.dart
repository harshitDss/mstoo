import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/feature/booking_request/controller/service_booking_controller.dart';
import 'package:mstoo/user/feature/booking_request/repo/service_booking_repo.dart';
import 'package:mstoo/user/feature/conversation/repo/conversation_repo.dart';
import 'package:mstoo/user/feature/service_booking/repo/booking_details_repo.dart';

class BookingBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => BookingDetailsTabsController(bookingDetailsRepo: BookingDetailsRepo(
      sharedPreferences: Get.find(),
      apiClient: Get.find(),
    )));
    // Get.lazyPut(() => ServiceBookingController(serviceBookingRepo: ServiceBookingRepo(sharedPreferences: Get.find(), apiClient: Get.find())));
    Get.lazyPut(() => ServiceRequestBookingController(serviceRequestBookingRepo: ServiceRequestBookingRepo(sharedPreferences: Get.find(), apiClient: Get.find())));
    ///conversation controller is used in booking details screen
    Get.lazyPut(() => ConversationController(conversationRepo: ConversationRepo(apiClient: Get.find())));
  }
}