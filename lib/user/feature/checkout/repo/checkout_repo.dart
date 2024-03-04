import 'package:mstoo/user/data/provider/client_api.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/utils/app_constants.dart';

class CheckoutRepo extends GetxService {
  final ApiClient apiClient;
  CheckoutRepo({required this.apiClient});

  Future<Response> getPostDetails(String postId) async {
    return await apiClient.getData('${AppConstants.getPostDetails}/$postId');
  }
}
