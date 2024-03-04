import 'package:mstoo/user/data/provider/client_api.dart';
import 'package:mstoo/user/utils/app_constants.dart';
import 'package:get/get.dart';

class WalletRepo{
  final ApiClient apiClient;
  WalletRepo({required this.apiClient});

  Future<Response> getWalletTransactionData(int offset) async {
    return await apiClient.getData("${AppConstants.walletTransactionData}?limit=10&offset=$offset");
  }
}