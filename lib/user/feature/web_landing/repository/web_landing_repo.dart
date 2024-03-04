import 'package:mstoo/user/data/provider/client_api.dart';
import 'package:mstoo/user/feature/notification/repository/notification_repo.dart';
import 'package:mstoo/user/utils/app_constants.dart';

class WebLandingRepo {
  final ApiClient apiClient;

  WebLandingRepo({required this.apiClient});

  Future<Response> getWebLandingContents() async {
    return await apiClient.getData(AppConstants.webLandingContents,headers: AppConstants.configHeader);
  }

}