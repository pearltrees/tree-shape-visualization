package com.broceliand.ui.renderers.pageRenderers{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.visual.IPTVisualGraph;
   import com.broceliand.graphLayout.visual.PTVisualNodeBase;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.ui.GeometricalConstants;
   import com.broceliand.ui.effects.ChangePropertyEffect;
   import com.broceliand.ui.effects.EffectToggler;
   import com.broceliand.ui.effects.ForwardBackwardTogglerBase;
   import com.broceliand.ui.effects.VariableDurationEffectToggler;
   import com.broceliand.ui.interactors.InteractorRightsManager;
   import com.broceliand.ui.model.NewsLabelModel;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.renderers.MoveNotifier;
   import com.broceliand.ui.renderers.PageRendererBase;
   import com.broceliand.ui.renderers.TitleRenderer;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlBase;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlNotificationState;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.BroceliandMath;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   
   import mx.controls.Image;
   import mx.core.UIComponent;

   public class PearlRendererBase extends PageRendererBase  {

      protected var _pearl:PearlBase = null;
      private var _senderInfo:String = null;
      protected var _animationFactor:Number = 1;
      private var _titleRenderer:TitleRenderer;
      
      protected var _remoteResourceManager:IRemoteResourceManager;
      protected var _stateManager:PearlRendererStateManager;
      private var _forbidMove:Boolean=false; 
      private var _haloFilters:Array = null;
      protected var _showHalo:Boolean = false;
      private var _movNotifier:MoveNotifier;
      private var _hideTitleToDisplayInfo:Boolean = false;
      private var _zoomEffectToggler:EffectToggler;

      protected var _showHaloExternal:Boolean = false;
      private var _haloChangedExternal:Boolean = false;
      
      function PearlRendererBase(stateManager:PearlRendererStateManager, remoteResourceManager:IRemoteResourceManager){
         super();
         _stateManager = stateManager;
         _remoteResourceManager = remoteResourceManager;
         _movNotifier = new MoveNotifier(this);    
         var cpe:ChangePropertyEffect = new ChangePropertyEffect(this, "animationZoomFactor");
         cpe.fromValue = 1;
         cpe.toValue = GeometricalConstants.HIGHLIGHT_ZOOM_FACTOR;
         cpe.duration = 90;
         _zoomEffectToggler = new VariableDurationEffectToggler(cpe, 50, 50, true, false); 
      }

      public function get remoteResourceManager():IRemoteResourceManager {
         return _remoteResourceManager;
      }
      
      public function isPointOnPearl(point:Point):Boolean {
         if(!pearl) return false;
         var topLeft:Point = localToGlobal(new Point(pearl.x, pearl.y));
         var radius:Number = scaleX * pearl.pearlWidth / 2.0;
         topLeft.offset(radius, radius);
         return (BroceliandMath.getDistanceBetweenPoints(topLeft, point) < radius);
      }

      public function excite():void { 
         pearl.warm();
      }
      
      public function relax():void{
         pearl.unwarm();
      }

      protected function instanciatePearl():void{
         throw new Error("instanciatePearl not implemented");
      }
      
      public function forbidMove(isMoveForbidden:Boolean):void {
         _forbidMove = isMoveForbidden;
      }

      override protected function createChildren():void {
         super.createChildren();
         instanciatePearl();
         _pearl.x = GeometricalConstants.PEARL_X;
         _pearl.y = GeometricalConstants.PEARL_Y;
         addChild(_pearl);
         
      }
      
      public function get moveNotifier():MoveNotifier {
         return _movNotifier;   
      }
      
      private function handleNewsButton():void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         var bnode:BroPTNode = node.getBusinessNode() as BroPTNode;
         (this as IUIPearl).markHasNotificationsForNewLabel(bnode && am.notificationCenter.newsButtonModel.hasNewLabel(bnode));
      }
      
      override protected function commitProperties():void{
         super.commitProperties();
         if(node && !node.isEnded()){
            if (pearlNotificationState) {
               handleNewsButton();
            }
            if(_vnode){
               _pearl.node = _vnode.node as IPTNode;
            }
         }
         updateVisualState();

         if (_haloChangedExternal) {
            _haloChangedExternal = false;
            if(_showHaloExternal){
               if(!_haloFilters){
                  _haloFilters = getHaloFilters();
               }
               filters = _haloFilters;
            }
            else{
               filters = null;
            }
         }
         
      }		
      protected function updateVisualState():void {
         
      }
      
      public function get pearl():PearlBase{
         return _pearl;
      }
      
      override public function invalidateProperties():void{
         super.invalidateProperties();
         if(pearl){
            pearl.invalidateProperties();	
         }
      }
      
      override public function invalidateDisplayList():void{
         super.invalidateDisplayList();
         if(pearl){
            pearl.invalidateDisplayList();	
         }
      }
      
      public function refresh():void{
         invalidateProperties();
         invalidateDisplayList();
      }
      
      public function canBeMoved():Boolean {
         if (_forbidMove) {
            return false;
         }
         if(node.isTopRoot){

            return false;
         }

         var rightsManager:InteractorRightsManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.interactorRightsManager;
         if(rightsManager.userHasRightToMoveNode(node)){
            return true;
         }else{
            return false;
         }
      }

      public function canBeCopied():Boolean {

         var rightsManager:InteractorRightsManager = ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.interactorRightsManager;
         if(rightsManager.canAddNodeToMyAccount(businessNode)) {
            return true ;
         }else{
            return false;
         }
      }

      public function get senderInfo():String {
         return _senderInfo;
      }
      
      public function set senderInfo(value:String):void {
         _senderInfo = value;
      }

      protected function belongsToSelectedTree():Boolean{
         var navigationManager:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         if(!businessNode){
            return false;
         }
         var ownerTree:BroPearlTree = businessNode.owner;
         if(!ownerTree){
            return false;
         }
         
         var selectedTree:BroPearlTree = navigationManager.getSelectedTree();
         
         if(businessNode is BroPTRootNode){
            
            var ownerTreeOneUp:BroPearlTree = (businessNode as BroPTRootNode).owner.refInParent.owner;
            if(ownerTreeOneUp == selectedTree){
               return true;
            }
         }        
         return (ownerTree == selectedTree);
      }
      
      internal function getTitleIcon():Image{
         return null;   
      }

      public function hasAvatar():Boolean{
         if(!(this is PagePearlRenderer)){
            return true;
         }else{
            return false;
         }
      }
      
      public function get titleRenderer():TitleRenderer {
         return _titleRenderer;
      }
      public function set titleRenderer(value:TitleRenderer):void {
         if(_titleRenderer != value) {          
            if(_titleRenderer) {
               _movNotifier.removeMoveListener(_titleRenderer);
            }
            _titleRenderer = value;
            if (_titleRenderer) {
               _movNotifier.addMoveListener(_titleRenderer);
               _titleRenderer.reposition();
            }
         }
      }
      
      override protected function clearMemory():void {
         
         _remoteResourceManager=null;
         _pearl.end();
         _pearl = null;
         _senderInfo=null;
         _movNotifier.end();
         super.clearMemory();
      }
      
      public function refreshAvatar():void{
         _pearl.refreshAvatar();
      }
      
      public function refreshLogo():void{
         _pearl.refreshLogo();
      }

      public function get isMoving ():Boolean
      {
         return PTVisualNodeBase(vnode).isMoving;
      }

      public function getShowHalo():Boolean {
         return _showHalo;
      }

      public function setShowHalo(value:Boolean):void {
         if(_showHalo != value){
            _showHalo = value;
            if(_showHalo){
               if(!_haloFilters){
                  _haloFilters = getHaloFilters();
               }
               filters = _haloFilters;
            }else{
               filters = null;
            }
         }
      }

      public function setShowHaloExternal(value:Boolean):void {
         if(_showHaloExternal != value){
            _showHaloExternal = value;
            _haloChangedExternal = true;
            invalidateProperties();
         }
      }
      
      protected function getHaloFilters():Array{
         var color:Number = ColorPalette.getInstance().pearltreesDarkColor;
         var angle:Number = 0;
         var alpha:Number = 0.8;
         var blurX:Number = 35;
         var blurY:Number = 35;
         var distance:Number = 0;
         var strength:Number = 2;
         var inner:Boolean = false;
         var knockout:Boolean = false;
         var quality:Number = BitmapFilterQuality.MEDIUM;
         var filter:DropShadowFilter = new DropShadowFilter(distance,
            angle,
            color,
            alpha,
            blurX,
            blurY,
            strength,
            quality,
            inner,
            knockout);
         var ret:Array = new Array();
         ret.push(filter);
         return ret;
      }

      override public function set alpha(value:Number):void{
         if (value != super.alpha) {
            super.alpha = value;
         }
      }
      
      override public function move(x:Number, y:Number):void{
         if (x!=super.x ||y !=super.y) {
            super.move(x, y);
            if (_pearl) {
               if (vnode && !IPTVisualGraph(vnode.vgraph).isSilentReposition()) {
                  
                  _pearl.repositionRing();
               }
            }

         }

      }
      public function hideTitleToDisplayInfo(hide:Boolean):void {
         if (_hideTitleToDisplayInfo != hide) {
            _hideTitleToDisplayInfo = hide;
            moveNotifier.afterMove(); 
            invalidateProperties();
         }
      }
      public function isTitleHiddenToDisplayInfo():Boolean {
         return _hideTitleToDisplayInfo;   
      }
      public function get uiComponent():UIComponent {
         return this;
      }
      public function get pearlNotificationState():PearlNotificationState {
         if (_pearl) { 
            return _pearl.pearlNotificationState; 
         }
         return null;
      }
      
      public function restoreInitialState():void {
         _hideTitleToDisplayInfo = false;
         _forbidMove = false;
         _showHalo = false;
         _showHaloExternal = false;
         _haloChangedExternal = false;
         titleRenderer = null;
         filters = null;
         
         if (_pearl) {
            _pearl.restoreInitialState();
         }
      }
      public function isBigger():Boolean {
         return _zoomEffectToggler.targetState == ForwardBackwardTogglerBase.PLAYED_FORWARD;
      }
      public function setBigger(zoom:Boolean):void {
         if (zoom) {
            _zoomEffectToggler.playForward();
         } else {
            _zoomEffectToggler.playBackward();
         }
      }
   }
}