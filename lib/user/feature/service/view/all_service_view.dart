import 'package:mstoo/user/components/menu_drawer.dart';
import 'package:get/get.dart';
import 'package:mstoo/user/components/footer_base_view.dart';
import 'package:mstoo/user/components/paginated_list_view.dart';
import 'package:mstoo/user/components/service_view_vertical.dart';
import 'package:mstoo/user/components/service_widget_vertical.dart';
import 'package:mstoo/user/core/core_export.dart';


const List<String> list = <String>['Newest','Oldest','Price: Low to High', 'Price: High to Low'];
String dropdownValue = list.first;

class AllServiceView extends StatefulWidget {
  final String fromPage;
  final String campaignID;
  const AllServiceView({super.key, required this.fromPage,required this.campaignID});

  @override
  State<AllServiceView> createState() => _AllServiceViewState();
}

class _AllServiceViewState extends State<AllServiceView> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();



    return Scaffold(
      appBar: CustomAppBar(
        title:widget.fromPage == 'allServices' ? 'all_service'.tr
            : widget.fromPage == 'fromRecommendedScreen' ? 'recommended_for_you'.tr
            : widget.fromPage == 'popular_services' ? 'popular_services'.tr
            : widget.fromPage == 'recently_view_services' ? 'recently_view_services'.tr
            : widget.fromPage == 'trending_services' ? 'trending_services'.tr
            : 'available_service'.tr,showCart: true,),
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      body: _buildBody(widget.fromPage,context,scrollController),
    );
  }

  Widget _buildBody(String fromPage,BuildContext context,ScrollController scrollController){
    if(fromPage == 'popular_services') {
      return GetBuilder<ServiceController>(
        initState: (state){
          Get.find<ServiceController>().getPopularServiceList(1,true);
        },
        builder: (serviceController){
          return FooterBaseView(
            scrollController: scrollController,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                children: [
                  if(ResponsiveHelper.isDesktop(context))
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.fontSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: TitleWidget(
                      title: 'popular_services'.tr,
                    ),
                  ),
                  PaginatedListView(
                    scrollController: scrollController,
                    totalSize: serviceController.popularBasedServiceContent != null ? serviceController.popularBasedServiceContent!.total! : null,
                    offset: serviceController.popularBasedServiceContent != null ? serviceController.popularBasedServiceContent!.currentPage != null ? serviceController.popularBasedServiceContent!.currentPage! : null : null,
                    onPaginate: (int offset) async {
                      return await serviceController.getPopularServiceList(offset, false);
                    },
                    itemView: ServiceViewVertical(
                      service: serviceController.popularBasedServiceContent != null ? serviceController.popularServiceList : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall :  Dimensions.paddingSizeSmall,
                      ),
                      type: 'others',
                      noDataType: NoDataType.home,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    else if(fromPage == 'trending_services') {
      return GetBuilder<ServiceController>(
        initState: (state){
          Get.find<ServiceController>().getTrendingServiceList(1,true);
        },
        builder: (serviceController){
          return FooterBaseView(
            scrollController: scrollController,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                children: [
                  if(ResponsiveHelper.isDesktop(context))
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.fontSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeSmall,
                      ),
                      child: TitleWidget(
                        title: 'trending_services'.tr,
                      ),
                    ),
                  PaginatedListView(
                    scrollController: scrollController,
                    totalSize: serviceController.trendingServiceContent != null ? serviceController.trendingServiceContent!.total! : null,
                    offset: serviceController.trendingServiceContent != null ? serviceController.trendingServiceContent!.currentPage != null ? serviceController.trendingServiceContent!.currentPage! : null : null,
                    onPaginate: (int offset) async {
                      return await serviceController.getTrendingServiceList(offset, false);
                    },
                    itemView: ServiceViewVertical(
                      service: serviceController.trendingServiceContent != null ? serviceController.trendingServiceList : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall :  Dimensions.paddingSizeSmall,
                      ),
                      type: 'others',
                      noDataType: NoDataType.home,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    else if(fromPage == 'recently_view_services') {
      return GetBuilder<ServiceController>(
        initState: (state){
          Get.find<ServiceController>().getRecentlyViewedServiceList(1,true);
        },
        builder: (serviceController){
          return FooterBaseView(
            scrollController: scrollController,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                children: [
                  if(ResponsiveHelper.isDesktop(context))
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.fontSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeSmall,
                      ),
                      child: TitleWidget(
                        title: 'recently_view_services'.tr,
                      ),
                    ),
                  PaginatedListView(
                    scrollController: scrollController,
                    totalSize: serviceController.recentlyViewServiceContent != null ? serviceController.recentlyViewServiceContent!.total! : null,
                    offset: serviceController.recentlyViewServiceContent != null
                        ? serviceController.recentlyViewServiceContent!.currentPage != null ? serviceController.recentlyViewServiceContent!.currentPage! : null : null,
                    onPaginate: (int offset) async {
                      return await serviceController.getRecentlyViewedServiceList(offset, false);
                    },
                    itemView: ServiceViewVertical(
                      service: serviceController.recentlyViewServiceContent != null ? serviceController.recentlyViewServiceList : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall :  Dimensions.paddingSizeSmall,
                      ),
                      type: 'others',
                      noDataType: NoDataType.home,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    else if(fromPage == 'fromCampaign') {
      return GetBuilder<ServiceController>(
        initState: (state){

          Get.find<ServiceController>().getEmptyCampaignService();
          Get.find<ServiceController>().getCampaignBasedServiceList(widget.campaignID,true);
        },
        builder: (serviceController){
          return _buildWidget(serviceController.campaignBasedServiceList,context);
        },
      );
    }
    else if(fromPage == 'fromRecommendedScreen'){
      return GetBuilder<ServiceController>(
        initState: (state){
          Get.find<ServiceController>().getRecommendedServiceList(1,true);
        },
        builder: (serviceController){
          return FooterBaseView(
            scrollController: scrollController,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                children: [
                  if(ResponsiveHelper.isDesktop(context))
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.fontSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: TitleWidget(
                      title: 'recommended_for_you'.tr,
                    ),
                  ),
                  PaginatedListView(
                    scrollController: scrollController,
                    totalSize: serviceController.recommendedBasedServiceContent != null ? serviceController.recommendedBasedServiceContent!.total! : null,
                    offset: serviceController.recommendedBasedServiceContent != null ? serviceController.recommendedBasedServiceContent!.currentPage != null ? serviceController.recommendedBasedServiceContent!.currentPage!: null : null,
                    onPaginate: (int offset) async {
                      printLog("inside_on_paginate:$offset");
                      return await serviceController.getRecommendedServiceList(offset, false);
                    },
                    itemView: ServiceViewVertical(
                      service: serviceController.recommendedBasedServiceContent != null ? serviceController.recommendedServiceList : null,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall :  Dimensions.paddingSizeSmall,
                      ),
                      type: 'others',
                      noDataType: NoDataType.home,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    else if(fromPage == 'all_service'){
      return GetBuilder<ServiceController>(
          initState: (state){
            Get.find<ServiceController>().getAllServiceList(1,true);
          },
          builder: (serviceController) {
        return FooterBaseView(
          scrollController: scrollController,
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(
              children: [
                if(ResponsiveHelper.isDesktop(context))
                  Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeSmall,
                  ),
                  child: TitleWidget(
                    title: 'all_service'.tr,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault,),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Sort by"),
                  DropdownMenu<String>(
                      initialSelection: list.first,
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        if(value == "Price: Low to High"){
                          Get.find<ServiceController>().sortAllServiceByPriceAsec(1,true);
                        }
                        else if(value == "Price: High to Low"){
                          Get.find<ServiceController>().sortAllServiceByPriceDesc(1,true);
                        }

                        else if(value == "Oldest"){
                          Get.find<ServiceController>().sortAllServiceByOldest(1,true);
                        }
                        else if(value == "Newest"){
                          Get.find<ServiceController>().getAllServiceList(1,true);
                        }
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value);
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 20),
                PaginatedListView(
                  scrollController: scrollController,
                  totalSize:serviceController.serviceContent != null ?  serviceController.serviceContent!.total != null ? serviceController.serviceContent!.total! : null:null,
                  offset: serviceController.serviceContent != null ? serviceController.serviceContent!.currentPage != null ? serviceController.serviceContent!.currentPage!: null : null,
                  onPaginate: (int offset) async => await serviceController.getAllServiceList(offset, false),
                  itemView: ServiceViewVertical(
                    service: serviceController.serviceContent != null ? serviceController.allService : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                      vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                    ),
                    type: 'others',
                    noDataType: NoDataType.home,
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
    else{
      return GetBuilder<ServiceController>(
        initState: (state){
          Get.find<ServiceController>().getSubCategoryBasedServiceList(fromPage,false,isShouldUpdate: true);
        },
        builder: (serviceController){
          return _buildWidget(serviceController.subCategoryBasedServiceList ,context);
        },
      );
    }
  }

  Widget _buildWidget(List<Service>? serviceList,BuildContext context){
    return FooterBaseView(
      isCenter:(serviceList == null || serviceList.isEmpty),
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: (serviceList != null && serviceList.isEmpty) ?  NoDataScreen(text: 'no_services_found'.tr,type: NoDataType.service,) :  serviceList != null ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              // ElevatedButton(onPressed: (){
              //   Get.find<ServiceController>().sortByPriceAsec(widget.fromPage, false);
              // }, child: Text("Price low to high")),

              // ElevatedButton(onPressed: (){
              //   Get.find<ServiceController>().sortByPriceDesc(widget.fromPage, false);
              // }, child: Text("Price high to low")),

              // ElevatedButton(onPressed: (){
              //   Get.find<ServiceController>().getSubCategoryBasedServiceList(widget.fromPage,false,isShouldUpdate: true);
              // }, child: Text("Default")),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Sort by"),
                  DropdownMenu<String>(
                      initialSelection: list.first,
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        if(value == "Price: Low to High"){
                          Get.find<ServiceController>().sortByPriceAsec(widget.fromPage, false);
                        }
                        else if(value == "Price: High to Low"){
                          Get.find<ServiceController>().sortByPriceDesc(widget.fromPage, false);
                        }

                        else if(value == "Oldest"){
                          Get.find<ServiceController>().sortByOldest(widget.fromPage, false);
                        }
                        else if(value == "Newest"){
                          Get.find<ServiceController>().getSubCategoryBasedServiceList(widget.fromPage,false,isShouldUpdate: true);
                        }
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value);
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              CustomScrollView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  if(ResponsiveHelper.isWeb())
                  const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,)),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: Dimensions.paddingSizeDefault,
                      mainAxisSpacing:  Dimensions.paddingSizeDefault,
                      childAspectRatio: ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isTab(context)  ? .9 : .75,
                      crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 5,
                      mainAxisExtent: 240,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        Get.find<ServiceController>().getServiceDiscount(serviceList[index]);
                        return ServiceWidgetVertical(service: serviceList[index],  isAvailable: true,fromType: widget.fromPage,);
                      },
                      childCount: serviceList.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: Dimensions.webCategorySize,)),
                ],
              ),
            ],
          ),
        ) : GridView.builder(
          key: UniqueKey(),
          padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: Dimensions.paddingSizeDefault,
            mainAxisSpacing:  Dimensions.paddingSizeDefault,
            childAspectRatio: ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isTab(context)  ? 1 : .70,
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 5,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return const ServiceShimmer(isEnabled: true, hasDivider: false);
          },
        ),
      ),
    );
  }
}

