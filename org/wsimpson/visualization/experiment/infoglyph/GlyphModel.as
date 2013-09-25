package org.wsimpson.visualization.experiment.infoglyph
/*
** Title:	GlyphModel.as
** Purpose: Create a data matrix of the processed glyph data
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Stores
	import org.wsimpson.store.ColorStore;
	import org.wsimpson.store.OrderStore;

	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.FieldRankUtil;
	import org.wsimpson.util.StatsUtil;	
	import org.wsimpson.util.StringUtil;	
	
	//UI
	import org.wsimpson.ui.GlyphConst;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.ScreenModel;	
	import org.wsimpson.visualization.experiment.ScreenError;

	public class GlyphModel
	{
		// PUBLIC Constants
		public static const RANK_INVALID = NaN;		// Indicates that the value is invalid
		public static const RANK_LABEL = "_rank";		// Labels for ranks
		public static const TYPE_STRING = "String";		// Column data types
		public static const TYPE_NUMERIC = "Numeric";	// Column data types
		public static const TYPE_NUMBER = "Number";		// Column data types
		
		// XML Definition
		private static const TEMPLATE_GRID = 
			"<grid>\n\t<input>\n\t\t {RAW}\n</input>\n\t<rules>\n\t\t{RULES}</rules>\n\t<table>\n\t\t{TABLE}\n</table>\n</grid>";
		private static const RAW_DATA = "{RAW}";	// Field to replace
		private static const RULES = "{RULES}";		// Field to replace
		private static const GRID_TABLE = 
			"{TABLE}";								// Field to replace

		// Private Instance Values
 		private	var _debugger:DebugUtil;			// Output and diagnostic window
		private var glyphDef:XML;					// XML defining the glyph fields
		private var glyphData:XML;					// XML representing the glyph data
		private var glyphStore:Array;				// Object containing the Glyph values
		private var defaultColors:Array;			// Array storing the default color for each fieldID
		private var rulesObj:Object;				// Associative array of Field Rules
		private var statsObj:Object;				// Associative array of statistics related to the field data
		private var avgRankBool:Boolean;			// Indicates that the average rank is a required field
		private var avgRankID:String;				// Indicates the average rank field ID
		private	var colorStore:ColorStore;			// Manages color scales used
		private var orderStore:OrderStore;			// Factory for creating objects containing name value pairs
		private var formatBool:Boolean;				// Defines whether or not to format the datastore for display

		// Patterns
		private var rawPattern:RegExp;				// Regular Expression pattern
		private var rulesPattern:RegExp;			// Regular Expression pattern
		private var gridPattern:RegExp;				// Regular Expression pattern
		
		/**
		*  Name:  	Constructor
		*  Purpose:	Creates a screen from the imported XML
		*
		*	@param inDef XML The XML defining the glyphs and their fields
		*	@param inData XML The XML with the raw data
		*	@param inFormatBool Boolean Indicates wether "getFields" will return raw or formatted values
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function GlyphModel(inDef:XML, inData:XML, inFormatBool:Boolean = false)
		{
			this._debugger = DebugUtil.getInstance();
			this.orderStore = new OrderStore();
			this.statsObj = new Object();
			this.glyphStore = new Array();
			this.formatBool = inFormatBool;
	
			// Define Patterns
			this.rawPattern = new RegExp(RAW_DATA);
			this.rulesPattern = new RegExp(RULES);
			this.gridPattern = new RegExp(GRID_TABLE);
			
			// Build the Data Grid
			this.glyphDef = inDef;
			this.glyphData = inData;
			this.colorStore = ColorStore.getInstance();
			
			// Instantiate the Rule Definitions
			this.initiateRules();
			
			// Define Ranks and the Average Ranks
 			this.avgRankBool = requiresAverageRank();

			this.assignRanks();
			if (this.avgRankBool)
			{
				this.assignAverageRank();
			}
			
			// Create the Grid
			this.initiateGlyphStore();
		}

		/**
		*  name:  	toXMLString
		*  Purpose: Converts the GlyphModel to an XML String
		*  @return String The field rule values as XML.
		*/
		public function toXMLString():String
		{		
			var tempStr:String;
			tempStr = TEMPLATE_GRID;
			tempStr = tempStr.replace(this.rawPattern,this.glyphData);
			tempStr = tempStr.replace(this.rulesPattern,this.rulesToXMLString());		
			tempStr = tempStr.replace(this.gridPattern,this.gridToXMLString());
			return tempStr;
		}

		/**
		*  name:  	rulesToXMLString
		*  Purpose: Convert the stats values received to XML
		*  @return String The statistics values as XML.
		*/
		public function rulesToXMLString():String
		{
			return this.compileXMLObj(this.rulesObj);
		}

		/**
		*  name:  	gridToXMLString
		*  Purpose: Convert the grid values received to XML
		*  @return String The grid values as XML.
		*/
		public function gridToXMLString():String
		{
			return this.compileXMLArr(this.glyphStore);
		}
		
		/**
		*  name:  	getColorArray
		*  Purpose: Retrieve the color scale assigned to the field
		*  @param inStr Strinng Label for the field
		*  @return Array Color Scale used for the field
		*/
		public function getColorArray(inStr:String):Array
		{
			// label_color is the name of the color scale used as defined in the field definitions
			return this.colorStore.getColorScale(this.rulesObj[retrieveFieldID(inStr)].label_color);
		}
		
		/**
		*  name:  	getDefaultColor
		*  Purpose: Retrieve the default color assigned to the field
		*  @param inStr Strinng Label for the field
		*  @return String Default color used for the field
		*/
		public function getDefaultColor(inStr:String):String
		{
			// label_color is the name of the color scale used as defined in the field definitions
			return this.colorStore.getColorDefault(this.rulesObj[retrieveFieldID(inStr)].label_color);
		}	

		/**
		*  name:  	getDefaultColors
		*  Purpose: Retrieve the color scale assigned to the field
		*  @return Array Default color array for all fields
		*/
		public function getDefaultColors():Array
		{
			return this.defaultColors;
		}		

		/**
		*  name:  	getLabelColor
		*  Purpose: Retrieve the field color
		*  @param inStr String Label color for the field
		*  @return String
		*/
		public function getLabelColor(inStr:String):String
		{
			return getDefaultColor(inStr);
		}

		/**
		*  name:  	glyphCount
		*  Purpose: Objtain the number of glyphs
		*  @return uint Count of Glyphs
		*/
		public function glyphCount():uint
		{
			return this.retrieveGlyphs().length();
		}
		
		/**
		*  name:  	getValueRank
		*  Purpose: Retrieve the field value rank
		*  @param inField Strinng Label for the field
		*  @param inValue Strinng field Value for the field
		*  @return int The Value's Rank
		*/
		public function getValueRank(inID:String,inValue:String):int
		{
			var tempInt:int;
			var tempStr:String;
			tempStr = retrieveFieldID(inID);
			tempInt = (this.rulesObj[tempStr]) ? this.rulesObj[tempStr].getRank(inValue) : RANK_INVALID;
			return tempInt;
		}

		/**
		*  name:  	getValuePercentile
		*  Purpose: Retrieve the field value percentile
		*  @param inField Strinng Label for the field
		*  @param inValue Strinng field Value for the field
		*  @return Number The Value's Percentile
		*/
		public function getValuePercentile(inID:String,inValue:String):Number
		{
			var tempNum:Number;
			var tempStr:String;
			tempStr = retrieveFieldID(inID);
			tempNum = (this.rulesObj[tempStr]) ? this.rulesObj[tempStr].getPercentile(inValue) : RANK_INVALID ;
			return tempNum;
		}
		
		/**
		*  name:  	getType
		*  Purpose: Objtain the sort data type
		*  @return String Field data type for sorting
		*/
		public function getType(inStr:String):String
		{
			var tempStr:String;
			if (inStr.indexOf(RANK_LABEL) > 0)
			{
				tempStr = TYPE_NUMERIC;
			} else if (inStr == GlyphConst.GLYPH_ID)
			{
				tempStr = TYPE_STRING;
			} else
			{
				var fieldIDStr:String;
				fieldIDStr = this.getFieldID(inStr).toString();
				tempStr = (this.rulesObj[fieldIDStr].dataType == TYPE_NUMBER) ? TYPE_NUMERIC : TYPE_STRING;
			}
			return tempStr;
		}

		/**
		*  name:  	getFields
		*  Purpose: Objtain the fields with the field ranks.
		*  @return Array Count of Glyphs
		*/
		public function getFields():Array
		{
			return this.glyphStore[0].valueArr;
		}
		
		/**
		*  name:  	getFieldLabel
		*  Purpose: Returns an String label value
		*  @param inStr String Field ID 
		*  @return String Field ID label
		*/
		public function getFieldLabel(inStr:String):String
		{
			// Note Changed with the addition of the new page Flight_Schedule.  Original glyphs page will need updating.
			return this.rulesObj[inStr].label;
		}

		/**
		*  name:  	parseFieldValue
		*  Purpose: Returns an String label value
		*  @param inStr String Field ID 
		*  @param inVal String Field Value 
		*  @return String Field Value Parsed for the value ranked
		*/
		public function parseFieldValue(inStr:String,inFieldValue:String):Number
		{
			return this.rulesObj[retrieveFieldID(inStr)].getParsed(inFieldValue);
		}

		/**
		*  name:  	getFieldStart
		*  Purpose: Returns the beginning of the field
		*  @param inStr String Field ID 
		*  @return Number Field Start Value
		*/
		public function getFieldStart(inStr:String):Number
		{
			return this.rulesObj[retrieveFieldID(inStr)].range_start;
		}
		
		/**
		*  name:  	getFieldEnd
		*  Purpose: Returns the beginning of the field
		*  @param inStr String Field ID 
		*  @return Number Field End Value
		*/
		public function getFieldEnd(inStr:String):Number
		{
			return this.rulesObj[retrieveFieldID(inStr)].range_end;
		}
		
		/**
		*  name:  	getFieldStats
		*  Purpose: Returns the field statistics
		*  @param inStr String Field ID 
		*  @return Object Contains name value pairs as defined by StatsUtil
		*/
		public function getFieldStats(inStr:String):Object
		{
			return this.rulesObj[retrieveFieldID(inStr)].stats;
		}

		/**
		*  name:  	getFieldTarget
		*  Purpose: Returns the target value for the field
		*  @param inStr String Field ID 
		*  @return Number Field Target Value
		*/
		public function getFieldTarget(inStr:String):Number
		{
			return this.rulesObj[retrieveFieldID(inStr)].range_target;
		}
		
		/**
		*  name:  	getFieldMin
		*  Purpose: Returns the target value for the field
		*  @param inStr String Field ID 
		*  @return Number Field Target Value
		*/
		public function getFieldMin(inStr:String):Number
		{
			return this.rulesObj[retrieveFieldID(inStr)].value_min;
		}

		/**
		*  name:  	getFieldMax
		*  Purpose: Returns the target value for the field
		*  @param inStr String Field ID 
		*  @return Number Field Target Value
		*/
		public function getFieldMax(inStr:String):Number
		{
			return this.rulesObj[retrieveFieldID(inStr)].value_max;
		}

		/**
		*  name:  	getFieldID
		*  Purpose: Convert field label to field ID
		*  @param inStr Strinng Label for the field
		*  @return Number ID for the Field.
		*/
		public function getFieldID(inStr:String):Number
		{
			return (Number(retrieveFieldID(inStr)));
		}
		
		/**
		*  name:  	getGlyphTable
		*  Purpose: Returns a DataTable of Glyph Data
		*  @return Object DataTable of Glyph Data
		*/
		public function getGlyphTable():Array
		{
			return this.glyphStore;
		}
		
		/**
		*  name:  	getTargetValues
		*  Purpose: Returns an Associative Array of fieldID target values
		*  @return Object Field ID targets used in this glyph
		*/
		public function getTargetValues():Object
		{
			var fieldList:XMLList;
			var tempObj:Object;
			tempObj = new Object();
			fieldList = this.retrieveFields();
			for each (var fieldRule:XML in fieldList)
			{
				var tempFieldID:String;
				var defaultColorBool:Boolean;
				var tempValue:String;
				var tempDisplayValue:String;
				tempFieldID = fieldRule.@fieldID.toString();
				defaultColorBool = (fieldRule.@default_color.toString().toLowerCase() == "true");

				tempValue = getTargetValue(tempFieldID);
				tempDisplayValue = getTargetDisplayValue(tempFieldID);
				if (tempValue)
				{
					tempObj[tempFieldID] = new Object();			
					tempObj[tempFieldID].label = this.getFieldLabel(tempFieldID);
					tempObj[tempFieldID].rank = (this.rulesObj[tempFieldID].isFormatted) ?  
												tempValue :
												this.getValueRank(tempFieldID,tempValue);
					if (tempDisplayValue != "")
					{
						tempValue = tempDisplayValue;
					} else
					{
						tempValue = (this.rulesObj[tempFieldID].isFormatted) ? 
									this.rulesObj[tempFieldID].formatValue(tempValue) :
									tempValue;
					}
					tempObj[tempFieldID].value = tempValue;
					tempObj[tempFieldID].color = 	(defaultColorBool) ?
													this.getDefaultColor(retrieveLabel(tempFieldID)) :
													this.getColorArray(retrieveLabel(tempFieldID))[tempObj[tempFieldID].rank];												
				}
			}
			return tempObj;
		}
		
		// This should probably be moved elsewhere
		private function getTargetColor(inObj:Object,inID:String):String
		{
			var tempStr:String;
				switch(inID)
				{
					case "5":
						tempStr = inObj[inID].color;
					break;
					case "1":
					case "2":
					case "3":
					case "4":
					case "6":
					default:
						tempStr = inObj[inID].defaultColor;
					break;
				}
			return tempStr;
		}
		
		/**
		*  name:  	glyphField
		*  Purpose: Returns an Object containing the values the glyph's meters will use to represent the data
		*  @return Object Data to populate the glyph's meers
		*/
		public function glyphField(glyphData:Object):Array
		{
			var tempArr:Array;		// Meter Specific values
			tempArr = new Array();

			// Assign Values
			for (var i:int = 0; i < glyphData.valueArr.length; i++)
			{
				var dataArr:Array;
				var tempStr:String;
				dataArr = new Array();
				tempStr = glyphData.valueArr[i];

				
				// Remapping from generic fields to specific meter required fields
				if ((tempStr != "id") && (tempStr != null))
				{
					var tempFieldID:String;
					tempFieldID = dataArr[GlyphConst.DATA_INDEX] = this.getFieldID(tempStr);
					dataArr[GlyphConst.DATA_DISPLAY_VALUE] = 	(this.rulesObj[tempFieldID].isFormatted) ? 
																this.rulesObj[tempFieldID].formatValue(glyphData[tempStr]) : 
																glyphData[tempStr];					
					dataArr[GlyphConst.DATA_RAW_VALUE] = glyphData[tempStr];					
					dataArr[GlyphConst.DATA_RANK] = this.getValueRank(tempStr,glyphData[tempStr]);
					dataArr[GlyphConst.DATA_PERCENTILE] = this.getValuePercentile(tempStr,glyphData[tempStr]);
					dataArr[GlyphConst.DATA_COLOR] = this.getColorArray(tempStr);
					dataArr[GlyphConst.DATA_DEFAULT_COLOR] = this.getDefaultColor(tempStr);
					dataArr[GlyphConst.DATA_MAX_VALUE] = this.getFieldMax(tempStr);
					dataArr[GlyphConst.DATA_LABEL] = tempStr;
					tempArr[this.getFieldID(tempStr)] = dataArr;
				}
			}
			return tempArr;
		}

		/******************************************************************************************************
		**  Private
		******************************************************************************************************/

				
		// Returns the files contained here
		private function initiateRules():void
		{
			var fieldList:XMLList;
			fieldList = this.retrieveFields();
			this.rulesObj = new Object();
			this.defaultColors = new Array();
			for each (var fieldRule:XML in fieldList)
			{
				var tempFieldID:String;
				tempFieldID = fieldRule.@fieldID.toString();
				this.defaultColors[Number(tempFieldID)] = this.colorStore.getColorDefault(fieldRule.@label_color.toString());
				try
				{
					this.rulesObj[tempFieldID] = new FieldRankUtil(fieldRule);
					this.rulesObj[tempFieldID].referencePoint = getTargetValue(tempFieldID);
					this.rulesObj[tempFieldID].scale = this.colorStore.getColorScaleLength(this.rulesObj[tempFieldID].label_color);
				} catch (e:Error)
				{	
					(ScreenError.getInstance()).reportError(ScreenModel.GLYPH_CONTENT_TYPE,e.message);
					(DebugUtil.getInstance()).errorTrace(e.getStackTrace());
					break;
				}
			}
		}
		
		private function assignRanks()
		{
			for (var fieldStr:String in this.rulesObj)
			{
				var tempList:XMLList;
				tempList = this.gerFields(fieldStr);
				try
				{
					if (fieldStr != this.avgRankID)
					{
						this.rulesObj[fieldStr].assignData(tempList);
					}
				}
				catch (e:Error)
				{	
					(ScreenError.getInstance()).reportError(ScreenModel.GLYPH_CONTENT_TYPE,e.message);
					(DebugUtil.getInstance()).errorTrace(e.getStackTrace());
					break;
				}
			}
		}

		private function assignAverageRank()
		{
			var glyphList:XMLList;
			var rankArray:Array;
			rankArray = new Array;
			glyphList = this.retrieveGlyphs();
			for each (var glyphFields:XML in glyphList)
			{
				var tempArr:Array;
				var rankArr:Array;
				tempArr = new Array;
				rankArr = new Array;
				for each (var cellXML:XML in glyphFields..cell)
				{
 					var tempRank:int;
					var breakBool:Boolean;
					breakBool = false;
					try
					{
						tempRank = this.getValueRank(cellXML.@fieldID,cellXML.@value);

					}
					catch (e:Error)
					{	
						(ScreenError.getInstance()).reportError(ScreenModel.GLYPH_CONTENT_TYPE,e.message);
						(DebugUtil.getInstance()).errorTrace(e.getStackTrace());
						breakBool = true;
						break;
					}
					
					// Only include data with valid values
					if ((!isNaN(tempRank)) && (!this.rulesObj[cellXML.@fieldID].isEnumeratedBool))
					{
						tempArr.push(tempRank);
					}
					// for comparison only
					rankArr.push(tempRank);
				}
				// Break if error occurs
				if (breakBool)
				{
					break;
				}
				this.statsObj[glyphFields.@glyphID] =  StatsUtil.getStats(tempArr);
			}
			this.rulesObj[this.avgRankID].assignData(this.getAverageList());
		}
		
		// Iniitiate Data Table
		private function initiateGlyphStore():void
		{
			var glyphList:XMLList;
			glyphList = this.retrieveGlyphs();
			for each (var glyphFields:XML in glyphList)
			{

				if (glyphFields.@size == glyphFields.cell.length())
				{
					var tempID:String;
					tempID = glyphFields.@glyphID;
					this.orderStore.newObj();	
					this.orderStore.addNameValue(GlyphConst.GLYPH_ID,tempID);					
					for each (var cellXML:XML in glyphFields..cell)
					{
						var tempValue:String;
						tempValue = ((this.rulesObj[cellXML.@fieldID].isFormatted) && this.formatBool) ? this.rulesObj[cellXML.@fieldID].formatValue(cellXML.@value) : cellXML.@value;

						this.addOrderStoreValue(cellXML.@fieldID,tempValue);
					}
					if (this.avgRankBool)
					{
						this.addOrderStoreValue(this.avgRankID,this.statsObj[tempID][StatsUtil.VALUE_MEAN]);
					}
					this.glyphStore.push(this.orderStore.getObj());
				} else 
				{
					(ScreenError.getInstance()).reportError(ScreenModel.GLYPH_CONTENT_TYPE,"Glyph " + glyphFields.@glyphID + " doesn't contain the defined number of cells.");	
				}
			}
		}
		
		// Add Label value and rank
		private function addOrderStoreValue(inID:String,inValue:String):void
		{
			var tempRank:int;

			this.orderStore.addNameValue(this.rulesObj[inID].label,inValue);
		}

		
		/******************************************************************************************************
		**  Private - XML Extraction
		******************************************************************************************************/

		// Returns the files contained here
		private function retrieveFields():XMLList
		{
			return this.glyphDef..field;
		}
		
		// Returns the fieldID
		private function retrieveFieldID(inStr:String):String
		{
			return this.glyphDef..field.(@label == inStr).@fieldID;
		}

		// Returns the fieldID
		private function retrieveLabel(inStr:String):String
		{
			return this.glyphDef..field.(@fieldID == inStr).@label;
		}
		
		// Returns the files contained here
		private function retrieveGlyphs():XMLList
		{
			return this.glyphData..glyph;
		}
		
		// list field values
		private function gerFields(inStr:String):XMLList
		{
			return this.glyphData..cell.(@fieldID == inStr).@value;
		}
		
		// list field values
		private function getTargetValue(inStr:String):XMLList
		{
			return this.glyphData..target.(@fieldID == inStr).@value;
		}

		// list field values
		private function getTargetDisplayValue(inStr:String):XMLList
		{
			return this.glyphData..target.(@fieldID == inStr).@display_value;
		}
		
		// list field values
		private function getFileID():String
		{
			return this.glyphData..file.@id.toString();
		}
		
		// Create XMLList from the Average data
		private function getAverageList():XMLList
		{
			var tempXML:XML;
			var tempObj:Object;
			this.orderStore.newObj();
			for (var tempStr in this.statsObj)
			{
				this.orderStore.addNameValue(tempStr,this.statsObj[tempStr][StatsUtil.VALUE_MEAN]);
			}
			tempXML = new XML("<list>" + this.orderStore.toXMLString() + "</list>");
			return tempXML..unit.@value;
		}
		
		// Confirm that the average rank is needed
		private function requiresAverageRank():Boolean
		{
			var tempBool:Boolean;
			var glyphList:XMLList;
			tempBool = false;
			glyphList = this.glyphDef..field;
			this.avgRankID = "-1";
			for each (var glyphFields:XML in glyphList)
			{	
				var tempStr:String;
				var rankBool:Boolean;
				tempStr = glyphFields.range.start.@calc.toString();
				rankBool = (tempStr.toLowerCase() == FieldRankUtil.OPERATION_AVG_RANK);
				tempBool = (rankBool || tempBool) ? true : false;			
				this.avgRankID = (rankBool) ? glyphFields.@fieldID : this.avgRankID;
			}
			return tempBool;
		}
				
		private function getXMLStr(inObj:Object):String
		{
			var tempStr:String;
			if (inObj.toXMLString)
			{
				tempStr = inObj.toXMLString();
			} else 
			{
				tempStr = this.orderStore.toXMLString(inObj);
			}
			return tempStr;
		}
		
		// Create concatenated XML String from an array of Objects
		private function compileXMLObj(inObj:Object):String
		{
			var tempStr:String;
			tempStr = "";
			for (var rowStr:String in inObj)
			{
				tempStr += getXMLStr(inObj[rowStr]);
			}
			return tempStr;
		}
		
		// Create concatenated XML String from an array of Objects
		private function compileXMLArr(inArr:Array):String
		{
			var tempStr:String;
			tempStr = "";
			for (var i:uint=0; i < inArr.length; i++)
			{
				tempStr += getXMLStr(inArr[i]);
			}
			return tempStr;
		}
		
	}			
}