package com.broceliand.pearlTree.io.object.tree {

import flash.utils.IExternalizable;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

[RemoteClass(alias="TreeEdito")]
public class TreeEditoData implements IExternalizable {

private var _treeId:int;
private var _text:String;
private var _lastUpdate:Number;

public function get treeId():int { return _treeId; }
public function set treeId(value:int):void { _treeId = value; }
public function get text():String { return _text; }
public function set text(value:String):void { _text = value; }
public function get lastUpdate():Number { return _lastUpdate; }
public function set lastUpdate(value:Number):void { _lastUpdate = value; }

public function readExternal(input:IDataInput):void {
treeId = input.readInt();
text = input.readObject() as String;
lastUpdate = input.readDouble();
}

public function writeExternal(output:IDataOutput):void {
output.writeInt(treeId);
output.writeObject(text);
output.writeDouble(lastUpdate);
}
}
}
