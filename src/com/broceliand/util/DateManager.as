package com.broceliand.util
{
   import com.broceliand.pearlTree.model.BroLink;
   
   public class DateManager
   {
      private static const MIN_DATE:Date = new Date(2010, 0, 1);
      
      public static function timestampToDate(time:Number,inSeconds:Boolean=false):Date {
         if(time < 0) return null;
         if(inSeconds){
            time = time * 1000;
         }
         return new Date(time);
      }
      
      public static function formatCompact(dateToFormat:Date):String{
         if(!dateToFormat) return "n/a";
         var year:String = dateToFormat.fullYear.toString();
         var monthId:Number = dateToFormat.month + 1;
         var month:String = monthId.toString();
         var date:String = dateToFormat.date.toString();
         return date+"/"+month+"/"+year;
      }

      private static function formatEnglishDate(dateToFormat:Date):String {
         if(!dateToFormat) return "n/a";
         var month:String = DateManager.getMonthLabelInEnglish(dateToFormat.month);
         var date:String = dateToFormat.date.toString();
         /* Hours and minutes are not used anymore
         var fullYear:String = dateToFormat.fullYear.toString();
         var year:String = fullYear.substr(fullYear.length-2, 2);
         var hours:String = (dateToFormat.hours >= 10)?dateToFormat.hours.toString():"0"+dateToFormat.hours.toString();
         var minutes:String = (dateToFormat.minutes >= 10)?dateToFormat.minutes.toString():"0"+dateToFormat.minutes.toString();
         */
         return date+" "+month;
      }  
      
      private static function formatEnglishDateWithYear(dateToFormat:Date):String {
         if(!dateToFormat) return "n/a";
         var month:String = DateManager.getMonthLabelInEnglish(dateToFormat.month);
         var date:String = dateToFormat.date.toString();
         var year:String = dateToFormat.fullYear.toString();
         return month + " " + date + ", " + year;
      }        

      private  static function formatFrenchDate(dateToFormat:Date):String {
         if(!dateToFormat) return "n/a";
         var month:String = DateManager.getMonthLabelInFrench(dateToFormat.month);
         var date:String = dateToFormat.date.toString();
         /* Hours and minutes are not used anymore 
         like formatEnglishDate*/
         return date +" " + month;
      }
      
      private  static function formatFrenchDateWithYear(dateToFormat:Date):String {
         if(!dateToFormat) return "n/a";
         var month:String = DateManager.getMonthLabelInFrench(dateToFormat.month);
         var date:String = dateToFormat.date.toString();
         var year:String = dateToFormat.fullYear.toString();         
         return date + " " + month + " " + year;
      }      

      public static function formatDate(dateToFormat:Date):String {
         if (BroLocale.getInstance().lang == BroLocale.FRENCH)
            return formatFrenchDate(dateToFormat);
         else (BroLocale.getInstance().lang == BroLocale.ENGLISH)
         return formatEnglishDate(dateToFormat);   
      }
      
      public static function formatDateWithYear(dateToFormat:Date):String {
         if (dateToFormat.getTime() < MIN_DATE.getTime()) {
            dateToFormat = MIN_DATE;
         }
         if (BroLocale.getInstance().lang == BroLocale.FRENCH)
            return formatFrenchDateWithYear(dateToFormat);
         else (BroLocale.getInstance().lang == BroLocale.ENGLISH)
         return formatEnglishDateWithYear(dateToFormat);   
      }      

      public static function formatDateContextual(dateToFormat:Date, inEnglish:Boolean = true):String {
         if(!dateToFormat) return "n/a";
         var currentDate:Date = new Date();

         var oneHourInMinutes:Number = 60;
         var oneDayInMinutes:Number = 24*oneHourInMinutes;
         var oneMonthInMinutes:Number = 30*oneDayInMinutes;
         var oneYearInMinutes:Number = 365*oneDayInMinutes;
         
         var currentMilliseconds:Number = currentDate.time;
         var dateToFormatMilliseconds:Number = dateToFormat.time;
         
         var absoluteMinutesDiff:Number = Math.floor((currentMilliseconds - dateToFormatMilliseconds)/60000);
         
         var yearDiff:Number = Math.floor(absoluteMinutesDiff/oneYearInMinutes);
         var monthDiff:Number = Math.floor(absoluteMinutesDiff/oneMonthInMinutes);
         var dateDiff:Number = Math.floor(absoluteMinutesDiff/oneDayInMinutes);
         var hoursDiff:Number = Math.floor(absoluteMinutesDiff/oneHourInMinutes);
         var minutesDiff:Number = absoluteMinutesDiff;
         
         if(yearDiff >= 2) return BroLocale.getText('datemanager.years',[yearDiff]);
         else if(yearDiff >= 1) return BroLocale.getText('datemanager.oneyear'); 
         
         if(monthDiff >= 2) return BroLocale.getText('datemanager.monthes',[monthDiff]);
         else if(monthDiff >= 1) return BroLocale.getText('datemanager.onemonth');

         if(dateDiff >= 21) return BroLocale.getText('datemanager.threeweeks');
         else if(dateDiff >= 14) return BroLocale.getText('datemanager.twoweeks');
         else if(dateDiff >= 7) return BroLocale.getText('datemanager.oneweek');
         else if(dateDiff >= 2) return BroLocale.getText('datemanager.days',[dateDiff]);
         else if(dateDiff >= 1) return BroLocale.getText('datemanager.oneday');
         
         if(hoursDiff >= 2) return BroLocale.getText('datemanager.hours',[hoursDiff]);
         else if(hoursDiff >= 1) return BroLocale.getText('datemanager.onehour');
         
         if(minutesDiff >= 2) return BroLocale.getText('datemanager.minutes',[minutesDiff]);
         else if(minutesDiff >= 1) return BroLocale.getText('datemanager.oneminute');            
         
         return BroLocale.getText('datemanager.seconds');           
      }
      
      public static function getMonthLabelInEnglish(monthNumber:uint):String {
         var monthLabels:Array = new Array(
            "january","february","march","april","may","june","july",
            "august","september","october","november","december");
         return monthLabels[monthNumber];
      }
      
      public static function getMonthLabelInFrench(monthNumber:uint):String {
         var monthLabels:Array = new Array(
            "janvier","février","mars","avril","mai","juin","juillet",
            "août","septembre","octobre","novembre","décembre");
         return monthLabels[monthNumber];
      }
      
      public static function areSameDay(timestamp1:Number, timestamp2:Number):Boolean {
         var date1:Date = timestampToDate(timestamp1);
         var date2:Date = timestampToDate(timestamp2);
         return ((date1.date == date2.date) && (date1.month == date2.month) && (date1.fullYear == date2.fullYear));
      }
      
   }
}