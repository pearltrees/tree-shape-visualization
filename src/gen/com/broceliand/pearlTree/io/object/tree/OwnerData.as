package com.broceliand.pearlTree.io.object.tree {

import com.broceliand.pearlTree.io.object.user.UserData;
import com.broceliand.pearlTree.io.object.tree.PearlData;
import flash.utils.IExternalizable;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

[RemoteClass(alias="Owner")]
public class OwnerData implements IExternalizable {

private var _userId:int;
private var _user:com.broceliand.pearlTree.io.object.user.UserData;
private var _assoId:int;
private var _repPearlId:int;
private var _repPearl:com.broceliand.pearlTree.io.object.tree.PearlData;
private var _state:int;
private var _lastRightsUpdate:Number;

public function get userId():int { return _userId; }
public function set userId(value:int):void { _userId = value; }
public function get user():com.broceliand.pearlTree.io.object.user.UserData { return _user; }
public function set user(value:com.broceliand.pearlTree.io.object.user.UserData):void { _user = value; }
public function get assoId():int { return _assoId; }
public function set assoId(value:int):void { _assoId = value; }
public function get repPearlId():int { return _repPearlId; }
public function set repPearlId(value:int):void { _repPearlId = value; }
public function get repPearl():com.broceliand.pearlTree.io.object.tree.PearlData { return _repPearl; }
public function set repPearl(value:com.broceliand.pearlTree.io.object.tree.PearlData):void { _repPearl = value; }
public function get state():int { return _state; }
public function set state(value:int):void { _state = value; }
public function get lastRightsUpdate():Number { return _lastRightsUpdate; }
public function set lastRightsUpdate(value:Number):void { _lastRightsUpdate = value; }

public function readExternal(input:IDataInput):void {
userId = input.readInt();
user = input.readObject() as com.broceliand.pearlTree.io.object.user.UserData;
assoId = input.readInt();
repPearlId = input.readInt();
repPearl = input.readObject() as com.broceliand.pearlTree.io.object.tree.PearlData;
state = input.readInt();
lastRightsUpdate = input.readDouble();
}

public function writeExternal(output:IDataOutput):void {
output.writeInt(userId);
output.writeObject(user);
output.writeInt(assoId);
output.writeInt(repPearlId);
output.writeObject(repPearl);
output.writeInt(state);
output.writeDouble(lastRightsUpdate);
}
}
}
