package com.broceliand.pearlTree.model
{
   public class WelcomePearlsExceptions
   {
      /*private static const WelcomePageUrlId1:int=406375;
      private static const WelcomePageUrlId2:int=406363;
      private static const WelcomePageUrlId3:int=324037;
      private static const WelcomePageUrlId4:int=911143;*/
      
      private static const HELP_DB_ID:int = 1;
      private static const HELP_USER_ID:int = 7180;
      /*private static const WelcomePearlId1:int=570274;
      private static const WelcomePearlId2:int=788602;
      private static const WelcomePearlId3:int=1645123;
      private static const WelcomePearlId4:int=1645060;*/
      private static const WelcomeHelpRootPearlId:int=564442;
      public static const WelcomeUser:int=7180;
      private static var WelcomeVideoTreeId:int = 0;
      
      static public function isWelcomePage(page:BroPage):Boolean {
         if (!page) {
            return false;
         }
         switch (page.urlId) {
            case 406375:
            case 406363:
            case 324037:
            case 911143:
            case 16297868:
            case 16297870:
            case 16297886:
            case 16297891:
            case 16297893:
            case 16297900:
            case 16297903:
            case 16297906:
            case 16297922:
            case 16297926:
            case 16297939:
            case 16297944:
            case 16297947:
            case 16297957:
            case 16297960:
            case 16297964:
            case 16297973:
            case 16297990:
            case 16297994:
            case 16297997:
            case 18786149:
            case 18786176:
            case 18786179:
            case 18786184:
            case 18786190:
            case 18786199:
            case 18786204:
            case 18786207:
            case 18786229:
            case 18786235:
            case 18786241:
            case 18786243:
               return true;
         }
         return false;   
      }

      static public function isWelcomePearlFromPearltreesAccount(node:BroPTNode):Boolean {
         if (node ==null || node.owner == null) return false;
         var author:User =  node.owner.getMyAssociation().preferredUser;
         if (author == null) {
            return false;
         }
         if (author.persistentDbId != HELP_DB_ID || author.persistentId != HELP_USER_ID) {
            return false;
         }
         if (isWelcomePearlIdFromPearltreesAccount(node.persistentID)) {
            return true;
         }
         if (node is BroPageNode) {
            if ((node as BroPageNode).isWelcomePage()) {
               return true;
            }
         }
         return false;
      }
      
      static public function isWelcomeHelpRootPearl(node:BroPTNode):Boolean {
         return  isWelcomeHelpRootPearlId(node.persistentID);
      }
      
      static public function isWelcomeHelpRootPearlId(persistentID:int):Boolean {
         return  persistentID == WelcomeHelpRootPearlId;
      }
      
      static public function isWelcomePearlIdFromPearltreesAccount(persistentID:int):Boolean {
         if (/*TODO we don't detect page pearls anymore
            persistentID ==  WelcomePearlId1 
            || persistentID ==  WelcomePearlId2 
            || persistentID ==  WelcomePearlId3 
            || persistentID ==  WelcomePearlId4 
            ||*/ isWelcomeHelpRootPearlId(persistentID)) {
            return true;
         } 
         return false;         
      }
      
      static public function isWelcomeVideoTree(tree:BroPearlTree):Boolean {
         return tree.id == WelcomeVideoTreeId;        
      }
      static public function initWelcomeVideoTreeId(id:int):void {
         WelcomeVideoTreeId = id;
      }
   }
}