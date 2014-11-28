package com.broceliand.util
{
   import flash.geom.Point;
   
   public interface IMoveOnValidation
   {
      function moveOnValidation(x:Number, y:Number):Boolean;
      function getTargetMove():Point;
      function commitMove():Boolean;
   }
}