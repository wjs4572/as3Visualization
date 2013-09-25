﻿﻿package org.wsimpson.ui

/*
** Title:	DateAxis.as
** Purpose: Handles drawing and axis based on Date values for charts that are not tied to the AS3 Charts
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	// Enumeration
	import org.wsimpson.store.OrderStore;
	
	// Styles
	import org.wsimpson.styles.Style;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;
	import org.wsimpson.util.StatsUtil;
	import org.wsimpson.util.StringUtil;
	import org.wsimpson.util.TextFieldUtil;
	
	// UI
	import org.wsimpson.ui.DisplayArea;	
	import org.wsimpson.ui.cell.GradientCell;
	import org.wsimpson.ui.screen.ExtendedScreen;
	
	// Adobe
	import fl.controls.SliderDirection;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextLineMetrics;
	
	public class Axis extends DisplayArea
	{
		
		// Axis orientation and positioning values
		public static const HORIZONTAL:String = SliderDirection.HORIZONTAL;		// Determines the direction 
		public static const VERTICAL:String = SliderDirection.VERTICAL;			// A alt value is present
		public static const ALIGN_TOP:String = StageAlign.TOP;					// Indicates the tics are to be at a greater Y value, but aligned along the X value
		public static const ALIGN_BOTTOM:String = StageAlign.BOTTOM;			// Indicates the tics are to be at a lesser Y value, but aligned along the X value
		public static const ALIGN_LEFT:String = StageAlign.LEFT;				// Indicates the tics are to be at a lesser X value, but aligned along the Y value
		public static const ALIGN_RIGHT:String = StageAlign.RIGHT;				// Indicates the tics are to be at a greater X value, but aligned along the Y value

		// Key axis values
		public static const AXIS_TARGET:String = "target";						// Axis data field -> value range
		public static const AXIS_BEGIN:String = "begin";						// Axis data field -> value range
		public static const AXIS_END:String = "end";							// Axis data field -> value range
		
		// Data object names
		public static const AXIS_STATS:String = "statistics";					// Axis data object
		public static const AXIS_RENDER:String = "rendering";					// Axis data object	
		
		// Axis rendering variables
		public static const AXIS_STARTX:String = "startX";						// Axis data field-> coordinates
		public static const AXIS_STARTY:String = "startY";						// Axis data field-> coordinates
		public static const AXIS_ENDX:String = "endX";							// Axis data field -> coordinates
		public static const AXIS_ENDY:String = "endY";							// Axis data field -> coordinates
		public static const AXIS_ALIGN:String = "align";						// Axis data field -> Determines how the axis tic marks and labels are drawn
		public static const AXIS_LENGTH:String = "axis_length";					// Axis data field -> The pixel length of the total axis (lowest to highest tick marks)
		public static const AXIS_GUIDE_LENGTH:String = "guide_line_length";		// Axis data field -> The pixel length of the total axis (lowest to highest tick marks)
		public static const AXIS_RANGE:String = "value_length";					// Axis data field -> The of values represented by the total axis (lowest to highest tick marks)
		public static const AXIS_ORIENTATION:String = "orientation";			// Axis data field -> Orientation is used for drawing
		public static const AXIS_LABEL:String = "label";						// Axis data field -> Text label assigned to the axis
		public static const AXIS_TICK_MAX:String = "tick_max";					// Axis data field -> Indicates the maximum number of tick marks that should be displayed
		public static const AXIS_TICK_UNIT:String = "tick_unit";				// Axis data field -> Indicates the unit of value represented by a tick mark
		public static const AXIS_TICK_SPAN:String = "tick_span";				// Axis data field -> Indicates the number of pixels by a tick mark
		public static const AXIS_TICK_WIDTH:String = "tick_width";				// Axis data field -> Indicates the number of pixels a tick mark label uses for width
		public static const AXIS_DEPTH:String = "depth";						// Axis data field -> The width or height of the added elements to determine placement 		
		public static const AXIS_DATATYPE:String = "type";						// Axis data field -> Axis specified
		public static const AXIS_SPACER:String = "spacer";						// Axis data field -> used to define the size of the point and the Tufte gaps
		public static const AXIS_MEDIAN_GAP:String = "gap";						// Axis data field -> Represents the median value in a Tufte axis
		public static const AXIS_LABEL_HEIGHT:String = "axis_label_height";		// Axis data field -> The actual height in pixels of the Axiz label, used to determine axis display length.
		public static const AXIS_LABEL_WIDTH:String = "axis_label_width";		// Axis data field -> The actual width in pixels of the Axiz label, used to determine axis display position and length.
		public static const AXIS_LABEL_COLOR:String = "axis_label_color";		// Axis data field -> The label color to be used.
		public static const AXIS_PIXEL_VALUE:String = "axis_pixel_value";		// Axis data field -> Determines the value represented by each pixel
		public static const LAST_LABEL_HEIGHT:String = "last_label_height";		// Axis data field -> Half of the vertical height of the last tick label will be subtracted from the axis length for vertical axes		public static const LAST_LABEL_HEIGHT:String = "last_label_height";		// Axis data field -> Half of the vertical height of the last tick label will be subtracted from the axis length for vertical axes
		public static const AXIS_LINE_OFFSET:String = "axis_line_offset";		// Axis data field -> used to define the size of label text to line up guidelines and other axises
		public static const AXIS_OFFSET:String = "axis_offset";					// Axis data field -> used to define the size of label text to line up guidelines and other axises
		public static const GUIDE_OFFSET:String = "guide_offset";				// Axis data field -> used to define the size of label text to line up guidelines and other axises
		public static const SHOW_GUIDELINES:String = "show_guidelines";			// Axis data field -> used to define the size of label text to line up guidelines and other axises

		// Configuration file definition attributes
		public static const MAX_TICKS:String = "max_ticks";						// Configuration XML Parameter
		public static const TICK_UNIT:String = "tick_value";					// Configuration XML Parameter
		public static const AXISLINES_BOOL:String = "axislines";				// Configuration XML Parameter
		public static const GUIDELINES_BOOL:String = "guidelines";				// Configuration XML Parameter
		public static const HASMAJOR_BOOL:String = "majorlabels";				// Configuration XML Parameter
		public static const AXIS_ALIGNMENT:String = "align";					// Configuration XML Parameter
		public static const AXIS_WIDTH:String = "width";						// Configuration XML Parameter
		public static const AXIS_HEIGHT:String = "height";						// Configuration XML Parameter
		
		// Tick Values
		public static const TIC_VALUE:String = "value";							// Ticks specified
		public static const TIC_LABEL:String = "label";							// Ticks specified
		public static const TIC_SIZE:String = "size";							// Ticks specified
		public static const TIC_INDEX:String = "index";							// Ticks specified
		public static const TIC_TEXT:String = "text";							// Ticks specified
		
		// Types of tick marks
		public static const TARGET:String = AXIS_TARGET;						// A alt value is present
		public static const MAJOR:String = "major";								// A alt value is present
		public static const MINOR:String = "minor";								// A alt value is present
		
		//Styles
		public static const AXIS_LABEL_CLASS:String = "axis_label_";			// Data Structure entry  (Forced CSS Naming Convention)
		public static const AXIS_LABEL_BORDER:String = "_border";				// Axis data field -> Axis specified		
		public static const AXIS_LINE:String = "axis_line";						// Data Structure entry
		public static const AXIS_GUIDE_LINE:String = "axis_guide_line";			// Data Structure entry
		public static const AXIS_TIC_TARGET:String = "tic_target";				// Data Structure entry
		public static const AXIS_TIC_MAJOR:String = "tic_major";				// Data Structure entry
		public static const AXIS_TIC_MINOR:String = "tick_minor";				// Data Structure entry
		public static const AXIS_STYLES:Array = [AXIS_LINE,AXIS_GUIDE_LINE,AXIS_TIC_MAJOR, AXIS_TIC_MINOR, AXIS_TIC_TARGET];

		// XML Template
		protected static const TEMPLATE_AXIS = 
		"<axis {ATTRIBUTES}>\n\t<render>\n\t\t{RENDER}\n</render><stats>\n\t\t{STATS}</stats>\n\t<axisPoints>\n\t\t{POINTS}\n</axisPoints>\n<guidelines>\n\t\t{GUIDELINES}\n</guidelines>\n<tufte_lines>\n\t\t{TUFTE}\n</tufte_lines>\n<ticks>\n\t\t{TICKS}\n</ticks>\n</axis>";
		protected static const AXIS_ATTRIBUTES = "{ATTRIBUTES}";						// Field to replace
		protected static const TEMPLATE_ATTRIBUTES =
			"label={LABEL}";
		protected static const RENDER = "{RENDER}";										// Field to replace
		protected static const STATS = "{STATS}";										// Field to replace
		protected static const FIELD_LABEL = "{LABEL}";									// Field to replace
		protected static const AXIS_POINTS = "{POINTS}";								// Field to replace
		protected static const AXIS_GUIDELINES = "{GUIDELINES}";						// Field to replace
		protected static const AXIS_TICKS = "{TICKS}";									// Field to replace
		protected static const AXIS_TUFTE = "{TUFTE}";									// Field to replace
		
		// Regex
		protected static const attributePattern:RegExp = new RegExp(AXIS_ATTRIBUTES);	// Regular Expression pattern
		protected static const labelPattern:RegExp = new RegExp(FIELD_LABEL);			// Regular Expression pattern
		protected static const renderPattern:RegExp = new RegExp(RENDER);				// Regular Expression pattern
		protected static const statsPattern:RegExp = new RegExp(STATS);					// Regular Expression pattern
		protected static const pointsPattern:RegExp = new RegExp(AXIS_POINTS);			// Regular Expression pattern
		protected static const guidelinesPattern:RegExp = new RegExp(AXIS_GUIDELINES);	// Regular Expression pattern
		protected static const ticksPattern:RegExp = new RegExp(AXIS_TICKS);			// Regular Expression pattern
		protected static const tuftePattern:RegExp = new RegExp(AXIS_TUFTE);			// Regular Expression pattern
		
		// Protected Instance Variables
        protected var _debugger:DebugUtil;
		protected var _axisArr:Array;				// Array of axis points and lines
		protected var _point:Array;					// Array of guide lines
		protected var _guideArr:Array;				// Array of guide lines
		protected var _tickArr:Array;				// Tickmarks each has (label, MINOR | MAJOR),
		protected var _minorArr:Array;				// Tickmarks each is MINOR
		protected var _boolVertical:Boolean;		// Indicates orientation of the axis
		protected var _data:Object;					// The data used to define the axis
		protected var _store:OrderStore;			// Manages name/value pairs
		protected var boolAxisLines:Boolean;		// Indicates whether the Tufte inspired axis lines should be shown
		
		// Private Instance Variables
		private var _axisLabel:TextField;			// The array of TextFields used for the axis labels
		private var _hasMajor:Boolean;				// Indicates whether to use the major format
		private var _align:String;					// Tickmarks each has (label, MINOR | MAJOR),
		private var _axisHeight:uint;				// Tickmarks each has (label, MINOR | MAJOR),
		private var _axisWidth:uint;				// Tickmarks each has (label, MINOR | MAJOR),
		private var _tickLabelWidth;				// The widest of the tick labels
		private var _tickUnit:Number;				// Number of units of measurement that each tick represents
		private var _maxTicks:uint;					// Maximum number of tick marks
		private var _style:Style;					// StyleSheet
		private var _boolGuideLines:Boolean;		// StyleSheet
		private var _axis_lines:GradientCell;		// AxisLines
		private var _guide_lines:GradientCell;		// AxisLines

		// Constructor
		public function Axis(inDef:XML,inStyle:Style,inDesc:String)
		{
			super(inDef,inStyle.getStyle(inDef.attribute("name")),inDesc);
			
			this._debugger = DebugUtil.getInstance();
			
			// Assign configuration
			this._style = inStyle;
			this._data = new Object();
			this._data[AXIS_RENDER] = new Object();
			this._data[AXIS_RENDER][AXIS_TICK_MAX] = this._definition.@[MAX_TICKS];
			this._data[AXIS_RENDER][AXIS_TICK_UNIT] = this._definition.@[TICK_UNIT];
			this.boolAxisLines = (this._definition.@[AXISLINES_BOOL]) ? ((this._definition.@[AXISLINES_BOOL]).toString().toLowerCase() == "true") : true;
			this._boolGuideLines = (this._definition.@[GUIDELINES_BOOL]) ? ((this._definition.@[GUIDELINES_BOOL]).toString().toLowerCase() == "true") : true;
			this._hasMajor = (this._definition.@[HASMAJOR_BOOL]) ? ((this._definition.@[HASMAJOR_BOOL]).toString().toLowerCase() == "true") : true;
			this._data[AXIS_RENDER][SHOW_GUIDELINES] = this._boolGuideLines.toString();
			
			// Assign Defaults
			this._data[AXIS_STATS] = null;
			this._data[AXIS_RENDER][AXIS_TICK_SPAN] = 0;
			this._data[AXIS_RENDER][AXIS_OFFSET] = 0;
			this._data[AXIS_RENDER][AXIS_LINE_OFFSET] = 0;
			this._data[AXIS_RENDER][GUIDE_OFFSET] = 0;
			this._data[AXIS_RENDER][AXIS_SPACER] = 0;
			this._data[AXIS_RENDER][LAST_LABEL_HEIGHT] = 0;
			this._data[AXIS_RENDER][AXIS_LABEL_WIDTH] = 0;
			this._data[AXIS_RENDER][AXIS_LABEL_COLOR] = "";
			
			// Configure orientation
			this._point = new Array();
			this._store = new OrderStore();
			this.align_axis = this._definition.@[AXIS_ALIGNMENT];
		}

		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/
	
		/**
		*  Name:  	align_axis
		*
		*
		*/
		public function get align_axis():String
		{
			return this._data[AXIS_RENDER][AXIS_ALIGN];
        }		
        public function set align_axis(inAlign:String):void
		{
			this._data[AXIS_RENDER][AXIS_ORIENTATION] = "";
			switch (inAlign)
			{
				case ALIGN_TOP:
				case ALIGN_BOTTOM:
					this._data[AXIS_RENDER][AXIS_ORIENTATION] = HORIZONTAL;
					this._data[AXIS_RENDER][AXIS_ALIGN] = inAlign;
					this._data[AXIS_RENDER][AXIS_LENGTH] = this._definition.@[AXIS_WIDTH];
					this._data[AXIS_RENDER][AXIS_GUIDE_LENGTH] = this._definition.@[AXIS_HEIGHT];				
					
				break;
				case ALIGN_LEFT:
				case ALIGN_RIGHT:
					this._data[AXIS_RENDER][AXIS_ORIENTATION] = VERTICAL;
					this._data[AXIS_RENDER][AXIS_ALIGN] = inAlign;
					this._data[AXIS_RENDER][AXIS_LENGTH] = this._definition.@[AXIS_HEIGHT];
					this._data[AXIS_RENDER][AXIS_GUIDE_LENGTH] = this._definition.@[AXIS_WIDTH];
				break;
				default:
					this.sendError("Unrecognized alignment value passed:  accepted values are axis values: ALIGN_TOP, ALIGN_BOTTOM, ALIGN_LEFT, ALIGN_RIGHT.  Received -> inAlign");
					this._data[AXIS_RENDER][AXIS_ALIGN] = ALIGN_TOP;
					this._data[AXIS_RENDER][AXIS_ORIENTATION] = HORIZONTAL;
				break;
			}
			this._boolVertical = (this._data[AXIS_RENDER][AXIS_ORIENTATION] == VERTICAL);
			this._align = (this._boolVertical) ? TextFormatAlign.RIGHT : TextFormatAlign.LEFT;
       }		
		
		/**
		*  Name:  	axis_orientation
		*
		*
		*/
		public function get axis_orientation():String
		{
			return this._data[AXIS_RENDER][AXIS_ORIENTATION];
		}
		
		public function set axis_orientation(inOrientation:String):void
		{
			// nada
		}

		/**
		*  Name:  	axis_begin
		*
		*
		*/
		public function get axis_begin():Number
		{
			return this._data[AXIS_RENDER][AXIS_BEGIN];
		}
		
		public function set axis_begin(inBegin:Number):void
		{
			this._data[AXIS_RENDER][AXIS_BEGIN] = inBegin;
		}

		/**
		*  Name:  	axis_end
		*
		*
		*/
		public function get axis_end():Number
		{
			return this._data[AXIS_RENDER][AXIS_END];
		}
		
		public function set axis_end(inEnd:Number):void
		{
			this._data[AXIS_RENDER][AXIS_END] = inEnd;
		}

		/**
		*  Name:  	axis_height
		*
		*
		*/
		public function get axis_height():uint
		{
			return this._axisHeight;
		}
		
		public function set axis_height(inLen:uint):void
		{
			// Do Nothing; 
		}
		
		/**
		*  Name:  axis_length
		*
		*
		*/		
		public function get axis_length():uint
		{
			return this._data[AXIS_RENDER][AXIS_LENGTH];
		}
		
		public function set axis_length(inLen:uint):void
		{
			this._data[AXIS_RENDER][AXIS_LENGTH] = inLen; 
		}
		
		/**
		*  Name:  	axis_range
		*
		*
		*/
		public function get axis_range():Number
		{
			return this._data[AXIS_RENDER][AXIS_RANGE];
        }	
        public function set axis_range(inRange:Number):void
		{
			// Do Nothing
        }
		
		/**
		*  Name:  	axis_width
		*
		*
		*/
		public function get axis_width():uint
		{
			return this._axisWidth;
		}
		
		public function set axis_width(inLen:uint):void
		{
			// Do Nothing; 
		}

	
		/**
		*  Name:  	guide_length
		*
		*
		*/
		public function get guide_length():uint
		{
			return this._data[AXIS_RENDER][AXIS_GUIDE_LENGTH];
		}
		
		public function set guide_length(inLen:uint):void
		{
			this._data[AXIS_RENDER][AXIS_GUIDE_LENGTH] = inLen; 
		}

		/**
		*  Name:  	axis_line_offset
		*
		*
		*/
		public function get axis_line_offset():uint
		{
			return this._data[AXIS_RENDER][AXIS_LINE_OFFSET];
		}
		
		public function set axis_line_offset(inLen:uint):void
		{
			this._data[AXIS_RENDER][AXIS_LINE_OFFSET] = inLen; 
		}

		/**
		*  Name:  	axis_offset
		*
		*
		*/
		public function get axis_offset():uint
		{
			return this._data[AXIS_RENDER][AXIS_OFFSET];
		}
		
		public function set axis_offset(inLen:uint):void
		{
			this._data[AXIS_RENDER][AXIS_OFFSET] = inLen; 
		}

	
		/**
		*  Name:  	guide_lines
		*
		*
		*/
		public function get guide_lines():Object
		{
			var guidePoints:Array;
			guidePoints = new Array();
			for (var i:int=0;i < this._minorArr.length; i++)
			{
				guidePoints.push(this.getCoordinates(this._minorArr[i]));
			}			
			return guidePoints;
		}
		
		public function set guide_lines(inLen:Object):void
		{
			// Do Nothing;
		}

		/**
		*  Name:  	guide_offset
		*
		*
		*/
		public function get guide_offset():uint
		{
			return this._data[AXIS_RENDER][GUIDE_OFFSET];
		}
		
		public function set guide_offset(inLen:uint):void
		{
			this._data[AXIS_RENDER][GUIDE_OFFSET] = inLen; 
		}

		
		/**
		*  Name:  	has_major
		*  Purpose:  Indicates the presence of major tick marks
		*
		*/
		public function get has_major():Boolean
		{
			return (this._data[AXIS_RENDER][AXIS_TARGET] != null);
        }		
        public function set has_major(inBool:Boolean):void
		{
			this._data[AXIS_RENDER][AXIS_TARGET] = (inBool) ? this._data[AXIS_RENDER][AXIS_TARGET] : null;
        }

		/**
		*  Name:  	label
		*
		*
		*/
		public function get label():String
		{
			return this._data[AXIS_RENDER][AXIS_LABEL];
        }		
        public function set label(inLabelStr:String):void
		{
			this._data[AXIS_RENDER][AXIS_LABEL] = inLabelStr;
        }

		/**
		*  Name:  	label_color
		*
		*
		*/
		public function get label_color():String
		{
			return this._data[AXIS_RENDER][AXIS_LABEL_COLOR];
        }		
        public function set label_color(inColor:String):void
		{
			var tempStyle:String;
			
			tempStyle = "." + AXIS_LABEL_CLASS + this._data[AXIS_RENDER][AXIS_LABEL];
			this._data[AXIS_RENDER][AXIS_LABEL_COLOR] = inColor;
	
			// Update Color
			// Confirm presence of required style definition.  This provides an error message, but a default style should probably be provided.
 			if (this._data[AXIS_RENDER][AXIS_LABEL_COLOR] != "")
			{
				var tempObj:Object;
				tempObj = this._style.getStyle(tempStyle);
				if (tempObj == null) 
				{
					this.sendError("Axis:  Missing CSS style for = " + tempStyle);
				} else
				{
					tempObj.color = this._data[AXIS_RENDER][AXIS_LABEL_COLOR];
					this._style.setStyle(tempStyle,tempObj);
				}
			}
        }
		
		/**
		*  Name:  	max_ticks
		*  Purpose: Provides maximum number of ticks that should be used.
		*  Note:  tick_units overrides this value.
		*
		*/
		public function get max_ticks():uint
		{
			return this._data[AXIS_RENDER][AXIS_TICK_MAX];
		}
		
		public function set max_ticks(inTicks:uint):void
		{
			this._data[AXIS_RENDER][AXIS_TICK_MAX] = inTicks;
		}
		
		/**
		*  Name:  	show_guidelines
		*
		*
		*/
		public function get show_guidelines():Boolean
		{
			return this._boolGuideLines;
		}
		
		public function set show_guidelines(inBool:Boolean):void
		{
			this._boolGuideLines = inBool;
			this._data[AXIS_RENDER][SHOW_GUIDELINES] = this._boolGuideLines.toString(); 
		}

		/**
		*  Name:  	target_value
		*
		*
		*/
		public function get target_value():Number
		{
			return this._data[AXIS_RENDER][AXIS_TARGET];
        }		
        public function set target_value(inStyle:Number):void
		{
			this._data[AXIS_RENDER][AXIS_TARGET] = inStyle;
        }


		/**
		*  Name:  	tick_value
		*
		*
		*/
		public function get tick_value():Number
		{
			return this._data[AXIS_RENDER][AXIS_TICK_UNIT];
        }	
        public function set tick_value(inTickValue:Number):void
		{
			this._data[AXIS_RENDER][AXIS_TICK_UNIT] = inTickValue;
        }
		
	
		/**
		*  Name:  	Statistics
		*/		

		/**
		*  Name:  	statistics
		*
		*
		*/
		public function get statistics():Object 
		{
			return this._data[Axis.AXIS_STATS];
        }		
        public function set statistics(inStats:Object):void 
		{
			this._data[Axis.AXIS_STATS] = inStats;
		}

		/**
		*  Name:  	Styles
		*/		

		/**
		*  Name:  	axis_style
		*
		*
		*/
		public function get axis_style():Style 
		{
			return this._style;
        }		
        public function set axis_style(inStyle:Style):void 
		{
			this._style = inStyle;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		
		/**
		*  Name:  	drawAxis
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/		
		public function drawAxis():void 
		{
			this.defineAxis();
			// This check should be unnecessary as the Display object defaults to 0
			if (isNaN(this.x) || isNaN(this.y))
			{
				this.sendError("The x and y coordinates of the start position must be set before an axis can be drawn");
			} else 
			{
				this.graphics.moveTo(this.x,this.y);
				this.setFinishCoordinates();
				this.addAxisLabel();
				this.calcReducedAxisLength();
				this.calcTickSpan();
				this.calcPixelValue();
				this.drawTickLabels();
				this.defineOffsets();
				if (this.boolAxisLines)
				{
					this.drawAxisLine();
				}
				this.drawGuideLine();
			}
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
			var tempStr2:String;
			tempStr = TEMPLATE_AXIS;
			tempStr2 = TEMPLATE_ATTRIBUTES;

			tempObj = this._store.convertNameValue(this._data[AXIS_RENDER]);
			
			tempStr = tempStr.replace(renderPattern,this._store.toXMLString(tempObj));
			tempStr2 = tempStr2.replace(labelPattern,StringUtil.doubeQuoteStr(this._data[AXIS_RENDER][AXIS_LABEL]));		
			tempStr = tempStr.replace(attributePattern,tempStr2);
			tempObj = this._store.convertNameValue(this._data[AXIS_STATS]);
			tempStr = tempStr.replace(statsPattern,this._store.toXMLString(tempObj));
			tempStr = tempStr.replace(guidelinesPattern,this._store.storeArrayXMLStr(this._guideArr));
			tempStr = tempStr.replace(pointsPattern,this._store.storeArrayXMLStr(this._point));
			tempStr = tempStr.replace(ticksPattern,this._store.storeArrayXMLStr(this._tickArr));
			if ((this._axisArr) && (this._axisArr.length > 0))
			{
				tempStr = tempStr.replace(tuftePattern,this._store.storeArrayXMLStr(this._axisArr));
			}
			return tempStr;
		}		

		/**
		*  name:  	getGlobalPoint
		*  Purpose: Determines the global coordinates of the point for this axis.
		*  @param inVal Number The value to map
		*  @return Point
		*/
		public function getGlobalPoint(inVal:Number):Point
		{
			var tempPoint:Point;
			tempPoint = this.getPoint(inVal);
			return this.localToGlobal(tempPoint);
		}
	
		/**
		*  name:  	getPoint
		*  Purpose: Determines the coordinates of the point for this axis.
		*  @param inVal Number The value to map
		*  @return Point
		*/
		public function getPoint(inVal:Number):Point
		{
			var tempObj:Object;
			
			tempObj = new Object();

			// define the axis array
			tempObj = this.getCoordinates(inVal);

			// Adjust for axis positioning
			tempObj = positionOffset(tempObj,this._data[AXIS_RENDER][AXIS_LINE_OFFSET]);
			
			// Adjust for Tufte Axis Second Quatile
			tempObj = tufteOffset(tempObj,inVal,this._data[AXIS_STATS][StatsUtil.VALUE_Q2_LESS],this._data[AXIS_STATS][StatsUtil.VALUE_Q2_PLUS]);

			// Adjust for Tufte Axis 1st Quartile
			tempObj = tufteOffset(tempObj,inVal,this._data[AXIS_STATS][StatsUtil.VALUE_Q1_LESS],this._data[AXIS_STATS][StatsUtil.VALUE_Q1_PLUS]);
		
			this._point.push(tempObj);
			return new Point(tempObj.x,tempObj.y);
		}
		
		/******************************************************************************************************
		**  Protected
		******************************************************************************************************/


		
		/**
		*  Name:  	axis_range
		*
		*
		*/
        protected function setRange(inRange:Number):void
		{
			this._data[AXIS_RENDER][AXIS_RANGE] = inRange;
        }
		
		protected function defineAxis():void 
		{
			this.defineMinorAxis();
			this.defineMajorAxis();
			this._data[AXIS_RENDER][AXIS_TICK_WIDTH] = TextFieldUtil.calcActualWidth(this._tickArr[this._tickArr.length-1][TIC_TEXT]);
		}		
		
		// Define minor tick marks by finding the next lowest power of 10 from the end of the scale
		protected function defineMinorAxis():void 
		{
			var numTics:int;
			var tempTF:TextField;
			
			// Initialize the array
			this._minorArr = (this._minorArr == null) ? new Array() : this._minorArr;
			this._tickArr = (this._tickArr == null) ? new Array() : this._tickArr;
			
			// Define the range
			this._data[AXIS_RENDER][AXIS_RANGE] = NumberUtil.getRange(this._data[AXIS_RENDER][AXIS_BEGIN],this._data[AXIS_RENDER][AXIS_END]);
			
			this._data[AXIS_RENDER][AXIS_TICK_UNIT] = (this.tick_value == 0) ? NumberUtil.calcFactor(this._data[AXIS_RENDER][AXIS_RANGE],this._data[AXIS_RENDER][AXIS_TICK_MAX]) : this._data[AXIS_RENDER][AXIS_TICK_UNIT];
			numTics = this._data[AXIS_RENDER][AXIS_END] / this._data[AXIS_RENDER][AXIS_TICK_UNIT];

			for (var i:int=0; i <= numTics;i++) 
			{
				var tempValue:Number = i * this._data[AXIS_RENDER][AXIS_TICK_UNIT];
				this._store.newObj();
				this._store.addNameValue(TIC_VALUE,tempValue);
				tempTF = this.addLabel(MINOR,tempValue.toString());
				this._store.addNameValue(TIC_LABEL,tempValue.toString());
				this._store.addNameValue(TIC_TEXT,tempTF);
				this._store.addNameValue(TIC_SIZE,MINOR);
				this._store.addNameValue(TIC_INDEX,i);
				this._tickArr[i] = this._store.getObj();
				this._minorArr.push(tempValue);
			}
		}
			
		protected function defineMajorAxis():void 
		{
			if (this.has_major)
			{
				this.addToMajorAxis(this._data[AXIS_RENDER][AXIS_BEGIN]);
				this.addToMajorAxis(this._data[AXIS_RENDER][AXIS_END]);
				if ((this._data[AXIS_RENDER][AXIS_TARGET] != null) && (this._hasMajor))
				{
					this.addToMajorAxis(this._data[AXIS_RENDER][AXIS_TARGET],TARGET);
				}
				this._tickArr.sortOn(TIC_VALUE,Array.NUMERIC);
				this.reIndex();
			}
		}

		protected function setFinishCoordinates():void 
		{
			this._data[AXIS_RENDER][AXIS_STARTX] = (this._boolVertical) ?  0 : this._data[AXIS_RENDER][AXIS_OFFSET];
			this._data[AXIS_RENDER][AXIS_STARTY] = (this._boolVertical) ? this._data[AXIS_RENDER][AXIS_OFFSET] : 0;
			this._data[AXIS_RENDER][AXIS_ENDX] = (this._boolVertical) ? 0: ((this.axis_length) + this._data[AXIS_RENDER][AXIS_STARTX]);
			this._data[AXIS_RENDER][AXIS_ENDY] = (this._boolVertical) ? ((this.axis_length) + this._data[AXIS_RENDER][AXIS_STARTY]): 0;
		}		
		
		protected function addAxisLabel():void
		{
			var tempTF:TextField;
			
			// Create Axis Label
			this.name = this._data[AXIS_RENDER][AXIS_LABEL];
			tempTF = this.addLabel(this._data[AXIS_RENDER][AXIS_LABEL],this._data[AXIS_RENDER][AXIS_LABEL],TextFormatAlign.LEFT);
			this._data[AXIS_RENDER][AXIS_LABEL_HEIGHT] = TextFieldUtil.calcActualHeight(tempTF);
			
			// Update Positioning
			tempTF.x = 0;
			// Use same positioning as all labels, but account for alignment used for tickmarks
			tempTF.y = calcLabelPosY(tempTF,tempTF.y);
			tempTF.y += (this._boolVertical) ? (this._data[AXIS_RENDER][AXIS_LABEL_HEIGHT] / 2) : 0;
			
			this._axisLabel = tempTF;
			this.addDisplayObject(tempTF);
		}
		
		protected function addLabel(inLabel:String,inStr:String,inAlign:String=TextFormatAlign.LEFT):TextField
		{
			var tempTF:TextField;
			var formatLabel:String;
			var styleArr:Array = AXIS_STYLES;
			var tempStyle:String = AXIS_LABEL_CLASS + inLabel
			var tempBorderStyle:String = "";
			
			formatLabel = "<p class='" + tempStyle + "' align='" + inAlign + "'>" + inStr + "</p>";		
			// Classes require the "." prefix in the definition, but not the HTML class attribute
			tempBorderStyle = tempStyle = "." + tempStyle;
			tempBorderStyle += AXIS_LABEL_BORDER;
			styleArr.push(tempStyle);
			
			// Confirm presence of expected style definition.  This provides an error message, but a default style should probably be provided.
 			if (!this._style.hasStyles(styleArr))
			{
				this.sendError("Axis:  Missing CSS style for = " + this._style.missingStyles(styleArr));
			} else 
			{
				tempTF = TextFieldUtil.newTextField(formatLabel,this._style);					
				tempTF.border = this._style.hasStyle(tempBorderStyle);
				tempTF.borderColor = (tempTF.border) ? this.CSS_to_RGB(this._style.getStyle(tempBorderStyle).color) : 0x000000;
				//tempTF.autoSize = TextFieldAutoSize.LEFT;
				tempTF.multiline = (this._boolVertical) ? true : false;
				tempTF.selectable = false;
				if (this._boolVertical)
				{
					TextFieldUtil.resizeToActualWidth(tempTF);
				}
			}
			return tempTF;
		}
		
		protected function calcReducedAxisLength():void
		{
			var tickObj:Object;	
			var renderObj:Object;
			renderObj = this._data[AXIS_RENDER];
			
			// Determine height of the last label
			tickObj = this._tickArr[this._tickArr.length-1];
			renderObj[LAST_LABEL_HEIGHT] = Math.round(TextFieldUtil.calcActualHeight(tickObj[TIC_TEXT])/2);
			renderObj[AXIS_LABEL_WIDTH] = TextFieldUtil.calcActualWidth(this._axisLabel);
			
			// Adjust Axis to compensate for labels
			if (this._boolVertical)
			{	// Vertical
				renderObj[AXIS_STARTY] += renderObj[AXIS_LABEL_HEIGHT];
				renderObj[AXIS_LENGTH] -= renderObj[AXIS_STARTY];
				renderObj[AXIS_LENGTH] -= renderObj[LAST_LABEL_HEIGHT];
			} else
			{	// Horizontal
				renderObj[AXIS_OFFSET] = (renderObj[AXIS_OFFSET] > renderObj[AXIS_LABEL_WIDTH]) ? renderObj[AXIS_OFFSET] : renderObj[AXIS_LABEL_WIDTH];
				renderObj[AXIS_STARTX] = renderObj[AXIS_OFFSET];
				//renderObj[AXIS_LENGTH] -= renderObj[AXIS_TICK_WIDTH];
				//renderObj[AXIS_LENGTH] -= renderObj[AXIS_STARTX];
			}
		}
		
		protected function getCoordinates(inVal:Number):Object
		{
			var tempObj:Object;
			var valueRatio: Number;
			valueRatio = inVal / this._data[AXIS_RENDER][AXIS_RANGE];
		
			tempObj = new Object();
			tempObj.x = (this._boolVertical) ? this._data[AXIS_RENDER][AXIS_ENDX] : (this._data[AXIS_RENDER][AXIS_STARTX] + Math.round(this._data[AXIS_RENDER][AXIS_LENGTH] * valueRatio));
			tempObj.y = (this._boolVertical) ? (this._data[AXIS_RENDER][AXIS_STARTY] + (this._data[AXIS_RENDER][AXIS_LENGTH] - Math.round(this._data[AXIS_RENDER][AXIS_LENGTH] * valueRatio))) : this._data[AXIS_RENDER][AXIS_ENDY];
			tempObj.value = inVal;

			return tempObj;
		}

		protected function drawTickLabels():void 
		{
			var tempWidth:int;
			for (var i:int=0;i < this._tickArr.length; i++)
			{
				var labelWidth:int;			
				this.drawTickLabel(i);
				labelWidth = this._tickArr[i][TIC_TEXT].width;
				tempWidth = (labelWidth > tempWidth) ? labelWidth : tempWidth;
			}
			this._tickLabelWidth = tempWidth;
			this.normalizeTickMarkLabels(this._tickLabelWidth);
		}
		
		protected function defineOffsets():void 
		{
			// Define the offset used for the guidelines
			this._data[AXIS_RENDER][AXIS_LINE_OFFSET] = getAxisLineOffset();
					
			// Define the axis spacing base on the en dash
			this._data[AXIS_RENDER][AXIS_SPACER]  = TextFieldUtil.getCharWidth("i",this._style.getStyleTextFormat("." + AXIS_LABEL_CLASS + MINOR));
		}
		
		protected function drawAxisLine():void 
		{

			// Create axis line spans if there is statistics data
			if (this._data[AXIS_STATS])
			{			
				// Initiate the axis lines
				this._axis_lines = new GradientCell();	
				if (this._style.hasStyle(AXIS_LINE))
				{
					this._axis_lines.setRGB_CSS(this._style.getStyle(AXIS_LINE).color);
				}
				
				// Draw main axis
				this._axis_lines.lineThickness = 1;
				this._axis_lines.clear();


				var tempStep:int;
				var valueRatio:Number;
				
				// Creates gap around median of 5 pixels
				tempStep = Math.round(this._data[AXIS_RENDER][AXIS_PIXEL_VALUE] * 5);
				
				// Determine what percentage of the full axis range is represented by the 10% of a tick unit
				valueRatio = (2 * tempStep) / this._data[AXIS_RENDER][AXIS_RANGE];
				
				// Assign the gap size in pixels to the AXIS_MEDIAN_GAP
				this._data[AXIS_RENDER][AXIS_MEDIAN_GAP] = Math.round(this.axis_length * valueRatio);
				
				// Draw the points; max, min and median on the axis
				this._axisArr = new Array();
				this.addAxisPoint(this._data[AXIS_STATS][StatsUtil.VALUE_MIN]);
				this.addAxisPoint(this._data[AXIS_STATS][StatsUtil.VALUE_MAX]);
				this.addAxisPoint(this._data[AXIS_STATS][StatsUtil.VALUE_MEDIAN]);
				
				// Draw the Tufte quartile lines on the axis
				this.addAxisSegment(this._data[AXIS_STATS][StatsUtil.VALUE_Q1_LESS],this._data[AXIS_STATS][StatsUtil.VALUE_MEDIAN]-tempStep);
				this.addAxisSegment(this._data[AXIS_STATS][StatsUtil.VALUE_Q1_PLUS],this._data[AXIS_STATS][StatsUtil.VALUE_MEDIAN]+tempStep);
				this.addAxisSegment(this._data[AXIS_STATS][StatsUtil.VALUE_Q2_LESS],this._data[AXIS_STATS][StatsUtil.VALUE_Q1_LESS]-1);
				this.addAxisSegment(this._data[AXIS_STATS][StatsUtil.VALUE_Q2_PLUS],this._data[AXIS_STATS][StatsUtil.VALUE_Q1_PLUS]+1);

				// Place in start position
				for (var i:int=0;i < this._axisArr.length; i++)
				{
					var coorObj:Object;
					coorObj = this._axisArr[i];
					this._axis_lines.drawLine(coorObj[AXIS_ENDX],coorObj[AXIS_ENDY],coorObj[AXIS_STARTX],coorObj[AXIS_STARTY]);
				}
				this.addDisplayObject(this._axis_lines);
			}
			this.refreshLayout();
		}


		protected function calcTickSpan():void 
		{
			this._data[AXIS_RENDER][AXIS_TICK_SPAN] = (this.axis_length /(this._tickArr.length - 1));
		}

		protected function calcPixelValue():void 
		{
			this._data[AXIS_RENDER][AXIS_PIXEL_VALUE] = this._data[AXIS_RENDER][AXIS_RANGE] / this._data[AXIS_RENDER][AXIS_LENGTH];
		}
		
		protected function sendError(errorMsg:String):void
		{
			throw new Error(errorMsg);	
		}

		protected function findTick(inVal:Number,inArr:Array,inCount:int=0):int
		{
			var tempCount:int;
			var tempHalf:int;
			var tempPos:int;
			tempPos = -1;
			tempCount = inCount + 1;
			tempHalf = ((inArr.length > 0) && (inArr[0][TIC_VALUE] != undefined)) ? Math.sqrt(inArr.length) : -1;
			// sqrt of self is 1, this will cause an error with array length 1.
			tempHalf = (inArr.length == 1) ? 0 : tempHalf;

			if ((tempHalf > 0) && (inArr[tempHalf][TIC_VALUE] != inVal))
			{
				var tempArr:Array;
				tempArr = (inVal > inArr[tempHalf][TIC_VALUE])? inArr.slice(tempHalf,inArr.length) : inArr.slice(0,tempHalf);
				tempHalf = -1;
				tempPos = findTick(inVal,tempArr,tempCount);
			} else if (tempHalf == 0)
			{
				tempPos = (inArr[tempHalf][TIC_VALUE] != inVal) ? -1 : 0;
			}
			tempPos = ((tempPos < 0) && (tempHalf >= 0)) ? inArr[tempHalf][TIC_INDEX] : tempPos;
			return (tempPos >= 0) ? tempPos : -1;
		}
		
		protected  function addToAxis(inVal:Number,inSize:String=MINOR):void 
		{
			this.addToMajorAxis(inVal,inSize);
		}
		protected  function addToMajorAxis(inVal:Number,inSize:String=MAJOR):void 
		{
			var tempIndex:int;
			var tempTF:TextField;
			this._tickArr = (this._tickArr == null) ? new Array() : this._tickArr;
			tempIndex = this.findTick(inVal,this._tickArr);
			tempTF = this.addLabel(inSize,inVal.toString());
			if (tempIndex >= 0)
			{
				this._tickArr[tempIndex][TIC_SIZE] = inSize;
				this._tickArr[tempIndex][TIC_TEXT] = tempTF;			
			} else
			{				
				this._store.newObj();
				this._store.addNameValue(TIC_VALUE,inVal);
				this._store.addNameValue(TIC_LABEL,inVal.toString());
				this._store.addNameValue(TIC_TEXT,tempTF);
				this._store.addNameValue(TIC_SIZE,inSize);
				this._store.addNameValue(TIC_INDEX,0);
				this._tickArr.push(this._store.getObj());
			}
		}

		
		public function convertGuideLines(inLines:Array,inAlign:String):void 
		{
			var startPoint:Point;
			var endPoint:Point;
			var lineArr:Array;
			lineArr = new Array();
			startPoint = this.getPoint(this._data[AXIS_RENDER][AXIS_BEGIN]);
			endPoint = this.getPoint(this._data[AXIS_RENDER][AXIS_END]);
			for (var i:int=0;i < inLines.length; i++)
			{
				var tempObj:Object
				tempObj = new Object();
				if (inAlign == HORIZONTAL)
				{

					tempObj[AXIS_STARTX] = inLines[i].x;
					tempObj[AXIS_ENDX] = inLines[i].x;
					tempObj[AXIS_STARTY] = startPoint.y;
					tempObj[AXIS_ENDY] = endPoint.y;
				} else
				{
					tempObj[AXIS_STARTX] = startPoint.x,
					tempObj[AXIS_ENDX] = endPoint.x;
					tempObj[AXIS_STARTY] = inLines[i].x;
					tempObj[AXIS_ENDY] = inLines[i].x;
				}
				lineArr.push(tempObj);
			}
			this.drawLines(lineArr);
		}
		
		public function drawLines(inLines:Array):void 
		{
			for (var j:int=0;j < inLines.length; j++)
			{
				var guideObj:Object;
				guideObj = inLines[j];
				this._guide_lines.drawLine(guideObj[AXIS_ENDX],guideObj[AXIS_ENDY],guideObj[AXIS_STARTX],guideObj[AXIS_STARTY]);
			}
			this._guide_lines.refreshLayout();
			this.refreshLayout();
		}
		
		protected function drawGuideLine():void 
		{
			// Initiate the axis lines
			this._guide_lines = (this._guide_lines) ? this._guide_lines : new GradientCell();
			
			// Draw Guide Lines
			this._guide_lines.lineThickness = 1;
			this._guide_lines.clear();
			
			this._guideArr = new Array();
			this._guide_lines.lineThickness = 0;
			this._guide_lines.lineFade = 0;
			if (this._style.hasStyle(AXIS_GUIDE_LINE))
			{
				this._guide_lines.setRGB_CSS(this._style.getStyle(AXIS_GUIDE_LINE).color);
			}				
			
			// Draw tick guidelines
			this.addGuideLines();
								
			//Place in start position
			for (var j:int=0;j < this._guideArr.length; j++)
			{
				var guideObj:Object;
				guideObj = this._guideArr[j];
				this._guide_lines.drawLine(guideObj[AXIS_ENDX],guideObj[AXIS_ENDY],guideObj[AXIS_STARTX],guideObj[AXIS_STARTY]);
			} 

			this.addDisplayObject(this._guide_lines);
			this.refreshLayout();			
		}
		
		/******************************************************************************************************
		**  Private
		******************************************************************************************************/


		private function reIndex():void 
		{
			for (var i:int=0;i < this._tickArr.length; i++)
			{
				this._tickArr[i][TIC_INDEX] = i;
			}
		}

		private function normalizeTickMarkLabels(inInt:int):void
		{
			for (var i:int=0;i < this._tickArr.length; i++)
			{
				this._tickArr[i][TIC_TEXT].width = inInt;
			}				
		}


		private function drawTickLabel(inIndex:int):void 
		{
			var tickObj:Object;
			var tempObj:Object;
			tickObj = this._tickArr[inIndex];	
			tempObj = this.getCoordinates(tickObj[TIC_VALUE]);
			this._point.push(tempObj);
			tickObj[TIC_TEXT].x = tempObj.x;
			tickObj[TIC_TEXT].y = calcLabelPosY(tickObj[TIC_TEXT],tempObj.y);
			if ((this._boolVertical) || (this._data[AXIS_RENDER][AXIS_LENGTH] >= (tempObj.x + tickObj[TIC_TEXT].width)))
			{
				this.addDisplayObject(tickObj[TIC_TEXT]);
			}
		}
		
		private function calcLabelPosY(inTF:TextField,inPos:int):int
		{
			var tempPos:int;
			var labelHeight:int;
			labelHeight = TextFieldUtil.calcActualHeight(inTF);
			switch (this._data[AXIS_RENDER][AXIS_ALIGN])
			{
				case ALIGN_TOP:
					tempPos = inPos;
				break;
				case ALIGN_BOTTOM:
					tempPos = inPos + this._data[AXIS_RENDER][AXIS_GUIDE_LENGTH] - labelHeight;
				break;
				case ALIGN_LEFT:	
				case ALIGN_RIGHT:
					tempPos = (inPos - (labelHeight / 2));
				break;
				default:
					tempPos = 0;
				break;
			}
			return tempPos;
		}
		
		private function addGuideLines():void 
		{
			var tempObj:Object;
			var render:Object;
			render = this._data[AXIS_RENDER];
			
			for (var i:int=0;i < this._tickArr.length; i++)
			{
				var tempOffset:uint;

				tempOffset = render[AXIS_LINE_OFFSET];
				tempObj = this.getCoordinates(this._tickArr[i][TIC_VALUE]);

				// Create axis line spans if there is statistics data
				if (this._data[AXIS_STATS])
				{
					tempOffset += (3*render[AXIS_SPACER]);
				}

				tempOffset = (render[GUIDE_OFFSET] > tempOffset) ? render[GUIDE_OFFSET] : tempOffset;
				render[GUIDE_OFFSET] = tempOffset;

				// Adjust for axis positioning
				tempObj.x += (this._boolVertical) ? tempOffset : 0;
				tempObj.y += (this._boolVertical) ? 0 : tempOffset;
				
				tempObj[AXIS_ENDX] = tempObj[AXIS_STARTX] = tempObj.x;
				tempObj[AXIS_ENDY] = tempObj[AXIS_STARTY] = tempObj.y;
				if (this.show_guidelines)
				{
					// passed by pointer so no return necessary
					this.defineGuideLine(tempObj);
				} else
				{
					this.guide_length = 0;
				}
				this._guideArr.push(tempObj);
			}
			this._axisHeight = (this._boolVertical) ? this.axis_length : (this.guide_length + tempObj[AXIS_STARTX]);
			this._axisWidth = (this._boolVertical) ? (this.guide_length + tempObj[AXIS_STARTX]) : this.axis_length;
		}

		private function defineGuideLine(inObj:Object):void
		{
			switch (this._data[AXIS_RENDER][AXIS_ALIGN])
			{
				case ALIGN_TOP:
					inObj[AXIS_ENDX] += 0;
					inObj[AXIS_ENDY] += this.guide_length - inObj[AXIS_STARTY];
				break;
				case ALIGN_BOTTOM:
					inObj[AXIS_ENDX] -= 0;
					inObj[AXIS_ENDY] -= (this.guide_length - inObj[AXIS_STARTX]);
				break;
				case ALIGN_LEFT:
					inObj[AXIS_ENDX] += (this.guide_length - inObj[AXIS_STARTX]);
					inObj[AXIS_ENDY] += 0;
				break;
				case ALIGN_RIGHT:
					inObj[AXIS_ENDX] -= (this.guide_length - inObj[AXIS_STARTX]);
					inObj[AXIS_ENDY] -= 0;
				break;
				default:
					// Do Nothing
				break;
			}
		}
		
		private function addAxisPoint(inVal:Number):void
		{
			var tempObj:Object;
			tempObj = new Object();

			// define the axis array
			tempObj = this.getCoordinates(inVal);

			// Adjust for axis positioning
			tempObj = positionOffset(tempObj,this._data[AXIS_RENDER][AXIS_LINE_OFFSET]);

			tempObj[AXIS_ENDX] = tempObj[AXIS_STARTX] = tempObj.x;
			tempObj[AXIS_ENDY] = tempObj[AXIS_STARTY] = tempObj.y;
			tempObj[AXIS_ENDX] += (this._boolVertical) ? 0 : 1;
			tempObj[AXIS_ENDY] += (this._boolVertical) ? 1 : 0;
			this._axisArr.push(tempObj);
		}

		private function addAxisSegment(inStartVal, inEndVal):void
		{
			var tempPointStart:Point;
			var tempPointEnd:Point;
			var tempObj:Object;
			tempObj = new Object();			
			
			// define the axis array
			tempPointStart = this.getPoint(inStartVal);
			tempPointEnd = this.getPoint(inEndVal);
			
			tempObj[AXIS_STARTX] = tempPointStart.x;
			tempObj[AXIS_STARTY] = tempPointStart.y;
			tempObj[AXIS_ENDX] = tempPointEnd.x;
			tempObj[AXIS_ENDY] = tempPointEnd.y;

			this._axisArr.push(tempObj);
		}
	
		private function getAxisLineOffset():int
		{
			var tempOffsetX:int;
			var tempOffsetY:int;
			var tempOffset:int;
			
			tempOffset = (this._data[AXIS_RENDER][AXIS_LINE_OFFSET] == undefined) ? 0 : this._data[AXIS_RENDER][AXIS_LINE_OFFSET];
			tempOffsetX = (this._tickLabelWidth > this._axisLabel.width) ? this._tickLabelWidth : this._axisLabel.width;
			tempOffsetY = TextFieldUtil.calcActualHeight(this._axisLabel);
			
			switch (this._data[AXIS_RENDER][AXIS_ALIGN])
			{
				case ALIGN_TOP:
					tempOffset = tempOffsetY;
				break;
				case ALIGN_BOTTOM:
					tempOffset = 0;
				break;
				case ALIGN_LEFT:
					tempOffset = tempOffsetX;
				break;
				case ALIGN_RIGHT:
					tempOffset = -tempOffsetX;
				break;
				default:
					// Do Nothing
				break;
			}
			return tempOffset;
		}

		private function positionOffset(inObj:Object,inOffset:int):Object
		{
			switch (this._data[AXIS_RENDER][AXIS_ALIGN])
			{
				case ALIGN_TOP:
					inObj.y += inOffset;
				break;
				case ALIGN_BOTTOM:
					inObj.y -= inOffset;
				break;
				case ALIGN_LEFT:
					inObj.x += inOffset;
				break;
				case ALIGN_RIGHT:
					inObj.x -= inOffset;
				break;
				default:
					// Do Nothing
				break;
			}
			return inObj;
		}

	
		private function tufteOffset(inObj:Object,inVal:Number,inBegin:Number,inEnd:Number):Object
		{
			var rangeBool:Boolean;
			
			// Adjust for Tufte Axis 1st Quartile
			rangeBool = NumberUtil.rangeCheck(inVal,inBegin,inEnd,false);
			if 	(rangeBool && (inVal != this._data[AXIS_STATS][StatsUtil.VALUE_MEDIAN]))
			{
				// A Tufte access requires an offset of the axis line for the first and second quartile values.
				// So the AXIS_SPACER, proportional to the en dash, with label styling, is used.
				inObj = positionOffset(inObj,this._data[AXIS_RENDER][AXIS_SPACER]);
			}
			return inObj;
		}

    }
}