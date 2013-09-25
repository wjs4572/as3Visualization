package org.wsimpson.util

/*
** Title:	DateUtil.as
** Purpose: Class for calculations and routines not available in Flash Date
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
/**
* @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/Date.html#Date()
* @see http://www.museumstuff.com/learn/topics/first_quarter_of_a_calendar_year
*/
{
	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;
	
	public class DateUtil
	{	
		// Public Constants
		public static const MAXPRECISION:int = 6; 								// Used to cut of floating point calculation errors
		public static const TOTALDAYSFOURCENTURIES:int = (365.25 * 400) - 3; 	// Only centuries divisible by 4 are leap years
		public static const TOTALMONTHSFOURCENTURIES:int = (12 * 400);
		public static const AVERAGEDAYSPERYEAR:Number = NumberUtil.roundDec((TOTALDAYSFOURCENTURIES / 400),MAXPRECISION);
		public static const AVERAGEDAYSPERMONTH:Number = NumberUtil.roundDec((TOTALDAYSFOURCENTURIES / TOTALMONTHSFOURCENTURIES),MAXPRECISION);
		public static const AVERAGEWEEKSPERMONTH:Number = NumberUtil.roundDec((AVERAGEDAYSPERMONTH / 7),MAXPRECISION);
		public static const MILLISECONDSPERMILLISECOND:int = 1;
		public static const MILLISECONDSPERCENTISECOND:int = 10;
		public static const MILLISECONDSPERDECISECOND:int = 100;
		public static const MILLISECONDSPERSECOND:int = 1000;
		public static const MILLISECONDSPERMINUTE:int = MILLISECONDSPERSECOND * 60;
		public static const MILLISECONDSPERHOUR:int = MILLISECONDSPERMINUTE * 60;
		public static const MILLISECONDSPERDAY:int = MILLISECONDSPERHOUR * 24;
		public static const MILLISECONDSPERWEEK:int = MILLISECONDSPERDAY * 7;
		// Anything larger than MILLISECONDSPERWEEK is too large for the int data type.  Range supported is -2**31 to 2**31-1 (** indicates raise to power)

		// For mapping to the unit array
		public static const MINUTESPERMILLISECOND:Number = NumberUtil.roundDec((1 / (1000 * 60)),MAXPRECISION);
		public static const MINUTESPERCENTISECOND:Number =  NumberUtil.roundDec((1 / (100 * 60)),MAXPRECISION);
		public static const MINUTESPERDECISECOND:Number =  NumberUtil.roundDec((1 / (10 * 60)),MAXPRECISION);
		public static const MINUTESPERSECOND:Number = NumberUtil.roundDec((1 / 60),MAXPRECISION);
		public static const MINUTESPERMINUTE:Number = 1;
		public static const MINUTESPERHOUR:Number = MINUTESPERMINUTE * 60;
		public static const MINUTESPERDAY:Number = MINUTESPERHOUR * 24;
		public static const MINUTESPERWEEK:Number = MINUTESPERDAY * 7;
		public static const MINUTESPERMONTH:Number = NumberUtil.roundDec((MINUTESPERDAY * AVERAGEDAYSPERMONTH),MAXPRECISION);
		public static const MINUTESPERYEAR:Number = NumberUtil.roundDec((MINUTESPERDAY * AVERAGEDAYSPERYEAR),MAXPRECISION);
		public static const MINUTESPERDECADE:Number = NumberUtil.roundDec((MINUTESPERYEAR * 10),MAXPRECISION);
		public static const MINUTESPERCENTURY:Number = NumberUtil.roundDec((MINUTESPERYEAR * 100),MAXPRECISION);
		public static const MINUTESPERMILLENNIA:Number = NumberUtil.roundDec((MINUTESPERYEAR * 1000),MAXPRECISION);
		public static const MINUTESARR:Array = [MINUTESPERMILLISECOND,MINUTESPERCENTISECOND,MINUTESPERDECISECOND,MINUTESPERSECOND,MINUTESPERMINUTE,MINUTESPERHOUR,MINUTESPERDAY,MINUTESPERWEEK,MINUTESPERMONTH,MINUTESPERYEAR,MINUTESPERDECADE,MINUTESPERCENTURY,MINUTESPERMILLENNIA];
		// Rough Conversion factor from one unit to the next unit with the higher index.
		public static const CONVARR:Array = [10,10,10,60,60,24,7,AVERAGEWEEKSPERMONTH,12,10,10,10,10];
		
		// Public Time Unites
		// Public Instance Variables
		public static const BEGINDATE:uint = 0;				
		public static const ENDDATE:uint = 1;				
		public static const MILLISECONDS:uint = 0;				
		public static const CENTISECONDS:uint = 1;				
		public static const DECISECONDS:uint = 2;				
		public static const SECONDS:uint = 3;					
		public static const MINUTES:uint = 4;					
		public static const HOURS:uint = 5;						
		public static const DAYS:uint = 6;						
		public static const WEEKS:uint = 7;						
		public static const MONTHS:uint = 8;					
		public static const YEARS:uint = 9;						
		public static const DECADES:uint = 10;					
		public static const CENTURIES:uint = 11;				
		public static const MILLENNIA:uint = 12;
		public static const UNITARR:Array = ['Milliseconds','Centiseconds','Deciseconds','Seconds','Minutes','Hours','Days','Weeks','Months','Years','Decades','Centuries','Millennia'];
		
		// For tests
		public static const FUNC_CEIL:String = "CEIL";			// Testing the date function at multiple unit levels
		public static const FUNC_FLOOR:String = "FLOOR";		// Testing the date function at multiple unit levels
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		
		// Constructor
		public function DateUtil()
		{
			////this._debugger = DebugUtil.getInstance();
		}
		/*********************************************************************************************************
		**  DIAGNOSTICS																							**
		**********************************************************************************************************/

		/**
		*  Name:  	fullDiagnostic
		*			Supports testing for floor and ceiling functions
		*
		*  @example	var newDate:Date;
		*			newDate = new Date(2111,5,9,4,23,42,543);
		*			DateUtil.fullDiagnostic(newDate);
		*
		*  @param 	inDate	Date Date for comparison
		*/
		public static function fullDiagnostic(inDate):void
		{
			testConstants();
			(DebugUtil.getInstance()).wTrace("Base Date " + inDate + " ms = " +  inDate.getMilliseconds());
			testDateFunctions(inDate,FUNC_FLOOR);
			testDateFunctions(inDate,FUNC_CEIL);
			testTimeUnitValues(inDate);
			testDateRanges(inDate);
		}

		/**
		*  Name:  	testConstants
		*			Supports testing for floor and ceiling functions
		*  @param 	inDate	Date Date for comparison
		*/
		public static function testConstants():void
		{
			(DebugUtil.getInstance()).wTrace("DateUtil constants ")
			for (var i:int=0; i <= MILLENNIA; i++)
			{
				(DebugUtil.getInstance()).wTrace(UNITARR[i] + " each have " +  MINUTESARR[i] + " minutes");
			}
		}
		
		/**
		*  Name:  	testTimeUnitValues
		*			Supports testing for floor and ceiling functions
		*  @param 	inDate	Date Date for comparison
		*/
		public static function testTimeUnitValues(inDate:Date):void
		{
			(DebugUtil.getInstance()).wTrace("Base Date " + inDate + " ms = " +  inDate.getMilliseconds())
			for (var i:int=0; i <= MILLENNIA; i++)
			{
				(DebugUtil.getInstance()).wTrace("Unit value " + UNITARR[i] + ":  " + getTimeUnitValue(inDate,i));

			}
		}
		
		/**
		*  Name:  	testDateFunctions
		*			Supports testing for floor and ceiling functions
		*  @param 	inDate	Date Date for comparison
		*  @param 	inFunc	String Date Function being tested, supported (FUNC_CEIL,FUNC_FLOOR)
		*/
		public static function testDateFunctions(inDate:Date,inFunc:String):void
		{
			var newDate:Date;
			
			(DebugUtil.getInstance()).wTrace("Testing Function " + inFunc);
			for (var i:int=0; i <= MILLENNIA; i++)
			{
				(DebugUtil.getInstance()).wTrace("in unit " + UNITARR[i]);
				switch(inFunc)
				{
					case FUNC_CEIL:
						newDate = dateCeil(inDate,i);
					break;
					case FUNC_FLOOR:
						newDate = dateFloor(inDate,i);
					break;
				}
				(DebugUtil.getInstance()).wTrace("Out Date " + newDate + " ms = " +  newDate.getMilliseconds())
			}
		}

		/**
		*  Name:  	testDateRanges
		*			Supports testing for floor and ceiling functions
		*  @param 	inDate	Date Date for comparison		
		*/
		public static function testDateRanges(inDate:Date):void
		{
			var newDate:Date;
			(DebugUtil.getInstance()).wTrace("Base Date " + inDate + " ms = " +  inDate.getMilliseconds());
			for (var i:int=0; i <= MILLENNIA; i++)
			{
				(DebugUtil.getInstance()).wTrace("Unit difference set " + UNITARR[i]);
				newDate = 	addTimeUnit(inDate,5,i);
				(DebugUtil.getInstance()).wTrace("New Date " + newDate + " ms = " +  newDate.getMilliseconds());
				(DebugUtil.getInstance()).wTrace("Unit difference set " + UNITARR[getTimeUnitBetween(inDate, newDate)]);
			}
		}

		/*********************************************************************************************************
		**  PUBLIC																								**
		**********************************************************************************************************/
		/**
		*  Name:  	covertUnits
		*  @param 	inVal	Number Original Value
		*  @param 	inUnit	uint Original time unit
		*  @param   inUnit2 uint Desired Unit
		*  @return  Number Coverted value
		*/
		public static function covertUnits(inVal:Number,inUnit:uint, inUnit2:uint):Number
		{
			var tempVal:Number;
			
			tempVal = (inUnit <= inUnit2) ? scaleUp(inVal,inUnit,inUnit2) : scaleDown(inVal,inUnit,inUnit2);
			return tempVal;
		}

		/**
		*  Name:  	calcFactor
		*  @param 	inDate1	Date Date for comparison
		*  @param 	inDate2	Date Date for comparison
		*  @param   inMax uint The maximum number of tick marks desired
		*  @return  uint Returns an the time unit multiplier to ensure the quantity of ticks is less than the max
		*/
		public static function calcFactor(inDate1:Date,inDate2:Date, inMax:int=20):uint
		{
			var contraintArr:Array;
			var factorsArr:Array;
			var timeUnit:int;
			var tempFactor:int;
			var numMinutes:Number;
			var tempIn1:Number;
			var tempIn2:Number;
			var range:int;
			
			timeUnit = getTimeUnitBetween(inDate1, inDate2);
			contraintArr = getDateRange(inDate1,inDate2,timeUnit);
			timeUnit--;
			numMinutes = MINUTESARR[timeUnit];
			
			tempIn1 = contraintArr[BEGINDATE].getTime();
			tempIn2 = contraintArr[ENDDATE].getTime();
			range = covertUnits(tempIn2 - tempIn1,MILLISECONDS,MINUTES);
			
			range = range / numMinutes;
			tempFactor = int(NumberUtil.getMaxReturn(range,inMax));

			return tempFactor;
		}

		/**
		*  Name:  	getMaxUnit
		*  Purpose:	Used to scale up time units
		* @param inVal Number DateValue
		* @param inUnit int The starting unit value, assumed lowest (i.e. milliseconds)
		* @return int The maximum date unit that can divide this number
		*/			
		public static function getMaxUnit(inVal:Number,inUnit:int=-1):uint
		{
			var tempVal:Number;
			var tempUnit:uint;
			var prevUnit:uint;
			tempVal = inVal;
			tempUnit = (inUnit >= 0) ? inUnit : MILLISECONDS;
			prevUnit = tempUnit;

			for (var i:uint = (tempUnit + 1); i < UNITARR.length;i++)
			{
				var tempNum:Number;
				tempNum = scaleUp(tempVal,prevUnit,i);
				tempUnit = (tempNum > 0) ? i : tempUnit;
				prevUnit = i;
			}
			return tempUnit;
		}
				
		/**
		*  Name:  	getTimeUnitRange
		*  @param 	inDate1	Date Date for comparison
		*  @param 	inDate2	Date Date for comparison
		*  @param	inFactor int	Multiplier to reduce the size of the array
		*  @param	inUnit int	Force a specific time unit to be used.
		*  @return Array Returns an array with maximum time units containing the two compared.
		*/
		public static function getTimeUnitRange(inDate1:Date,inDate2:Date, inFactor:int = 1,inUnit:int = -1):Array
		{
			var timeArr:Array;
			var constraintArr:Array;
			var beginDate:Date;
			var endDate:Date;
			var newDate:Date;
			var timeUnit:int;	
			timeArr = new Array();
			inFactor = (inFactor <= 1) ? 1 : inFactor;
			timeUnit = (inUnit >= 0) ? (inUnit + 1) : getTimeUnitBetween(inDate1, inDate2);
			
			constraintArr = getDateRange(inDate1,inDate2,timeUnit);
			beginDate = constraintArr[BEGINDATE];
			endDate = constraintArr[ENDDATE];
			timeArr.push(beginDate);
			newDate = beginDate;
			
			timeUnit--;
			do 
			{
				newDate = addTimeUnit(newDate,(1 * inFactor),timeUnit);
				timeArr.push(newDate);
			} while (newDate < endDate)
			return timeArr;
		}
			
		/**
		*  Name:  	addTimeUnit
		*  @param 	inDate	Date Date for addition
		*  @param 	inUnit	int Time unit to round to
		*  @return Date The new Date value.
		*/
		public static function addTimeUnit(inDate:Date,inVal:int,inUnit:int):Date
		{
			var newDate:Date;

			switch(inUnit)
			{
				case MILLENNIA:
					newDate = addMillennia(inDate,inVal);
				break;
				case CENTURIES:
					newDate = addCenturies(inDate,inVal);
				break;
				case DECADES:
					newDate = addDecades(inDate,inVal);
				break;
				case YEARS:
					newDate = addYears(inDate,inVal);
				break;
				case MONTHS:
					newDate = addMonths(inDate,inVal);
				break;
				case WEEKS:
					newDate = addWeeks(inDate,inVal);
				break;
				case DAYS:
					newDate = addDays(inDate,inVal);
				break;
				case HOURS:
					newDate = addHours(inDate,inVal);
				break;
				case MINUTES:
					newDate = addMinutes(inDate,inVal);
				break;
				case SECONDS:
					newDate = addSeconds(inDate,inVal);
				break;
				case DECISECONDS:
					newDate = addDeciSeconds(inDate,inVal);
				break;
				case CENTISECONDS:
					newDate = addCentiSeconds(inDate,inVal);
				break;
				default:
					(DebugUtil.getInstance()).wTrace("Unrecognized timeUnit = " + inUnit);
				case MILLISECONDS:
					newDate = addMilliSeconds(inDate,inVal);
			}
			return newDate;
		}

		/**
		*  Name:  	getTimeUnitValue
		*  @param 	inDate	Date Date to parse
		*  @param 	inUnit	int Time unit to return
		*  @return int value returned.
		*/
		public static function getTimeUnitValue(inDate:Date,inUnit:int):int
		{
			var tempInt:int;
			
			switch(inUnit)
			{
				case MILLENNIA:
					tempInt = Math.floor(inDate.getFullYear() / 1000);
				break;
				case CENTURIES:
					tempInt = Math.floor(inDate.getFullYear() / 100);
				break;
				case DECADES:
					tempInt = Math.floor(inDate.getFullYear() / 10);
				break;
				case YEARS:
					tempInt = inDate.getFullYear();
				break;
				case MONTHS:
					tempInt = inDate.getMonth();
				break;
				case WEEKS:
					tempInt = weeksBetween(inDate, dateFloor(inDate,MONTHS));
				break;
				case DAYS:
					tempInt = inDate.getDate();
				break;
				case HOURS:
					tempInt = inDate.getHours();
				break;
				case MINUTES:
					tempInt = inDate.getMinutes();
				break;
				case SECONDS:
					tempInt = inDate.getSeconds();
				break;
				case DECISECONDS:
					tempInt = Math.floor(inDate.getMilliseconds() / 100);
				break;
				case CENTISECONDS:
					tempInt = Math.floor(inDate.getMilliseconds() / 10);
				break;
				case MILLISECONDS:
					tempInt = inDate.getMilliseconds();
				break;
				default:
					(DebugUtil.getInstance()).wTrace("DateUtil.getTimeUnitValue:  Unrecognized timeUnit = " + inUnit);
				break;
			}
			return tempInt;
		}

		
		/**
		*  Name:  	getTimeUnitBetween
		*  @param 	inDate1	Date Date for comparison
		*  @param 	inDate2	Date Date for comparison
		*  @return int The maximum time unit supported between these dates.
		* 
		*/
		public static function getTimeUnitBetween(inDate1:Date,inDate2:Date):int
		{
			var timeUnit:int;
			timeUnit = -1;
			for (var i:int = MILLENNIA; i >= 0; i--)
			{
				var tempDiff:Number;
				tempDiff = getTimeBetween(inDate1,inDate2,i);
				if (tempDiff > 1)
				{
					timeUnit = i;
					i = -1;
				}
			}
			return timeUnit;
		}		
		
		/**
		*  Name:  	dateFloor
		*  @param 	inDate	Date Date for comparison
		*  @param 	inUnit	int Time unit to round to
		*  @return Date The nearest time unit before.
		*/
		public static function dateFloor(inDate:Date,inUnit:int):Date
		{
			var newDate:Date;
			var newYear:int;
			var newMonth:int;
			var newCalDay:int;
			var newHour:int;
			var newMinute:int;
			var newSecond:int;
			var newMillisecond:int;
			var tempDay:int;
			newYear = inDate.getFullYear();
			newMonth = inDate.getMonth();
			newCalDay = inDate.getDate();
			newHour = inDate.getHours();
			newMinute = inDate.getMinutes();
			newSecond = inDate.getSeconds();
			newMillisecond = inDate.getMilliseconds();

			switch(inUnit)
			{
				case MILLENNIA:
					// Floor to the nearest Millenium
					newYear = Math.floor(newYear/1000) * 1000;
				case CENTURIES:
					// Floor to the nearest Century
					newYear = Math.floor(newYear/100) * 100;
				case DECADES:
					// Floor to the nearest Decade
					newYear = Math.floor(newYear/10) * 10;
				case YEARS:
					// Floor to the nearest Year
					newMonth = 0;
				case MONTHS:
					newCalDay = 1;
				case DAYS:
					newHour = 0;
				case HOURS:
					newMinute = 0;
				case MINUTES:
					newSecond = 0;
				case SECONDS:
					newMillisecond = 0;
				case DECISECONDS:
					newMillisecond = Math.floor(newMillisecond/100) * 100;			
				case CENTISECONDS:
					newMillisecond = Math.floor(newMillisecond/10) * 10;				
				case MILLISECONDS:
					// Do Nothing
				break;
				case WEEKS:
					// If not Sunday, resets to previous Sunday
					tempDay = inDate.getDay();
					inDate = dateFloor(inDate,DAYS);
				break;
				default:
					(DebugUtil.getInstance()).wTrace("DateUtil.dateFloor: testing the timeUnit = " + inUnit);
				break;
			}
			return (tempDay > 0) ? addDays(inDate,-tempDay) : new Date(newYear,newMonth,newCalDay,newHour,newMinute,newSecond,newMillisecond);

		}
		
		/**
		*  Name:  	dateCeil
		*  @param 	inDate	Date Date for comparison
		*  @param 	inUnit	int Time unit to round to
		*  @return Date The nearest time unit after.
		*/
		public static function dateCeil(inDate:Date,inUnit:int):Date
		{
			var newDate:Date;
			var tempInt:int;
			var tempUnit:int;
			
			tempUnit = (inUnit > MILLISECONDS) ? (inUnit - 1) : MILLISECONDS;
			newDate = dateFloor(inDate,inUnit);
			tempInt = getTimeUnitValue(inDate,tempUnit) - getTimeUnitValue(newDate,tempUnit);
			tempInt = (tempInt > 0) ? 1 : 0;
			newDate = addTimeUnit(inDate,tempInt,inUnit);

			if (inUnit > MILLISECONDS)
			{
				newDate = dateFloor(newDate,inUnit);
			};
			return newDate;
		}
		
		/**
		*  Name:  	getTimeBetween
		*  @param 	inDate1	Date Date for comparison
		*  @param 	inDate2	Date Date for comparison
		*  @param 	inUnit	uint Unit of time for the comparison
		*  @return Number The absoluate value oftime between two dates
		*/
		public static function getTimeBetween(inDate1:Date,inDate2:Date,inUnit:uint):Number
		{
			var tempNum:Number;
			tempNum = -1;
			switch(inUnit)
			{
				case MILLISECONDS:
					tempNum = msBetween(inDate1,inDate2);
				break;
				case CENTISECONDS:
					tempNum = csBetween(inDate1,inDate2);
				break;
				case DECISECONDS:
					tempNum = dsBetween(inDate1,inDate2);
				break;
				case SECONDS:
					tempNum = secondsBetween(inDate1,inDate2);
				break;
				case MINUTES:
					tempNum = minutesBetween(inDate1,inDate2);
				break;
				case HOURS:
				tempNum = hoursBetween(inDate1,inDate2);
				break;
				case DAYS:uint:
				tempNum = daysBetween(inDate1,inDate2);
				break;
				case WEEKS:
				tempNum = weeksBetween(inDate1,inDate2);
				break;
				case MONTHS:
				tempNum = monthsBetween(inDate1,inDate2);
				break;
				case YEARS:
				tempNum = yearsBetween(inDate1,inDate2);
				break;
				case DECADES:
				tempNum = decadesBetween(inDate1,inDate2);
				break;
				case CENTURIES:
				tempNum = centuriesBetween(inDate1,inDate2);
				break;
				case MILLENNIA:
				tempNum = millenniaBetween(inDate1,inDate2);
				break;
				default:
					(DebugUtil.getInstance()).warningTrace("DateUtil: Time Unit not supported " + inUnit);	
				break;
			}
			return tempNum;
		}

		/*********************************************************************************************************
		**  PRIVATE																								**
		**********************************************************************************************************/
		
		/*
		*  Name:  	getDateRange
		*/
		private static function getDateRange(inDate1:Date,inDate2:Date,inUnit:uint):Array
		{
			var tempIn1:Number;
			var tempIn2:Number;
			var tempArr:Array;
			tempIn1 = inDate1.getTime();
			tempIn2 = inDate2.getTime();
			tempArr = new Array();
			tempArr[BEGINDATE] = dateFloor(new Date(Math.min(tempIn1,tempIn2)),inUnit);
			tempArr[ENDDATE] = dateCeil(new Date(Math.max(tempIn1,tempIn2)),inUnit);
			return tempArr;
		}
		
		/*
		*  Name:  	millenniaBetween
		*/
		private static function millenniaBetween(inDate1:Date,inDate2:Date):Number
		{	
			return (yearsBetween(inDate1,inDate2) / 1000);
		}
		
		/*
		*  Name:  	centuriesBetween
		*/
		private static function centuriesBetween(inDate1:Date,inDate2:Date):Number
		{	
			return (yearsBetween(inDate1,inDate2) / 100);
		}

		/*
		*  Name:  	decadesBetween
		*/
		private static function decadesBetween(inDate1:Date,inDate2:Date):Number
		{	
			return (yearsBetween(inDate1,inDate2) / 10);
		}

		/*
		*  Name:  	yearsBetween
		*/
		private static function yearsBetween(inDate1:Date,inDate2:Date):Number
		{
			return (monthsBetween(inDate1,inDate2) / 12);
		}
		
		/*
		*  Name:  	monthsBetween
		*/
		private static function monthsBetween(inDate1:Date,inDate2:Date):Number
		{
			return Math.abs((inDate2.getMonth() - inDate1.getMonth()) + ((inDate2.getFullYear() - inDate1.getFullYear()) * 12));
		}
		
		/*
		*  Name:  	weeksBetween
		*/
		private static function weeksBetween(inDate1:Date,inDate2:Date):Number
		{
			return (daysBetween(inDate1, inDate2) / 7);
		}

		/*
		*  Name:  	daysBetween
		*/
		private static function daysBetween(inDate1:Date,inDate2:Date):Number
		{
			return (msBetween(inDate1,inDate2)/(1000*60*60*24));
		}

		/*
		*  Name:  	hoursBetween
		*/
		private static function hoursBetween(inDate1:Date,inDate2:Date):Number
		{
			return (msBetween(inDate1,inDate2)/(1000*60*60));
		}
		
		/*
		*  Name:  	minutesBetween
		*/
		private static function minutesBetween(inDate1:Date,inDate2:Date):Number
		{
			return (msBetween(inDate1,inDate2)/(1000*60));
		}
		
		/*
		*  Name:  	secondsBetween
		*/
		private static function secondsBetween(inDate1:Date,inDate2:Date):Number
		{
			return (msBetween(inDate1,inDate2)/1000);
		}

		/*
		*  Name:  	dsBetween
		*  Purpose:	Get the difference between two dates in Deciseconds
		*/
		private static function dsBetween(inDate1:Date,inDate2:Date):Number
		{
			return (msBetween(inDate1,inDate2)/100);
		}

		/*
		*  Name:  	csBetween
		*  Purpose:	Get the difference between two dates in Centiseconds
		*/
		private static function csBetween(inDate1:Date,inDate2:Date):Number
		{
			return (msBetween(inDate1,inDate2)/10);
		}
		
		/*
		*  Name:  	msBetween
		*  Purpose:	Get the difference between two dates in Milliseconds
		*/
		private static function msBetween(inDate1:Date,inDate2:Date):Number
		{
			return Math.abs(inDate1.time - inDate2.time);
		}
		
		/*
		*  Name:  	addMillennia
		*  Purpose:	Change the date by the number of millenia provided
		*/
		private static function addMillennia(inDate:Date,inMillennia:int):Date
		{
			var newDate:Date;
			newDate = new Date(inDate.getTime());
			newDate.setFullYear(inDate.getFullYear() + (inMillennia * 1000));
			return newDate;
		}

		/*
		*  Name:  	addCenturies
		*  Purpose:	Change the date by the number of centuries provided
		*/
		private static function addCenturies(inDate:Date,inCenturies:int):Date
		{
			var newDate:Date;
			newDate = new Date(inDate.getTime());
			newDate.setFullYear(inDate.getFullYear() + (inCenturies * 100));
			return newDate;
		}

		/*
		*  Name:  	addDecades
		*  Purpose:	Change the date by the number of decades provided
		*/
		private static function addDecades(inDate:Date,inDecades:int):Date
		{
			var newDate:Date;
			newDate = new Date(inDate.getTime());
			newDate.setFullYear(inDate.getFullYear() + (inDecades * 10));
			return newDate;
		}
		
		/*
		*  Name:  	addYears
		*  Purpose:	Change the date by the number of years provided
		*/
		private static function addYears(inDate:Date,inYears:int):Date
		{
			var newDate:Date;
			newDate = new Date(inDate.getTime());
			newDate.setFullYear(inDate.getFullYear() + inYears);
			return newDate;
		}
			
		/*
		*  Name:  	addMonths
		*  Purpose:	Change the date by the number of months provided
		*/
		private static function addMonths(inDate:Date,inMonths:int):Date
		{
			var totalMonths:int;
			var newYear:int;
			var newMonth:int;
			var newDate:Date;
			newYear = inDate.getFullYear();
			newMonth = inDate.getMonth();
			
			totalMonths = newMonth + inMonths;
			newYear += (totalMonths / 12);
			newMonth = (totalMonths % 12);
		
			newDate = new Date(inDate.getTime());
			newDate.setFullYear(newYear);
			newDate.setMonth(newMonth);
			return newDate;
		}
		
		/*
		*  Name:  	addWeeks
		*  Purpose:	Change the date by the number of weeks provided
		*/
		private static function addWeeks(inDate:Date,inWeeks:int):Date
		{
			return new Date(inDate.getTime() + (inWeeks * 7 * MILLISECONDSPERDAY));
		}
		
		/*
		*  Name:  	addDays
		*  Purpose:	Change the date by the number of days provided
		*/
		private static function addDays(inDate:Date,inDays:int):Date
		{
			return new Date(inDate.getTime() + (inDays * MILLISECONDSPERDAY));
		}
		
		/*
		*  Name:  	addHours
		*  Purpose:	Change the date by the number of hours provided
		*/
		private static function addHours(inDate:Date,inHours:int):Date
		{
			return new Date(inDate.getTime() + (inHours * MILLISECONDSPERHOUR));
		}
		
		/*
		*  Name:  	addMinutes
		*  Purpose:	Change the date by the number of minutes provided
		*/
		private static function addMinutes(inDate:Date,inMinutes:int):Date
		{
			return new Date(inDate.getTime() + (inMinutes * MILLISECONDSPERMINUTE));
		}
			
		/*
		*  Name:  	addSeconds
		*  Purpose:	Change the date by the number of seconds provided
		*/
		private static function addSeconds(inDate:Date,inSeconds:int):Date
		{
			return new Date(inDate.getTime() + (inSeconds * 1000));
		}

		/*
		*  Name:  	addDeciSeconds
		*  Purpose:	Change the date by the number of centiseconds provided
		*/
		private static function addDeciSeconds(inDate:Date,inDeciSeconds:int):Date
		{
			return new Date(inDate.getTime() + (inDeciSeconds * 100));
		}
		
		/*
		*  Name:  	addCentiSeconds
		*  Purpose:	Change the date by the number of centiseconds provided
		*/
		private static function addCentiSeconds(inDate:Date,inCentiSeconds:int):Date
		{
			return new Date(inDate.getTime() + (inCentiSeconds * 10));
		}
		
		/*
		*  Name:  	addMilliSeconds
		*  Purpose:	Change the date by the number of milliseconds provided
		*/
		private static function addMilliSeconds(inDate:Date,inMilliSeconds:int):Date
		{
			return new Date(inDate.getTime() + inMilliSeconds);
		}	

		/*
		*  Name:  	scaleUp
		*  Purpose:	Used to scale up time units
		*/			
		private static function scaleUp(inVal,inUnit,inUnit2):Number
		{
			var tempVal:Number;

			tempVal = inVal;

			for (var i:uint=inUnit; i < inUnit2;i++)
			{
				tempVal = tempVal / CONVARR[i];
				tempVal = NumberUtil.roundDec(tempVal,MAXPRECISION);
			}
			return tempVal;
		}

		/*
		*  Name:  	scaleDown
		*  Purpose:	Used to scale down time units
		*/
		private static function scaleDown(inVal,inUnit,inUnit2):Number
		{
			var tempVal:Number;

			tempVal = inVal;

			for (var i:uint=(inUnit-1); i >= inUnit2;i--)
			{
				tempVal = tempVal * CONVARR[i];
				tempVal = NumberUtil.roundDec(tempVal,MAXPRECISION);
			}
			return tempVal;
		}
    }
}