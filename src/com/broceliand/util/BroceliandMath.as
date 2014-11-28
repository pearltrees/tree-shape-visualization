package com.broceliand.util
{
   import com.broceliand.ui.GeometricalConstants;
   
   import flash.geom.Point;

   public class BroceliandMath
   {
      static public  function getDistanceBetweenPoints(p1:Point, p2:Point):Number{
         if((p1 == null) || (p2 == null)){
            return uint.MAX_VALUE;
         }else{
            var xDiff:Number = p2.x - p1.x; 
            var yDiff:Number = p2.y - p1.y;
            return Math.sqrt(xDiff * xDiff + yDiff * yDiff);
         }			
      }
      static public  function getSquareDistanceBetweenPoints(p1:Point, p2:Point):Number{
         if((p1 == null) || (p2 == null)){
            return uint.MAX_VALUE;
         }else{
            var xDiff:Number = p2.x - p1.x; 
            var yDiff:Number = p2.y - p1.y;
            return (xDiff * xDiff + yDiff * yDiff);
         }        
      }
      static public  function getSquareDistanceBetweenPointsWithWeight(p1:Point, p2:Point, yFactor:Number):Number{
         if((p1 == null) || (p2 == null)){
            return uint.MAX_VALUE;
         }else{
            var xDiff:Number = p2.x - p1.x; 
            var yDiff:Number = (p2.y - p1.y) * yFactor;
            return (xDiff * xDiff + yDiff * yDiff);
         }        
      }
   }
}