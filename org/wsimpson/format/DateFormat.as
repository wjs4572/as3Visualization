package org.wsimpson.format

/*
** Title:	DateFormat.as
** Purpose: Provides date formats.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
/**
* Intended support
* Based on mx.formatters.DateFormatter 
* @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/formatters/DateFormatter.html
* @example
	YYYY	- 2005		= four digit year
    YY		- 05		= two digit year - with leading zeros
	MMMM	- January	= full Name
	MMM		- Jan		= Three letter abreviation
	MM		- 01		= two digit month with leading zeros (Note: these will be calendar values)
	M		- 1			= single digit month
	DD		- 01		= two digit calendar day of the month with leading zeros
	D		- 1			= single digit calendar day of the month
	EEEE	- Monday	= full Name - day of week
	EEE     - Mon		= Three letter abbreviation - day of week
	EE 		- 01		= two digit day of week
	E		- 1			= single digit day of week
	e		- M			= single letter for day of week
	A		- am | pm	= indicates ante meridiem and post meridiem (am/pm)
	hh		- 01		= two digit hour with leading zeros (00-23) (Note:  This diviates from the DateFormatter API)
	h		- 1			= hour without leading zeros (0-23)
	kk		- 01		= two digit hour in am/pm with leading zeros (00-11) Note: 0 is replaced with 12
	k		- 1			= hour in am/pm without leading zeros (0-11) Note: 0 is replaced with 12
	mm		- 01		= two digit minute with leading zeros (00-59)
	m		- 1			= minute without leading zeros (0-59)
	ss		- 01		= two digit second with leading zeros (00-59)
	s		- 1			= second without leading zeros (0-59)
	qqq		- 005		= three digit millisecond with leading zeros (000-999)
	q		- 5			= milliseond without leading zeros (0-999)
*/	
	
