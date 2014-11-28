package com.broceliand.pearlTree.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.io.object.tree.SearchResultData;
   import com.broceliand.util.BroLocale;
   
   public class BroSearchResultItem
   {
      private var _treeId:int;
      private var _title:String;
      private var _userId:int;
      private var _userName:String;
      private var _avatarHash:String;
      private var _user:User;
      private var _hits:int;
      private var _pearlCount:int;
      public function BroSearchResultItem(searchData:SearchResultData)
      {
         _treeId = searchData.treeId;
         _title  = searchData.tree.title;
         var uf:UserFactory = ApplicationManager.getInstance().userFactory;
         _userId = searchData.tree.user.id;
         _user  = uf.getOrMakeUser(1, _userId);
         _userName = searchData.tree.user.userName;
         if (!_user.isInit() ) {
            _user.username= _userName;
            _user.avatarHash = searchData.tree.user.avatarHash == null ? null : BroPage.byteArrayToHexString(searchData.tree.user.avatarHash);
         }
         
         _avatarHash = _user.avatarHash;
         _hits = searchData.tree.hits;
         _pearlCount = searchData.tree.pearlCount;
      }
      public function get treeId():int { return _treeId; }
      public function get title():String { 
         if(_title != BroPearlTree.DEFAULT_SERVER_TITLE) {
            return _title;
         }
         else{
            return BroLocale.getInstance().getText('defaultMapName');
         }
      }
      public function get userId():int { return _userId; }
      public function get userName():String { return _userName; }
      public function get avatarHash():String { return _avatarHash; }
      public function get hits():int { return _hits; }
      public function get pearlCount():int { return _pearlCount; }
      public function get user():User{ return _user; }

   }
}