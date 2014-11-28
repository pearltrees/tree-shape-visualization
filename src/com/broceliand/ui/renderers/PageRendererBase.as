package com.broceliand.ui.renderers{
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.graphLayout.visual.IScrollable;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.renderers.factory.IPearlRecyclingManager;
   import com.broceliand.util.Assert;
   
   import mx.containers.Canvas;
   import mx.core.IDataRenderer;
   import mx.core.ScrollPolicy;
   import mx.events.FlexEvent;

   public class PageRendererBase extends Canvas implements IDataRenderer, IScrollable{
      /*
      protected var _data:Object = null;
      public function get data():Object{
      return _data;
      }
      */		
      
      private var _isEnded:Boolean =false;
      
      protected var _vnode:IPTVisualNode;
      protected var _creationCompleted:Boolean= false;
      protected var _pearlRecyclingManager:IPearlRecyclingManager;
      protected var _nodeChanged:Boolean = false;
      
      public function PageRendererBase():void{
         super();
         horizontalScrollPolicy = ScrollPolicy.OFF;
         verticalScrollPolicy = ScrollPolicy.OFF;
         addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
      }
      public function get vnode():IPTVisualNode {
         return _vnode;
      }

      override protected function commitProperties():void {
         super.commitProperties();
         if (_nodeChanged) {
            _nodeChanged = false;
         }
      }
      override public function set data(value:Object):void{
         if(value != _vnode){
            Assert.assert(value is IPTVisualNode, "data is not IVisualNode");
            super.data = value;
            setVNode(value as IPTVisualNode);
         }			
      }
      protected function setVNode(vnode:IPTVisualNode):void {
         if (_vnode !=null) {
            _nodeChanged = true;
            invalidateProperties();
         }
         _vnode = vnode;
      }
      
      public function get node():IPTNode{
         if(!_vnode){
            return null;
         }else{
            return _vnode.node as IPTNode;    
         }
         
      }
      
      public function end():void {
         callLater(clearMemory);
         _isEnded=true;
      }
      public function isEnded():Boolean{
         return _isEnded;
      }
      protected function clearMemory():void{
         removeAllChildren();
         super.data=null;
         _vnode = null;
         
      }
      
      public function isScrollable():Boolean{
         if(node && node.getDock()){
            return false;
         }else {
            return this != ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.draggedPearl;  
         }
      }
      
      public function get businessNode():BroPTNode {
         return node.getBusinessNode();
      }
      
      private function creationCompleteHandler(event:FlexEvent):void {
         _creationCompleted = true;
         removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
      }
      
      public function isCreationCompleted():Boolean {
         return _creationCompleted;
      }
      public function set pearlRecyclingManager(pearlRecyclingManager:IPearlRecyclingManager):void {
         _pearlRecyclingManager = pearlRecyclingManager;
         
      }
      public function get pearlRecyclingManager():IPearlRecyclingManager {
         return _pearlRecyclingManager;
      }
      
   }
}