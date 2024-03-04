import 'package:mstoo/user/data/provider/client_api.dart';
import 'package:mstoo/user/feature/review/model/review_body.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/utils/app_constants.dart';

class ServiceRepo extends GetxService {
  final ApiClient apiClient;
  ServiceRepo({required this.apiClient});

  Future<Response> getAllServiceList(int offset) async {
    return await apiClient.getData('${AppConstants.allServiceUri}?offset=$offset&limit=10');
  }
  Future<Response> getPopularServiceList(int offset) async {
    return await apiClient.getData('${AppConstants.popularServiceUri}?offset=$offset&limit=10');
  }

  Future<Response> getTrendingServiceList(int offset) async {
    return await apiClient.getData('${AppConstants.trendingServiceUri}?offset=$offset&limit=10');
  }

  Future<Response> getRecentlyViewedServiceList(int offset) async {
    return await apiClient.getData('${AppConstants.recentlyViewedServiceUri}?offset=$offset&limit=10');
  }

  Future<Response> getFeatheredCategoryServiceList() async {
    return await apiClient.getData(AppConstants.getFeaturedCategoryService);
  }

  Future<Response> getRecommendedServiceList(int offset) async {
    return await apiClient.getData('${AppConstants.recommendedServiceUri}?limit=10&offset=$offset');
  }

  Future<Response> getRecommendedSearchList() async {
    return await apiClient.getData(AppConstants.recommendedSearchUri);
  }

  Future<Response> getOffersList(int offset) async {
    return await apiClient.getData('${AppConstants.offerListUri}?limit=10&offset=$offset');
  }

  Future<Response> getServiceListBasedOnSubCategory({required String subCategoryID, required int offset}) async {
    return await apiClient.getData('${AppConstants.serviceBasedOnSubcategory}$subCategoryID?limit=30&offset=$offset');
  }

  Future<Response> sortByPriceAsec({required String subCategoryID, required int offset}) async {
    return await apiClient.getData('${AppConstants.sortByPriceAsec}$subCategoryID?limit=30&offset=$offset');
  }

  Future<Response> sortByPriceDesc({required String subCategoryID, required int offset}) async {
    return await apiClient.getData('${AppConstants.sortByPriceDesc}$subCategoryID?limit=30&offset=$offset');
  }

  Future<Response> sortByOldest({required String subCategoryID, required int offset}) async {
    return await apiClient.getData('${AppConstants.sortByOldest}$subCategoryID?limit=30&offset=$offset');
  }

  Future<Response> getItemsBasedOnCampaignId({required String campaignID}) async {
    return await apiClient.getData('${AppConstants.itemsBasedOnCampaignId}$campaignID&limit=100&offset=1');
  }

  Future<Response> submitReview(ReviewBody reviewBody) async {
    return await apiClient.postData(AppConstants.serviceReview, reviewBody.toJson());
  }

  // Sort all services 
  Future<Response> sortAllServiceByPriceAsec(int offset) async {
    return await apiClient.getData('${AppConstants.sortAllServiceByPriceAsec}?offset=$offset&limit=10');
  }

  Future<Response> sortAllServiceByPriceDesc(int offset) async {
    return await apiClient.getData('${AppConstants.sortAllServiceByPriceDesc}?offset=$offset&limit=10');
  }

  Future<Response> sortAllServiceByOldest(int offset) async {
    return await apiClient.getData('${AppConstants.sortAllServiceByOldest}?offset=$offset&limit=10');
  }

}
