package com.broceliand.ui.pearlBar.deck {
   
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.ui.highlight.IHighlightable;
   
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;

   public interface IDeckModel extends IEventDispatcher, IHighlightable {

      function addItem(value:DeckItem):void;
      
      function dockCopyBroPTNode(businessNode:BroPTNode, effectSource:Point=null, node:IPTNode=null):IPTNode;   
      function dockNode(node:IPTNode, copy:Boolean=false, effectSource:Point=null):IPTNode;   
      function undockNode(node:IPTNode, withDeleteEffect:Boolean=false, updateSeleciton:Boolean = true):void;
      function repositionNodes():void;
      function createItemNode(item:DeckItem):IPTNode;
      function getItemAt(index:int):DeckItem;
      function getItemsCount():uint; 
      function findItemIndexFromNode(node:IPTNode):int;
      function getNodeAt(itemIndex:int, createIfNotExist:Boolean = true):IPTNode;
      function getNodeWithBusinessNode(node:BroPTNode):IPTNode; 
      function clearDropzone():void;

      function set title(value:String):void;
      function set isTitleVisible(value:Boolean):void;
      function set emptyText(value:String):void;
      function set isVisible(value:Boolean):void;
      function get isVisible():Boolean;
      function set deckType(value:uint):void;
      function set isEnabled(value:Boolean):void;
      function get isEnabled():Boolean;
      function get isHighlighted():Boolean;
      function get isScollEffectPlaying():Boolean;
      function isDropZone():Boolean;

      function goToNextPage():void;
      function goToPreviousPage():void;
      function goToPageWithBusinessNode(node:BroPTNode):void;   
      function isFirstPage():Boolean;
      function isLastPage():Boolean;
      function set isNavButtonVisible(value:Boolean):void;
      function getPearlNumber():int;
      function get isClearing():Boolean;

      function refreshAtAnimationEnds():void;
   }
}