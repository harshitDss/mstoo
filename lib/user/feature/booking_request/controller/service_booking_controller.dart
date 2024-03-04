import 'package:mstoo/user/components/custom_snackbar.dart';
import 'package:mstoo/user/core/helper/responsive_helper.dart';
import 'package:mstoo/user/core/helper/route_helper.dart';
import 'package:mstoo/user/data/provider/checker_api.dart';
import 'package:mstoo/user/feature/cart/controller/cart_controller.dart';
import 'package:mstoo/user/feature/checkout/controller/checkout_controller.dart';
import 'package:mstoo/user/feature/location/controller/location_controller.dart';
import 'package:mstoo/user/feature/booking_request/model/service_booking_model.dart';
import 'package:get/get.dart';

import '../repo/service_booking_repo.dart';

enum BookingRequestStatusTabs {all, pending, accepted, ongoing,completed,canceled }
// enum BookingStatusTabs {accepted,completed }

class ServiceRequestBookingController extends GetxController implements GetxService {
  final ServiceRequestBookingRepo serviceRequestBookingRepo;
  ServiceRequestBookingController({required this.serviceRequestBookingRepo});

  bool _isPlacedOrdersuccessfully = false;
  bool get isPlacedOrdersuccessfully => _isPlacedOrdersuccessfully;
  List<BookingRequestModel>? _bookingRequestList;
  List<BookingRequestModel>? get bookingRequestList => _bookingRequestList;
  int _offset = 1;
  int? get offset => _offset;
  BookingContent? _bookingContent;
  BookingContent? get bookingContent => _bookingContent;

  int _bookingListPageSize = 0;
  final int _bookingListCurrentPage = 0;
  int get bookingListPageSize=> _bookingListPageSize;
  int get bookingListCurrentPage=> _bookingListCurrentPage;

  // BookingStatusTabs _selectedBookingStatus = BookingStatusTabs.all;
  BookingRequestStatusTabs _selectedBookingStatus = BookingRequestStatusTabs.all;

  BookingRequestStatusTabs get selectedBookingStatus =>_selectedBookingStatus;

  bool _isLoading= false;
  bool get isLoading => _isLoading;




  void updateBookingStatusTabs(BookingRequestStatusTabs bookingStatusTabs, {bool firstTimeCall = true, bool fromMenu= false}){
    _selectedBookingStatus = bookingStatusTabs;
    if(firstTimeCall){
      getAllBookingRequest(offset: 1, bookingStatus: _selectedBookingStatus.name.toLowerCase(),isFromPagination:false);
    }
  }

  Future<void> placeBookingRequest({required String paymentMethod,required String userID,required String serviceAddressId, required String schedule, required String note})async{
    String zoneId = Get.find<LocationController>().getUserAddress()!.zoneId.toString();
    int cartLength =0;
    _isLoading = true;
    update();
    cartLength = Get.find<CartController>().cartList.length;
    if(cartLength>0){

      Response response = await serviceRequestBookingRepo.placeBookingRequest(
        paymentMethod:paymentMethod,
        userId: userID,
        schedule: schedule,
        serviceAddressID: serviceAddressId,
        zoneId:zoneId,
        note: note,
      );
      if(response.statusCode == 200){
        _isPlacedOrdersuccessfully = true;
        Get.find<CheckOutController>().updateState(PageState.complete);
        ///navigate replace
        if(ResponsiveHelper.isWeb()) {
          Get.toNamed(RouteHelper.getCheckoutRoute('cart',Get.find<CheckOutController>().currentPageState.name,"null"));
        }
        customSnackBar('service_booking_successfully'.tr,isError: false,margin: 55);
        Get.find<CartController>().getCartListFromServer();
        update();
      }
    }else{
      Get.offNamed(RouteHelper.getOrderSuccessRoute('fail'));
    }

    _isLoading = false;
    update();
  }

  Future<void> getAllBookingService({required int offset, required String bookingStatus, required bool isFromPagination, bool fromMenu= false})async{
    _offset = offset;
    if(!isFromPagination){
      _bookingRequestList = null;
    }
    Response response = await serviceRequestBookingRepo.getBookingList(offset: offset, bookingStatus: bookingStatus);
    if(response.statusCode == 200){
      ServiceRequestBookingList serviceBookingModel = ServiceRequestBookingList.fromJson(response.body);
      if(!isFromPagination){
        _bookingRequestList = [];
      }
      for (var element in serviceBookingModel.content!.bookingRequestModel!) {
        _bookingRequestList!.add(element);
      }
      _bookingListPageSize = response.body['content']['last_page'];
      _bookingContent = serviceBookingModel.content!;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getAllBookingRequest({required int offset, required String bookingStatus, required bool isFromPagination, bool fromMenu= false})async{
    _offset = offset;
    if(!isFromPagination){
      _bookingRequestList = null;
    }
    Response response = await serviceRequestBookingRepo.getBookingRequest(offset: offset, bookingStatus: bookingStatus);
    if(response.statusCode == 200){
      ServiceRequestBookingList serviceBookingModel = ServiceRequestBookingList.fromJson(response.body);
      if(!isFromPagination){
        _bookingRequestList = [];
      }
      for (var element in serviceBookingModel.content!.bookingRequestModel!) {
        _bookingRequestList!.add(element);
      }
      _bookingListPageSize = response.body['content']['last_page'];
      _bookingContent = serviceBookingModel.content!;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
