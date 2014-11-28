package com.broceliand.graphLayout.visual
{
   import com.broceliand.graphLayout.layout.IPTLayouter;
   import com.broceliand.graphLayout.model.EditedGraphVisualModification;
   import com.broceliand.graphLayout.model.EndNodeVisibilityManager;
   import com.broceliand.graphLayout.model.GraphicalDisplayedModel;
   import com.broceliand.ui.model.ZoomModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlTree.IGraphControls;
   import com.broceliand.ui.renderers.factory.IPearlRecyclingManager;
   
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   import mx.core.IFactory;
   import mx.core.UIComponent;
   import mx.effects.Effect;
   import mx.effects.Move;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public interface IPTVisualGraph extends IVisualGraph
   {
      function get controls():IGraphControls;
      function get effectForItemRemoval():Effect; 
      function set effectForItemRemoval(effect:Effect):void;  
      
      function set pearlRendererFactories(value:PearlRendererFactories):void;
      function linkNodesAtIndex(v1:IVisualNode, v2:IVisualNode, index:int):IVisualEdge;
      function moveNodeTo(v:IVisualNode,x:int, y:int, duration:int=300, play:Boolean=true):Move;
      function get PTLayouter():IPTLayouter;
      function backgroundDragInProgress():Boolean; 
      
      function isSilentReposition():Boolean;
      function get zoomModel():ZoomModel;
      
      function showNodeTitle(pearlRenderer:IUIPearl, above:Boolean, onTop:Boolean, inDockedSpace:Boolean):void;

      function isAnimating():Boolean;
      
      function getEditedGraphVisualModification():EditedGraphVisualModification;
      function get ringLayer():UIComponent;
      function ensureDragEnd(event:MouseEvent):void;
      function refreshNodes():void;
      function get endNodeVisibilityManager():EndNodeVisibilityManager;
      function refreshEdges():void;
      function getDraggedComponent():UIComponent;
      function isBackdroungDragInProgress():Boolean;
      function getDisplayModel():GraphicalDisplayedModel;

      function dragNodeBegin(renderer:UIComponent, event:MouseEvent):void;
      function dragEndEventSafe(event:Event):void;
      function handleDragPearl(event:MouseEvent):void;

      function getPtwPearlRecyclingMananager():IPearlRecyclingManager;

      function containsSubTrees():Boolean;
      function offsetOrigin(x:Number, y:Number):void;
   }
}