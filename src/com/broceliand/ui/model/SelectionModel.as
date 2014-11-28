package com.broceliand.ui.model
{
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTWPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.IBroPTWNode;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.navigation.INavigationManager;
   import com.broceliand.pearlTree.navigation.NavigationEvent;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.pearlWindow.PWModel;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   import mx.events.FlexEvent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
   
   public class SelectionModel  extends EventDispatcher
   {
      static public var NEW_NODE_SELECTED_EVENT:String = "NEW_NODE_SELECTED";
      static public var NODE_SELECTED_TWICE_EVENT:String = "NODE_SELECTED_TWICE_EVENT";
      static public var NEW_TREE_SELECTED_EVENT:String = "NEW_TREE_SELECTED";
      static public var NEW_USER_WORLD_SELECTED_EVENT:String = "NEW_USER_WORLD_SELECTED";
      
      private static const TIME_BEFORE_CENTERGRAPH_ON_FIRST_NAV:int = 850;
      private static const DURATION_CENTERGRAPH_ON_FIRST_NAV:int = 900;
      
      private var _highlightedTree:BroPearlTree;      
      private var _cacheSelectedNode:IPTNode;  		
      private var _selectedNode:IPTNode;
      private var _selectedNodeId:Number;
      private var _nodeBeingSelected:IPTNode;
      private var _selectedNodeOwnerOnLastSelect:BroPearlTree;
      private var _intersection:int = -1;
      private var _selectedFromNavBar:Boolean;
      
      private var _openingTree:BroPearlTree;
      private var _navigationManager:INavigationManager;  
      
      private var _nodeSelectedTwice:Boolean = false;
      private var _crossingBusinessNode:BroPTNode;   
      
      private var _turnOffDisplayInfo:Boolean = false;
      private var _isCentering:Boolean = false;
      
      private var _pendingSelection : IPTNode = null; 

      public function SelectionModel(navigationModel:INavigationManager) {
         _navigationManager = navigationModel;
         _navigationManager.addEventListener(NavigationEvent.NAVIGATION_EVENT, updateSelectionOnNavigation);
      }

      public function selectNode(node:IPTNode , intersection:int=-1, dontCheckChangeInSelection:Boolean=false):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         _nodeBeingSelected = node;
         _openingTree = null;

         var bnode:BroPTNode;
         if (node is EndNode) {
            node = EndNode(node).rootNodeOfMyTree;
         } 
         if (node !=null) {
            bnode = node.getBusinessNode();   
         }

         if (node != null && node.isDocked) {

            if (node == _selectedNode) {
               _nodeSelectedTwice = true;
               dispatchEvent(new FlexEvent(NODE_SELECTED_TWICE_EVENT));
            }
            else {
               _nodeSelectedTwice = false;
               setSelectedNode(node);
               _intersection  = intersection;
               dispatchEvent(new FlexEvent(NEW_NODE_SELECTED_EVENT));  
            }
            return;
         }

         if ( isNodeMatchTheCurrentNavigation(node,intersection) || bnode is IBroPTWNode || bnode is BroNeighbourRootPearl) {
            if (node == _selectedNode && !dontCheckChangeInSelection) {
               if (node !=null) {
                  _nodeSelectedTwice = true;
                  dispatchEvent(new FlexEvent(NODE_SELECTED_TWICE_EVENT));
               }
            }  else {
               _nodeSelectedTwice = false;
               
               var hasNotReallyChanged:Boolean = node && node.getBusinessNode() && 
                  node.getBusinessNode().persistentID == _selectedNodeId && !(_selectedNode.getBusinessNode() is BroPTWPageNode);
               setSelectedNode(node);
               _intersection  = intersection;
               if (!hasNotReallyChanged)
                  dispatchEvent(new FlexEvent(NEW_NODE_SELECTED_EVENT));  
            }
            
         } 
         else {
            
            var user:User = _navigationManager.getSelectedUser();
            var focus:BroPearlTree = _navigationManager.getFocusedTree();
            var selectedTree:BroPearlTree=null; 

            if (bnode) {
               selectedTree = bnode.owner;
            }
            
            if (!user) {
               
               return;
            } else {
               if (!focus) {
                  trace ("no Focus tree available on node selection : "+node);
               } else {
                  if (!selectedTree) {
                     
                  } else if (!bnode) {
                     _navigationManager.goTo(focus.getMyAssociation().associationId, 
                        user.persistentId,  
                        focus.id,
                        selectedTree.id);
                  } else {
                     var playState:int = _navigationManager.getPlayState();
                     _navigationManager.goTo(focus.getMyAssociation().associationId, 
                        user.persistentId,
                        focus.id, 
                        selectedTree.id, 
                        bnode.persistentID, 
                        intersection, playState);
                  }
               }
            }         
         }
      }
      
      public function centerGraphOnCurrentSelectionWithPWDisplayed(displayPW:Boolean=true, withAnimation:Boolean= false, pwPanel:int = 1, highlightNotes:Boolean = false, centerPoint:Point = null, slowAnimation:Boolean = false):Boolean{
         var toBeCentered:Boolean = centerGraphOnNodeWithPWDisplayed(getSelectedNode(), displayPW, withAnimation, pwPanel, highlightNotes, centerPoint, slowAnimation);
         var navModel:INavigationManager = ApplicationManager.getInstance().visualModel.navigationModel;
         if    (!toBeCentered                    
            && !navModel.willShowPlayer) {    
            navModel.isFirstSelectionPerformed = true;
         }
         return toBeCentered;
      }
      
      public function centerGraphOnNodeWithPWDisplayed(node:IPTNode, displayPW:Boolean=true, withAnimation:Boolean= false, pwPanel:int = 1, highlightNotes:Boolean = false, centerPoint:Point = null, slowAnimation:Boolean = false):Boolean{
         
         if (node!= null && node.vnode!=null && node.vnode.isVisible && !_isCentering) {
            var vgraph:IVisualGraph=node.vnode.vgraph;
            var graphCenter:Point = vgraph.center;
            var point:Point = node.vnode.viewCenter;
            if (Math.abs(graphCenter.x-point.x)<3 &&  Math.abs(graphCenter.y -point.y)<3) {
               if(displayPW) {
                  openPWPanel(node, pwPanel, highlightNotes);
               }
               return false;
            } else {
               if(!centerPoint) centerPoint = graphCenter;
               
               if (centerPoint.x <1 && centerPoint.y<1) {
                  return false;
               }
               _isCentering = true;
               var am:ApplicationManager = ApplicationManager.getInstance();
               var navModel:INavigationManager = am.visualModel.navigationModel;
               var timeBeforeCenterGraph:int = (navModel.isFirstSelectionPerformed ? 100 : TIME_BEFORE_CENTERGRAPH_ON_FIRST_NAV);
               var centerGraphAnimationDuration:int = (navModel.isFirstSelectionPerformed ? (slowAnimation ? 500:100) : DURATION_CENTERGRAPH_ON_FIRST_NAV);
               new CenterGraphWithTimer(node, displayPW, withAnimation, this , timeBeforeCenterGraph, pwPanel, highlightNotes, centerPoint, centerGraphAnimationDuration);
               return true;
            }
         }
         return false;            
      }
      
      public static function openPWPanel(node:IPTNode, pwPanel:int = 1, highlightNotes:Boolean = false):void {
         var wc:IWindowController = ApplicationManager.getInstance().components.windowController;
         wc.setPearlWindowDocked(false);
         if (pwPanel == PWModel.CONTENT_PANEL) {
            wc.displayNodeInfo(node);
         }
         else if (pwPanel == PWModel.CROSS_PANEL) {
            wc.displayNodeCrosses(node);
         }
         else if (pwPanel == PWModel.CONNECTION_PANEL) {
            wc.displayConnectionList(node);
         }
         else if (pwPanel == PWModel.NOTE_PANEL) {
            wc.displayNodeNotes(node, false, false, highlightNotes);
         }
         else if (pwPanel == PWModel.SHARE_PANEL) {
            wc.displayNodeShare(node);
         }
         else if (pwPanel == PWModel.MOVE_PANEL) {
            wc.displayMoveNode(node);
         }
         else if (pwPanel == PWModel.MOVE_PRIVATE_PANEL) {
            wc.displayMovePrivateNode(node);
         }
            /*else if (pwPanel == PWModel.MOVE_PUBLIC_PANEL) {
            wc.displayMovePrivateNode(node);
            }*/
         else if (pwPanel == PWModel.COPY_PANEL) {
            wc.displayCopyNodeTo(node);
         }
         else if (pwPanel == PWModel.PICK_PANEL) {
            wc.displayPickNodeTo(node);
         }
         else if(pwPanel == PWModel.TEAM_LIST_PANEL) {
            wc.displayAuthorTeamList(node);
         }
         else if(pwPanel == PWModel.AUTHOR_PANEL) {
            wc.displayOrHideAuthorInfo(node);
         }
         else if(pwPanel == PWModel.TEAM_INFO_PANEL) {
            wc.displayOrHideTeamInfo(node, false, false, true);
         }
         else if (pwPanel == PWModel.TEAM_DISCUSSION_PANEL) {
            wc.displayTeamDiscussion(node, false, false, highlightNotes);
         }
         else if (pwPanel == PWModel.TREE_EDITO_PANEL) {
            wc.displayTreeEdito();
         }
         else if (pwPanel == PWModel.LIST_PRIVATE_MSG_PANEL) {
            wc.displayPrivateMessages(node);
         }
         else if (pwPanel == PWModel.SEND_PRIVATE_MSG_PANEL) {
            wc.displaySendPrivateMessage(node);
         } else if (pwPanel == PWModel.TEAM_FREEZE_MEMBER_PANEL) {
            wc.displayOrHideFreezeTeamMember(node, false, false, true);
         }
         else if (pwPanel == PWModel.FACEBOOK_INVITATION_DEFAULT_PANEL) {
            wc.displayFacebookInvitationDefault(node);
         }
         else if (pwPanel == PWModel.FACEBOOK_INVITATION_TEAMUP_PANEL) {
            wc.displayFacebookInvitationTeamUp(node);
         }
         else if (pwPanel == PWModel.CUSTOMIZATION_AVATAR_PANEL) {
            wc.displayCustomizeAvatar(node);
         }
         else if (pwPanel == PWModel.CUSTOMIZATION_LOGO_PANEL) {
            wc.displayCustomizeLogo(node);
         }
         else if (pwPanel == PWModel.CUSTOMIZATION_BACKGROUND_PANEL) {
            wc.displayCustomizeBackground(node);
         }
      }
      
      private function isNodeMatchTheCurrentNavigation(node:IPTNode, intersection:int):Boolean {
         var bnode:BroPTNode;
         if (node is EndNode) {
            node = EndNode(node).rootNodeOfMyTree;
         } 
         if (node !=null) {
            bnode = node.getBusinessNode();   
         }
         var mustUpdateSelection:Boolean =false;
         if ( _navigationManager.getSelectionIntersectionIndex() != intersection) {
            mustUpdateSelection =true;
         } 
         if (bnode!=null && _navigationManager.getSelectedTree() !=bnode.owner) {
            mustUpdateSelection = true;
         } else if (bnode==null && _navigationManager.getSelectedTree()!=null) {
            mustUpdateSelection=true;
         } 
         if (bnode != _navigationManager.getSelectedPearl()) {
            if (_navigationManager.getSelectedPearl()==null) {
               if (!(bnode is BroPTRootNode)) {
                  mustUpdateSelection = true;
               }
            } else {
               mustUpdateSelection=true
            }
         }
         return !mustUpdateSelection;
      }
      
      private function updateSelectionOnNavigation(event:NavigationEvent):void {
         
         if (isNodeMatchTheCurrentNavigation(_cacheSelectedNode,_navigationManager.getSelectionIntersectionIndex())) {
            if (_selectedNode != _cacheSelectedNode || _intersection != _navigationManager.getSelectionIntersectionIndex()) {
               selectNode(_cacheSelectedNode); 
               _intersection = _navigationManager.getSelectionIntersectionIndex();
               dispatchEvent(new FlexEvent(NEW_NODE_SELECTED_EVENT));
            };
            
         }

      } 

      public function getSelectedNode ():IPTNode
      {
         return _selectedNode;
      }
      
      private function setSelectedNode(node:IPTNode):void {
         if (_selectedNode != node) {
            var oldSelectedNode:IPTNode = _selectedNode;
            _selectedNode = node;
            if (_selectedNode && _selectedNode.getBusinessNode()) {
               _selectedNodeId = _selectedNode.getBusinessNode().persistentID;
            } else {
               _selectedNodeId = 0;
            }
            if (oldSelectedNode && oldSelectedNode.vnode && oldSelectedNode.vnode.view) {
               oldSelectedNode.vnode.view.invalidateProperties();
            }
         }
      }
      public function getIntersection ():int
      {
         return _intersection;
      }
      public function get nodeSelectedTwice():Boolean {
         return _nodeSelectedTwice;
      }
      
      public function set pendingSelection(value:IPTNode) : void {
         _pendingSelection = value;
      }
      
      public function flushPendingSelection(doSelectNode : Boolean = true) : void {
         if (_pendingSelection) {
            if (doSelectNode) {
               selectNode(_pendingSelection);
            }
            _pendingSelection = null;
         }
      }
      
      public function getCrossingBusinessNode():BroPTNode {
         return _crossingBusinessNode;
      }
      
      public function saveBusinessNodeToCenter(node:BroPTNode= null):void {
         if (node) {
            _crossingBusinessNode = node;
         } else {
            resetCrossingBusinessNode();
         }
      }
      public function saveCrossingBusinessNode(node:IPTNode = null):void {
         if(node == null){
            node = _selectedNode;
         }
         if (node) {
            _crossingBusinessNode = node.getBusinessNode();
         } else { 
            resetCrossingBusinessNode();
         }
      }
      public function resetCrossingBusinessNode():void {
         _crossingBusinessNode=null;
      }
      public function get nodeBeingSelected() :IPTNode {
         return _nodeBeingSelected;
      }
      override public function dispatchEvent(event:Event):Boolean {
         var ret:Boolean = super.dispatchEvent(event);
         resetAfterDispatch();
         return ret;
      }
      protected function resetAfterDispatch():void {
         _selectedFromNavBar=false;
      }
      public function set selectedFromNavBar (value:Boolean):void
      {
         _selectedFromNavBar = value;
      }
      
      public function get selectedFromNavBar ():Boolean
      {
         return _selectedFromNavBar;
         
      }
      public function set openingTree (value:BroPearlTree):void
      {
         _openingTree = value;
      }
      
      public function get openingTree ():BroPearlTree
      {
         return _openingTree;
      }
      
      public function highlightTree(tree:BroPearlTree):Boolean {
         if (_highlightedTree != tree){
            if (tree && tree.isDropZone()) {
               tree = null;
            }
            _highlightedTree = tree;
            return true;
         }
         return false;
      }
      public function getHighlightedTree():BroPearlTree {
         return _highlightedTree;
      }
      
      public function set turnOffDisplayInfo(value:Boolean):void{
         _turnOffDisplayInfo = value;
      }

      public function get turnOffDisplayInfo():Boolean{
         return _turnOffDisplayInfo;
      }            
      
      public function get isCentering():Boolean
      {
         return _isCentering;
      }
      
      public function set isCentering(value:Boolean):void
      {
         _isCentering = value;
      }

   }

}
import com.broceliand.ApplicationManager;
import com.broceliand.graphLayout.model.IPTNode;
import com.broceliand.graphLayout.visual.IPTVisualGraph;
import com.broceliand.pearlTree.model.BroPearlTree;
import com.broceliand.ui.controller.IWindowController;
import com.broceliand.ui.model.SelectionModel;
import com.broceliand.ui.pearl.IUIPearl;
import com.broceliand.ui.pearlWindow.PWModel;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Dictionary;
import flash.utils.Timer;

