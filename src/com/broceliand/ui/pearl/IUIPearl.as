package com.broceliand.ui.pearl
{
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.graphLayout.visual.IScrollable;
   import com.broceliand.ui.renderers.MoveNotifier;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.renderers.factory.IPearlRecyclingManager;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlBase;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlNotificationState;
   import com.broceliand.util.IMoveOnValidation;
   
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   import mx.core.IUIComponent;
   import mx.core.UIComponent;
   
   public interface IUIPearl extends IScrollable, IUIComponent, IMoveOnValidation
   {
      
      function get pearlWidth():Number;
      function get pearlMaxWidth():Number;
      function get pearlCenter():Point;
      function get titleCenter():Point;
      
      function get uiComponent():UIComponent;

      function canBeMoved():Boolean;
      function canBeCopied():Boolean;
      function refresh():void;
      function get pearl():PearlBase;
      function removeChild(child:DisplayObject):DisplayObject;
      function addChild(child:DisplayObject):DisplayObject;
      function get titleRenderer():TitleRenderer;
      function set titleRenderer(value:TitleRenderer):void;

      function set senderInfo(value:String):void;
      function get senderInfo():String;
      function forbidMove(value:Boolean):void;
      function get isMoving():Boolean;
      function excite():void;
      function setInSelection(value:Boolean):void;
      function get node():IPTNode;
      function get vnode():IPTVisualNode;
      function relax():void;
      
      function setShowHalo(value:Boolean):void;
      function setShowHaloExternal(value:Boolean):void;
      function get updateCompletePendingFlag():Boolean;
      function invalidateProperties():void;
      function refreshAvatar():void;
      function hasAvatar():Boolean;
      function refreshLogo():void;
      function hideTitleToDisplayInfo(hide:Boolean):void;
      function isTitleHiddenToDisplayInfo():Boolean;
      function isPointOnPearlOrAddon(point:Point):Boolean;
      function isPointOnPearl(point:Point):Boolean;
      function end():void;
      function isEnded():Boolean;
      function get moveNotifier():MoveNotifier;
      function set pearlRecyclingManager(pearlRecyclingManager:IPearlRecyclingManager):void;
      function get pearlRecyclingManager():IPearlRecyclingManager;
      function get pearlNotificationState():PearlNotificationState;
      function isCreationCompleted():Boolean;
      function restoreInitialState():void;
      function markHasNotificationsForNewLabel(value:Boolean):void;

      function setScale(value:Number):void;
      function getScale():Number;
      
      function isBigger():Boolean;
      function setBigger(zoom:Boolean):void;
      function get animationZoomFactor():Number;
      function set animationZoomFactor(value:Number):void;
      function get positionWithoutZoom():Point;
      function moveWithoutZoomOffset(toX:Number, toY:Number):void;
      function isNewLabelVisible():Boolean;

      function showPadlock(isActive:Boolean, isTeam:Boolean):void;
      function hidePadlock():void;
   }
}