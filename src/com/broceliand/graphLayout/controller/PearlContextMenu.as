package com.broceliand.graphLayout.controller {
   
   import com.broceliand.ApplicationManager;
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.io.object.tree.OwnerData;
   import com.broceliand.pearlTree.model.BroDistantTreeRefNode;
   import com.broceliand.pearlTree.model.BroLocalTreeRefNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPTRootNode;
   import com.broceliand.pearlTree.model.BroPage;
   import com.broceliand.pearlTree.model.BroPageNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.BroTreeRefNode;
   import com.broceliand.ui.controller.IEditionController;
   import com.broceliand.ui.controller.IWindowController;
   import com.broceliand.ui.interactors.InteractorManager;
   import com.broceliand.ui.model.SelectionModel;
   import com.broceliand.ui.mouse.MouseManager;
   import com.broceliand.ui.pearl.IUIPearl;
   import com.broceliand.ui.pearlWindow.PWModel;
   import com.broceliand.ui.pearlWindow.ui.share.ShareHelper;
   import com.broceliand.ui.renderers.pageRenderers.pearl.PearlBase;
   import com.broceliand.ui.window.WindowController;
   import com.broceliand.util.BroLocale;
   
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   
   import mx.core.Application;
   
   public class PearlContextMenu {
      
      private var _contextMenu:ContextMenu;
      
      private var _optionAnonymous:Array;
      private var _optionAnonymousNotPearl:Array;
      private var _optionNotAnonymousAndNotHome:Array;
      private var _optionNotAnonymousAndHome:Array;
      private var _optionsInPTWorld:Array;
      private var _optionNotPearl:Array;
      private var _optionDropZone:Array;
      private var _optionEmbed:Array;
      private var _optionEmbedNotPearl:Array;
      private var _pearlRendererUnderCursor:IUIPearl;
      
      private var _interactorManager:InteractorManager = null;
      private var _isEditing:Boolean = false;
      private var _optionNotAnonymousAndHomeRename:ContextMenuItem;
      
      public function get contextMenu():ContextMenu{
         return _contextMenu;
      }
      
      public function PearlContextMenu() {
         
         _contextMenu = new ContextMenu();
         _contextMenu.hideBuiltInItems();
         _contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelect);
         
         registryPearlContextMenu();
         
         constructOptionAnonymous();
         optionAnonymousNotPearl();
         constructMenuPTW();
         optionNotAnonymousAndNotHome();
         optionNotAnonymousAndHome();
         optionEmbed();
         optionEmbedNotPearl();
         optionNotPearl();
         optionDropZone();
      }
      
      private function getPearlUnderCursor():IUIPearl {
         var mousePosition:Point = new Point();
         mousePosition.x =Application.application.stage.mouseX;
         mousePosition.y = Application.application.stage.mouseY;
         
         return PearlBase.getPearlRendererUnderPoint(mousePosition);
      }
      
      private function contextMenuSelect(evt:ContextMenuEvent):void {
         _pearlRendererUnderCursor = getPearlUnderCursor();
         if (_pearlRendererUnderCursor) {
            var am:ApplicationManager = ApplicationManager.getInstance();
            
            var interactorManager:InteractorManager = am.components.pearlTreeViewer.interactorManager;
            if (!interactorManager.ensureEndDrag() && !(_pearlRendererUnderCursor.node.isDocked && isInPTW())) {
               changePearlSelection(_pearlRendererUnderCursor);
            }
            selectOptionsPearl(_pearlRendererUnderCursor);
            
         }
         else {
            selectOptionsNotPearl(_pearlRendererUnderCursor);
         }
         
         getMouseManager().showMouseOnRightClick();
      }
      
      private function updateShowDetailTitle(showDetail:ContextMenuItem):void {
         if (getWindowController().isPearlWindowDocked()) {
            showDetail.caption = BroLocale.getText("pearlContextMenu.showdetail");
         } else {
            showDetail.caption = BroLocale.getText("pearlContextMenu.hidedetail");
         }
      }
      
      private function selectOptionsNotPearl(pearlRenderer:IUIPearl):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         
         if(am.isEmbed()) {
            _contextMenu.customItems = _optionEmbedNotPearl;
         }
         else if(userIsAnonymous()) {
            _contextMenu.customItems = _optionAnonymousNotPearl;
         }
         else {
            _contextMenu.customItems = _optionNotPearl;
         }
      }
      
      private function isUgcPearl(pearlRenderer:IUIPearl):Boolean {
         if (!pearlRenderer) {
            return false;
         }
         var node:BroPTNode = pearlRenderer.node.getBusinessNode();
         if (node as BroPageNode) {
            var page:BroPage = (node as BroPageNode).refPage;
            if (page.isUserContent()) {
               return true;
            }
         } 
         return false;
      }
      private function selectOptionsPearl(pearlRenderer:IUIPearl):void{
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed()) {
            setRightToOpenInNewTab(_optionEmbed[0], pearlRenderer);
            _contextMenu.customItems = _optionEmbed;
         }
         else if (isDocked(pearlRenderer)){
            if(isInPTW()) {
               _contextMenu.customItems = _optionNotPearl;
            }else{
               optionsDocked(pearlRenderer);
            }
         }else if (isInPTW() && userIsAnonymous()) {
            _contextMenu.customItems = _optionAnonymous;
            setRightToOpenInNewTab(_optionAnonymous[0], pearlRenderer);
         }else if (isInPTW() && !userIsAnonymous()){
            updateShowDetailTitle(_optionsInPTWorld[1]);
            _contextMenu.customItems = _optionsInPTWorld;
         }else if (userIsAnonymous()) {
            setRightToOpenInNewTab(_optionAnonymous[0], pearlRenderer);
            _contextMenu.customItems = _optionAnonymous;
            var contextMenuNode:IPTNode = pearlRenderer.pearl.node;
         }else if (!userIsAnonymous() && isInMyWorld()) {
            setOptionsNotAnonymousInMyWorld(pearlRenderer);
            
         }else if (!userIsAnonymous() && !isInMyWorld()) {
            _contextMenu.customItems = _optionNotAnonymousAndNotHome;
            setRightToOpenInNewTab(_optionNotAnonymousAndNotHome[0], pearlRenderer);
            updateShowDetailTitle(_optionNotAnonymousAndNotHome[1]);
            setRightToPickPearltreeOrPrivateUGC(_optionNotAnonymousAndNotHome[2],pearlRenderer);
            
         } else {
            
            _contextMenu.customItems = _optionNotPearl;
         }
         
      }
      
      private function setOptionsNotAnonymousInMyWorld(pearlRenderer:IUIPearl):void{
         _contextMenu.customItems = _optionNotAnonymousAndHome;
         setRightsNotAnonymousInMyWorld(pearlRenderer);
      }
      
      private function optionsDocked(pearlRenderer:IUIPearl):void{
         _contextMenu.customItems = _optionDropZone;
         setRightToOpenInNewTab(_optionDropZone[0], pearlRenderer);
         _optionDropZone[0].enabled = _optionDropZone[0].enabled && pearlRenderer.node.getBusinessNode() is BroPageNode;
         updateShowDetailTitle(_optionDropZone[1]); 
         setRightToPickPearltreeOrPrivateUGC(_optionDropZone[2], pearlRenderer);
         if (_optionDropZone[6]) {
            setRightToRename(_optionDropZone[6], pearlRenderer);
         }
         
      }
      
      private function setRightToRename(renameItem:ContextMenuItem, pearlRenderer:IUIPearl):Boolean{
         var contextMenuNode:IPTNode = pearlRenderer.pearl.node;
         renameItem.enabled = userHasRightToEditNodeTitle(contextMenuNode)
         return renameItem.enabled;
      }
      
      private function setRightToOpenInNewTab(openInNewTabItem:ContextMenuItem, pearlRenderer:IUIPearl):Boolean{
         openInNewTabItem.enabled = !isUgcPearl(pearlRenderer);
         return openInNewTabItem.enabled;
      }
      private function setRightToPickPearltreeOrPrivateUGC(pickPearltreeItem:ContextMenuItem, pearlRenderer:IUIPearl):Boolean{
         pickPearltreeItem.enabled = !isPrivatePearltreeOrPrivateUGC(pearlRenderer);
         return pickPearltreeItem.enabled;
      }
      
      private function isPrivatePearltreeOrPrivateUGC(pearlRenderer:IUIPearl):Boolean {
         if (!pearlRenderer || !pearlRenderer.node || !pearlRenderer.node.getBusinessNode()) {
            return false;
         }
         var node:BroPTNode = pearlRenderer.node.getBusinessNode();
         if (node.owner.isPrivate() && !node.owner.isCurrentUserAuthor()) {
            if ((node is BroPageNode) && (node as BroPageNode).refPage.isUserContent()) {
               return true;
            }
         }
         var t:BroPearlTree = getTreeNode(pearlRenderer.node);
         if (t && t.isPrivate()) {
            return true;
         }
         
         return false;
      }
      private function setRightsNotAnonymousInMyWorld(pearlRenderer:IUIPearl):void{
         
         var contextMenuNode:IPTNode = pearlRenderer.pearl.node;
         var isExpiredPearl:Boolean = contextMenuNode.getBusinessNode().owner.isPrivatePearltreeOfCurrentUserNotPremium();
         var i:int=0;
         
         setRightToOpenInNewTab(_optionNotAnonymousAndHome[i++], pearlRenderer);

         updateShowDetailTitle(_optionNotAnonymousAndHome[i]);
         _optionNotAnonymousAndHome[i++].enabled = true;
         var isCurrentUserRoot:Boolean = contextMenuNode.isTopRoot ;
         if (isCurrentUserRoot) {
            isCurrentUserRoot = (contextMenuNode.getBusinessNode() as BroPTRootNode).isAssociationHierarchyRoot() && !contextMenuNode.getBusinessNode().owner.isInATeam();
         }
         if (isCurrentUserRoot) {
            isCurrentUserRoot = contextMenuNode.getBusinessNode().owner.isCurrentUserAuthor();
         }
         
         _optionNotAnonymousAndHome[i++].enabled = !isCurrentUserRoot && !isExpiredPearl;
         if (_optionNotAnonymousAndHome[i-1].enabled ) {
            setRightToPickPearltreeOrPrivateUGC(_optionNotAnonymousAndHome[i-1], pearlRenderer);
         }
         var t:BroPearlTree = getTreeNode(contextMenuNode);
         _optionNotAnonymousAndHome[i++].enabled = !contextMenuNode.isTopRoot && !isExpiredPearl && (!t || !t.isAssociationRoot());
         _optionNotAnonymousAndHome[i++].enabled = !contextMenuNode.isTopRoot && !isExpiredPearl;
         _optionNotAnonymousAndHome[i++].enabled = userHasRightToEditNodeTitle(contextMenuNode);
         return ;
      }

      private function userHasRightToEditNodeTitle(node:IPTNode):Boolean{
         if (node && node.getBusinessNode()) {
            return node.getBusinessNode().isTitleEditable();
         }
         return false;
      }

      private function isDocked(pearlRenderer:IUIPearl):Boolean{
         return pearlRenderer.pearl.node.isDocked;
      }
      
      private function makeItem(type:String, separatorBefore:Boolean = false):ContextMenuItem {
         var item:ContextMenuItem = new ContextMenuItem(BroLocale.getText("pearlContextMenu."+type), separatorBefore);
         
         if (type == "openinnewtab") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doOpenInNewTab);
         } else if (type == "openemptytab") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doOpenEmptyTab);
         } else if (type == "logPearltrees") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showMenuLogin);
         } else if (type == "join") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showMenuJoin);
         } else if (type == "pick") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doPickSelection);
         } else if (type == "move") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doMoveSelection);
         } else if (type =="delete") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doDeleteSelection);
         } else if (type == "rename") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showRename);
         }  else if (type == "copy") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doCopySelection);
         }  else if (type == "showdetail") {
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showHideDetail);
         }
         return item;
      }
      
      private function constructOptionAnonymous():void{
         var cmiNewTab:ContextMenuItem = makeItem("openinnewtab");
         var cmiLog:ContextMenuItem =  makeItem("logPearltrees", true);
         var cmiJoin:ContextMenuItem = makeItem("join");
         _optionAnonymous = [cmiNewTab, cmiLog, cmiJoin];
      }
      
      public function getTreeNode(node:IPTNode):BroPearlTree {
         var bnode:BroPTNode  = node.getBusinessNode();
         if (bnode is BroPTRootNode) {
            return bnode.owner;
         } else if (bnode is BroLocalTreeRefNode) {
            return (bnode as BroLocalTreeRefNode).refTree;
         }
         return null;
      }
      
      private function optionAnonymousNotPearl():void {
         _optionAnonymousNotPearl = new Array();
         if (isIE10Metro()) {
            _optionAnonymousNotPearl.push(makeItem("openemptytab"));
         }
         _optionAnonymousNotPearl.push(makeItem("logPearltrees", true));
         _optionAnonymousNotPearl.push(makeItem("join"));
      }
      
      private function constructMenuPTW():void{
         var cmiNewTab:ContextMenuItem = makeItem("openinnewtab");
         var cmiDetail:ContextMenuItem = makeItem("showdetail");
         cmiDetail.enabled = false;
         
         var cmiCopy:ContextMenuItem = makeItem("pick", true);
         var cmiMove:ContextMenuItem = makeItem("move");
         cmiMove.enabled = false;
         var cmiDelete:ContextMenuItem = makeItem("delete");
         cmiDelete.enabled = false;
         var _optionNotAnonymousAndNotHomeRename:ContextMenuItem = makeItem("rename", false);
         _optionNotAnonymousAndNotHomeRename.enabled = false;
         _optionsInPTWorld = [cmiNewTab, cmiDetail, cmiCopy, cmiMove, cmiDelete, _optionNotAnonymousAndNotHomeRename ];
      }
      
      private function optionDropZone():void {
         var cmiNewTab:ContextMenuItem = makeItem("openinnewtab");
         var cmiDetail:ContextMenuItem = makeItem("showdetail");
         var cmiCopy:ContextMenuItem = makeItem("copy", true);
         var cmiMove:ContextMenuItem = makeItem("move");
         var cmiDelete:ContextMenuItem = makeItem("delete");
         var cmiRename:ContextMenuItem = makeItem("rename");
         cmiRename.enabled = true;
         _optionDropZone = [cmiNewTab, cmiDetail, cmiCopy, cmiMove, cmiDelete, cmiRename];
      }
      
      private function optionNotAnonymousAndNotHome():void{
         var cmiNewTab:ContextMenuItem = makeItem("openinnewtab");
         var cmiDetail:ContextMenuItem = makeItem("showdetail");
         
         var cmiCopy:ContextMenuItem = makeItem("pick", true);
         var cmiMove:ContextMenuItem = makeItem("move");
         cmiMove.enabled = false;
         var cmiDelete:ContextMenuItem = makeItem("delete");
         cmiDelete.enabled = false;
         var _optionNotAnonymousAndNotHomeRename:ContextMenuItem = makeItem("rename");
         _optionNotAnonymousAndNotHomeRename.enabled = false;
         _optionNotAnonymousAndNotHome = [cmiNewTab, cmiDetail, cmiCopy, cmiMove, cmiDelete, _optionNotAnonymousAndNotHomeRename ];
      }
      
      private function optionEmbed():void {
         var cmiNewTab:ContextMenuItem = makeItem("openinnewtab", true);
         var cmiJoin:ContextMenuItem = makeItem("join", true);
         _optionEmbed = [cmiNewTab, cmiJoin];
      }
      
      private function optionEmbedNotPearl():void {
         var cmiJoin:ContextMenuItem = makeItem("join", true);
         _optionEmbedNotPearl = [cmiJoin];
      }
      
      private function optionNotPearl():void {
         _optionNotPearl = new Array();
         if (isIE10Metro()) {
            _optionNotPearl.push(makeItem("openemptytab"));
         }
      }
      
      private function isIE10Metro():Boolean {
         var am:ApplicationManager = ApplicationManager.getInstance();

         return (am.getOS() == ApplicationManager.OS_NAME_WINDOWS && am.getOSVersion() == "8" && am.getBrowserName() == ApplicationManager.BROWSER_NAME_MSIE);
      }
      
      private function optionNotAnonymousAndHome():void{
         
         var cmiNewTab:ContextMenuItem = makeItem("openinnewtab");
         var cmiDetail:ContextMenuItem = makeItem("showdetail");
         
         var cmiCopy:ContextMenuItem = makeItem("copy", true);
         var cmiMove:ContextMenuItem = makeItem("move");
         var cmiDelete:ContextMenuItem = makeItem("delete");
         
         _optionNotAnonymousAndHomeRename = makeItem("rename");
         
         _optionNotAnonymousAndHome = [cmiNewTab, cmiDetail, cmiCopy, cmiMove, cmiDelete, _optionNotAnonymousAndHomeRename];
         
      }

      private function changePearlSelection(pearlRenderer:IUIPearl):void {
         if (pearlRenderer) {
            var selectedNode:IPTNode = getSelectionModel().getSelectedNode() as IPTNode;
            var contextMenuNode:IPTNode = pearlRenderer.pearl.node;
            
            if (selectedNode != contextMenuNode) {
               getSelectionModel().selectNode(contextMenuNode);
               
               if (selectedNode && selectedNode.vnode && selectedNode.vnode.view) {
                  selectedNode.vnode.view.callLater(selectedNode.vnode.view.invalidateProperties);
               }
            }
         }
      }
      
      private function showMenuLogin (evt:ContextMenuEvent):void{
         ApplicationManager.getInstance().menuActions.login();
      }
      
      private function  showMenuJoin (evt:ContextMenuEvent):void {
         var am:ApplicationManager = ApplicationManager.getInstance();
         if(am.isEmbed()) {
            am.embedManager.openCreateAccountTab();
         }else{
            am.menuActions.signUp();
         }
      }
      
      private function doPickSelection(evt:ContextMenuEvent):void {
         var pearlRenderer:IUIPearl = _pearlRendererUnderCursor;
         if (pearlRenderer) {
            var contextMenuNode:IPTNode = pearlRenderer.pearl.node;
            getWindowController().setPearlWindowDocked(false);
            getWindowController().displayPickNodeTo(contextMenuNode);
         }
      }
      private function doCopySelection(evt:ContextMenuEvent):void {
         var pearlRenderer:IUIPearl = _pearlRendererUnderCursor;
         if (pearlRenderer) {
            var contextMenuNode:IPTNode = pearlRenderer.node;
            ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.turnOffSelectionOnOver(true, WindowController.PEARL_WINDOW, PWModel.COPY_PANEL);
            getWindowController().setPearlWindowDocked(false);
            getWindowController().displayCopyNodeTo(contextMenuNode);
         }
      }
      private function showHideDetail(evt:ContextMenuEvent):void {
         var wc:IWindowController = getWindowController();
         wc.setPearlWindowDocked(!wc.isPearlWindowDocked());
      }
      
      private function doDeleteSelection(evt:ContextMenuEvent):void{
         getEditionController().deleteSelection();
      }
      
      private function doOpenInNewTab(evt:ContextMenuEvent):void{
         var pearlRenderer:IUIPearl = _pearlRendererUnderCursor;
         if (pearlRenderer) {
            var contextMenuNode:IPTNode = pearlRenderer.node;
            var node:BroPTNode = contextMenuNode.getBusinessNode();
            var url:String;
            if (node is BroPageNode) {
               url = ShareHelper.getPageUrl(node as BroPageNode);
            }
            else {
               url = ShareHelper.getNodeUrl(node);
            }
            ApplicationManager.getInstance().getExternalInterface().openWindow(url, "_blank");
         }
      }
      
      private function doOpenEmptyTab(evt:ContextMenuEvent):void {
         ApplicationManager.getInstance().getExternalInterface().openWindow("", "_blank");
      }
      
      private function showRename(evt:ContextMenuEvent):void{
         var pearlRenderer:IUIPearl = _pearlRendererUnderCursor;
         if (pearlRenderer) {
            ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.turnOffSelectionOnOver(true, WindowController.PEARL_WINDOW, PWModel.CONTENT_PANEL);
            var contextMenuNode:IPTNode = pearlRenderer.node;
            getWindowController().setPearlWindowDocked(false);
            getWindowController().displayRenamePearlDialog(contextMenuNode);
         }
         
      }
      
      private function doMoveSelection(evt:ContextMenuEvent):void {
         var pearlRenderer:IUIPearl = _pearlRendererUnderCursor;
         if (pearlRenderer) {
            var contextMenuNode:IPTNode = pearlRenderer.node;
            getWindowController().setPearlWindowDocked(false);
            ApplicationManager.getInstance().components.pearlTreeViewer.interactorManager.turnOffSelectionOnOver(true, WindowController.PEARL_WINDOW, PWModel.MOVE_PANEL);
            getWindowController().displayMoveNode(contextMenuNode);
         }
      }
      
      private function getWindowController():IWindowController {
         return ApplicationManager.getInstance().components.windowController;
      }
      
      private function getEditionController():IEditionController {
         return ApplicationManager.getInstance().visualModel.editionController;
      }
      
      private function getSelectionModel():SelectionModel {
         return ApplicationManager.getInstance().visualModel.selectionModel;
      }
      
      private function userIsAnonymous():Boolean {
         return ApplicationManager.getInstance().currentUser.isAnonymous()
      }
      
      private function isInMyWorld():Boolean {
         return ApplicationManager.getInstance().visualModel.navigationModel.isInMyWorld();
      }
      
      private function isInPTW():Boolean {
         return ApplicationManager.getInstance().visualModel.navigationModel.isShowingPearlTreesWorld();
      }
      
      private function getMouseManager():MouseManager {
         return ApplicationManager.getInstance().visualModel.mouseManager;
      }
      
      private function registryPearlContextMenu():void{
         ApplicationManager.getInstance().pearlContextMenu = this;
      }
      
      private function isAliasOfHiddenTree(pearlRenderer:IUIPearl):Boolean {
         if (!pearlRenderer)
            return false;
         
         var bnode:BroDistantTreeRefNode = pearlRenderer.node.getBusinessNode() as BroDistantTreeRefNode;
         if (bnode) {
            return bnode.refTree.isHidden();
         } else
            return false;
      }
      
      private function isAliasOfDeletedTree(pearlRenderer:IUIPearl):Boolean {
         if (!pearlRenderer)
            return false;
         
         var bnode:BroDistantTreeRefNode = pearlRenderer.node.getBusinessNode() as BroDistantTreeRefNode;
         if (bnode){
            return bnode.refTree.isDeleted();
         } else
            return false;
      }
      
   }
}