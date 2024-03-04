import 'package:get/get.dart';
import 'package:mstoo/user/feature/conversation/controller/conversation_controller.dart';
import 'package:mstoo/user/feature/conversation/repo/conversation_repo.dart';

class ConversationBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => ConversationController(conversationRepo: ConversationRepo(apiClient: Get.find())));
  }
}