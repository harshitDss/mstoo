import 'package:mstoo/user/core/core_export.dart';
import 'package:mstoo/user/feature/search/widget/recommended_search.dart';
import 'package:mstoo/user/feature/search/widget/suggested_search.dart';
import 'recent_search.dart';

class SearchSuggestion extends StatelessWidget {
  const SearchSuggestion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: Dimensions.webMaxWidth,
      child: Padding(
        padding:  EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecentSearch(),
            SizedBox(height: Dimensions.paddingSizeLarge,),
            SuggestedSearch(),
            SizedBox(height: Dimensions.paddingSizeLarge,),
            RecommendedSearch()
          ],
        ),
      ),
    );
  }
}
