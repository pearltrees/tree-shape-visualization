package com.broceliand.pearlTree.model
{
   import org.un.cava.birdeye.ravis.utils.Geometry;

   public class BroRadialPosition
   {
      
      private var _radius:Number;
      private var _angleInRad:Number;
      
      public function BroRadialPosition(radius:Number, angleInRad:Number)
      {
         _radius = radius;
         _angleInRad = angleInRad;
      }
      public function get radius ():Number
      {
         return _radius;
      }
      public function get angleInRad ():Number
      {
         return _angleInRad;
      }
      public function get angleInDeg() : Number {
         return  Geometry.rad2deg(_angleInRad);
      }
   }
}