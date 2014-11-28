package com.broceliand.ui.controller {
   
   import com.broceliand.graphLayout.model.IPTNode;
   import com.broceliand.pearlTree.model.BroPTNode;
   import com.broceliand.pearlTree.model.BroPearlTree;
   import com.broceliand.pearlTree.model.User;
   import com.broceliand.pearlTree.model.paginatedlists.IPaginatedList;
   import com.broceliand.pearlTree.model.team.TeamRequest;
   import com.broceliand.ui.controller.startPolicy.StartupMessage;
   import com.broceliand.ui.pearlWindow.PearlWindow;
   import com.broceliand.ui.pearlWindow.ui.share.ShareAttributes;
   import com.broceliand.ui.window.ui.INoveltyFeedWindow;
   import com.broceliand.ui.window.ui.infoWindow.InfoWindowModel;
   import com.broceliand.util.IAction;
   import com.broceliand.util.NoteInputTransferer;
   
   import flash.display.Bitmap;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;

   public interface IWindowController extends IEventDispatcher {
      
      /*function openInstallPearlerWindow():void;
      function closeInstallPearlerWindow():void;
      function isInstallPearlerWindowOpen():Boolean;
      
      function openUpgradeToPremiumPrivacyWindow():void;
      function closeUpgradeToPremiumPrivacyWindow():void;
      function isUpgradeToPremiumWindowPrivacyOpen():Boolean;
      
      function openUpgradeToPremiumCustomizeWindow():void;
      function closeUpgradeToPremiumCustomizeWindow():void;
      function isUpgradeToPremiumWindowCustomizeOpen():Boolean;*/
      
      function openSocialSyncWindow():void;
      function closeSocialSyncWindow():void;
      function isSocialSyncWindowOpen():Boolean;
      
      function openImportWindow():void;
      function closeImportWindow():void;
      function isImportWindowOpen():Boolean;
      
      function openInviteWindow(teamUpTree:BroPearlTree = null, startPanelIsFacebook:Boolean = false, findMode:Boolean=false):void;
      function closeInviteWindow():void;
      function isInviteWindowOpen():Boolean;
      
      function openLastWindowToAddPearl():void;
      
      function openAddPearlsCoverWindow():void;
      function closeAddPearlCoverWindow():void;
      function isAddPearlsCoverWindowOpen():Boolean;
      
      function openPearlUrlWindow():void;
      function closePearlUrlWindow():void;
      function isPearlUrlWindowOpen():Boolean;
      
      function openPearlNoteWindow():void;
      function closePearlNoteWindow():void;
      function isPearlNoteWindowOpen():Boolean;
      
      function openPearlNoteEditionWindow(node:IPTNode):void;
      
      function openPearlPhotoWindow():void;
      function closePearlPhotoWindow():void;
      function isPearlPhotoWindowOpen():Boolean;
      
      function openPearlDocumentWindow():void;
      function closePearlDocumentWindow():void;
      function isPearlDocumentWindowOpen():Boolean;
      
      function openNewPearltreeWindow():void;
      function closeNewPearltreeWindow():void;
      function isNewPearltreeWindowOpen():Boolean;
      function isAnyCreationWindowOpen() : Boolean;
      function closeAnyCreationWindowOpen() : void;

      function openNotificationWindow():void;
      function closeNotificationWindow():void;
      function isNotificationWindowOpen():Boolean;
      
      function openNoveltyFeedWindow():void;
      function closeNoveltyFeedWindow():void;
      function noveltyFeedWindow():INoveltyFeedWindow;
      function isNoveltyFeedWindowOpen():Boolean;
      function jumpToNoveltyPageIndex(indexAmongPage:int):void;
      function getNoveltyItemSnapshot(indexAmongPages:int):Bitmap;
      function getNoveltyItemBounds(indexAmongPages:int):Rectangle;
      
      function openSettingsWindow():void;
      function closeSettingsWindow():void;
      function isSettingsWindowOpen():Boolean;
      
      function openSearchModeWindow():void;
      function closeSearchModeWindow():void;
      function isSearchModeWindowOpen():Boolean;
      
      function displayOrHideInfoWindow(textKey:String, imageURL:String):void;
      function openInfoWindow(textKey:String, imageURL:String, buttonType:uint=0, linkTxtsArray:Array=null, params:Array=null, useSystemFont:int=0, fallabckToScreenWindow:Boolean = true, paramsForTitle:Array=null, centerDim:Boolean = false):InfoWindowModel;
      function closeInfoWindow():void;
      function isInfoWindowOpen():Boolean;
      
      function openBigActionWindow(skin:uint):void;
      function closeBigActionWindow():void;
      function isBigActionWindowOpen():Boolean;
      function getBigActionWindowSkin():uint;
      
      function openErrorWindow(errorCode:int, skipButton:Boolean=false, message:String=null, actionToPerform:IAction=null, title:String=null):void;
      function isErrorWindowOpen():Boolean;
      
      function openUpdateAddonWindow():void;
      function isUpdateAddonWindowOpen():Boolean;
      
      function offsetHeightDueToSignupBanner():int;
      function refreshPearlWindowPositionWhenLoging():void;
      
      function openStartupMessageWindow(message:StartupMessage):void;
      function isStartupMessageWindowOpen():Boolean;
      
      function openEventPromoWindow():void;
      function isEventPromoWindowOpen(): Boolean;
      function hasShowedBigPromotionWindowDuringSession():Boolean;
      
      function openDeletionRecoveryWindow():void;
      function closeDeletionRecoveryWindow():void;
      
      function openClearDropzoneWindow():void;
      function closeClearDropzoneWindow():void;
      
      function closeAllWindows():void;
      function isAllWindowClosed():Boolean;
      function resetAllWindowsState():void;
      function isPointOverWindow(x:Number, y:Number):Boolean;
      function isPointOverNotificationWindow(x:Number, y:Number):Boolean;
      function isPointOverMenuWindow(x:Number, y:Number):Boolean;

      function setAllWindowBackward(value:Boolean):void;
      function setNotificationWindowBackward(value:Boolean):void;
      
      function skipNextDisplayNodeInfoOnTreeCreation(node:IPTNode) : void;
      function displayNodeInfo(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayNodeEmptyContent(node:IPTNode=null):void;
      function displayOrHideAuthorInfo(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayOrHideTeamInfo(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false, showOnly:Boolean=false):void;
      function displayOrHideFreezeTeamMember(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false, showOnly:Boolean=false):void;
      function displayOrHideTeamHistory(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false, showOnly:Boolean=false):void;
      function displayAuthorTeamList(node:IPTNode=null, teamList:Array=null, totalTeamCount:Number=-1, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayNodeCrosses(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayConnectionList(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayNodeNotes(node:IPTNode=null, waitEndOfAnimation:Boolean=false, focusAddNote:Boolean=false, highlightUnseenNotes:Boolean=false):void;
      function displayTeamDiscussion(node:IPTNode=null, waitEndOfAnimation:Boolean=false, focusAddNote:Boolean=false, highlightUnseenNotes:Boolean=false):void;
      function displayNodeShare(node:IPTNode=null, waitEndOfAnimation:Boolean=false, selectedPanelInShare:uint=0, shareAttributes:ShareAttributes=null):void;
      function displayMoveNode(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayMovePrivateNode(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayCopyNodeTo(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayPickNodeTo(node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayCustomizeAvatar(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayCustomizeLogo(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayCustomizeBackground(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayImagesBibli(imageManager:EventDispatcher, requestId:String, node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displayTeamCandidacy(node:IPTNode=null, request:TeamRequest=null, isNewTeam:Boolean=true, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayTeamAcceptCandidacy(node:IPTNode=null, tree:BroPearlTree=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false, invitationRequest:TeamRequest=null):void;
      function displayTreeEdito(node:IPTNode=null, origin:int=-1, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function acceptTeamRequestWithEffect(node:IPTNode=null, teamRequest:TeamRequest=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function displayNewTeamMemberSharingPointAfterEffect(node:IPTNode, isNewTeam:Boolean, isCurrentUserGuest:Boolean, origin:uint, waitEndOfAnimation:Boolean, undockPearlWindow:Boolean, needEditoCycle:Boolean):void;
      function displayTeamSharingPoint(node:IPTNode, isNewTeam:Boolean, isCurrentUserGuest:Boolean, origin:uint, waitEndOfAnimation:Boolean, undockPearlWindow:Boolean, updateModel:Boolean, isInviteSharingPoint:Boolean, needEditoCycle:Boolean):void;
      function displayCreateAccountForm(node:IPTNode=null, candidateOnCurrentTree:Boolean=false, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false):void;
      function exploreTeamRequestGuestTrees(teamRequest:TeamRequest, pwPanel:uint=0, navigateToAlias:Boolean=true):void;
      function exploreTeamRequestHostTrees(teamRequest:TeamRequest, pwPanel:uint=0, navigateToAlias:Boolean=true):void;
      function displayPrivateMessages(node:IPTNode=null, waitEndOfAnimation:Boolean=false):void;
      function displaySendPrivateMessage(node:IPTNode=null, toUser:User=null, pearlAttached:BroPTNode=null, inviteToTeam:Boolean=false, privateMsgContacts:IPaginatedList=null, waitEndOfAnimation:Boolean=false):void;
      function displayTeamNotification(notificationType:uint, teamRequest:TeamRequest, node:IPTNode=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false, showOnly:Boolean=false):void;
      function displayTeamAcceptInvitation(node:IPTNode=null, tree:BroPearlTree=null, waitEndOfAnimation:Boolean=false, undockPearlWindow:Boolean=false, invitationRequest:TeamRequest=null):void;
      function displayFacebookInvitationDefault(node:IPTNode=null):void;
      function displayFacebookInvitationTeamUp(node:IPTNode=null):void;

      function getPWPanelTypeDisplaying():uint;

      function getNodeDisplayed():IPTNode;

      function displaySaveTreeDialog(node:IPTNode):void;

      function displayRenamePearlDialog(node:IPTNode=null):void;
      
      function displayReorganizationPanel(rootNodeOfReorganizedTree:IPTNode, newOrganizationLevel:int):void;

      function setPearlWindowDocked(value:Boolean, effectSource:IPTNode=null, skipEffect:Boolean=false, selectedPanel:uint=0, showPearlWindow:Boolean=true, undockPearlWindowOnLeavePTW:Boolean=true):void;
      function isPearlWindowDocked():Boolean;
      function set isFirstOpenEffect(value:Boolean):void;
      
      function getPearlWindowBounds():Rectangle;
      function getPearlWindowSnapshot():Bitmap;
      function temporaryHidePearlWindow(value:Boolean):void;
      function resetLastWindowPosition():void;
      function get pearlWindow():PearlWindow;
      function get noteInputTransferer():NoteInputTransferer;
      function get hasAppearedOnce():Boolean;
      function get isFirstUndock():Boolean;
      function isPearlWindowVisible():Boolean;
      function get visibleWindowId():uint;
      
      function refresh():void; 
      function toUndockPWImediatelyForAnonymousUser():Boolean;   
   }
}
