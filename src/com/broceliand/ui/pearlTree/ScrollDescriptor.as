package com.broceliand.ui.pearlTree
{
   
   public class ScrollDescriptor
   {
      
      protected var _speed:Number;
      protected var _xMultiplier:Number;
      protected var _yMultiplier:Number;
      
      public function get yMultiplier():Number {
         return _yMultiplier;
      }
      
      public function set yMultiplier(o:Number):void {
         _yMultiplier = o;
      }
      
      public function get xMultiplier():Number {
         return _xMultiplier;
      }
      
      public function set xMultiplier(o:Number):void {
         _xMultiplier = o;
      }
      
      public function get speed():Number {
         return _speed;
      }
      
      public function set speed(o:Number):void {
         _speed = o;
      }
      
   }
}