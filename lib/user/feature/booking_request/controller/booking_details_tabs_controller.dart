import 'package:get/get.dart';
import 'package:mstoo/user/feature/service_booking/model/invoice.dart';
import 'package:mstoo/user/feature/service_booking/repo/booking_details_repo.dart';
import '../../../core/core_export.dart';

enum BookingDetailsTabs { bookingDetails, status }

class BookingDetailsTabsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  BookingDetailsRepo bookingDetailsRepo;
  BookingDetailsTabsController({required this.bookingDetailsRepo});

  BookingDetailsTabs _selectedDetailsTabs = BookingDetailsTabs.bookingDetails;
  BookingDetailsTabs get selectedBookingStatus => _selectedDetailsTabs;
  TabController? detailsTabController;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;
  BookingDetailsContent? _bookingDetailsContent;
  BookingDetailsContent? get bookingDetailsContent => _bookingDetailsContent;
  List<InvoiceItem> _invoiceItems = [];
  List<InvoiceItem> get invoiceItems => _invoiceItems;
  double _invoiceGrandTotal = 0.0;
  double get invoiceGrandTotal => _invoiceGrandTotal;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TimeOfDay _selectedTimeOfDay = TimeOfDay.now();
  TimeOfDay get selectedTimeOfDay => _selectedTimeOfDay;

  String _schedule = '';
  String get schedule => _schedule;

  List<double> _unitTotalCost = [];
  double _allTotalCost = 0;
  double _totalDiscount = 0;
  double _totalDiscountWithCoupon = 0;
  List<double> get unitTotalCost => _unitTotalCost;
  double get allTotalCost => _allTotalCost;
  double get totalDiscount => _totalDiscount;
  double get totalDiscountWithCoupon => _totalDiscountWithCoupon;

  void updateBookingStatusTabs(BookingDetailsTabs bookingDetailsTabs) {
    _selectedDetailsTabs = bookingDetailsTabs;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    detailsTabController =
        TabController(length: BookingDetailsTabs.values.length, vsync: this);
  }

  Future<void> bookingCancel({required String bookingId}) async {
    _isCancelling = true;
    update();
    Response? response =
        await bookingDetailsRepo.bookingCancel(bookingID: bookingId);
    if (response.statusCode == 200) {
      _isCancelling = false;
      customSnackBar('booking_cancelled_successfully'.tr, isError: false);
      await getBookingDetails(bookingId: bookingId);
    } else {
      _isCancelling = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getBookingDetails({required String bookingId}) async {
    _invoiceGrandTotal = 0;

    _bookingDetailsContent = null;
    Response response =
        await bookingDetailsRepo.getBookingDetails(bookingID: bookingId);
    if (response.statusCode == 200) {
      _allTotalCost = 0.0;
      _unitTotalCost = [];
      _invoiceItems = [];

      _bookingDetailsContent =
          BookingDetailsContent.fromJson(response.body['content']);
      if (_bookingDetailsContent!.detail != null) {
        for (var element in _bookingDetailsContent!.detail!) {
          _unitTotalCost
              .add(element.serviceCost!.toDouble() * element.quantity!);
        }
        for (var element in _unitTotalCost) {
          _allTotalCost = _allTotalCost + element;
        }

        for (var element in _bookingDetailsContent!.detail!) {
          _invoiceItems.add(InvoiceItem(
            discountAmount: (element.discountAmount! +
                    element.campaignDiscountAmount!.toDouble() +
                    element.overallCouponDiscountAmount!.toDouble())
                .toStringAsFixed(2),
            tax: element.taxAmount!.toStringAsFixed(2),
            unitAllTotal: element.totalCost!.toStringAsFixed(2),
            quantity: element.quantity!,
            serviceName:
                "${element.serviceName ?? 'service_deleted'.tr} \n${element.variantKey?.replaceAll('-', ' ').capitalizeFirst ?? 'variantKey_not_available'.tr}",
            unitPrice: element.serviceCost!.toStringAsFixed(2),
          ));
        }
      }
      double? discount =
          _bookingDetailsContent!.totalDiscountAmount!.toDouble();
      double? campaignDiscount =
          _bookingDetailsContent!.totalCampaignDiscountAmount!.toDouble();
      _totalDiscount = (discount + campaignDiscount);
      _totalDiscountWithCoupon = discount +
          campaignDiscount +
          (_bookingDetailsContent!.totalCouponDiscountAmount!);

      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  String calculateDiscount(
      double? discountAmount, double? campaignDiscount, int qty) {
    return ((discountAmount! + campaignDiscount!) * qty).toStringAsFixed(3);
  }

  String calculateTex(double? tax, int qty) {
    return (tax! * qty).toStringAsFixed(3);
  }

  double calculateTotalCost(BookingContentDetailsItem element) {
    double? discount = element.discountAmount!.toDouble();
    double? campaignDiscount = element.campaignDiscountAmount!.toDouble();
    double? totalDiscount = discount + campaignDiscount;
    double? tex = element.taxAmount!.toDouble();
    int? qty = element.quantity!;
    double? total = element.serviceCost!.toDouble();
    double texQ = tex * qty;
    double discountQ = totalDiscount * qty;
    double totalQ = total * qty;
    double? allTotal = (totalQ + texQ) - discountQ;
    printLog("=========>$allTotal");
    _invoiceGrandTotal = _invoiceGrandTotal + allTotal;
    return allTotal;
  }

// custom function by naresh for change schedule in user
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: Get.context!,
        initialDate: _selectedDate,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Get.isDarkMode
                    ? Theme.of(context).cardColor
                    : Theme.of(context).primaryColor,
                onPrimary: Get.isDarkMode
                    ? Theme.of(context).primaryColorLight
                    : Theme.of(context).cardColor,
                onSurface: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.8),
                background: Theme.of(context).cardColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor:
                      // Theme.of(context).primaryColorLight, // button text color
                      Theme.of(context).primaryColorDark, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      _selectedDate = picked;

      update();
      selectTimeOfDay();
    }
  }

  Future<void> selectTimeOfDay() async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!, initialTime: TimeOfDay.now());

    if (pickedTime != null && pickedTime != _selectedTimeOfDay) {
      _selectedTimeOfDay = pickedTime;

      update();
      buildSchedule();
    }
  }

  Future<void> buildSchedule() async {
    _schedule =
        "${DateConverter.resheduleDate(_selectedDate.toString())}"
        " ${selectedTimeOfDay.hour.toString()}:${selectedTimeOfDay.minute.toString()}:00";

        print(_schedule);

    if (_schedule != "") {
      changeSchedule();
      update();
    }
  }

  Future<void> changeSchedule() async {
    Response response = await bookingDetailsRepo.changeSchedule(bookingDetailsContent!.id!, _schedule);
    if (response.statusCode == 200) {
      // getBookingDetailsData(_bookingDetailsContent!.id!,reload: false);
      customSnackBar("service_schedule_changed_successfully".tr,isError: false);
    } else {
      customSnackBar(response.statusText.toString().tr);
    }
  }

  Future<void> markCompleted() async {
    Response response = await bookingDetailsRepo.markCompleted(bookingID : bookingDetailsContent!.id!);
    if (response.statusCode == 200) {
      // getBookingDetailsData(_bookingDetailsContent!.id!,reload: false);
      customSnackBar("Booking marked as completed successfully",isError: false);
    } else {
      customSnackBar(response.statusText.toString().tr);
    }
  }
  // closed

  @override
  void onClose() {
    detailsTabController!.dispose();
    super.onClose();
  }
}
