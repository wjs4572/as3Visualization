package org.wsimpson.util
/**
* @name		FieldRankUtil.as
* Purpose	Defines field value calculations
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Itilities
	import org.wsimpson.util.ArrayUtil;
	import org.wsimpson.util.DateUtil;
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;
	import org.wsimpson.util.StringUtil;
	import org.wsimpson.util.StatsUtil;
	
	// Formats
	import org.wsimpson.format.DateFormat;	
	
	// Stores
	import org.wsimpson.store.OrderStore;

	public class FieldRankUtil
	{
		// PUBLIC Constants
		public static const STATE_INIT = "init";										// States supported for the field
		public static const STATE_EVAL = "eval";										// States supported for the field
		public static const TYPE_NUMBER = "number";										// Field supported datatypes
		public static const TYPE_DATETIME = "datetime";									// Field supported datatypes
		public static const TYPE_UINT = "uint";											// Field supported datatypes
		public static const TYPE_CURRENCY = "currency";									// Field supported datatypes
		public static const TYPE_ENUMERATED = "enumerated";								// Field supported datatypes
		public static const OPERATION_AVG_RANK = "averagerank";							// Field supported operation
		public static const OPERATION_FREQ = "frequency";								// Field supported operation
		public static const OPERATION_MAP = "map";										// Field supported operation
		public static const OPERATION_PERCENT = "percent";								// Field supported operation
		public static const OPERATION_ABSOLUTEHRS = 
										"absolutehours";								// Field supported operation
		public static const OPERATION_HOURS = 
										"hours";										// Field supported operation										
										
		public static const TYPE_ARR = 
			[TYPE_NUMBER, TYPE_DATETIME, TYPE_UINT, TYPE_CURRENCY,TYPE_ENUMERATED];
		public static const OPERATION_ARR =
			[OPERATION_AVG_RANK, OPERATION_FREQ, OPERATION_PERCENT, OPERATION_ABSOLUTEHRS, OPERATION_HOURS, OPERATION_MAP];
		public static const INVALID_VALUE = "invalid_Value";							// unsupported field type found
		public static const DECIMAL = 2;												// Field decimal formatting
		public static const RANGE_START = "start";										// Start value of the range
		public static const RANGE_END = "end";											// End value of the range
		public static const RANGE_STEP = "step";										// Direction of scale [Positve (1) or Negative (-1)]
		public static const RANGE_POINT = "point";										// Reference point of the range, for bidirectional operations
		public static const RANGE_INVALID = NaN;										// Reference point of the range, for bidirectional operations
		public static const XML_INVALID = -1;											// Reference point of the range, for bidirectional operations

		// Properties
		public var scale:Number;														// The number of values that will be handled by the meter
	
		// Private Constant XML Templates
		private static const TEMPLATE_RULE = 
			"<rule {ATTRIBUTES}>\n\t<range>\n\t\t{RULE}\n</range>{MAPPING}\n\t<stats>\n\t\t{STATS}</stats>\n\t<field_data>\n\t\t{DATA}\n</field_data>\n</rule>";
		private static const RULE = "{RULE}";											// Field to replace
		private static const MAPPING = "{MAPPING}";										// Field to replace
		private static const PAIRS= "{PAIRS}";											// Field to replace
		private static const TEMPLATE_MAPPING = "\n\t<MAPPING>{PAIRS}</MAPPING>";		// Field to replace
		private static const RULE_ATTRIBUTES = "{ATTRIBUTES}";							// Field to replace
		private static const TEMPLATE_ATTRIBUTES =
			"id={RULE_ID} label={LABEL} color={COLOR} calc={CALC} valid={VALID} dataType={DATATYPE}";
		private static const RULE_ID = "{RULE_ID}";										// Field to replace
		private static const FIELD_LABEL = "{LABEL}";									// Field to replace
		private static const FIELD_COLOR = "{COLOR}";									// Field to replace
		private static const FIELD_CALC = "{CALC}";										// Field to replace
		private static const FIELD_VALID = "{VALID}";									// Field to replace
		private static const FIELD_DATATYPE = "{DATATYPE}";								// Field to replace
		private static const STATS_FIELD = "{STATS}";									// Field to replace
		private static const FIELD_DATA = "{DATA}";										// Field to replace
		private static const TEMPLATE_DATA = 
			"\n\t<instance id={FIELD_ID}>\n\t{DATA_VALUES}\n</instance>";				// Field to replace
		private static const FIELD_ID = "{FIELD_ID}";									// Field to replace
		private static const FIELD_DATA_VALUES = "{DATA_VALUES}";						// Field to replace
			
		// Patterns
		private static const attributePattern:RegExp = new RegExp(RULE_ATTRIBUTES);		// Regular Expression pattern
		private static const rulePattern:RegExp = new RegExp(RULE);						// Regular Expression pattern
		private static const ruleIDPattern:RegExp = new RegExp(RULE_ID);				// Regular Expression pattern
		private static const labelPattern:RegExp = new RegExp(FIELD_LABEL);				// Regular Expression pattern
		private static const colorPattern:RegExp = new RegExp(FIELD_COLOR);				// Regular Expression pattern
		private static const calcPattern:RegExp = new RegExp(FIELD_CALC);				// Regular Expression pattern
		private static const validPattern:RegExp = new RegExp(FIELD_VALID);				// Regular Expression pattern
		private static const dataTypePattern:RegExp = new RegExp(FIELD_DATATYPE);		// Regular Expression pattern
		private static const statsPattern:RegExp = new RegExp(STATS_FIELD);				// Regular Expression pattern
		private static const dataValuesPattern:RegExp = new RegExp(FIELD_DATA_VALUES);	// Regular Expression pattern
		private static const fieldIDPattern:RegExp = new RegExp(FIELD_ID);				// Regular Expression pattern
		private static const fieldDataPattern:RegExp = new RegExp(FIELD_DATA);			// Regular Expression pattern
		private static const mappingPattern:RegExp = new RegExp(MAPPING);				// Regular Expression pattern
		private static const pairsPattern:RegExp = new RegExp(PAIRS);					// Regular Expression pattern
				
		// Instance Variables
		private	var _debugger:DebugUtil;												// Output and diagnostic window
		private var _ruleXML:XML;														// XML defining the field rule
		private var _mappingObj:Object;													// Associative array of Field Enumerated Values
		private var _reverseMappingObj:Object;											// Associative array of Field Enumerated Values
		private var _ruleObj:Object;													// Object containing the minimum and maximum
		private var _state:String;														// Calculations are state dependent
		private var _statsObj:Object;													// Object containing StatsUtil statistics
		private var _ranksObj:Object;													// Maps unique values to rankings
		private var _dateFormat:DateFormat;												// Formats the Date value to a Mask
		private var _xmlFormat:OrderStore;												// OrderStore doubles as a XML formatter of name value pairs


		/**
		*  Name:  	Constructor
		*  Purpose:	Creates the definition for how the field value is processed
		*
		*	@param inField XML Field definition
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function FieldRankUtil(inField:XML)
		{
			this._debugger = DebugUtil.getInstance();
			this._ruleXML = inField;
			this._ruleObj = new Object();
			this._ranksObj = new Object();
			this._xmlFormat = new OrderStore();
			this._dateFormat = new DateFormat();
			this._dateFormat.mask  = this.date_mask;
			
			this.init();
		}
		
		/************************************************************************************************************************************
		**  PARAMETERS
		************************************************************************************************************************************/
		
		/**
		*  name:  	dataType
		*  Purpose: Indicates the assigned data type
		*  @param inStr String Datatype assigned to this field
		*  @return String Definition assigned value.		
		*/
        public function get dataType():String {
			return (this.valid_range()) ? this._ruleXML.range.start.@type : INVALID_VALUE;
        }		
        public function set dataType(inStr:String):void {
			this._ruleXML.range.start.@type = inStr;
        }

		/**
		*  name:  	Operation
		*  Purpose: Indicates the assigned data type
		*  @param inStr String operation assigned to this field
		*  @return String Definition assigned value.		
		*/
        public function get operation():String {
			return (this.valid_range()) ? this._ruleXML.range.start.@calc : INVALID_VALUE;
        }		
        public function set operation(inStr:String):void {
			this._ruleXML.range.start.@calc = inStr;
        }
		
		/**
		*  name:  	label_color
		*  Purpose: Indicates field label_color
		*  @param inStr String label_color assigned via XML, is Constant
		*  @return String Definition assigned value.		
		*/
        public function get label_color():String {
			return this._ruleXML.@label_color;
        }		
        public function set label_color(inStr:String):void {
			// Do nothing
			// this.label_color = this._ruleXML.@label_color
        }

		/**
		*  name:  	date_mask
		*  Purpose: Indicates the expected format of the datetime value
		*  @param inStr String Date Mask
		*  @return String Date Mask.		
		*/
        public function get date_mask():String {
			return (this._ruleXML.@date_mask) ? this._ruleXML.@date_mask : "";
        }		
        public function set date_mask(inStr:String):void {
			// Do nothing
        }

		/**
		*  name: 	range_start
		*  Purpose: Indicates the start value of the field range
		*  @return Number Return the Number		
		*/
        public function get range_start():Number {
			return this._ruleObj[RANGE_START];
        }		
        public function set range_start(inObj:Number):void {
			// Do nothing
			// this._ruleObj[RANGE_START]= inObj
        }
		
		/**
		*  name: 	range_end
		*  Purpose: Indicates the end value of the field range
		*  @return Number Return the Number		
		*/
        public function get range_end():Number {
			return this._ruleObj[RANGE_END];
        }		
        public function set range_end(inObj:Number):void {
			// Do nothing
			// this._ruleObj[RANGE_START]= inObj
        }
		
		/**
		*  name: 	range_target
		*  Purpose: Indicates the end value of the field range
		*  @return Number Return the Number		
		*/
        public function get range_target():Number {
			return this._ruleObj[RANGE_POINT];
        }		
        public function set range_target(inObj:Number):void {
			// Do nothing
			// this._ruleObj[RANGE_POINT]= inObj
        }
		
		/**
		*  name:  	label
		*  Purpose: Indicates field label
		*  @param inStr String label assigned via XML, is Constant
		*  @return String Definition assigned value.
		*/
        public function get label():String {
			return this._ruleXML.@label;
        }		
        public function set label(inStr:String):void {
			// Do nothing
			// this.label = this._ruleXML.@label;
        }
		
		/**
		*  name:  	fieldID
		*  Purpose: Indicates field id
		*  @param inStr String Name assigned via XML, is Constant
		*  @return String Definition assigned value
		*/
        public function get fieldID():String {
			return this._ruleXML.@fieldID;
        }		
        public function set fieldID(inStr:String):void {
			// Do nothing
			// this.fieldID = this._ruleXML.@fieldID;
        }
		
		/**
		*  name:  	referencePoint
		*  Purpose: Some operations require a reference point
		*  @param inStr String Name assigned via XML, is Constant
		*  @return String Value assigned as reference point for calculations of the defined field.
		*/
        public function get referencePoint():String {
			return this._ruleObj[RANGE_POINT].toString();
        }		
        public function set referencePoint(inStr:String):void {
			this._ruleObj[RANGE_POINT] = this.newValue(inStr);
        }
		
		/**
		*  name:  	isEnumeratedBool
		*  Purpose: indicates whether the value is enumerated
		*  @param inBool Boolean Boolean value indicating whether an enumerated set has been mapped to this field
		*  @return Boolean Indicates that the type is enumerated
		*/
        public function get isEnumeratedBool():Boolean {
			return (this._mappingObj != null);
        }		
        public function set isEnumeratedBool(inBool:Boolean):void {
			// Do Nothing
        }

		/**
		*  name:  	isFormatted
		*  Purpose: Indicates the assigned data has or does not have a defined format expected
		*  @param inBool Boolean Boolean value indicating whether this is a formatted value
		*  @return Boolean Indicates that the type is formatted
		*/
        public function get isFormatted():Boolean {
			return ((this.date_mask != "") || this.isEnumeratedBool);
        }		
        public function set isFormatted(inBool:Boolean):void {
			// Do Nothing
        }
		
		 /**
		*  name: 	value_min
		*  Purpose: Indicates the minimum actual value received
		*  @return Number Return the minimum value received	
		*/
        public function get value_min():Number {
			return this._statsObj[StatsUtil.VALUE_MIN];
        }		
        public function set value_min(inNum:Number):void {
			// Do nothing
        }
		/**
		*  name: 	value_max
		*  Purpose: Indicates the maximum actual value received
		*  @return Number Return the maximum value received	
		*/
        public function get value_max():Number {
			return this._statsObj[StatsUtil.VALUE_MAX];
        }		
        public function set value_max(inNum:Number):void {
			// Do nothing
        }
		/**
		*  name: 	value_median
		*  Purpose: Indicates the median value 
		*  @return Number Return the median value 	
		*/
        public function get value_median():Number {
			return this._statsObj[StatsUtil.VALUE_MEDIAN];
        }		
        public function set value_median(inNum:Number):void {
			// Do nothing
        }
		/**
		*  name: 	value_mean
		*  Purpose: Indicates the mean value
		*  @return Number Return the mean value
		*/
        public function get value_mean():Number {
			return this._statsObj[StatsUtil.VALUE_MEAN];
        }		
        public function set value_mean(inNum:Number):void {
			// Do nothing
        }
		/**
		*  name: 	value_stdv
		*  Purpose: Indicates the standard deviation 
		*  @return Number Return the standard deviation
		*/
        public function get value_stdv():Number {
			return this._statsObj[StatsUtil.VALUE_STANDARD_DEVIATION];
        }		
        public function set value_stdv(inNum:Number):void {
			// Do nothing
        }

		/**
		*  name: 	value_range
		*  Purpose: Indicates the value range of the values received
		*  @return Number Return the value range of the values received	
		*/
        public function get value_range():Number {
			return this._statsObj[StatsUtil.VALUE_RANGE];
        }		
        public function set value_range(inNum:Number):void {
			// Do nothing
        }
		
		/**
		*  name: 	stats
		*  Purpose: Returns field statistics
		*  @return Object Returns object of statistical name value pairs
		*/
        public function get stats():Object {
			return this._statsObj;
        }		
        public function set stats(inObj:Object):void {
			// Do nothing
        }
		
		/**
		*  name:  	rank
		*  Purpose: Return the rank
		*  @param inStr String  The value to be ranked
		*  @return Number Ranking assigned
		*/	
        public function getRank(inStr:String):int {
			var tempStr:String;
			tempStr = (this.isEnumeratedBool) ? this._mappingObj[inStr.toLowerCase()] : inStr.toString();
			return (this._ranksObj[tempStr].rank as int);
        }

		/**
		*  name:  	percentile
		*  Purpose: Return the percentile
		*  @param inStr String  The value to be ranked
		*  @return Number Ranking assigned
		*/	
        public function getPercentile(inStr:String):Number {
			var tempStr:String;
			tempStr = (this.isEnumeratedBool) ? this._mappingObj[inStr.toLowerCase()] : inStr.toString();
			return (this._ranksObj[tempStr].percentile as Number);
        }
		
		/**
		*  name:  	getParsed
		*  Purpose: Return the rank
		*  @param inStr String  The value to be ranked
		*  @return Number Ranking assigned
		*/	
        public function getParsed(inStr:String):Number {
			var tempStr:String;
			tempStr = (this.isEnumeratedBool) ? this._mappingObj[inStr.toLowerCase()] : inStr.toString();
			return this._ranksObj[tempStr].orig;
        }
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*  name:  	getDateValue
		*  Purpose: Range validation
		*  @param String value
		*  @return String value
		*/
		public function getDateValue(inVal:String):String
		{
			return this._dateFormat.format(new Date(inVal));
		}

		/**
		*  name:  	getEnumVal
		*  Purpose: Range validation
		*  @param String value
		*  @return String value
		*/
		public function getEnumVal(inVal:String):String
		{
			return (this._reverseMappingObj) ? this._reverseMappingObj[inVal] : "";
		}
		
		/**
		*  name:  	formatValue
		*  Purpose: Return the formatted value
		*  @param String value		
		*  @return String The value fomatted by data type
		*/
		public function formatValue(inVal:String):String
		{
			return this.formatByType(inVal);
		}

		/**
		*  name:  	valid_type
		*  Purpose: Range validation
		*  @return Boolean Indicates the range defined for this field is consistent
		*/
		public function valid_type():Boolean
		{
			return ((TYPE_ARR.indexOf(this._ruleXML.range.start.@type.toLowerCase())!= XML_INVALID) &&
					(TYPE_ARR.indexOf(this._ruleXML.range.end.@type.toLowerCase())!= XML_INVALID))
		}

		/**
		*  name:  	valid_calc
		*  Purpose: Range validation
		*  @return Boolean Indicates the range defined for this field is consistent
		*/
		public function valid_calc():Boolean
		{
			return ((OPERATION_ARR.indexOf(this._ruleXML.range.start.@calc.toLowerCase())!= XML_INVALID) &&
					(OPERATION_ARR.indexOf(this._ruleXML.range.end.@calc.toLowerCase())!= XML_INVALID))
		}

		/**
		*  name:  	valid_range
		*  Purpose: Range validation
		*  @return Boolean Indicates the range defined for this field is consistent
		*/
		public function valid_range():Boolean
		{
			return ((this._ruleXML.range.start.@type == this._ruleXML.range.end.@type) &&
					(this._ruleXML.range.start.@calc == this._ruleXML.range.end.@calc));
		}

		/**
		*  name:  	assign Data
		*  Purpose: Receives the full list for determining the stats.
		*  @param inList XMLList Data for this field
		*/
		public function assignData(inList:XMLList):void
		{
			var tempArr:Array;
			var tempStr:String;
			tempArr = new Array();
			for each (var tempVal:XML in inList)
			{
				tempStr = (this.isEnumeratedBool) ? this._mappingObj[tempVal.toString().toLowerCase()] : tempVal.toString();
				// Apply ranks to the values
				this.initRankObj(tempStr);
				if (this._ranksObj[tempStr].inRangeBool)
				{
					var tempObj:Object;
					tempObj = (this.dataType.toLowerCase() == TYPE_DATETIME) ? this._ranksObj[tempStr].orig : this._ranksObj[tempStr].value;
					tempArr.push(tempObj);
				} else
				{
					this._ranksObj[tempStr].rank = RANGE_INVALID;
				}
			}
			
			this._statsObj = StatsUtil.getStats(tempArr);
			this.rankInstances();
		}

		/**
		*  name:  	toXMLString
		*  Purpose: Converts the Field Rule values to an XML String
		*  @return String The field rule values as XML.
		*/
		public function toXMLString():String
		{
			var tempObj:Object;	
			var tempStr:String;
			tempStr = TEMPLATE_RULE;
			tempObj = this._xmlFormat.convertNameValue(this._ruleObj);
			
			tempStr = tempStr.replace(FieldRankUtil.rulePattern,this._xmlFormat.toXMLString(tempObj));
			tempStr = tempStr.replace(FieldRankUtil.mappingPattern,mappingToXMLString());		
			tempStr = tempStr.replace(FieldRankUtil.attributePattern,this.attrToXMLString());		
			tempStr = tempStr.replace(FieldRankUtil.statsPattern,this.statsToXMLString());
			tempStr = tempStr.replace(FieldRankUtil.fieldDataPattern,this.ranksToXMLString());
			return tempStr;
		}

		/**
		*  name:  	mappingToXMLString
		*  Purpose: Convert the mapping values received to XML
		*  @return String The statistics values as XML.
		*/
		public function mappingToXMLString():String
		{
			var tempMapObj:Object;	
			var tempMappingStr:String;
			tempMappingStr = "";

			if (this.isEnumeratedBool)
			{
				tempMapObj = this._xmlFormat.convertNameValue(this._mappingObj);	
				tempMappingStr = TEMPLATE_MAPPING;
				tempMappingStr = tempMappingStr.replace(FieldRankUtil.pairsPattern,this._xmlFormat.toXMLString(tempMapObj));
			}
			return tempMappingStr;
		}
		
		/**
		*  name:  	attrToXMLString
		*  Purpose: Convert the stats values received to XML
		*  @return String The statistics values as XML.
		*/
		public function attrToXMLString():String
		{
			var tempStr:String;
			tempStr = TEMPLATE_ATTRIBUTES;
			tempStr = tempStr.replace(FieldRankUtil.ruleIDPattern,StringUtil.doubeQuoteStr(this.fieldID));
			tempStr = tempStr.replace(FieldRankUtil.labelPattern,StringUtil.doubeQuoteStr(this.label));
			tempStr = tempStr.replace(FieldRankUtil.colorPattern,StringUtil.doubeQuoteStr(this.label_color));
			tempStr = tempStr.replace(FieldRankUtil.calcPattern,StringUtil.doubeQuoteStr(this.operation));
			tempStr = tempStr.replace(FieldRankUtil.validPattern,StringUtil.doubeQuoteStr(this.valid_range().toString()));
			tempStr = tempStr.replace(FieldRankUtil.dataTypePattern,StringUtil.doubeQuoteStr(this.dataType));
			return tempStr;
		}

		/**
		*  name:  	statsToXMLString
		*  Purpose: Convert the stats values received to XML
		*  @return String The statistics values as XML.
		*/
		public function statsToXMLString():String
		{
			return this._xmlFormat.toXMLString(this._statsObj);
		}

		/**
		*  name:  	ranksToXMLString
		*  Purpose: Convert the ranks values received to XML
		*  @return String The details of data values as XML.
		*/
		public function ranksToXMLString():String
		{
			var tempStr:String;
			tempStr = "";
			for (var nameStr:String in this._ranksObj)
			{
				var dataStr:String;
				dataStr = TEMPLATE_DATA;
				dataStr = dataStr.replace(FieldRankUtil.fieldIDPattern,StringUtil.doubeQuoteStr(nameStr));
				if (this._ranksObj[nameStr])
				{
					var tempObj:Object;
					tempObj = this._xmlFormat.convertNameValue(this._ranksObj[nameStr]);
					dataStr = dataStr.replace(FieldRankUtil.dataValuesPattern,this._xmlFormat.toXMLString(tempObj));
				}
				tempStr +=  dataStr;
			}
			return tempStr;
		}
		
		
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/

		private function formatByType(inVal:String):String
		{
			var tempStr:String;
			switch(this.dataType.toLowerCase())
			{
				case TYPE_DATETIME:
					tempStr = this.getDateValue(inVal);
				break;
				case TYPE_UINT:
				case TYPE_NUMBER:
					tempStr = inVal;
				break;
				case TYPE_ENUMERATED:
					tempStr = this.getEnumVal(inVal);
					// If the value is already formatted or unrecognized perserve the recieved value.
					tempStr = (tempStr) ? tempStr : inVal;
				break;
				case TYPE_CURRENCY:
					tempStr = inVal;					
				break;
				default:
					tempStr = "\tField not fomattable -> field id:  " + this.fieldID +
					"\n\n\tSupported data types include: <br/> &quot;Number&quot;, &quot;DateTime&quot;, &quot;uint&quot;, &quot;map&quot;, or &quot;Currency&quot;";
					this._debugger.warningTrace(tempStr);	
					this.sendError(tempStr);		
				break;
			}
			return tempStr;
		}
		private function sendError(errorMsg:String):Boolean
		{
			throw new Error(errorMsg);	
		}		

		/**
		* @see "Ranking Calculation.xls" and ColorScale
		*/
		private function initRankObj(inStr:String):Boolean
		{
			if (!this._ranksObj[inStr])
			{
				this._ranksObj[inStr] = new Object();
				this._ranksObj[inStr].freq = 0;
				this._ranksObj[inStr].orig = this.newValue(inStr);			
				this._ranksObj[inStr].value = this.applyOperation(this._ranksObj[inStr].orig);
				this._ranksObj[inStr].inRangeBool = !(isNaN(this._ranksObj[inStr].value as Number));
			}
			this._ranksObj[inStr].freq++;
			return this._ranksObj[inStr].inRangeBool;
		}
		
		private function rankInstances():void
		{
			for (var nameStr in this._ranksObj)
			{
				var tempRank:Number;
				var tempNum:Number;
				var tempRange:Number;
				var tempMin:Number;
				tempMin = (this._ruleObj[RANGE_END] >= this._ruleObj[RANGE_START]) ? this._ruleObj[RANGE_START] : this._ruleObj[RANGE_END];
				tempNum = this._ranksObj[nameStr].value;
				tempRange = Math.abs(this._ruleObj[RANGE_END] -  this._ruleObj[RANGE_START]);
				this._ranksObj[nameStr].percentile = ((tempNum - tempMin) / tempRange);
				this._ranksObj[nameStr].percentile = (this._ruleObj[RANGE_STEP] > 0) ? this._ranksObj[nameStr].percentile : (1 - this._ranksObj[nameStr].percentile);
				this._ranksObj[nameStr].percentile = NumberUtil.roundDec(this._ranksObj[nameStr].percentile);
				tempRank = 0;
				if (this.isEnumeratedBool)
				{
					this._ranksObj[nameStr].rank = this._ranksObj[nameStr].value;
				}
				else if (this._ranksObj[nameStr].inRangeBool)
				{

					this._ranksObj[nameStr].rank = Math.ceil(this.scale - ((this.scale/5) * Math.log((101-(this._ranksObj[nameStr].percentile*100)))));
				}
			}
		}

		private function applyOperation(inObj:Object):Number
		{
			var tempNum:Number;
			var tempStr:String;
			var operationStr:String;
			operationStr = this.operation.toLowerCase();
			try
			{
				switch(operationStr)
				{
					case OPERATION_AVG_RANK:
					case OPERATION_MAP:
					case OPERATION_FREQ:
					case OPERATION_PERCENT:
						// requires calculation upon completion of the field rankings
						tempNum = inObj as Number; 
					break;
					case OPERATION_ABSOLUTEHRS:					
					case OPERATION_HOURS:
						var startDate:Date;
						var endDate:Date;
						var sign:int;
						startDate = new Date(inObj);
						endDate = new Date(this._ruleObj[RANGE_POINT]);
						sign = (startDate > endDate) ? 1 : -1;
						tempNum = NumberUtil.roundDec(DateUtil.getTimeBetween(startDate, endDate, DateUtil.HOURS));
						tempNum = (operationStr == OPERATION_ABSOLUTEHRS) ?	tempNum : (tempNum * sign);
					break;
					default:
						tempStr = "Invalid field definition for field id:  " + this.fieldID + " = " + this.operation +
						"\n\n\tSupported data types include: <br/> &quot;Number&quot;, &quot;DateTime&quot;, &quot;uint&quot;, or &quot;Currency&quot;";
						this._debugger.wTrace(tempStr);						
						this.sendError(tempStr);
					break;
				}
				tempNum = (NumberUtil.rangeCheck(tempNum,this._ruleObj[RANGE_START],this._ruleObj[RANGE_END])) ?
							tempNum : RANGE_INVALID;
				if (isNaN(tempNum as Number))
				{
					this._debugger.warningTrace("\tThe value is not valid for " + this.fieldID);
				}
			} catch (e:Error)
			{
				tempStr = "The value " + inObj.toString() + " is not a valid for " + this.operation + "\n " + e.message;
				this._debugger.warningTrace(tempStr);
				this._debugger.warningTrace(e.getStackTrace());
				tempNum = RANGE_INVALID;
			}
			return tempNum;
		}
		
		private function newValue(inString:String):Object
		{
			var tempObj:Object;
			var tempStr:String;			
			if (inString != "")
			{
				try
				{
					switch(this.dataType.toLowerCase())
					{
						case TYPE_DATETIME:
							if (this._state == STATE_INIT)
							{
								if (StringUtil.isInteger(inString))
								{
									tempObj = uint(inString);
								} else if (StringUtil.isNumber(inString))
								{
									tempObj = int(inString);
								} else
								{
									tempObj = RANGE_INVALID;				
								}							
							} else
							{
								tempObj = new Date(inString).getTime();
							}
						break;
						case TYPE_UINT:
							tempObj = (StringUtil.isInteger(inString)) ?  uint(inString) : RANGE_INVALID;
						break;
						case TYPE_NUMBER:
						case TYPE_ENUMERATED:
							tempObj = NumberUtil.parseNumber(inString)
							tempObj = (isNaN(tempObj as Number)) ? RANGE_INVALID : tempObj;
						break;
						case TYPE_CURRENCY:
							tempObj = NumberUtil.parseCurrency(inString)
							tempObj = (isNaN(tempObj as Number)) ? RANGE_INVALID : tempObj;					
						break;
						default:
							tempStr = "\tfield id:  " + this.fieldID +
							"\n\n\tSupported data types include: <br/> &quot;Number&quot;, &quot;DateTime&quot;, &quot;uint&quot;, &quot;map&quot;, or &quot;Currency&quot;";
							this._debugger.warningTrace(tempStr);	
							this.sendError(tempStr);					
						break;

					}	
					if (isNaN(tempObj as Number))
					{
						tempStr = "The value " + StringUtil.doubeQuoteStr(inString) + " is not a valid " + this.dataType + "\n ";
						tempStr += "\tInvalid field definition for field id:  " + this.fieldID;
						this.sendError(tempStr);					
					}
				} catch (e:Error)
				{
					tempStr = "#Error:  Invalid Field Definition\n" + e.message +  "\n";
					this.sendError(tempStr);
					this._debugger.errorTrace(e.getStackTrace());
				}
			}
			return tempObj;
		}
		
		// list field mapping pairs
		private function getFieldMappings():XMLList
		{
			return this._ruleXML..pair;
		}

		private function newMapping(inMappingXML:XMLList):void
		{
			var tempObj:Object;
			var tempObj2:Object;
			tempObj = new Object();
			tempObj2 = new Object();
			for each (var valueMapping:XML in inMappingXML)
			{
				tempObj[valueMapping.@name.toLowerCase()] = valueMapping.@value;
				tempObj2[valueMapping.@value] = valueMapping.@name.toLowerCase();
			}
			this._mappingObj = tempObj;
			this._reverseMappingObj = tempObj2;
		}
		
		private function assignRange()
		{
			var tempStr:String;
			if (!valid_type())
			{
				tempStr = "\tInvalid field definition for field id:  " + this.fieldID + "\n\ttype = " + StringUtil.doubeQuoteStr(this.dataType);
				tempStr += "\n\tAccepted values are: " + TYPE_ARR;
				this.sendError(tempStr);	
			} else if (!valid_calc())
			{
				tempStr = "\tInvalid field definition for field id:  " + this.fieldID + "\n\tcalc = " + StringUtil.doubeQuoteStr(this.operation);
				tempStr += "\n\tAccepted values are: " + OPERATION_ARR;
				this.sendError(tempStr);	
			} else {
				this._ruleObj[RANGE_START] = this.newValue(this._ruleXML.range.start.@value); 
				this._ruleObj[RANGE_END] = this.newValue(this._ruleXML.range.end.@value);	
				this._ruleObj[RANGE_STEP] = (this._ruleObj[RANGE_START] > this._ruleObj[RANGE_END]) ? -1 : 1;
				
				if (this.dataType.toLowerCase() == TYPE_ENUMERATED)
				{
					this.newMapping(this.getFieldMappings());
				}
			}
		}
		
		private function init()
		{
			this._state = STATE_INIT;
			if (this.valid_range())
			{
				this.assignRange();
			} else
			{

				var tempStr:String;
				tempStr = "Invalid range definition for field id:  " + this.fieldID + ".\n\tThe type or calc attributes are inconsistent";
				this.sendError(tempStr);
			}
			this._state = STATE_EVAL;
		}
	}
}