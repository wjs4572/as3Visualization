﻿package org.wsimpson.ui

/*
** Title:	DateAxis.as
** Purpose: Handles drawing and axis based on Date values for charts that are not tied to the AS3 Charts
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Enumeration
	import org.wsimpson.store.OrderStore;
	
	// Utitlies
	import org.wsimpson.util.DateUtil;
	import org.wsimpson.util.NumberUtil;;
	import org.wsimpson.util.StatsUtil;;
	import org.wsimpson.util.StringUtil;
	
	// Formats
	import org.wsimpson.format.DateFormat;
	
	// Styles
	import org.wsimpson.styles.Style;
	
	// Adobe
	import flash.text.TextField;
	
	public class DateAxis extends Axis
	{	
		// Axis Constants
		public static const DATE_MASK:String = "date_mask";		// Helps determine the 
				
		// Private Instance Variables
		private var _baseUnits:uint;		// Value indicating the date unit
		private var _dateFormat:DateFormat;	// Formats the Date value to a Mask

		// Constructor
		public function DateAxis(inDef:XML,inStyle:Style,inDesc:String)
		{
			super(inDef,inStyle,inDesc);
			this._definition = inDef;
			this._dateFormat = new DateFormat();
			this._dateFormat.mask  = (_definition.@[DATE_MASK] == undefined) ? "MM/DD hh:mm" : _definition.@[DATE_MASK];
		}

		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/

		/**
		*  Name:  	mask
		*  Purpose: Provides the format for the date
		*  Note:  The Axis object inherits from Sprite, which has a graphics property for "mask"
		*
		*/
		public function get format():String
		{
			return this._dateFormat.mask;
		}
		
		public function set format(inMask:String):void
		{
			this._dateFormat.mask = inMask;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*  Name:  	drawAxis
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/		
		 public override function drawAxis():void 
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
		public override function toXMLString():String
		{
			var tempObj:Object;	
			var tempStr:String;
			var tempStr2:String;
			tempStr = TEMPLATE_AXIS;
			tempStr2 = TEMPLATE_ATTRIBUTES;

			this._data[AXIS_RENDER][AXIS_TARGET] = this._dateFormat.format(new Date(this._data[AXIS_RENDER][AXIS_TARGET]));
			this._data[AXIS_RENDER][AXIS_BEGIN] = this._dateFormat.format(new Date(this._data[AXIS_RENDER][AXIS_BEGIN]));
			this._data[AXIS_RENDER][AXIS_END] = this._dateFormat.format(new Date(this._data[AXIS_RENDER][AXIS_END]));
			this._data[AXIS_RENDER][AXIS_RANGE] = this._dateFormat.formatRange(this._data[AXIS_RENDER][AXIS_RANGE]);
			this._data[AXIS_STATS][StatsUtil.VALUE_MIN] = this._dateFormat.format(new Date(this._data[AXIS_STATS][StatsUtil.VALUE_MIN]));
			this._data[AXIS_STATS][StatsUtil.VALUE_MAX] = this._dateFormat.format(new Date(this._data[AXIS_STATS][StatsUtil.VALUE_MAX]));
			this._data[AXIS_STATS][StatsUtil.VALUE_MEAN] = this._dateFormat.format(new Date(this._data[AXIS_STATS][StatsUtil.VALUE_MEAN]));
			this._data[AXIS_STATS][StatsUtil.VALUE_MEDIAN] = this._dateFormat.format(new Date(this._data[AXIS_STATS][StatsUtil.VALUE_MEDIAN]));
			this._data[AXIS_STATS][StatsUtil.VALUE_MODE] = this._dateFormat.format(new Date(this._data[AXIS_STATS][StatsUtil.VALUE_MODE]));
			tempObj = this._store.convertNameValue(this._data[AXIS_RENDER]);
			
			tempStr = tempStr.replace(renderPattern,this._store.toXMLString(tempObj));
			tempStr2 = tempStr2.replace(labelPattern,StringUtil.doubeQuoteStr(this._data[AXIS_RENDER][AXIS_LABEL]));		
			tempStr = tempStr.replace(attributePattern,tempStr2);
			tempObj = this._store.convertNameValue(this._data[AXIS_STATS]);
			tempStr = tempStr.replace(statsPattern,this._store.toXMLString(tempObj));
			tempStr = tempStr.replace(guidelinesPattern, this._store.storeArrayXMLStr(this._guideArr));
			tempStr = tempStr.replace(pointsPattern, this._store.storeArrayXMLStr(this._point));
			tempStr = tempStr.replace(ticksPattern,this._store.storeArrayXMLStr(this._tickArr));
			if ((this._axisArr) && (this._axisArr.length > 0))
			{
				tempStr = tempStr.replace(tuftePattern,this._store.storeArrayXMLStr(this._axisArr));
			}			
			return tempStr;
		}

		/******************************************************************************************************
		**  Protected
		******************************************************************************************************/

		protected override function defineMinorAxis():void 
		{
			var dateBegin:Date;
			var dateEnd:Date;
			var tickUnits:Array;
			var tempTF:TextField;		
			
			// Define the dates
			dateBegin = new Date(this._data[AXIS_RENDER][AXIS_BEGIN]);
			dateEnd = new Date(this._data[AXIS_RENDER][AXIS_END]);
			
			this.tick_value = (this.tick_value == 0) ? DateUtil.calcFactor(dateBegin,dateEnd,this.max_ticks) : this.tick_value;

			tickUnits = DateUtil.getTimeUnitRange(dateBegin,dateEnd,this.tick_value);

			if (tickUnits[tickUnits.length -1] > dateEnd)
			{
				tickUnits.pop();
			}
				
			// Initialize the array
			this._minorArr = (this._minorArr == null) ? new Array() : this._minorArr;			
			this._tickArr = (this._tickArr == null) ? new Array() : this._tickArr;
			
			if (tickUnits.length > 1)
			{
				// If the tick_value was never defined this will define it.
				this.tick_value = tickUnits[1].getTime() - tickUnits[0].getTime();
				this.setRange(tickUnits[(tickUnits.length - 1)].getTime() - tickUnits[0].getTime());

				for (var i:int=0; i < tickUnits.length;i++) 
				{
					var tempStr:String;
					this._store.newObj();
					this._store.addNameValue(TIC_VALUE,tickUnits[i]);
					tempStr = this._dateFormat.format(this._store.getValue(TIC_VALUE) as Date);			
					tempTF = this.addLabel(MINOR,tempStr);
					this._store.addNameValue(TIC_LABEL,tempStr);
					this._store.addNameValue(TIC_TEXT,tempTF);
					this._store.addNameValue(TIC_SIZE,MINOR);
					this._store.addNameValue(TIC_INDEX,i);
					this._tickArr[i] = this._store.getObj();
					this._minorArr.push(this._store.getValue(TIC_VALUE) as Date);
				}
			} else
			{
				sendError("DateArray:  Failure to identify tick units of measurement - tickUnits.length = " + tickUnits.length);
			}
 		}
		
		protected override function addToMajorAxis(inVal:Number,inSize:String=MAJOR):void 
		{
			var tempIndex:int;
			var tempStr:String;			
			var tempTF:TextField;
			this._tickArr = (this._tickArr == null) ? new Array() : this._tickArr;
			tempIndex = this.findTick(inVal,this._tickArr);
			tempStr = this._dateFormat.format(new Date(inVal));
			tempTF = this.addLabel(inSize,tempStr);			
			if (tempIndex >= 0)
			{
				this._tickArr[tempIndex][TIC_SIZE] = inSize;
				this._tickArr[tempIndex][TIC_VALUE] = inVal;				
				this._tickArr[tempIndex][TIC_LABEL] = tempStr;				
				this._tickArr[tempIndex][TIC_TEXT] = tempTF;		
			} else
			{				
				this._store.newObj();
				this._store.addNameValue(TIC_VALUE,inVal);
				this._store.addNameValue(TIC_LABEL,tempStr);
				this._store.addNameValue(TIC_TEXT,tempTF);
				this._store.addNameValue(TIC_SIZE,inSize);
				this._store.addNameValue(TIC_INDEX,0);
				this._tickArr.push(this._store.getObj());
			}
		}
		
		protected override function getCoordinates(inVal:Number):Object
		{
			var tempObj:Object;
			var tempVal:uint;
			var tempRange:uint;
			var tempOffset:uint;
			var valueRatio: Number;
			
			tempOffset = this._tickArr[0][TIC_VALUE];
			tempRange = this._data[AXIS_RENDER][AXIS_RANGE];
			tempVal = inVal - tempOffset;
			valueRatio = tempVal / tempRange;
	
			tempObj = new Object();
			tempObj.x = (this._boolVertical) ? this._data[AXIS_RENDER][AXIS_ENDX] : (this._data[AXIS_RENDER][AXIS_STARTX] + Math.round(this._data[AXIS_RENDER][AXIS_LENGTH] * valueRatio));
			tempObj.y = (this._boolVertical) ? (this._data[AXIS_RENDER][AXIS_STARTY] + (this._data[AXIS_RENDER][AXIS_LENGTH] - Math.round(this._data[AXIS_RENDER][AXIS_LENGTH] * valueRatio))) : this._data[AXIS_RENDER][AXIS_ENDY];	
			tempObj.value = inVal;
			tempObj.formatted = this._dateFormat.format(new Date(inVal));;
			
			return tempObj;
		}
		
		/******************************************************************************************************
		**  Private
		******************************************************************************************************/

    }
}