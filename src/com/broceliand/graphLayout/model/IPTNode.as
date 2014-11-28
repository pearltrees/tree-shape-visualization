package com.broceliand.graphLayout.model
{
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.INode;
   
   public interface IPTNode extends INode
   {
      function addOutEdgeAtIndex(e:IEdge, index:int):void;
      function updatingNumberOfDescendant():Number;
      function get rootNodeOfMyTree():IPTNode; 
      
      function get treeOwner():BroPearlTree;
      function get containingPearlTreeModel():IPearlTreeModel;
      function set containingPearlTreeModel(o:IPearlTreeModel):void;
      function get parent():IPTNode;
      function get edgeToParent():IEdge;
      function isLastChild():Boolean;
      function isOnLastBranch():Boolean; 
      function getDescendantsAndSelf():Array;  
      function get renderer():IUIPearl;
      function get isTopRoot():Boolean; 
      function getDock():IDeckModel; 
      function get isInDropZone():Boolean;
      function get isDocked():Boolean;
      function dock(dock:IDeckModel):void;
      function undock(updateSelection:Boolean = true):void;
      function getBusinessNode():BroPTNode; 
      function isRendererInScreen():Boolean;
      function get pearlVnode():IPTVisualNode;
      function end():void;
      function get name():String;
      function wasSameNode(node:IPTNode):Boolean;
      function isEnded():Boolean;
      function getDescendantWeight():Number;
      function getChildCount():Number;
      function get isDisappearing():Boolean;
      function set isDisappearing(isDisappearing:Boolean):void;
      
   }
}