package com.broceliand.pearlTree.io.object.tree {

import com.broceliand.pearlTree.io.object.tree.AssociationData;
import flash.utils.IExternalizable;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

[RemoteClass(alias="Tree")]
public class TreeData implements IExternalizable {

private var _id:int;
private var _title:String;
private var _creationDate:Number;
private var _lastUpdate:Number;
private var _lastStructureUpdate:Number;
private var _lastEditorVisit:Number;
private var _rootPearlId:int;
private var _assoId:int;
private var _asso:com.broceliand.pearlTree.io.object.tree.AssociationData;
private var _state:int;
private var _visibility:int;
private var _organize:int;
private var _hits:int;
private var _descendantHits:int;
private var _version:int;
private var _avatarHash:flash.utils.ByteArray;
private var _backgroundHash:flash.utils.ByteArray;
private var _hasEdito:int;
private var _pearlCount:int;
private var _descendantPearlCount:int;
private var _descendantPrivatePearlCount:int;
private var _rootPearlNoteCount:int;
private var _rootPearlNeighbourCount:int;
private var _pearls:Array;
private var _parentTreeId:int;
private var _isOwner:int;
private var _clientId:int;
private var _collapsed:int;
private var _containsSubTeam:int;
private var _containsPrivate:int;
private var _edito:String;

public function get id():int { return _id; }
public function set id(value:int):void { _id = value; }
public function get title():String { return _title; }
public function set title(value:String):void { _title = value; }
public function get creationDate():Number { return _creationDate; }
public function set creationDate(value:Number):void { _creationDate = value; }
public function get lastUpdate():Number { return _lastUpdate; }
public function set lastUpdate(value:Number):void { _lastUpdate = value; }
public function get lastStructureUpdate():Number { return _lastStructureUpdate; }
public function set lastStructureUpdate(value:Number):void { _lastStructureUpdate = value; }
public function get lastEditorVisit():Number { return _lastEditorVisit; }
public function set lastEditorVisit(value:Number):void { _lastEditorVisit = value; }
public function get rootPearlId():int { return _rootPearlId; }
public function set rootPearlId(value:int):void { _rootPearlId = value; }
public function get assoId():int { return _assoId; }
public function set assoId(value:int):void { _assoId = value; }
public function get asso():com.broceliand.pearlTree.io.object.tree.AssociationData { return _asso; }
public function set asso(value:com.broceliand.pearlTree.io.object.tree.AssociationData):void { _asso = value; }
public function get state():int { return _state; }
public function set state(value:int):void { _state = value; }
public function get visibility():int { return _visibility; }
public function set visibility(value:int):void { _visibility = value; }
public function get organize():int { return _organize; }
public function set organize(value:int):void { _organize = value; }
public function get hits():int { return _hits; }
public function set hits(value:int):void { _hits = value; }
public function get descendantHits():int { return _descendantHits; }
public function set descendantHits(value:int):void { _descendantHits = value; }
public function get version():int { return _version; }
public function set version(value:int):void { _version = value; }
public function get avatarHash():flash.utils.ByteArray { return _avatarHash; }
public function set avatarHash(value:flash.utils.ByteArray):void { _avatarHash = value; }
public function get backgroundHash():flash.utils.ByteArray { return _backgroundHash; }
public function set backgroundHash(value:flash.utils.ByteArray):void { _backgroundHash = value; }
public function get hasEdito():int { return _hasEdito; }
public function set hasEdito(value:int):void { _hasEdito = value; }
public function get pearlCount():int { return _pearlCount; }
public function set pearlCount(value:int):void { _pearlCount = value; }
public function get descendantPearlCount():int { return _descendantPearlCount; }
public function set descendantPearlCount(value:int):void { _descendantPearlCount = value; }
public function get descendantPrivatePearlCount():int { return _descendantPrivatePearlCount; }
public function set descendantPrivatePearlCount(value:int):void { _descendantPrivatePearlCount = value; }
public function get rootPearlNoteCount():int { return _rootPearlNoteCount; }
public function set rootPearlNoteCount(value:int):void { _rootPearlNoteCount = value; }
public function get rootPearlNeighbourCount():int { return _rootPearlNeighbourCount; }
public function set rootPearlNeighbourCount(value:int):void { _rootPearlNeighbourCount = value; }
public function get pearls():Array { return _pearls; }
public function set pearls(value:Array):void { _pearls = value; }
public function get parentTreeId():int { return _parentTreeId; }
public function set parentTreeId(value:int):void { _parentTreeId = value; }
public function get isOwner():int { return _isOwner; }
public function set isOwner(value:int):void { _isOwner = value; }
public function get clientId():int { return _clientId; }
public function set clientId(value:int):void { _clientId = value; }
public function get collapsed():int { return _collapsed; }
public function set collapsed(value:int):void { _collapsed = value; }
public function get containsSubTeam():int { return _containsSubTeam; }
public function set containsSubTeam(value:int):void { _containsSubTeam = value; }
public function get containsPrivate():int { return _containsPrivate; }
public function set containsPrivate(value:int):void { _containsPrivate = value; }
public function get edito():String { return _edito; }
public function set edito(value:String):void { _edito = value; }

public function readExternal(input:IDataInput):void {
id = input.readInt();
title = input.readObject() as String;
creationDate = input.readDouble();
lastUpdate = input.readDouble();
lastStructureUpdate = input.readDouble();
lastEditorVisit = input.readDouble();
rootPearlId = input.readInt();
assoId = input.readInt();
asso = input.readObject() as com.broceliand.pearlTree.io.object.tree.AssociationData;
state = input.readInt();
visibility = input.readInt();
organize = input.readInt();
hits = input.readInt();
descendantHits = input.readInt();
version = input.readInt();
avatarHash = input.readObject() as flash.utils.ByteArray;
backgroundHash = input.readObject() as flash.utils.ByteArray;
hasEdito = input.readInt();
pearlCount = input.readInt();
descendantPearlCount = input.readInt();
descendantPrivatePearlCount = input.readInt();
rootPearlNoteCount = input.readInt();
rootPearlNeighbourCount = input.readInt();
pearls = input.readObject() as Array;
parentTreeId = input.readInt();
isOwner = input.readInt();
clientId = input.readInt();
collapsed = input.readInt();
containsSubTeam = input.readInt();
containsPrivate = input.readInt();
edito = input.readObject() as String;
}

public function writeExternal(output:IDataOutput):void {
output.writeInt(id);
output.writeObject(title);
output.writeDouble(creationDate);
output.writeDouble(lastUpdate);
output.writeDouble(lastStructureUpdate);
output.writeDouble(lastEditorVisit);
output.writeInt(rootPearlId);
output.writeInt(assoId);
output.writeObject(asso);
output.writeInt(state);
output.writeInt(visibility);
output.writeInt(organize);
output.writeInt(hits);
output.writeInt(descendantHits);
output.writeInt(version);
output.writeObject(avatarHash);
output.writeObject(backgroundHash);
output.writeInt(hasEdito);
output.writeInt(pearlCount);
output.writeInt(descendantPearlCount);
output.writeInt(descendantPrivatePearlCount);
output.writeInt(rootPearlNoteCount);
output.writeInt(rootPearlNeighbourCount);
output.writeObject(pearls);
output.writeInt(parentTreeId);
output.writeInt(isOwner);
output.writeInt(clientId);
output.writeInt(collapsed);
output.writeInt(containsSubTeam);
output.writeInt(containsPrivate);
output.writeObject(edito);
}
}
}
