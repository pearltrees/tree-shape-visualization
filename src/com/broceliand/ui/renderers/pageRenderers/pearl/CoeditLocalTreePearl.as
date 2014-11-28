package com.broceliand.ui.renderers.pageRenderers.pearl {
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlAssets;
   import com.broceliand.pearlTree.model.team.ITeamRequestModel;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.ui.util.FiltersManager;
   
   import flash.filters.ShaderFilter;
   
   import mx.controls.Image;
   import mx.core.UIComponent;
   
   public class CoeditLocalTreePearl extends PTRootPearl {
      
      protected static const PUZZLE_WIDTH:Number = 56; 
      
      protected var _puzzleImage:Image = null;
      protected var _filterColor:uint;
      
      public function CoeditLocalTreePearl() {
         super();
      }
      
      override protected function commitProperties():void{
         super.commitProperties();
         var newColor:uint = getPuzzleColor();
         if (_filterColor != newColor) {
            _filterColor = newColor;
            filterPuzzle(_filterColor);
         }
      }
      override protected function makeNormalState():UIComponent {
         var normalState:UIComponent  = super.makeNormalState();
         _puzzleImage = createTeamPuzzle(normalState);
         return normalState;
      }
      
      private function createTeamPuzzle(parentComponent:UIComponent):Image {
         var puzzleImage:Image = new Image();
         puzzleImage.width = puzzleImage.height = PUZZLE_WIDTH;
         puzzleImage.source = AssetsManager.getEmbededAsset(PearlAssets.COEDIT_MINI_PUZZLE);
         puzzleImage.x = (parentComponent.width - puzzleImage.width) / 2;
         puzzleImage.y = (parentComponent.height- puzzleImage.height) / 2;
         parentComponent.addChild(puzzleImage);
         return puzzleImage;
      }
      
      private function filterPuzzle(color:uint):void {
         var colorizer:ShaderFilter = FiltersManager.getColorizeFilter(color);
         if (_puzzleImage) {
            _puzzleImage.filters = [colorizer];
         }
      }
      
      private function getPuzzleColor():uint {
         var requestModel:ITeamRequestModel  = ApplicationManager.getInstance().notificationCenter.teamRequestModel;
         if (requestModel.hasRequestsToAccept(getPearlTreeForAvatar())) {
            return PearlAssets.COEDIT_ACCEPT;
         }
         var aliasId:int;
         if (node && node.getBusinessNode()) {
            aliasId = node.getBusinessNode().persistentID;
         }
         if (requestModel.hasPendingRequests(getPearlTreeForAvatar(), aliasId)) {
            return PearlAssets.COEDIT_PENDING;
         }
         return PearlAssets.COEDIT_NORMAL;
      }

      override protected function getForegroundSelectedAsset():Class {
         
         return AssetsManager.getEmbededAsset(PearlAssets.TREE_FOREGROUND_SELECTED_PNG);
      }
      
      override protected function getForegroundOverAsset():Class {
         return AssetsManager.getEmbededAsset(PearlAssets.TREE_FOREGROUND_OVER_PNG);
      }
      
   }
}