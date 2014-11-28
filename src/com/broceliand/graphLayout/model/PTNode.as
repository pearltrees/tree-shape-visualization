package com.broceliand.graphLayout.model
{
   import com.broceliand.graphLayout.visual.IPTVisualNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlBar.deck.Deck;
   import com.broceliand.ui.pearlBar.deck.IDeckModel;
   
   import flash.events.Event;
   
   import org.un.cava.birdeye.ravis.graphLayout.data.IEdge;
   import org.un.cava.birdeye.ravis.graphLayout.data.Node;
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;
   
   public class PTNode extends Node implements IPTNode
   {
      
      private var _calculatingDescendant:Boolean= false;
      private static const MAX_DESCENDANTS_DEPTH_ALLOWED:Number = 100;
      public static const DOCKED_CHANGE_EVENT:String = "dockedChange";

      private var _dock:IDeckModel = null;
      protected var _businessNode:BroPTNode;
      private var _containingPearlTreeModel:IPearlTreeModel;
      protected var _numDescendantCache:Number = 0;
      private var _isDisappearing:Boolean;

      public function PTNode(id:int, sid:String, vn:IVisualNode, bnode:BroPTNode)  {
         super(id, sid, vn, bnode);
         _businessNode = bnode;
         _isDisappearing = false;
         if (_businessNode) {
            _businessNode.graphNode = this;
         }
         
      }
      public function get containingPearlTreeModel():IPearlTreeModel {
         var pn:IPTNode = parent;
         var i:int =0;
         while (pn!= null && pn != this) {
            i++;
            if (pn is PTRootNode && (PTRootNode(pn).isOpen() || PTRootNode(pn).containedPearlTreeModel.openingState == OpeningState.CLOSING)) {
               _containingPearlTreeModel = (pn as PTRootNode).containedPearlTreeModel;
               break; 
            } else { 
               if (pn is EndNode) {
                  pn = pn.rootNodeOfMyTree;
               }
               pn =pn.parent;
            } 
            if (i>1000) {
               trace("PTNOde.containingPearlTreeModel : Error loops in PTNode");
               break;
            }
         }
         return _containingPearlTreeModel;
      }
      
      public function set containingPearlTreeModel(o:IPearlTreeModel):void {
         _containingPearlTreeModel =o;
      }
      
      public function get isInDropZone():Boolean{
         
         if (_dock){
            return _dock.isDropZone();
         } else {
            return false;
         }  
      } 

      public function get treeOwner():BroPearlTree {
         return _businessNode.owner;
      }
      
      public function addOutEdgeAtIndex(e:IEdge, index:int):void {
         /* same story here */
         if(e.othernode(this) == null) {
            throw Error("Edge:"+e.id+" has no toNode");
         }
         
         _successors.splice(index,0, e.othernode(this));
         _outEdges.splice(index,0,e); 
         
      }
      
      public function updatingNumberOfDescendant():Number{
         if(_calculatingDescendant ){
            throw new Error("loop in tree");
         }	
         _calculatingDescendant = true; 	
         try {	
            var num:Number = 0;
            if(successors){
               var len:Number = successors.length;
               
               num += len;
               
               for(var i:Number = 0; i < len; i++){
                  if ((successors[i] as IPTNode).vnode != null && (successors[i] as IPTNode).vnode.isVisible) {
                     num += successors[i].updatingNumberOfDescendant();
                  }
               }
               
            }
            _numDescendantCache = num;
         } finally {
            _calculatingDescendant = false;
         }
         return num;
         
      }
      
      public function get rootNodeOfMyTree():IPTNode{
         if(this is PTRootNode || isDocked){
            return this;
         }
         var deducedRootNode:IPTNode = null;
         var immediateParent:IPTNode = this;
         while(!deducedRootNode){
            immediateParent = immediateParent.predecessors[0] as IPTNode;
            if((!immediateParent)){
               trace("error getting rootNodeOfMyTree, missing parent");
               deducedRootNode = this;
            }else{
               if(immediateParent is PTRootNode && immediateParent.treeOwner == treeOwner){
                  deducedRootNode = immediateParent;
               }
            }
            
         }
         return deducedRootNode;

      }
      
      public function get parent():IPTNode {
         if (predecessors!=null && predecessors.length>0) {
            return predecessors[0]; 
         } 
         return null;  
      }
      
      public function get edgeToParent():IEdge{
         if(inEdges && inEdges[0]){
            return inEdges[0] as IEdge;
         }else{
            return null;
         }
      }      
      
      public function isLastChild():Boolean {
         if (!parent || parent.successors[parent.successors.length -1] == this) {
            return true;
         }   
         return false;
      }
      public function isOnLastBranch():Boolean {
         if (isLastChild()) {
            if (parent is PTRootNode) {
               return true;
            } else return (parent==null? true:parent.isOnLastBranch());
         } else return false;
      }

      protected function getDesc(model:IPearlTreeModel):Array{
         
         if (!model) {
            return new Array(this);
         }
         var ret:Array = new Array();
         var nodesToProcess:Array = new Array();
         nodesToProcess.push(this);
         while(nodesToProcess.length > 0){
            var processedNode:IPTNode = nodesToProcess.pop();
            ret.push(processedNode);
            if(processedNode != model.endNode || processedNode == this){
               for each(var successor:IPTNode in processedNode.successors){
                  nodesToProcess.push(successor);
               }
            }
         }
         return ret;
      }
      
      public function getDescendantsAndSelf():Array{
         return getDesc(containingPearlTreeModel);
      }
      
      public function get renderer():IUIPearl{
         if(_vnode && _vnode.view){
            return _vnode.view as IUIPearl;
         }else{
            return null;
         }	
      }
      
      public function get isTopRoot():Boolean{
         return false;
      }
      
      public function getDock():IDeckModel {
         return _dock;
      }
      
      public function dock(dock:IDeckModel):void{
         if(_dock != dock){
            if(_dock){
               undockInternal(false, false);
            }
            _dock = dock;
            dock.dockNode(this);
            if (pearlVnode) {
               pearlVnode.pearlView.setScale(1.0);
            }
            dispatchEvent(new Event(DOCKED_CHANGE_EVENT));
         }         
      }
      
      public function undock(updateSelection:Boolean = true):void{
         undockInternal(true, updateSelection);             
      }
      private function undockInternal(restoreScale:Boolean, updateSelection:Boolean= true):void {
         if(_dock){
            var tmpDock:IDeckModel = _dock;
            _dock = null;
            tmpDock.undockNode(this, false, updateSelection);
            if (restoreScale && pearlVnode) {
               pearlVnode.pearlView.setScale(pearlVnode.vgraph.scale);
            }
            dispatchEvent(new Event(DOCKED_CHANGE_EVENT));
         }   
      }
      
      public function get isDocked():Boolean{
         return (_dock != null);
      }
      
      override public function set vnode(v:IVisualNode):void {
         super.vnode = v;
         if(isDocked && pearlVnode) {

            pearlVnode.pearlView.setScale(Deck.PEARL_SCALE);
            
         }
      }
      
      public function get pearlVnode():IPTVisualNode {
         return vnode as IPTVisualNode;
      }
      
      public function getBusinessNode():BroPTNode{
         return _businessNode;
      }      
      
      public function isRendererInScreen():Boolean {
         if (!pearlVnode) {
            return false;
         }
         if (pearlVnode.view==null) {
            return false;
         }
         
         if (pearlVnode.viewX< -pearlVnode.pearlView.pearlWidth|| pearlVnode.viewX> pearlVnode.vgraph.width) {
            
            return false;
         }
         if (vnode.viewY<-pearlVnode.pearlView.pearlWidth || pearlVnode.viewY> pearlVnode.vgraph.height) {
            return false;
         }  
         return true;
         
      }
      public function end():void {
         vnode =null;
         if (_businessNode && _businessNode.graphNode == this) {
            _businessNode.graphNode = null;
         }
         
         _businessNode = null;
         
         vnode = null;
         _containingPearlTreeModel = null;
      }
      public function get name():String {
         var node:BroPTNode = getBusinessNode();
         if (node) {
            return node.title
         } else {
            if (treeOwner) {
               return treeOwner + "  "+toString();
            }
         }
         return "no bnode";
      }
      
      override public function toString():String {
         return name;
      }
      
      public function nodeInstanceName():String {
         return super.toString();
      }
      public function wasSameNode(node:IPTNode):Boolean {
         if (node is PTRootNode || node is DistantTreeRefNode) {
            var bnode:BroPTNode = getBusinessNode();
            if (!(bnode is BroPTWDistantTreeRefNode)) { 
               return getBusinessNode().persistentID == node.getBusinessNode().persistentID;
            }
         }
         return false; 
      }
      public function isEnded():Boolean {
         if (!vnode) {
            return true;
         }
         return false;
      }
      public function getDescendantWeight():Number {
         return _numDescendantCache;
      }
      public function getChildCount():Number {
         if (this.successors) {
            return this.successors.length;
         } else {
            return 0;
         }
      }
      public function get isDisappearing():Boolean {
         return _isDisappearing;      
      }
      public function set isDisappearing(isDisappearing:Boolean):void {
         _isDisappearing = isDisappearing;
      }
      
   }
}
