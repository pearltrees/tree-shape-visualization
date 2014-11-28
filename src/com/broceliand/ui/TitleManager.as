package com.broceliand.ui
{
   import com.broceliand.ui.renderers.TitleRenderer;
   
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.getTimer;
   
   import mx.controls.Label;
   import mx.core.UIComponent;
   import mx.core.mx_internal;

   public class TitleManager
   {
      private static const END_LINE_SYMBOL:String = "...";
      private static const LEFT_RIGHT_PADDING:Number = 2;
      
      public static function formatPearlTitle(title:String, lineContainer:Label, maxLines:int) :Array {
         var result:Array = TitleManager.formatTitleLines(title, lineContainer, maxLines);
         if (result.length == 1 && maxLines > 1) {
            var spacePosition:int = title.lastIndexOf(" ");
            var bestSplit:int = spacePosition;
            var mid:int= title.length / 2;
            while (spacePosition>0) {
               if (Math.abs(spacePosition - mid) < Math.abs(bestSplit - mid) && spacePosition>3) {
                  bestSplit = spacePosition;
               }
               spacePosition = title.lastIndexOf(" ", spacePosition-1);
            }
            if (bestSplit>3) {
               result[0] = title.substr(0, bestSplit);
               result.push(title.substr(bestSplit+1, title.length));
            }
            
         }
         return result;
      }
      
      public static function formatTitleLines(title:String, lineContainer:Label, maxLines:uint=1):Array{
         if(!title) return new Array();
         
         var lines:Array = splitTitleByLines(title, lineContainer, maxLines);
         if(lines.length > maxLines) {
            
            lines.splice(maxLines, lines.length - maxLines);

            var lastLine:String = lines[lines.length-1];
            var lastLineWidth:Number = lineContainer.measureHTMLText(lastLine).width;            
            var lineMaxWidth:Number = getLineMaxWidth(lineContainer);
            var symbolWidth:Number = lineContainer.measureHTMLText(END_LINE_SYMBOL).width;
            if(lastLineWidth + symbolWidth > lineMaxWidth) {
               lastLine = lastLine.substr(0, indexOfCharAtWidth(lastLine, lineContainer, lastLineWidth - symbolWidth));
               
            }
            lines[lines.length-1] = lastLine + END_LINE_SYMBOL;
         }
         return lines;
      }
      
      private static function getLineMaxWidth(lineContainer:UIComponent):Number {
         var lineMaxWidth:Number = 0;
         if(lineContainer.width == 0) {
            lineMaxWidth = lineContainer.maxWidth;
         }
         else {
            lineMaxWidth = (lineContainer.width > lineContainer.maxWidth)?lineContainer.maxWidth:lineContainer.width;
         }
         return lineMaxWidth - (LEFT_RIGHT_PADDING * 2);
      }
      
      private static function splitTitleByLines(title:String, lineContainer:Label, maxLines:int):Array {
         
         var lineMaxWidth:Number = getLineMaxWidth(lineContainer);
         
         var lines:Array = new Array();
         var titleToSplit:String = title;         
         
         for(var i:uint=0; titleToSplit.length > 0; i++) {
            if (i>maxLines) {
               lines[i] = titleToSplit;
               break;
            }
            
            var titleToSplitWidth:Number = lineContainer.measureHTMLText(titleToSplit).width;
            
            if(titleToSplitWidth > lineMaxWidth) {
               var splitPos:Number = indexOfCharAtWidth(titleToSplit, lineContainer, lineMaxWidth);
               var currentLine:String = titleToSplit.substr(0, splitPos);
               var spacePos:Number = currentLine.lastIndexOf(' ');
               if(spacePos > 1) {
                  splitPos = spacePos;
               }
               currentLine = titleToSplit.substr(0, splitPos);
               lines[i] = currentLine;
               titleToSplit = titleToSplit.substring(splitPos, titleToSplit.length);
            }
            else{
               lines[i] = titleToSplit;
               titleToSplit = "";
            }
         }
         return lines;
      }
      
      private static function indexOfCharAtWidth(chars:String, textContainer:Label, maxWidth:Number):Number {
         var result:int = chars.length;
         var tf:TextField = textContainer.mx_internal::getTextField(); 
         if (tf) {
            result = indexOfCharAtWidthWithTextField(chars,tf, maxWidth);     
         }  else {
            for(var i:uint=0; i < chars.length; i++) {
               var toMeasure:String = chars.substr(0,i);
               var width:Number = textContainer.measureText(toMeasure).width;
               if(width > maxWidth && i > 1) {
                  result =  i - 2;
               }
            }
         }
         return result;
      }
      
      private static function indexOfCharAtWidthWithTextField(chars:String, textContainer:TextField, maxWidth:Number):Number {
         var textOrigin:String = textContainer.text;
         textContainer.text = chars;
         var result:int = chars.length;
         var startX:Number = 0;
         for(var i:uint=0; i < chars.length; i++) {
            var rect:Rectangle = textContainer.getCharBoundaries(i);
            if (rect == null) {
               continue;
            }
            if (startX== 0) {
               startX = rect.left;
            }
            if ((rect.right - startX)> maxWidth && i > 1) {
               result = i-2;
               break;
            }
         }
         textContainer.text = textOrigin;
         return result;
      }
   }
}