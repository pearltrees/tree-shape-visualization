package com.broceliand.graphLayout.model
{
   public class EdgeData
   {
      
      protected var _visible:Boolean = true;
      protected var _weight:Number = 1;
      protected var _temporary:Boolean = false;
      private var _highlighted:Boolean = false;;

      public function get temporary():Boolean {
         return _temporary;
      }
      
      public function set temporary(o:Boolean):void {
         _temporary = o;
      }
      
      public function get visible():Boolean {
         return _visible;
      }
      
      public function set visible(o:Boolean):void {
         _visible = o;
      }
      
      public function get weight():Number {
         return _weight;
      }
      
      public function set weight(o:Number):void {
         _weight = o;
      }
      public function set highlighted (value:Boolean):void
      {
         _highlighted = value;
      }
      
      public function get highlighted ():Boolean
      {
         return _highlighted;
      }
      
   }
}