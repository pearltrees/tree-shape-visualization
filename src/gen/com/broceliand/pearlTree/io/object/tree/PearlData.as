package com.broceliand.pearlTree.io.object.tree {

import com.broceliand.pearlTree.io.object.tree.TreeData;
import com.broceliand.pearlTree.io.object.tree.TreeData;
import com.broceliand.pearlTree.io.object.url.UrlData;
import com.broceliand.pearlTree.io.object.tree.SectionData;
import flash.utils.IExternalizable;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

[RemoteClass(alias="Pearl")]
public class PearlData implements IExternalizable {

private var _id:int;
private var _treeId:int;
private var _tree:com.broceliand.pearlTree.io.object.tree.TreeData;
private var _state:int;
private var _contentType:int;
private var _contentId:int;
private var _contentTree:com.broceliand.pearlTree.io.object.tree.TreeData;
private var _isRepresentativeForLoggedUser:int;
private var _urlId:int;
private var _url:com.broceliand.pearlTree.io.object.url.UrlData;
private var _title:String;
private var _inTreeSinceDate:Number;
private var _inTreeSinceVersion:int;
private var _lastEditorUserId:int;
private var _logoHash:flash.utils.ByteArray;
private var _leftIndex:int;
private var _rightIndex:int;
private var _editionStatus:int;
private var _neighbourCount:int;
private var _localNoteCount:int;
private var _fullFeedNoteCount:int;
private var _clientId:int;
private var _commentsAck:Number;
private var _treeEditoAck:Number;
private var _editedLayout:int;
private var _type:int;
private var _cache:int;
private var _titleDisplay:int;
private var _sectionInfo:com.broceliand.pearlTree.io.object.tree.SectionData;

public function get id():int { return _id; }
public function set id(value:int):void { _id = value; }
public function get treeId():int { return _treeId; }
public function set treeId(value:int):void { _treeId = value; }
public function get tree():com.broceliand.pearlTree.io.object.tree.TreeData { return _tree; }
public function set tree(value:com.broceliand.pearlTree.io.object.tree.TreeData):void { _tree = value; }
public function get state():int { return _state; }
public function set state(value:int):void { _state = value; }
public function get contentType():int { return _contentType; }
public function set contentType(value:int):void { _contentType = value; }
public function get contentId():int { return _contentId; }
public function set contentId(value:int):void { _contentId = value; }
public function get contentTree():com.broceliand.pearlTree.io.object.tree.TreeData { return _contentTree; }
public function set contentTree(value:com.broceliand.pearlTree.io.object.tree.TreeData):void { _contentTree = value; }
public function get isRepresentativeForLoggedUser():int { return _isRepresentativeForLoggedUser; }
public function set isRepresentativeForLoggedUser(value:int):void { _isRepresentativeForLoggedUser = value; }
public function get urlId():int { return _urlId; }
public function set urlId(value:int):void { _urlId = value; }
public function get url():com.broceliand.pearlTree.io.object.url.UrlData { return _url; }
public function set url(value:com.broceliand.pearlTree.io.object.url.UrlData):void { _url = value; }
public function get title():String { return _title; }
public function set title(value:String):void { _title = value; }
public function get inTreeSinceDate():Number { return _inTreeSinceDate; }
public function set inTreeSinceDate(value:Number):void { _inTreeSinceDate = value; }
public function get inTreeSinceVersion():int { return _inTreeSinceVersion; }
public function set inTreeSinceVersion(value:int):void { _inTreeSinceVersion = value; }
public function get lastEditorUserId():int { return _lastEditorUserId; }
public function set lastEditorUserId(value:int):void { _lastEditorUserId = value; }
public function get logoHash():flash.utils.ByteArray { return _logoHash; }
public function set logoHash(value:flash.utils.ByteArray):void { _logoHash = value; }
public function get leftIndex():int { return _leftIndex; }
public function set leftIndex(value:int):void { _leftIndex = value; }
public function get rightIndex():int { return _rightIndex; }
public function set rightIndex(value:int):void { _rightIndex = value; }
public function get editionStatus():int { return _editionStatus; }
public function set editionStatus(value:int):void { _editionStatus = value; }
public function get neighbourCount():int { return _neighbourCount; }
public function set neighbourCount(value:int):void { _neighbourCount = value; }
public function get localNoteCount():int { return _localNoteCount; }
public function set localNoteCount(value:int):void { _localNoteCount = value; }
public function get fullFeedNoteCount():int { return _fullFeedNoteCount; }
public function set fullFeedNoteCount(value:int):void { _fullFeedNoteCount = value; }
public function get clientId():int { return _clientId; }
public function set clientId(value:int):void { _clientId = value; }
public function get commentsAck():Number { return _commentsAck; }
public function set commentsAck(value:Number):void { _commentsAck = value; }
public function get treeEditoAck():Number { return _treeEditoAck; }
public function set treeEditoAck(value:Number):void { _treeEditoAck = value; }
public function get editedLayout():int { return _editedLayout; }
public function set editedLayout(value:int):void { _editedLayout = value; }
public function get type():int { return _type; }
public function set type(value:int):void { _type = value; }
public function get cache():int { return _cache; }
public function set cache(value:int):void { _cache = value; }
public function get titleDisplay():int { return _titleDisplay; }
public function set titleDisplay(value:int):void { _titleDisplay = value; }
public function get sectionInfo():com.broceliand.pearlTree.io.object.tree.SectionData { return _sectionInfo; }
public function set sectionInfo(value:com.broceliand.pearlTree.io.object.tree.SectionData):void { _sectionInfo = value; }

public function readExternal(input:IDataInput):void {
id = input.readInt();
treeId = input.readInt();
tree = input.readObject() as com.broceliand.pearlTree.io.object.tree.TreeData;
state = input.readInt();
contentType = input.readInt();
contentId = input.readInt();
contentTree = input.readObject() as com.broceliand.pearlTree.io.object.tree.TreeData;
isRepresentativeForLoggedUser = input.readInt();
urlId = input.readInt();
url = input.readObject() as com.broceliand.pearlTree.io.object.url.UrlData;
title = input.readObject() as String;
inTreeSinceDate = input.readDouble();
inTreeSinceVersion = input.readInt();
lastEditorUserId = input.readInt();
logoHash = input.readObject() as flash.utils.ByteArray;
leftIndex = input.readInt();
rightIndex = input.readInt();
editionStatus = input.readInt();
neighbourCount = input.readInt();
localNoteCount = input.readInt();
fullFeedNoteCount = input.readInt();
clientId = input.readInt();
commentsAck = input.readDouble();
treeEditoAck = input.readDouble();
editedLayout = input.readInt();
type = input.readInt();
cache = input.readInt();
titleDisplay = input.readInt();
sectionInfo = input.readObject() as com.broceliand.pearlTree.io.object.tree.SectionData;
}

public function writeExternal(output:IDataOutput):void {
output.writeInt(id);
output.writeInt(treeId);
output.writeObject(tree);
output.writeInt(state);
output.writeInt(contentType);
output.writeInt(contentId);
output.writeObject(contentTree);
output.writeInt(isRepresentativeForLoggedUser);
output.writeInt(urlId);
output.writeObject(url);
output.writeObject(title);
output.writeDouble(inTreeSinceDate);
output.writeInt(inTreeSinceVersion);
output.writeInt(lastEditorUserId);
output.writeObject(logoHash);
output.writeInt(leftIndex);
output.writeInt(rightIndex);
output.writeInt(editionStatus);
output.writeInt(neighbourCount);
output.writeInt(localNoteCount);
output.writeInt(fullFeedNoteCount);
output.writeInt(clientId);
output.writeDouble(commentsAck);
output.writeDouble(treeEditoAck);
output.writeInt(editedLayout);
output.writeInt(type);
output.writeInt(cache);
output.writeInt(titleDisplay);
output.writeObject(sectionInfo);
}
}
}
