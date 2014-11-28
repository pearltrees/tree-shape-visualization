package com.broceliand.pearlTree.io.object.tree {

import com.broceliand.pearlTree.io.object.user.UserData;
import flash.utils.IExternalizable;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

[RemoteClass(alias="Association")]
public class AssociationData implements IExternalizable {

private var _id:int;
private var _title:String;
private var _avatarHash:flash.utils.ByteArray;
private var _backgroundHash:flash.utils.ByteArray;
private var _assoTreesVersion:int;
private var _rootAssoOfUserId:int;
private var _chiefUserId:int;
private var _chiefUser:com.broceliand.pearlTree.io.object.user.UserData;
private var _foundingAssoId:int;
private var _foundingUserId:int;
private var _memberCount:int;
private var _teamDiscussionCount:int;
private var _visibility:int;
private var _descendantPearlCount:int;
private var _descendantPrivatePearlCount:int;

public function get id():int { return _id; }
public function set id(value:int):void { _id = value; }
public function get title():String { return _title; }
public function set title(value:String):void { _title = value; }
public function get avatarHash():flash.utils.ByteArray { return _avatarHash; }
public function set avatarHash(value:flash.utils.ByteArray):void { _avatarHash = value; }
public function get backgroundHash():flash.utils.ByteArray { return _backgroundHash; }
public function set backgroundHash(value:flash.utils.ByteArray):void { _backgroundHash = value; }
public function get assoTreesVersion():int { return _assoTreesVersion; }
public function set assoTreesVersion(value:int):void { _assoTreesVersion = value; }
public function get rootAssoOfUserId():int { return _rootAssoOfUserId; }
public function set rootAssoOfUserId(value:int):void { _rootAssoOfUserId = value; }
public function get chiefUserId():int { return _chiefUserId; }
public function set chiefUserId(value:int):void { _chiefUserId = value; }
public function get chiefUser():com.broceliand.pearlTree.io.object.user.UserData { return _chiefUser; }
public function set chiefUser(value:com.broceliand.pearlTree.io.object.user.UserData):void { _chiefUser = value; }
public function get foundingAssoId():int { return _foundingAssoId; }
public function set foundingAssoId(value:int):void { _foundingAssoId = value; }
public function get foundingUserId():int { return _foundingUserId; }
public function set foundingUserId(value:int):void { _foundingUserId = value; }
public function get memberCount():int { return _memberCount; }
public function set memberCount(value:int):void { _memberCount = value; }
public function get teamDiscussionCount():int { return _teamDiscussionCount; }
public function set teamDiscussionCount(value:int):void { _teamDiscussionCount = value; }
public function get visibility():int { return _visibility; }
public function set visibility(value:int):void { _visibility = value; }
public function get descendantPearlCount():int { return _descendantPearlCount; }
public function set descendantPearlCount(value:int):void { _descendantPearlCount = value; }
public function get descendantPrivatePearlCount():int { return _descendantPrivatePearlCount; }
public function set descendantPrivatePearlCount(value:int):void { _descendantPrivatePearlCount = value; }

public function readExternal(input:IDataInput):void {
id = input.readInt();
title = input.readObject() as String;
avatarHash = input.readObject() as flash.utils.ByteArray;
backgroundHash = input.readObject() as flash.utils.ByteArray;
assoTreesVersion = input.readInt();
rootAssoOfUserId = input.readInt();
chiefUserId = input.readInt();
chiefUser = input.readObject() as com.broceliand.pearlTree.io.object.user.UserData;
foundingAssoId = input.readInt();
foundingUserId = input.readInt();
memberCount = input.readInt();
teamDiscussionCount = input.readInt();
visibility = input.readInt();
descendantPearlCount = input.readInt();
descendantPrivatePearlCount = input.readInt();
}

public function writeExternal(output:IDataOutput):void {
output.writeInt(id);
output.writeObject(title);
output.writeObject(avatarHash);
output.writeObject(backgroundHash);
output.writeInt(assoTreesVersion);
output.writeInt(rootAssoOfUserId);
output.writeInt(chiefUserId);
output.writeObject(chiefUser);
output.writeInt(foundingAssoId);
output.writeInt(foundingUserId);
output.writeInt(memberCount);
output.writeInt(teamDiscussionCount);
output.writeInt(visibility);
output.writeInt(descendantPearlCount);
output.writeInt(descendantPrivatePearlCount);
}
}
}
