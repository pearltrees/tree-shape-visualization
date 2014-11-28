package com.broceliand.ui.pearlBar.deck {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.assets.PearlDeckAssets;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.graphLayout.model.PageNode;
   import com.broceliand.ui.button.PTButton;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.util.AssetsManager;
   import com.broceliand.ui.util.ColorPalette;
   import com.broceliand.util.GraphicalActionSynchronizer;
   import com.broceliand.util.IAction;
   
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   
   import mx.containers.Box;
   import mx.containers.Canvas;
   import mx.controls.Label;
   import mx.effects.Effect;
   import mx.effects.MaskEffect;
   import mx.effects.Move;
   import mx.effects.Parallel;
   import mx.events.EffectEvent;

   public class Deck extends Canvas implements IAction {
      
      private static const DECK_HEIGHT:Number = 58;
      public static const PEARL_SCALE:Number = 0.67;
      public static const EMBED_PEARL_SCALE:Number = 0.56;
      public static const NAV_BUTTON_WIDTH:Number = 25;
      private static const REPOSITION_EFFECT_TIME:Number = 200;

      private var modelChanged:Boolean;
      private var _model:IDeckModel;
      
      private var _nextPageButton:PTButton;
      private var _previousPageButton:PTButton;
      
      private var refreshDisplay:Boolean;
      private var _lastRedrawWidth:Number;
      private var _lastRedrawY:Number;
      private var _scrollMasks:Vector.<DisplayObject>;
      private var _moveEffects:Parallel;

      public function Deck() {
         super();
         visible = includeInLayout = false;
         height = DECK_HEIGHT;
         clipContent = false;
         _scrollMasks = new Vector.<DisplayObject>;
         
         this.setStyle("backgroundColor",0xFFFFFF);
         this.setStyle("backgroundAlpha",0);
      }

      protected function get model():DeckModel {
         return _model as DeckModel;
      }
      
      public function get deckModel():IDeckModel {
         if(!_model) {
            deckModel = new DeckModel();
         }
         return _model;
      }
      public function set deckModel(value:IDeckModel):void {
         if(value != _model) {
            if(_model) {
               _model.removeEventListener(DeckModel.MODEL_CHANGE, onModelChange);
            }
            _model = value;
            _model.addEventListener(DeckModel.MODEL_CHANGE, onModelChange);
            onModelChange(null);
         }
      }
      
      private function onModelChange(event:Event):void {
         modelChanged = true;
         invalidateProperties();
         invalidateSize();
         invalidateDisplayList();
      }

      override protected function createChildren():void {
         super.createChildren();

         _nextPageButton = new PTButton();
         _nextPageButton.width=49;
         _nextPageButton.height=54;
         _nextPageButton.setStyle("right", 0);
         _nextPageButton.setStyle("top", 0);
         _nextPageButton.setStyle("upSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW));
         _nextPageButton.setStyle("downSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW_OVER));
         _nextPageButton.setStyle("overSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW_OVER));
         _nextPageButton.setStyle("disabledSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW));
         _nextPageButton.addEventListener(MouseEvent.CLICK, onClickNextPageButton);
         addChild(_nextPageButton);
         
         _previousPageButton = new PTButton();
         _previousPageButton.width=49;
         _previousPageButton.height=54;
         _previousPageButton.setStyle("left", 0);
         _previousPageButton.setStyle("top", 0);
         _previousPageButton.setStyle("upSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW));
         _previousPageButton.setStyle("downSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW_OVER));
         _previousPageButton.setStyle("overSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW_OVER));
         _previousPageButton.setStyle("disabledSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW));
         _previousPageButton.addEventListener(MouseEvent.CLICK, onClickPreviousPageButton);
         addChild(_previousPageButton);
         
         stage.addEventListener(Event.RESIZE, onStageResize);
      }
      
      private function getFreeEffectMask():DisplayObject {
         var freeMask:Box;
         for each(var mask:Box in _scrollMasks) {
            if(!mask.visible) {
               mask.visible = true;
               freeMask = mask;
               break;
            }
         }
         if(!freeMask) {
            freeMask = createScrollMask();
         }
         
         if (!model.isNavButtonVisible){
            freeMask.setStyle("left", 0);
            freeMask.setStyle("right", 0);
         }else{
            freeMask.setStyle("left", 25);
            freeMask.setStyle("right", 25);
         }
         return freeMask;
      }
      
      private function createScrollMask():Box {
         var scrollMask:Box = new Box();
         scrollMask.setStyle("top", 0);
         scrollMask.setStyle("bottom", 0);
         scrollMask.setStyle("backgroundColor", 0x000000);
         addChild(scrollMask);
         _scrollMasks.push(scrollMask);
         return scrollMask;
      }

      protected function get extraPaddingLeft():Number {
         return 0;
      }
      
      private function releaseAllMasks():void {
         for each(var mask:DisplayObject in _scrollMasks) {
            mask.visible = false;
         }
      }
      
      override protected function commitProperties():void {
         super.commitProperties();
         var am:ApplicationManager = ApplicationManager.getInstance();
         visible = includeInLayout = model.isVisible;
         
         if(modelChanged && visible) {
            modelChanged = false;
            
            _previousPageButton.enabled = !model.isFirstPage() && model.isEnabled;
            _previousPageButton.visible = model.isNavButtonVisible && !am.isEmbed();
            _nextPageButton.visible = model.isNavButtonVisible && !am.isEmbed();
            _nextPageButton.enabled = !model.isLastPage() && model.isEnabled;
            refreshDisplay = true;
            if (model.isHighlighted){
               _previousPageButton.setStyle("upSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW_OVER));
               _previousPageButton.setStyle("disabledSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW_OVER));
               _nextPageButton.setStyle("upSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW_OVER));
               _nextPageButton.setStyle("disabledSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW_OVER));
            }else{
               _previousPageButton.setStyle("upSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW));
               _previousPageButton.setStyle("disabledSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_LEFT_ARROW));
               _nextPageButton.setStyle("upSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW));
               _nextPageButton.setStyle("disabledSkin", AssetsManager.getEmbededAsset(PearlDeckAssets.DROP_ZONE_RIGHT_ARROW));
            }
         }
      }

      private function refreshNodesPosition(deckGlobalPosition:Point):void {
         if(model.isScollEffectPlaying) return;
         
         model.refreshNodesToShow();
         
         _nextPageButton.enabled = !model.isLastPage() && model.isNavButtonVisible;
         _previousPageButton.enabled = !model.isFirstPage() && model.isNavButtonVisible;
         
         var nodesToShow:Vector.<IPTNode> = model.nodesToShow;
         var nodesCount:Number = nodesToShow.length;
         var node:IPTNode;
         var nodeView:IUIPearl;
         var i:uint;
         var nodeX:Number;
         var nodeY:Number;
         var mask:MaskEffect;
         var move:Move;
         _moveEffects = new Parallel();
         var gas:GraphicalActionSynchronizer = new GraphicalActionSynchronizer(this);
         if(nodesCount > 0) {
            var extraWidth:Number = 0;
            
            if(!model.isLastPage()) {
               extraWidth = Math.floor((model.availableWidth - (nodesCount * model.itemWidth)) / nodesCount);
            }
            
            var nodeWidth:Number = model.itemWidth + extraWidth;
            
            var nodesCurrentlyHidden:Vector.<IPTNode> = new Vector.<IPTNode>();
            for each(node in nodesToShow) {
               nodeView = (node.pearlVnode)?node.pearlVnode.pearlView:null;
               if(nodeView && !nodeView.visible) {
                  nodesCurrentlyHidden.push(node);
               }
            }
            
            for (i=0; i < nodesCount; i++) {
               node = nodesToShow[i];
               nodeView = (node.pearlVnode)?node.pearlVnode.pearlView:null;
               if(!nodeView) continue;
               
               if(nodeView.getScale() != PEARL_SCALE && !model.repositionWithEffect) continue;            

               var navButtonSpace:Number = (model.isNavButtonVisible)?NAV_BUTTON_WIDTH:0;
               nodeX = 20 + navButtonSpace + extraPaddingLeft + deckGlobalPosition.x + i * nodeWidth; 
               nodeY = deckGlobalPosition.y + 2;
               
               if(nodeX != nodeView.x || nodeY != nodeView.y) {
                  if(model.repositionWithEffect || model.playScrollEffect) {                 
                     move = new Move(nodeView);
                     move.duration = REPOSITION_EFFECT_TIME;
                     move.xTo = nodeX;
                     move.yTo = nodeY;
                     if(model.playScrollEffect == DeckModel.SCROLL_EFFECT_NEXT) {
                        move.xFrom = nodeX + model.availableWidth;
                        move.yFrom = nodeY;
                     }else if(model.playScrollEffect == DeckModel.SCROLL_EFFECT_PREVIOUS) {
                        move.xFrom = nodeX - model.availableWidth;
                        move.yFrom = nodeY;
                     }else if(!nodeView.visible) {
                        move.xFrom = nodeX + (nodesCurrentlyHidden.length * nodeWidth);
                        move.yFrom = nodeY;
                     }else{
                        move.xFrom = nodeView.x;
                        move.yFrom = nodeView.y;
                     }
                     if(model.playScrollEffect || !nodeView.visible) {
                        nodeView.mask = getFreeEffectMask();
                        nodeView.titleRenderer.mask = getFreeEffectMask();
                     }
                     _moveEffects.addChild(move);
                     if(!nodeView.uiComponent.initialized) {
                        gas.registerComponentToWaitForCreation(nodeView.uiComponent);
                     }
                     if(!nodeView.titleRenderer.initialized) {
                        gas.registerComponentToWaitForCreation(nodeView.titleRenderer);
                     }
                  }else{
                     nodeView.move(nodeX, nodeY);
                  }
               }
               nodeView.visible = true;
               nodeView.refresh();
            }
         }     
         model.repositionWithEffect = false;
         
         var nodesToHideWithEffect:Vector.<IPTNode> = model.nodesToHideWithEffect;
         nodesCount = (nodesToHideWithEffect)?nodesToHideWithEffect.length:0;
         if(nodesCount > 0) {
            for (i=0; i < nodesCount; i++) {
               node = nodesToHideWithEffect[i];
               nodeView = (node.pearlVnode)?node.pearlVnode.pearlView:null;
               if(!nodeView) continue;
               nodeX = nodeView.x;
               
               nodeY = nodeView.y;
               if(model.playScrollEffect == DeckModel.SCROLL_EFFECT_NEXT) {
                  nodeX -= model.availableWidth;
               }else if(model.playScrollEffect == DeckModel.SCROLL_EFFECT_PREVIOUS) {
                  nodeX += model.availableWidth;
               }else{
                  nodeX += nodesCount * nodeWidth;
               }
               if(nodeX != nodeView.x || nodeY != nodeView.y) {
                  move = new Move(nodeView);
                  move.duration = REPOSITION_EFFECT_TIME;
                  move.xTo = nodeX;
                  move.yTo = nodeY;
                  nodeView.mask = getFreeEffectMask();
                  nodeView.titleRenderer.mask = getFreeEffectMask();
                  _moveEffects.addChild(move);
                  if(!nodeView.uiComponent.initialized) {
                     gas.registerComponentToWaitForCreation(nodeView.uiComponent);
                  }
                  if(!nodeView.titleRenderer.initialized) {
                     gas.registerComponentToWaitForCreation(nodeView.titleRenderer);
                  }
               }            
            }
         }
         
         if(_moveEffects.children.length > 0) {
            model.isScollEffectPlaying = true;
         }
         gas.performActionAsap();
      }
      
      public function performAction():void {
         if(_moveEffects.children.length > 0) {
            _moveEffects.addEventListener(EffectEvent.EFFECT_END, onMoveEffectsEnd);
            callLater(_moveEffects.play);
         }      
      }
      
      private function onMoveEffectsEnd(event:EffectEvent):void {
         for each(var effect:Effect in _moveEffects.children) {
            var nodeView:IUIPearl = effect.target as IUIPearl;
            nodeView.mask = null;
            if(nodeView.titleRenderer) {
               nodeView.titleRenderer.mask = null;
            }
         }
         releaseAllMasks();
         model.isScollEffectPlaying = false;
      }
      
      private function onStageResize(event:Event):void {
         callLater(onModelChange, [null]);
      }
      
      override protected function updateDisplayList(w:Number, h:Number):void {
         super.updateDisplayList(w, h);

         model.availableWidth = w - (model.isNavButtonVisible? NAV_BUTTON_WIDTH * 2 : 0) - 10;
         var deckGlobalPosition:Point = localToGlobal(new Point());
         model.defaultUndockPosition.x = deckGlobalPosition.x + (w / 2) - 20;
         model.defaultUndockPosition.y = deckGlobalPosition.y - 50;
         
         if(_lastRedrawWidth != w || _lastRedrawY != deckGlobalPosition.y || refreshDisplay) {
            refreshDisplay = false;
            _lastRedrawWidth = w;
            _lastRedrawY = deckGlobalPosition.y;

            drawBackground(w, h);

            refreshNodesPosition(deckGlobalPosition);
         }
      }   

      protected function drawBackground(w:Number, h:Number):void {
         
      }
      
      private function getTitleFilters():Array {
         var color:int = ColorPalette.getInstance().backgroundColor;
         var angle:Number = 0;
         var alpha:Number = 1;
         var blurX:Number = 6;
         var blurY:Number = 6;
         var distance:Number = 0;
         var strength:Number = 10;
         var inner:Boolean = false;
         var knockout:Boolean = false;
         var quality:Number = BitmapFilterQuality.MEDIUM;
         var filter:DropShadowFilter = new DropShadowFilter(distance,angle,color,alpha,blurX,blurY,strength,quality,inner,knockout);
         return [filter];
      }

      private function onClickNextPageButton(event:Event):void {
         if(!model.isScollEffectPlaying) {
            model.goToNextPage();
         }
      }
      
      private function onClickPreviousPageButton(event:Event):void {
         if(!model.isScollEffectPlaying) {
            model.goToPreviousPage();
         }
      }
      
   }
}