import mx.effects.Effect;
import mx.effects.Parallel;
import mx.events.EffectEvent;

import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualGraph;
import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

internal class CenterGraphWithTimer {
   
   private var _node:IPTNode;
   private var _displayPW :Boolean;
   private var  _withAnimation:Boolean;
   private var _pwPanel:int;
   private var _highlightNotes:Boolean;
   private var _centerPoint:Point;
   private var _selectionModel:SelectionModel;
   private var _animationDuration:int;
   
   public function CenterGraphWithTimer(node:IPTNode, displayPW:Boolean, withAnimation:Boolean, selectionModel:SelectionModel, delay:int=100, pwPanel:int=1, highlightNotes:Boolean=false, centerPoint:Point=null, animationDur:int = 300) {
      
      _node = node;
      _displayPW = displayPW;
      _withAnimation = withAnimation;
      _pwPanel = pwPanel;
      _highlightNotes = highlightNotes;
      _centerPoint = centerPoint;
      _selectionModel = selectionModel;
      _animationDuration = animationDur;
      
      var timer :Timer = new Timer(delay, 1);
      timer.addEventListener(TimerEvent.TIMER, centerOnTime);
      timer.start();
   }
   
   private function centerOnTime(event:TimerEvent):void{
      if (event) {      
         Timer(event.target).removeEventListener(TimerEvent.TIMER, centerOnTime);
      }
      _selectionModel.isCentering = false;
      
      var point:Point = null; 
      if (!_node.vnode) {
         return;
      }           
      point = _node.vnode.viewCenter;
      var vgraph:IPTVisualGraph=IPTVisualGraph(_node.vnode.vgraph);
      if (!_centerPoint) {
         _centerPoint = vgraph.center;
      }
      
      if (vgraph.origin.length ==0 && vgraph.currentRootVNode.viewCenter.length <10) {
         
         vgraph.offsetOrigin(0.5- vgraph.center.x, 0.5 - vgraph.center.y);
      }
      var deltaX:Number = _centerPoint.x-point.x;
      var deltaY:Number = _centerPoint.y-point.y;

      if (!_withAnimation) {

         if (new Point(deltaX, deltaY).length > 100) {
            var position:Dictionary = vgraph.PTLayouter.computeLayoutPositionOnly();
            vgraph.scroll(deltaX, deltaY);
            point  = position[_node.vnode];
            vgraph.origin.offset(-deltaX, -deltaY);
            deltaX = _centerPoint.x-point.x;
            deltaY = _centerPoint.y-point.y;
            vgraph.origin.offset(deltaX, deltaY)
         } else {
            vgraph.scroll(deltaX, deltaY);
         }
         dispatchFirstCenterPerformed();
         vgraph.refresh();
      } else {        
         var par:Parallel = new Parallel();
         var effect:Effect;
         for each (var vnode:IVisualNode in vgraph.visibleVNodes) {
            if (!IPTNode(vnode.node).isDocked) {
               var pearl:IUIPearl = vnode.view as IUIPearl;
               var zoomPoint:Point = pearl.positionWithoutZoom;
               effect = vgraph.moveNodeTo(vnode, zoomPoint.x + deltaX, zoomPoint.y +deltaY, _animationDuration, false);
               par.addChild(effect);
            }  
         }
         if (effect) {
            effect.addEventListener(EffectEvent.EFFECT_END, updateGraph);
            _selectionModel.isCentering = true;
         }
         else {
            showPWIfNeeded();
         }
         vgraph.offsetOrigin(deltaX, deltaY);
         par.play();
      }
      
      if (event) {
         event.updateAfterEvent();
      }
   }
   
   private function showPWIfNeeded():void {
      if (_displayPW) {
         SelectionModel.openPWPanel(_node, _pwPanel, _highlightNotes);
      }
      dispatchFirstCenterPerformed();
   }
   
   private function updateGraph(event:Event):void {
      if (_node.vnode) {
         _node.vnode.vgraph.refresh();
      }
      _selectionModel.isCentering = false;
      showPWIfNeeded();
      ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.updatePearlUnderCursorAfterCross();
   }
   
   private function dispatchFirstCenterPerformed():void {
      ApplicationManager.getInstance().visualModel.navigationModel.isFirstSelectionPerformed = true;
   }
} 