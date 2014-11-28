package com.broceliand.pearlTree.io.object.url {

import flash.utils.IExternalizable;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

[RemoteClass(alias="Url")]
public class UrlData implements IExternalizable {

private var _id:int;
private var _url:String;
private var _urlHash:flash.utils.ByteArray;
private var _logoHash:flash.utils.ByteArray;
private var _playerUrl:String;
private var _frameType:int;
private var _layout:int;
private var _logoType:int;
private var _extension:String;
private var _isPearlSquareImageAvailable:int;
private var _isNotFound:int;
private var _isB52SquareImageAvailable:int;

public function get id():int { return _id; }
public function set id(value:int):void { _id = value; }
public function get url():String { return _url; }
public function set url(value:String):void { _url = value; }
public function get urlHash():flash.utils.ByteArray { return _urlHash; }
public function set urlHash(value:flash.utils.ByteArray):void { _urlHash = value; }
public function get logoHash():flash.utils.ByteArray { return _logoHash; }
public function set logoHash(value:flash.utils.ByteArray):void { _logoHash = value; }
public function get playerUrl():String { return _playerUrl; }
public function set playerUrl(value:String):void { _playerUrl = value; }
public function get frameType():int { return _frameType; }
public function set frameType(value:int):void { _frameType = value; }
public function get layout():int { return _layout; }
public function set layout(value:int):void { _layout = value; }
public function get logoType():int { return _logoType; }
public function set logoType(value:int):void { _logoType = value; }
public function get extension():String { return _extension; }
public function set extension(value:String):void { _extension = value; }
public function get isPearlSquareImageAvailable():int { return _isPearlSquareImageAvailable; }
public function set isPearlSquareImageAvailable(value:int):void { _isPearlSquareImageAvailable = value; }
public function get isNotFound():int { return _isNotFound; }
public function set isNotFound(value:int):void { _isNotFound = value; }
public function get isB52SquareImageAvailable():int { return _isB52SquareImageAvailable; }
public function set isB52SquareImageAvailable(value:int):void { _isB52SquareImageAvailable = value; }

public function readExternal(input:IDataInput):void {
id = input.readInt();
url = input.readObject() as String;
urlHash = input.readObject() as flash.utils.ByteArray;
logoHash = input.readObject() as flash.utils.ByteArray;
playerUrl = input.readObject() as String;
frameType = input.readInt();
layout = input.readInt();
logoType = input.readInt();
extension = input.readObject() as String;
isPearlSquareImageAvailable = input.readInt();
isNotFound = input.readInt();
isB52SquareImageAvailable = input.readInt();
}

public function writeExternal(output:IDataOutput):void {
output.writeInt(id);
output.writeObject(url);
output.writeObject(urlHash);
output.writeObject(logoHash);
output.writeObject(playerUrl);
output.writeInt(frameType);
output.writeInt(layout);
output.writeInt(logoType);
output.writeObject(extension);
output.writeInt(isPearlSquareImageAvailable);
output.writeInt(isNotFound);
output.writeInt(isB52SquareImageAvailable);
}
}
}
