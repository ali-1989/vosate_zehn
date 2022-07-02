
class AppBadge {
  AppBadge._();

  /*static void prepareBadgesAndRefresh() async {
    final user = Session.getLastLoginUser();

    if(user == null){
      homePageBadges.clear();
      return;
    }

    //------ notify --------------------------------------------------------------
    final list = NotifierModelDb.fetchUnSeenRecords(user.userId);

    if(list.isEmpty){
      homePageBadges[0] = 0;
    }
    else {
      homePageBadges[0] = list.length;
    }
    //------ chat --------------------------------------------------------------
    final manager = ChatManager.managerFor(user.userId);
    var chatCount = 0;

    for(final chat in manager.allChatList){
      chatCount += chat.unReadCount();
    }

    if(chatCount == 0){
      homePageBadges[4] = 0;
    }
    else {
      homePageBadges[4] = chatCount;
    }
    //--------------------------------------------------------------------
    homeScreenKey.currentState?.navBarRefresher.update();
  }*/
}