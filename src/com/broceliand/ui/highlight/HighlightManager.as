package com.broceliand.ui.highlight
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.pearlTree.model.BroPearlTree;
   
   import flash.utils.Dictionary;

   public class HighlightManager
   {
      private var _name2Registered:Dictionary;
      private var _highlightedCloseTree:BroPearlTree;
      public function HighlightManager()
      {
         
         _name2Registered = new Dictionary(true);  
      }

      public function registerHighlightableObject(command:String, obj:IHighlightable):void{
         _name2Registered[command] = obj;
      }
      
      public function unregisterHighlightableObject(command:String, obj:IHighlightable):void{
         if(_name2Registered[command] == obj){
            delete _name2Registered[command];
         }
      }
      
      public function highlight(command:String):void{
         var obj:IHighlightable = _name2Registered[command];
         if(obj){
            obj.highlight();
         }
      }
      
      public function unhighlight(command:String):void{
         var obj:IHighlightable = _name2Registered[command];
         if(obj){
            obj.unhighlight();
         }
      }
      public function highlightCloseTree(tree:BroPearlTree):void {
         if (_highlightedCloseTree != tree) {
            _highlightedCloseTree = tree;
            ApplicationManager.getInstance().components.pearlTreeViewer.vgraph.refreshEdges()

         }
      }
      public function getHighlightedCloseTree():BroPearlTree{
         return _highlightedCloseTree;
      }
      
   }
}