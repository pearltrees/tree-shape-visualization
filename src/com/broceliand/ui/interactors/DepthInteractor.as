package com.broceliand.ui.interactors
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.PTVisualGraph;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlBar.deck.DeckModel;
   import com.broceliand.ui.pearlBar.deck.DockedNodeStateEvent;
   
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   import mx.collections.ArrayCollection;
   import mx.core.UIComponent;
   import mx.events.CollectionEvent;
   import mx.events.CollectionEventKind;
   import mx.events.FlexEvent;
   
   public class DepthInteractor
   {
      private var _interactorManager:InteractorManager = null;
      private var _pearlAboveAllElse:IUIPearl = null;
      
      private var _moveToNormalDepthQueue:Dictionary = null;
      private static const NUM_CHILDREN_ABOVE_PEARLS:int = 2; 
      public function DepthInteractor(interactorManager:InteractorManager)
      {
         _interactorManager = interactorManager;
         _interactorManager.pearlTreeViewer.vgraph.controls.dropZoneDeckModel.addEventListener(DeckModel.NODE_STATE_CHANGE, onDockedNodeStateChange);
         _moveToNormalDepthQueue = new Dictionary();
         _interactorManager.pearlTreeViewer.vgraph.addEventListener(FlexEvent.UPDATE_COMPLETE, onVgraphUpdateComplete);         
      }
      
      public function moveBranchAboveAllElse(branchNodes:Array):void{
         
         for each (var renderer:IUIPearl in branchNodes) {
            
         }
         
      }
      public function movePearlAboveAllElse(renderer:IUIPearl):void{
         if(!renderer || !renderer.parent){
            return;
         }
         var newDepth:int = 0;      
         newDepth = renderer.parent.numChildren - 1 - NUM_CHILDREN_ABOVE_PEARLS; 
         moveUIComponentToDepth(renderer.uiComponent, newDepth);
         _pearlAboveAllElse = renderer;
         
      }
      
      public function returnPearlAboveAllElseToNormalPosition():void{
         if(_pearlAboveAllElse){
            movePearlToNormalDepth(_pearlAboveAllElse);
         }
         _pearlAboveAllElse = null;         
      }
      private function onVgraphUpdateComplete(event:Event):void{
         handleQueue();
      }
      
      private function traceSiblings(comp:UIComponent):void{
         return;
         trace("siblings for : "+ getQualifiedClassName(comp));
         for(var i:int = 0; i < comp.parent.numChildren; i++){
            var sibling:DisplayObject = comp.parent.getChildAt(i);
            if(sibling == comp){
               trace(i + ": self");
            }else if(sibling is IUIPearl){
               trace(i + ": " + getQualifiedClassName(sibling) + ", isDocked : " +  (sibling as IUIPearl).node.isDocked);
            }else{
               trace(i + ": " + getQualifiedClassName(sibling));
            }
         }    
         
      }
      
      public function movePearlUp(renderer:IUIPearl):void{
         
         if(!renderer || !renderer.parent){
            return;
         }
         
         var newDepth:int = 0;      
         var controlLayerDepth:int = _interactorManager.pearlTreeViewer.vgraph.controls.getDepthInParent();    
         if(renderer.node.isDocked){
            newDepth = renderer.parent.numChildren - 1 - NUM_CHILDREN_ABOVE_PEARLS;
         }else{
            newDepth = controlLayerDepth - 1;
         }
         
         moveUIComponentToDepth(renderer.uiComponent, newDepth);
      }      
      
      private function moveUIComponentToDepth(comp:UIComponent, depth:int):void{
         try{
            if(!comp.parent){
               trace("no parent");
               return;
            }
            var compParent:UIComponent = comp.parent as UIComponent; 
            if((depth < 0) || (depth > compParent.numChildren)){
               trace("depth not within bounds :" + depth);
               return;
            }
            traceSiblings(comp);
            var currentDepth:int = compParent.getChildIndex(comp);
            
            if(currentDepth == depth){
               
               return;
            }
            
            compParent.setChildIndex(comp, depth);
            compParent.invalidateDisplayList();
         }catch(err:Error){
            trace("error setting node renderer index" + err.message);            
         }
         
      }
      
      public function handleQueue():void{
         for each(var renderer:IUIPearl in _moveToNormalDepthQueue){
            if(renderer.parent){
               movePearlToNormalDepth(renderer);
               delete _moveToNormalDepthQueue[renderer];
            } else if (!renderer.visible) {
               delete _moveToNormalDepthQueue[renderer];
            }
         }
      }
      private function onDockedNodeStateChange(event:DockedNodeStateEvent):void {
         var node:IPTNode = event.node;
         if(node && node.renderer) {
            if(node.isDocked) {
               movePearlToDockedDepth(node.renderer);
            }else{
               movePearlToUndockedDepth(node.renderer.uiComponent);
            }
         }
      }
      
      private function movePearlToUndockedDepth(renderer:UIComponent):void{
         if(!renderer || !renderer.parent){
            return;
         }        

         moveUIComponentToDepth(renderer, 3);
      }
      
      private function movePearlToDockedDepth(renderer:IUIPearl):void{
         if(!renderer || !renderer.parent){
            return;
         }
         
         var controlLayerDepth:int = _interactorManager.pearlTreeViewer.vgraph.controls.getDepthInParent();
         if(controlLayerDepth == renderer.parent.numChildren - 1 - NUM_CHILDREN_ABOVE_PEARLS){
            moveUIComponentToDepth(renderer.uiComponent, controlLayerDepth);
         }else{
            moveUIComponentToDepth(renderer.uiComponent, controlLayerDepth + 1);
         }
      }

      public function movePearlToNormalDepth(renderer:IUIPearl):void{
         if(!renderer){
            return;
         }
         
         if(!renderer.parent){
            _moveToNormalDepthQueue[renderer] = renderer;
            return;
         }
         
         if(renderer.node.getDock()){
            movePearlToDockedDepth(renderer);
         }else{
            movePearlToUndockedDepth(renderer.uiComponent);
         }
         
      }
      
   }
}