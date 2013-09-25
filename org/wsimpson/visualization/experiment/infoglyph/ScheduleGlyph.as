package org.wsimpson.visualization.experiment.infoglyph

/*
** Title:	ScheduleGlyph.as
** Purpose: Base class for all the glyphs used with the Flight_Schedule screen
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.display.DisplayObject;		
	import flash.display.MovieClip;	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	// UI
	import org.wsimpson.ui.Axis;
	import org.wsimpson.ui.Glyph;
	import org.wsimpson.ui.Meter;
	
	// Utitlies
	import org.wsimpson.util.DateUtil;
	import org.wsimpson.util.PointUtil;	
	import org.wsimpson.util.TransformUtil;	
	
	// Visualization Application Classes
	import org.wsimpson.interfaces.IGlyph
	
	public class ScheduleGlyph extends Glyph implements IGlyph
	{
		public static const DATA_TARGET_COLOR = 8;					// The fourth value is the maximum value allowed for the field
		public static const DEPARTURE = 1;							// Axis specified
		public static const ARRIVAL = 2;							// Axis specified
		public static const FLIGHT_TIME = 4;						// Axis specified
		public static const FARE_CLASS = 5;							// Axis specified
			
		// Public Instance Variables
		public var axis_x:Axis;
		public var axis_y:Axis;
		public var fixedHeight:Number;								// The designated height of the glyph
		public var fixedWidth:Number;								// The designated width of the glyph
		
		// Private Instance Variables
		private	var _def:XML;										// Glyph margin (Note this is used as a percentage)
		private var _startPoint:Point;								// Point calculated in external DisplayObject
		private var _startPointParent:DisplayObject;				// The external display object
		private var _endPoint:Point;								// Point calculated in external DisplayObject
		private var _endPointParent:DisplayObject;					// The external display object
		private var _vertical:Point;								// Point calculated in external DisplayObject
		private var _verticalPointParent:DisplayObject;				// The external display object
		private var _assignedBool:Boolean;							// Used for preloading
		
		// Constructor
		public function ScheduleGlyph(inDef:XML)
		{
			super();
			var tempArr:Array;
			this._def = inDef;
			tempArr = new Array();
			tempArr[HORIZONTAL] = this._def.attribute("width");
			tempArr[VERTICAL] = this._def.attribute("height");
			this.maxSize = tempArr;
			this._assignedBool = false;
			this._startPoint = null;
			this._endPoint = null;
		}
			
		/******************************************************************************************************
		**  Protected
		******************************************************************************************************/
		
		protected override function init():void
		{
			if (this._assignedBool)
			{
				this.positionBar();
				this.meter_4.colorAlpha = 25;
				super.init();
				this.showPlane();
			} else
			{
				addEventListener(Event.ENTER_FRAME, this.glyphOnEnterFrame);
			}
		}
		
		/******************************************************************************************************
		**  Public
		******************************************************************************************************/

	
		/**
		*  Name:  	addPoint
		*
		* @param inType	String	The orientation or meter being assigned
		* @param inParent	DisplayObject	Parent of the received position
		* @param inPoint	Point The position the glyph must align to.
		*/	
        public function addPoint(inType:String,inParent:DisplayObject,inPoint:Point):void
		{
			switch (inType)
			{
				case HORIZONTAL_START:
					this._startPoint = inPoint;
					this._startPoint.y = 0;
					this._startPointParent = inParent;
				break;
				case HORIZONTAL_END:
					this._endPoint = inPoint;
					this._endPoint.y = 0;					
					this._endPointParent = inParent;
				break;
				case VERTICAL.toString():
					this._vertical = inPoint;
					this._verticalPointParent = inParent;
				break;
				default:
					this.sendError("ScheduleGlyph.addPoint -> Unrecognized alignment value passed:  accepted values are axis values: HORIZONTAL_START, HORIZONTAL_END, VERTICAL.  Received -> inType " + inType);
				break;
			}
		}
		public function get assigned():Boolean
		{
			return this._assignedBool;
		}
		
		public function set assigned(inBool:Boolean):void
		{
			this._assignedBool = inBool;
		}
			
		/******************************************************************************************************
		**  EVENTS
		*******************************************************************************************************/
		/**
		*  Name:  	mouseEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public override function mouseEvent(inMC:MovieClip,event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.MOUSE_OUT:
					this.meter_4.highlight = false;
					this.meter_5.highlight = false;
					this.meter_6.highlight = false;
					this.moveBack();
				break;
				case MouseEvent.MOUSE_OVER:
					this.meter_4.highlight = true;
					if (this.meter_5.visible)
					{
						this.meter_5.highlight = true;
						this.meter_6.highlight = true;
					}
					this.moveFront();
				break;
				default:
					// do nothing
				break;
			}
		
			if (inMC is Meter)
			{
				if (event.type == MouseEvent.CLICK)
				{
					this.glyphButton.showButton();
				}
				super.trigger(event);
			} 
			super.mouseEvent(inMC,event);
		}
		
		public function glyphOnEnterFrame(event:Event):void
		{
			if (this._assignedBool)
			{
				removeEventListener(Event.ENTER_FRAME, this.glyphOnEnterFrame);	
				this.init();
			}
		}
		
		public override function reset():void
		{
			super.reset();
			this.rolloverStr = "";
			this.assignMeters(null);
			this._assignedBool = false;
			this.x = 0;
			this.y = 0;
			// Meter 6 is rotated horizontally so the positioning is differnt
			this.meter_6.scaleX = this.meter_6.scaleY = 1;
			this.meter_4.scaleX = this.meter_4.scaleY = 1;
			this.meter_6.x = this.meter_6.width;
			this.meter_6.y = this.meter_6.height;	
			
			// Update the size after the meters are reset to ensure original
			this.fixedHeight = this.maxSize[VERTICAL];
			this.fixedWidth = this.maxSize[HORIZONTAL];

			addEventListener(Event.ENTER_FRAME, this.glyphOnEnterFrame);
		}
			
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/
		private function showPlane()
		{
			this.glyphButton.hideButton();
			this.meter_5.showMeter();
			this.meter_6.showMeter();
			// if (this.data_array[FARE_CLASS] != undefined)
			// {
				// this.meter_5.showMeter();
				// this.meter_6.showMeter();
			// } else
			// {
				// this.meter_5.hideMeter();
				// this.meter_6.hideMeter();
			// }		
		}	

		private function positionVertically():void
		{
			var midpoint:Number;
			
			// Redefine vertical in terms of the ScheduleGlyph coordinates and center on that point
			midpoint = this.fixedHeight / 2;

			this._vertical = PointUtil.localToLocal(this._verticalPointParent,this,this._vertical);			
			this.y = this._vertical.y - midpoint;
		}
		
		private function positionBar()
		{
			var tempStart:Point;
			var tempEnd:Point;
			var tempDistance:Number;
			var buttonWidth:Number;
			var midpoint:Number;
			var meter_6Size:Number;
			var minBarScale:Number;
			var tempRatio:Number;

			// Before Scaling
			this.positionVertically();
				
			// Compare Distance Before and After localToLocal conversion
			tempEnd = PointUtil.localToLocal(this._endPointParent,this,this._endPoint);
			tempStart = PointUtil.localToLocal(this._startPointParent,this,this._startPoint);
			buttonWidth = this.fixedWidth / this.fullScale.scaleX;
			
			// Position the glyph to the arrival time
			this.moveScreenX((this._endPoint.x - this.fixedWidth));

			// Horizontally position meter_4 and meter_6 to the departure time
			tempDistance = -(tempEnd.x - tempStart.x) + this.fixedWidth;
			this.meter_4.moveScreenX(tempDistance);
			this.meter_6.moveScreenX(tempDistance);

 			// Scale meter_4 for displaying the duration 
			this.meter_4.screenWidth = -tempDistance + this.fixedWidth;
			this.meter_4.screenHeight = ((this.fixedHeight * this.fullScale.scaleX) * 2) / this.meter_4.height;

			// Update if meter_5 is not shown
			this.meter_4.screenWidth += (this.data_array[FARE_CLASS] == undefined) ? (2 * buttonWidth) : 0;

			// Set percentage following the intake of flight hours due to the resizing.		
			this.meter_4.setPercentHours(this.calcFlightPercent());
			
			// Scale rotated meter_6 for displaying layovers
			this.meter_6.x -= this.meter_6.width;  // compensate for rotation
			this.meter_6.screenWidth = this.meter_6.minWidth;
			this.meter_6.x += this.meter_6.width / 2;
			
			// Vertically position meter_4 and meter_6 at center using internal coordinate system
			midpoint = (this.fixedWidth / 2) / this.fullScale.scaleX;		
			this.meter_6.y = midpoint - (this.meter_6.height / 2);
			this.meter_4.y = midpoint - (this.meter_4.height / 2);
		}

		/******************************************************************************************************
		**  Private
		*******************************************************************************************************/
		
		private function calcFlightPercent():Number
		{
			var dateBegin:Date;
			var dateEnd:Date;
			var diff:Number;	
			
			// Define the dates
			dateBegin = new Date(this.data_array[DEPARTURE][DATA_RAW_VALUE]);
			dateEnd = new Date(this.data_array[ARRIVAL][DATA_RAW_VALUE]);
			diff = DateUtil.getTimeBetween(dateBegin,dateEnd,DateUtil.HOURS);	
			return 	(diff > this.data_array[FLIGHT_TIME][DATA_RAW_VALUE]) ?
					(this.data_array[FLIGHT_TIME][DATA_RAW_VALUE]/diff) :
					1;
		}
   }   
}