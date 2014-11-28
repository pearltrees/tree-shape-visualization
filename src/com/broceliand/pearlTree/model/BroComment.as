package com.broceliand.pearlTree.model {
   import com.broceliand.ui.model.NoteModel;
   import com.broceliand.util.Alert;
   import com.broceliand.util.BroLocale;

   public class BroComment {
      public static const TYPE_USER_MESSAGE:uint = 1;
      public static const TYPE_TEAM_DISCUSSION_MESSAGE:uint = 4;
      
      public static const TYPE_NEW_USER_MESSAGE:uint = 6; 
      public static const TYPE_NEW_TEAM_DISCUSSION_MESSAGE:uint = 7; 
      
      protected var _persistentID:int = -1;
      protected var _persistentDbID:int = -1;
      protected var _text:String;
      protected var _date:Number;
      protected var _author:User;
      protected var _parentTree:BroPearlTree;
      protected var _type:uint;
      protected var _editable:Boolean;
      protected var _pearlId:int;
      protected var _pearlDb:int;
      protected var _toUser:User;
      
      function BroComment() {
         _type = TYPE_USER_MESSAGE;
      }
      
      public function set persistentID(value:int):void{
         _persistentID = value;
      }
      public function get persistentID():int{
         return _persistentID;
      }
      
      public function set persistentDbID(value:int):void{
         _persistentDbID = value;
      }
      public function get persistentDbID():int{
         return _persistentDbID;
      }      
      
      public function isPersisted():Boolean {
         return (_persistentID != -1 && _persistentDbID != -1);
      }
      
      public function set text(value:String):void{
         _text = value;
      }
      public function get text():String{
         return _text;
      }
      
      public function set pearlId(value:int):void{
         _pearlId = value;
      }
      public function get pearlId():int{
         return _pearlId;
      }
      
      public function set pearlDb(value:int):void{
         _pearlDb = value;
      }
      public function get pearlDb():int{
         return _pearlDb;
      }
      
      public function set date(value:Number):void{
         _date = value;
      }
      public function get date():Number{
         return _date;
      }		
      
      public function set author(value:User):void{
         _author = value;
      }
      public function get author():User{
         return _author;
      }
      
      public function set parentTree(value:BroPearlTree):void{
         _parentTree = value;
      }
      public function get parentTree():BroPearlTree{
         return _parentTree;
      }
      
      public function set type(value:uint):void{
         _type = value;
      }
      public function get type():uint{
         return _type;
      }
      
      public function get editable():Boolean {
         return _editable;
      }
      public function set editable(value:Boolean):void {
         _editable = value;
      }
      
      public function equals(note:BroComment):Boolean {
         return (note && note.persistentID == persistentID && note.persistentDbID == persistentDbID);
      }
      
      public function get toUser():User {
         return _toUser;
      }
      
      public function set toUser(value:User):void {
         _toUser = value;
      }
      
   }
}