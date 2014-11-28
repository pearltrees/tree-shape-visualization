package com.broceliand.graphLayout.visual
{
   import com.broceliand.graphLayout.model.EndNode;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroCoeditDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroCoeditLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroCoeditNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroCoeditPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroNeighbourRootPearl;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPTWAliasNode;
   import com.broceliand.pearlTree.model.BroPTWDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.renderers.factory.CoeditCenterPTWPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.CoeditDistantTreeRefPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.CoeditLocalTreeRefPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.CoeditPTWPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.DistantDeletedTreeRefPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.DistantHiddenTreeRefPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.DistantTreeRefPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.EndPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.IPearlRecyclingManager;
   import com.broceliand.ui.renderers.factory.PTCenterPTWPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.PTRootPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.PTWPearlRendererFactory;
   import com.broceliand.ui.renderers.factory.PagePearlRendererFactory;
   import com.broceliand.ui.renderers.pageRenderers.PearlRendererStateManager;
   import com.broceliand.util.Assert;
   import com.broceliand.util.resources.IRemoteResourceManager;
   
   import mx.core.IFactory;
   import mx.core.UIComponent;
   
   import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualNode;

   public class PearlRendererFactories
   {
      private var _coeditPtwRootPearlRendererFactory:IFactory;
      private var _ptwRootPearlRendererFactory:IFactory;
      private var _ptwPearlRendererFactory:IFactory;
      private var _coeditPtwPearlRendererFactory:IFactory;
      private var _rootPearlRendererFactory:IFactory = null;
      private var _pagePearlRendererFactory:IFactory = null;
      private var _endPearlRendererFactory:IFactory = null;
      private var _DistantTreeRefPearlRendererFactory:IFactory = null;
      private var _DistantDeletedTreeRefPearlRendererFactory:IFactory = null;
      private var _DistantHiddenTreeRefPearlRendererFactory:IFactory = null;
      private var _coeditDistantTreeRefPearlRendererFactory:IFactory = null;
      private var _coeditLocalTreeRefPearlRendererFactory:IFactory = null;
      
      public function PearlRendererFactories(remoteResourceManager:IRemoteResourceManager, interactorManager:InteractorManager, pearlRendererStateManager:PearlRendererStateManager)
      {
         _pagePearlRendererFactory = new PagePearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _endPearlRendererFactory = new EndPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _rootPearlRendererFactory = new PTRootPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _DistantTreeRefPearlRendererFactory = new DistantTreeRefPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _DistantDeletedTreeRefPearlRendererFactory = new DistantDeletedTreeRefPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _DistantHiddenTreeRefPearlRendererFactory = new DistantHiddenTreeRefPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _coeditDistantTreeRefPearlRendererFactory = new CoeditDistantTreeRefPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _coeditLocalTreeRefPearlRendererFactory = new CoeditLocalTreeRefPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _ptwRootPearlRendererFactory = new PTCenterPTWPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _ptwPearlRendererFactory = new PTWPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _coeditPtwPearlRendererFactory = new CoeditPTWPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
         _coeditPtwRootPearlRendererFactory = new CoeditCenterPTWPearlRendererFactory(remoteResourceManager, interactorManager, pearlRendererStateManager);
      }
      
      public function createVNodeComponent(vn:IVisualNode):UIComponent {
         var mycomponent:UIComponent = null;
         var node:IPTNode = vn.node as IPTNode;
         var bnode:BroPTNode = node.getBusinessNode();
         if (node is EndNode) {
            bnode = null;
         }
         
         if(bnode is BroCoeditNeighbourRootPearl) {
            mycomponent = _coeditPtwRootPearlRendererFactory.newInstance();
         } 
         else if(bnode is BroNeighbourRootPearl){
            mycomponent = _ptwRootPearlRendererFactory.newInstance();
         } 
         else if (bnode is BroPTRootNode) {
            if(bnode.owner.isAssociationRoot() && bnode.owner.isInATeam()) {
               mycomponent = _coeditLocalTreeRefPearlRendererFactory.newInstance();
            }
            else {
               mycomponent = _rootPearlRendererFactory.newInstance();
            }
         }
         else if(bnode is BroCoeditLocalTreeRefNode) {
            mycomponent = _coeditLocalTreeRefPearlRendererFactory.newInstance();
         }
         else if(bnode is BroLocalTreeRefNode) {
            var localRefNode:BroLocalTreeRefNode = bnode as BroLocalTreeRefNode;
            if(localRefNode.refTree.isAssociationRoot() && localRefNode.refTree.isInATeam()) {
               mycomponent = _coeditLocalTreeRefPearlRendererFactory.newInstance();
            }
            else {
               mycomponent = _rootPearlRendererFactory.newInstance();
            }
         }
         else if (bnode is BroPTWAliasNode) {
            var alias:BroPTWAliasNode = bnode as BroPTWAliasNode;
            if(alias.refTree.isAssociationRoot() && alias.refTree.isInATeam()) {
               mycomponent = _coeditDistantTreeRefPearlRendererFactory.newInstance();
            }
            else {
               mycomponent = _DistantTreeRefPearlRendererFactory.newInstance();
            }
         }
         else if(bnode is BroCoeditPTWDistantTreeRefNode) {
            mycomponent = _coeditPtwPearlRendererFactory.newInstance();
         }
         else if(bnode is BroPTWDistantTreeRefNode) {
            mycomponent = _ptwPearlRendererFactory.newInstance();
         }
         else if(bnode is BroCoeditDistantTreeRefNode) {
            mycomponent = _coeditLocalTreeRefPearlRendererFactory.newInstance();
         }
         else if(bnode is BroDistantTreeRefNode) {
            var distantNode:BroDistantTreeRefNode = bnode as BroDistantTreeRefNode;
            if(distantNode.refTree.isDeleted()) {
               mycomponent = _DistantDeletedTreeRefPearlRendererFactory.newInstance();
            }
            else if(distantNode.refTree.isHidden()) {
               mycomponent = _DistantHiddenTreeRefPearlRendererFactory.newInstance();
            }
            else if(distantNode.refTree.isAssociationRoot() && distantNode.refTree.isInATeam()) {
               mycomponent = _coeditDistantTreeRefPearlRendererFactory.newInstance();
            }
            else {
               mycomponent = _DistantTreeRefPearlRendererFactory.newInstance();
            }
         }
         else if (bnode is BroPageNode){
            mycomponent = _pagePearlRendererFactory.newInstance();
         }
         else if (_endPearlRendererFactory != null){ 
            mycomponent = _endPearlRendererFactory.newInstance();
         }
         else {
            Assert.assert(false, "Unknown type of node "+ bnode);
         }
         return mycomponent;          
         
      }
      
      public function getPtwPearlRecyclingMananager():IPearlRecyclingManager {
         return (_ptwPearlRendererFactory as IPearlRecyclingManager);
      }
      
   }
}