{
		
	// ActionScript 3.0 CookBook
	import ascb.util.Locale;	
		
	// Formats
	import org.wsimpson.format.NumberFormat;	

	// Utilities
	import org.wsimpson.util.ArrayUtil;	
	import org.wsimpson.util.DateUtil;	
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;
	
	public class DateFormat
	{	
		// Public Constants - Localization Object
		public static const MONTH_NAME_LONG = "month_name_long";								// Associative array index
		public static const MONTH_NAME_SHORT = "month_name_short";								// Associative array index
		public static const WEEKDAY_NAME_LONG = "weekday_name_long";							// Associative array index
		public static const WEEKDAY_NAME_SHORT = "weekday_name_short";							// Associative array index
		public static const MERIDIEM_NAME = "meridiem_name";									// Associative array index
		public static const LOCALE_MASK = "locale_mask";										// Associative array index

		// Public Constances
		public static const YEAR_FOUR = "YYYY";													// four digit year
		public static const YEAR_TWO = "YY";													// two digit year - with leading zeros
		public static const MONTH_LONG = "MMMM";												// full Name
		public static const MONTH_SHORT = "MMM";												// Three letter abreviation
		public static const MONTH_NUM_ZERO = "MM";												// two digit month with leading zeros (Note: these will be calendar values)
		public static const MONTH_NUM = "M";													// single digit month
		public static const CALDAY_ZERO = "DD";													// two digit calendar day of the month with leading zeros
		public static const CALDAY = "D";														// single digit calendar day of the month
		public static const WEEKDAY_LONG = "EEEE";												// full Name day of week
		public static const WEEKDAY_SHORT = "EEE";												// Three letter abbreviation - day of week
		public static const WEEKDAY_TWO_ZERO = "EE";											// two digit day of week
		public static const WEEKDAY = "E";														// single digit day of week
		public static const WEEKDAY_2 = "e";													// single letter day of week
		public static const MERIDIEM = "A";														// indicates ante meridiem and post meridiem (am/pm)
		public static const HOUR_TWO_ZERO = "hh";												// two digit hour with leading zeros (00-23) (Note:  This diviates from the DateFormatter API)
		public static const HOUR = "h";															// hour without leading zeros (0-23)
		public static const MERIDIEM_HOUR_TWO_ZERO = "kk";										// two digit hour in am/pm with leading zeros (00-11)
		public static const MERIDIEM_HOUR = "k";												// hour in am/pm without leading zeros (0-11)
		public static const MINUTE_TWO_ZERO = "mm";												// two digit minute with leading zeros (00-59)
		public static const MINUTE = "m";														// minute without leading zeros (0-59)
		public static const SECOND_TWO_ZERO = "ss";												// two digit second with leading zeros (00-59)
		public static const SECOND = "s";														// second without leading zeros (0-59)
		public static const MILLISECOND_THREE_ZERO = "qqq";										// three digit millisecond with leading zeros (000-999)
		public static const MILLISECOND = "q";													// milliseond without leading zeros (0-999)
		public static const MASKS = [YEAR_FOUR,YEAR_TWO,MONTH_LONG,MONTH_SHORT,MONTH_NUM_ZERO,MONTH_NUM,CALDAY_ZERO,CALDAY,WEEKDAY_LONG,WEEKDAY_SHORT,WEEKDAY_TWO_ZERO,WEEKDAY,WEEKDAY_2,MERIDIEM,HOUR_TWO_ZERO,HOUR,MERIDIEM_HOUR_TWO_ZERO,MERIDIEM_HOUR,MINUTE_TWO_ZERO,MINUTE,SECOND_TWO_ZERO,SECOND,MILLISECOND_THREE_ZERO,MILLISECOND];	

		// Localization Data
		private static const DEFAULT_LOCALE = "enUS";													// Associative array index
		private static const ENUS_MONTH_LONG = 
			['January','February','March','April','May','June','July','August','September','October','November','December'];
		private static const ENUS_MONTH_SHORT = 
			['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
		private static const ENUS_WEEKDAY_LONG = 
			['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
		private static const ENUS_WEEKDAY_SHORT = 
			['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
		private static const ENUS_WEEKDAY_SINGLE = 
			['S','M','T','W','T','F','S'];
		private static const ENUS_MERIDIEM = { am : 'am', pm : 'pm'};
		private static const ENUS_MASK = "MM/DD/YYYY hh:mm:ss:qqq";
	
		// Private Instance Variables
        private var _debugger:DebugUtil;	// Debugging utility
		private var _mask:String;			// Contains the format that will be substited with date values
		private var _dataTree:Object;		// Localization strings
		private var _langRegion:String		// The localization
		private var _locale:Locale;			// An object for determing localizatoin
		private var _maskObj:Object;		// The parsed _maske 
		private var _maskArr:Array;			// The elements used within the mask
		private var _dashPattern:RegExp;	// Regular expression for dealing with the hyphen
		
		// Constructor
		public function DateFormat(inMask:String="")
		{
			this._debugger = DebugUtil.getInstance();
			this._dataTree = new Object();
			this._dataTree[DEFAULT_LOCALE] = new Object();
			this._dataTree[DEFAULT_LOCALE][MONTH_NAME_LONG] = ENUS_MONTH_LONG;
			this._dataTree[DEFAULT_LOCALE][MONTH_NAME_SHORT] = ENUS_MONTH_SHORT;
			this._dataTree[DEFAULT_LOCALE][WEEKDAY_NAME_LONG] = ENUS_WEEKDAY_LONG;
			this._dataTree[DEFAULT_LOCALE][WEEKDAY_NAME_SHORT] = ENUS_WEEKDAY_SHORT;
			this._dataTree[DEFAULT_LOCALE][WEEKDAY_2] = ENUS_WEEKDAY_SINGLE;
			this._dataTree[DEFAULT_LOCALE][MERIDIEM_NAME] = ENUS_MERIDIEM;
			this._dataTree[DEFAULT_LOCALE][LOCALE_MASK] = ENUS_MASK;
			this._locale = new Locale();
			this._langRegion = this._locale.languageVariant;
			this._dashPattern = new RegExp("-","g");
			this._langRegion = this._langRegion.replace(this._dashPattern,"");
			this.mask = (inMask != "") ? inMask : this._dataTree[DEFAULT_LOCALE][LOCALE_MASK];
		}

		/*********************************************************************************************************
		**  Parameters																							**
		**********************************************************************************************************/
				
		/**
		*  Get and set the mask for the formatting. The mask can consist of 0's, #'s,
		*  commas, and dots.
		*/
		public function get mask():String {
			var tempStr:String;
			var re:RegExp;
			tempStr = this._mask;
			for (var i:int=0; i < this._maskArr.length; i++)
			{
				re = new RegExp(this._maskArr[i].sub,"g");
				tempStr = tempStr.replace(re,this._maskArr[i].element);
			}
			return tempStr;
		}

		public function set mask(inMask:String):void {
			this._mask = this.elementArr(inMask);
		}
		
		/**
		*  Get and set the mask for the formatting. The mask can consist of 0's, #'s,
		*  commas, and dots.
		* @throws Error
		*/
		public function get locale():String {
			return this._langRegion;
		}

		public function set locale(inLangRegion:String):void {
			inLangRegion = inLangRegion.replace(this._dashPattern,"");
			if (this._dataTree.hasOwnProperty(inLangRegion))
			{
				this._langRegion = inLangRegion;
			} else
			{
				this.sendError("DateFormate: Unsupported langauge variant recieved " + inLangRegion);
			}

		}


		/*********************************************************************************************************
		**  DIAGNOSTICS																							**
		**********************************************************************************************************/		

		/**
		*  Name:  	fullDiagnostic
		*  Purpose:	Test master pattern
		*/
		public function fullDiagnostic(inDate:Date):void
		{
			var tempStr:String;
			var tempMask:String;
			tempMask = this.mask;
			this.mask = buildMasterPattern();
			this._debugger.wTrace(format(inDate));
			this.mask = tempMask;
		}
		
		/*********************************************************************************************************
		**  PUBLIC																								**
		**********************************************************************************************************/

		
		/**
		*  Name:  	addLanguage
		*  Purpose:	Create a string matching the mask
		*  @param 	inLocale	String	The locale with two letter langage and two letter Locale concatenated
		*  @example	enUS
		*  @param 	inObj	Object	Must have Months Long, Months Short, Weekday Long, Weekday Short arrays, Meridiem
		*/
		public function addLanguage(inLocale:String,inObj:Object):void
		{
			var tempLocale:String; 
			tempLocale = tempLocale.replace(this._dashPattern,"");
			this._langRegion[tempLocale] = inObj;
		}

		/**
		*  Name:  	foramt
		*  Purpose:	Format the date using the assigned mask
		*  @param 	inDate	Date	The date to be formatted
		*  @return 	String	Formatted date string
		*/
		public function format(inDate:Date):String
		{
			var tempStr:String;
			
			// Assign Mask
			tempStr = this._mask;

			for (var i:int=0; i < this._maskArr.length; i++)
			{
				tempStr = mapDateValue(tempStr,inDate,this._maskArr[i].element,this._maskArr[i].sub);
			}

			return tempStr;
		}
		
		/**
		* Name: formatRange
		* Purpose:	Used to scale up time units
		* @param inVal Number DateValue
		* @param inUnit int The starting unit value, assumed lowest (i.e. milliseconds)
		* @return String Formatted value represetning the string
		*/			
		public function formatRange(inVal:Number,inUnit:int=-1):String
		{
			var tempUnit:uint;
			var tempUnit2:uint;
			var tempStr;
			tempUnit = DateUtil.getMaxUnit(inVal,inUnit);
			tempUnit2 = (inUnit >= 0) ? inUnit : DateUtil.MILLISECONDS;
			tempStr = DateUtil.covertUnits(inVal,tempUnit2,tempUnit) + " " + DateUtil.UNITARR[tempUnit];
			return tempStr;
		}
		
		/*********************************************************************************************************
		**  PROTECTED																								**
		**********************************************************************************************************/
		protected function sendError(errorMsg:String):void
		{
			throw new Error(errorMsg);	
		}
		
		/*********************************************************************************************************
		**  PRIVATE																								**
		**********************************************************************************************************/
		private function mapDateValue(inStr:String,inDate:Date,inElement:String,inMask:String):String
		{
			var re:RegExp;
			var tempStr:String;
			var nameObj:Object;
			var isAMPM:String;
			var tempHour:int;
			var tempMeridiemHr:int;
			var tempTime:int;
		
			var tempNF:NumberFormat;
			
			// Define Values
			nameObj = this._dataTree[this._langRegion];
			tempHour = inDate.getHours();
			tempMeridiemHr = (tempHour % 12);
			tempMeridiemHr = (tempMeridiemHr == 0) ? 12 : tempMeridiemHr;
			tempTime = Math.floor(tempHour / 12) * 12;
			isAMPM = (tempTime == 12)? 'pm' : 'am';
			tempNF = new NumberFormat('00');	
			tempStr = inStr;
			re = new RegExp(inMask,"g");
			
			switch(inElement)
				{
					case YEAR_FOUR:
						tempStr = tempStr.replace(re,inDate.getFullYear());
					break;
					case YEAR_TWO:
						tempStr = tempStr.replace(re,inDate.getFullYear() % 100);			
					break;
					case MONTH_LONG:
						tempStr = tempStr.replace(re,nameObj[MONTH_NAME_LONG][inDate.getMonth()]);
					break;
					case MONTH_SHORT:
						tempStr = tempStr.replace(re,nameObj[MONTH_NAME_SHORT][inDate.getMonth()]);
					break;
					case MONTH_NUM_ZERO:
						tempStr = tempStr.replace(re,tempNF.formatUINT(inDate.getMonth() + 1));
					break;
					case MONTH_NUM:
						tempStr = tempStr.replace(re,(inDate.getMonth() + 1));
					break;
					case CALDAY_ZERO:
						tempStr = tempStr.replace(re,tempNF.formatUINT(inDate.getDate()));
					break;
					case CALDAY:
						tempStr = tempStr.replace(re,inDate.getDate());
					break;
					case WEEKDAY_LONG:
						tempStr = tempStr.replace(re,nameObj[WEEKDAY_NAME_LONG][inDate.getDay()]);
					break;
					case WEEKDAY_SHORT:
						tempStr = tempStr.replace(re,nameObj[WEEKDAY_NAME_SHORT][inDate.getDay()]);
					break;
					case WEEKDAY_TWO_ZERO:
						tempStr = tempStr.replace(re,tempNF.formatUINT(inDate.getDay()));
					break;
					case WEEKDAY:
						tempStr = tempStr.replace(re,inDate.getDay());
					break;
					case WEEKDAY_2:
						tempStr = tempStr.replace(re,nameObj[WEEKDAY_2][inDate.getDay()]);
					break;
					case MERIDIEM:
						tempStr = tempStr.replace(re,nameObj[MERIDIEM_NAME][isAMPM]);
					break;
					case HOUR_TWO_ZERO:
						tempStr = tempStr.replace(re,tempNF.formatUINT(tempHour));
					break;
					case HOUR:
						tempStr = tempStr.replace(re,tempHour);
					break;
					case MERIDIEM_HOUR_TWO_ZERO: 
						tempStr = tempStr.replace(re,tempNF.formatUINT((tempMeridiemHr)));
					break;
					case MERIDIEM_HOUR:
						tempStr = tempStr.replace(re,(tempMeridiemHr));
					break;
					case MINUTE_TWO_ZERO:
						tempStr = tempStr.replace(re,tempNF.formatUINT(inDate.getMinutes()));
					break;
					case MINUTE:
						tempStr = tempStr.replace(re,inDate.getMinutes());
					break;
					case SECOND_TWO_ZERO:
						tempStr = tempStr.replace(re,tempNF.formatUINT(inDate.getSeconds()));
					break;
					case SECOND:
						tempStr = tempStr.replace(re,inDate.getSeconds());
					break;
					case MILLISECOND_THREE_ZERO:
						tempNF.mask = '000';
						tempStr = tempStr.replace(re,tempNF.formatUINT(inDate.getMilliseconds()));
					break;
					case MILLISECOND:
						tempStr = tempStr.replace(re,inDate.getMilliseconds());
					break;
					default:
						this._debugger.warningTrace("DateFormat:  Unrecognized element in the mask " + this._maskArr.element);
					break;
				}
			return tempStr;
		}
		private function elementArr(inMask:String):String
		{
			var tempStr:String;
			tempStr = inMask;
			this._maskArr = new Array();
			for (var i:int = 0; i < MASKS.length; i++)
			{
				var tempObj:Object;
				tempObj = new Object();
				tempObj.element = MASKS[i];
				tempObj.re = new RegExp(tempObj.element);
				tempObj.sub = "_" + i + "_";
				if (tempObj.re.test(tempStr))
				{
					tempStr = tempStr.replace(tempObj.re,tempObj.sub);
					this._maskArr.push(tempObj);
				}
			}
			return tempStr;
		}
		
		private function buildMasterPattern():String
		{
			var tempStr:String;
			tempStr = "";
			for (var i:int = 0; i < MASKS.length; i++)
			{
				tempStr += MASKS[i];
				tempStr += ((i+1) == MASKS.length) ? "" : " | ";
			}
			return tempStr;
		}

    }
}