import 'package:get/get.dart';
import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/core/onboard_data.dart';
import 'package:mstoo/user/feature/onboarding/controller/on_board_pager_controller.dart';

class OnBoardPopulated extends GetView<OnBoardController> {
  const OnBoardPopulated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
         
          Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                      onTap: () {
                        Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                        },
                      child: Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "skip".tr,
                            style: ubuntuRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.6),
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              onPageChanged: (value) {
                controller.onPageChanged(value);
              },
              itemCount: onBoardPagerData.length,
              itemBuilder: (context, index) => PagerContent(
                image: onBoardPagerData[index]["image"]!,
                text: onBoardPagerData[index]["text"]!,
                subText: onBoardPagerData[index]["subTitle"]!,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  Gaps.verticalGapOf(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        onBoardPagerData.length,
                        (index) => GetBuilder<OnBoardController>(
                                builder: (onBoardController) {
                              return PagerDot(index: index, currentIndex: onBoardController.pageIndex);
                            })),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
          GetBuilder<OnBoardController>(
            builder: (onBoardController) {
              if(onBoardController.pageIndex != 0) {
                return Align(alignment: Alignment.bottomRight, child: ElevatedButton(
                onPressed: () {
                  Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                },
                child: Container(
                  width: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("next".tr,style: ubuntuRegular.copyWith(color: Theme.of(context).primaryColorLight)),
                      Icon(
                        Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ));
              }
              return Align(alignment: Alignment.topRight,
              //  child: InkWell(
              //   onTap: () {
              //     Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
              //     },
              //   child: Container(
              //     decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text(
              //         "skip".tr,
              //         style: ubuntuRegular.copyWith(
              //           fontSize: Dimensions.fontSizeExtraLarge,
              //           color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.6),
              //         ),
              //       ),
              //     ),
              //   ),
              // )
              );
            },
          ),
        ],
      ),
    );
  }
}
