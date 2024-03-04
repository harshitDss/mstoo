import '../../../core/core_export.dart';
import '../../notification/repository/notification_repo.dart';

class BookingDetailsRepo {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;
  BookingDetailsRepo(
      {required this.sharedPreferences, required this.apiClient});

  Future<Response> getBookingDetails({required String bookingID}) async {
    return await apiClient.getData("${AppConstants.bookingDetails}/$bookingID");
  }

  Future<Response> bookingCancel({required String bookingID}) async {
    return await apiClient.postData('${AppConstants.bookingCancel}/$bookingID',
        {"booking_status": "canceled", "_method": "put"});
  }

  // custom function to change schedule by user
  Future<Response> changeSchedule(String bookingID, String schedule) async {
    return await apiClient.putData(
        "${AppConstants.changeScheduleUrl}/$bookingID", {'schedule': schedule});
  }

  Future<Response> markCompleted({required String bookingID}) async {
    return await apiClient.postData('${AppConstants.markCompleted}/$bookingID',
        {"booking_status": "completed", "_method": "put"});
  }
  //closed
}
