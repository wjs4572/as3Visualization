package org.wsimpson.visualization.experiment.screen
/*
** Title:	Flight_Schedule.as
** Purpose: Interactive for selecting color scales
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe UI
    import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;	
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;

	// Utitlies
	import org.wsimpson.util.DateUtil;
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.DispalyObjectContainerUtil;
	import org.wsimpson.util.ImageUtil;	
	import org.wsimpson.util.NumberUtil;
	import org.wsimpson.util.PointUtil;		
	import org.wsimpson.util.StatsUtil;
	import org.wsimpson.util.StringUtil;
	
	// Managers
	import org.wsimpson.visualization.experiment.infoglyph.manager.ScheduleGlyphManager;
	
	// UI Classes
	import org.wsimpson.ui.Axis;
	import org.wsimpson.ui.cell.Cell;
	import org.wsimpson.ui.ButtonBase;	
	import org.wsimpson.ui.DateAxis;
	import org.wsimpson.ui.DisplayArea;	
	import org.wsimpson.ui.GlyphConst;
	import org.wsimpson.ui.Overlay;
	import org.wsimpson.ui.Resizable;
	import org.wsimpson.ui.screen.ExtendedScreen;
	import org.wsimpson.ui.screen.Screen;

	// Style Definitions
	import org.wsimpson.styles.Style;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.button.ButtonRectangle;	
	import org.wsimpson.visualization.experiment.infoglyph.GlyphModel;
	import org.wsimpson.visualization.experiment.infoglyph.ScheduleGlyph;
	import org.wsimpson.visualization.experiment.ScreenModel;	
	import org.wsimpson.visualization.experiment.ScreenView;
	
	public class Flight_Schedule extends ExtendedScreen
	{
		// Contant values
		public static const GLYPH_DEFINITION = "glyph definitions";	// Screen Resource files
		public static const GLYPH_OVER_DETAILS = "glyph over";		// Screen Resource files
		public static const GLYPH_DISPLAY = "glyph display";		// Screen Resource files
		public static const GLYPH_SCREEN = "glyph screen";			// Screen Resource files
		public static const GLYPH_TARGETS = "glyph targets";		// Screen Resource files
		public static const GLYPH_OVERLAY = "overlay background";	// Screen Resource files
		public static const GLYPH_INTRO = "overlay instructions";	// Screen Resource files
		public static const GLYPH_IMAGE = "overlay image";			// Screen Resource files
		public static const GLYPH_LABLED = "labeled_glyph";			// Screen Resource files
		public static const GLYPH_MARGIN = "margin";				// Glyph Style
		// Events
		public static const MSG_START = "glyph_start";				// Glyph specific start
		public static const MSG_OVER = "glyph_over";				// Glyph specific mouse over
		public static const MSG_SELECTED = "glyph_selected";		// Glyph selected
		// Axis Fields Expected
		public static const AXIS_DEPARTURE = "departure";			// Axis specified
		public static const AXIS_ARRIVAL = "arrival";				// Axis specified
		public static const AXIS_COST = "cost";						// Axis specified
		
		// Overlay Indec
		public static const GLYPH_OVERLAY_INDEX = {"overlay background":0, "overlay instructions":1, "overlay image":2};
		
		// UI
		public static const TASK_GLYPH = "Task_Glyph";				// The configuration attributes for the displayed glyphs
		public static const NAV_GLYPH = "Glyph";					// Glyph Selected button (use with CSS)
		public static const NAV_START = "Start";					// Navigation button (use with CSS)
		public static const INTR_STYLE = "Instructions Style";		// Screen layout tranition definition name	
		public static const INTR_TEXT = "Instructions Text";		// Screen layout tranition definition name
		public static const OBJECT_STYLE = "style";					// Data Structure entry
		public static const OBJECT_DESC = "description";			// Data Structure entry
		public static const OBJECT_CONTENT = "content";				// Data Structure entry
		public static const OBJECT_TARGET = "target";				// Data Structure entry
		public static const AXIS_LABEL_DEPARTURE = 
			"axis_label_departure";									// Data Structure entry
		public static const AXIS_LABEL_ARRIVAL = 
			"axis_label_arrivall";									// Data Structure entry
		public static const AXIS_LABEL_COST = "axis_label_cost";	// Data Structure entry		

		// XML Definition
		private static const TEMPLATE_AXIS = 
			"\t<axes>\n\t\t<data>\n\t\t\t{MESSAGE}\n\t\t</data>\n\t</axes>";
		private static const TEMPLATE_GLYPHS = 
			"\t<glyphs>\n\t\t<data>\n\t\t\t{MESSAGE}\n\t\t</data>\n\t</glyphs>";
		private static const TEMPLATE_ROLLOVER = 
			"\t<rollover id=\"" + GlyphConst.GLYPHS_ID + "\">\n\t\t{MESSAGE}\n\t</rollover>";
		private static const TEMPLATE_SELECTION = 
			"\t<selection id=\"" + GlyphConst.GLYPHS_ID + "\">\n\t\t{MESSAGE}\n\t</selection>";	
		private static const TEMPLATE_START = 
			"\t<start>\n\t\t{MESSAGE}\n\t</start>";		
		
		// MVC 
		// Note: glyphModel is a model specific to the glyphs and not part of the parent screen player
		private var glyphModel:GlyphModel;				// Data model for displaying the glyphs
 		private var view:ScreenView;					// The View of MVC
			
		/*
		**	Private Instance Variables 
		*/
		//  Internal use 
 		private	var _debugger:DebugUtil;				// Output and diagnostic window
		private var _style:Style;						// Defines the display objectstyles used for the axes
		private	var _startButton:ButtonRectangle;		// Start Button
		private	var _glyphDetailsStr:String;			// Default details HTML
		private var targetObj:Object;					// Associative Array of Glyphs
		
		// Stage UI
		private	var screen:XML;							// References the active stage
		private	var displayDAName:String;				// Definition name for the DA displaying the display
		private	var detailsDAName:String;				// Definition name for the DA displaying the details
		private	var targetDAName:String;				// Definition name for the DA displaying the details
		private var axesObj:Object;						// The display axes
		private	var targetTF:TextField;					// Target Data to Display to display
		private	var detailsTF:TextField;				// Details to display
 		private var overlayText:TextField;				// Textfield for the overlay
		private var _clicked:Boolean;					// Prevent double clicks
		private var _labeledGlyph:String;				// Display object with labels
		private var _targetStr;							// The target string for between rollovers
		
		// Text Displays
		private var instrArr:Array;						// Instructions text display
		
		// Glyphs
		private var glyphArr:Array;						// Array of Glyphs
		private var glyphObj:Object;					// Associative Array of Glyphs
		private	var glyphMargin:String;					// Glyph margin (Note this is used as a percentage)
		private var _glyphManager:ScheduleGlyphManager; // Ensures previously rendered Glyphs don't get recreated.
		
		// In Files
		private	var _glyphDetailsTemplate:String;		// Template for rollover details HTML	
		private	var glyphData:XML;						// Glyph data
		private	var glyphDef:XML;						// Glyph definition
		private var _taskGlyph:XML;						// Defines glyph configuration parameters
		private var _viewBool:Boolean;					// The view has been created
		private var _addedGlyphs:Boolean;				// The glyphs are on the displayList

		// Patterns
		private var _idPattern:RegExp;				// Regular Expression pattern
		private var _indexPattern:RegExp;			// Regular Expression pattern
		private var _dataPattern:RegExp;			// Regular Expression pattern
		
		/**
		*  Name:  	Constructor
		*  Purpose:	Creates a screen from the imported XML
		*
		*	@param inView ScreenView From design pattern, MVC, the View for UI
		*	@param screenXML XML XML definition for the screen to display
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function Flight_Schedule(inView:ScreenView,screenXML:XML)
		{
			super();
			this._debugger = DebugUtil.getInstance();
	
			// Define Patterns
			this._idPattern = new RegExp(GlyphConst.GLYPHS_ID);
			this._indexPattern = new RegExp(GlyphConst.GLYPHS_FIELD_INDEX);
			this._dataPattern = new RegExp(GlyphConst.GLYPHS_MSG);
			this._viewBool = false;
			this._addedGlyphs = false;
			this._clicked = false;
		
			// Set the stage
			this.view = inView;  // Need boundry object
			
			// Assign the display XML
			this.screen = screenXML;
			this._glyphDetailsStr = "";
			this.targetDAName = "";
			
			// Store for TextFields created
			this.targetObj = new Object();
			
			// Manages display order of the Overlay elements
			this.instrArr = new Array();
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
		
		/**
		*  Name:  	onLabeled
		*  Purpose:  When the overlay has completed drawing display the start button.
		*/				
		private function onLabeled(event:Event):void
		{
			if (this._addedGlyphs)
			{
				this.daObj[this._labeledGlyph].removeEventListener(Event.ENTER_FRAME, this.onLabeled);
				
				// Start the task
				this._startButton.showButton();
			}
		}

		/**
		*  Name:  	onEnterFrame
		*  Purpose:  This event indicates that the screen has been loaded to the stage.
		*/				
		private function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (!this._viewBool)
			{
				this.init();
			}
		}
		
		
		/**
		*  Name:  	leaveScreen
		*  Purpose:  The glyph has been selected.
		*/		
 		public override function leaveScreen():void
		{
 			for (var targetStr:String in this.daObj)
			{
				if (this.daObj[targetStr])
				{
					this.daObj[targetStr].leaveStage();	
				}
				//DispalyObjectContainerUtil.removeAllChildren(this.daObj[targetStr]);
				if (this.daObj[targetStr].parent != null)
				{
					this.daObj[targetStr].parent.removeChild(this.daObj[targetStr]);
				}
			}
		}

		/**
		*  Name:  	mouseEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public function mouseEvent(inMC:MovieClip,event:Event):void {

			switch(event.type)
			{
				case flash.events.MouseEvent.CLICK:
				case flash.events.MouseEvent.DOUBLE_CLICK:
					this.clickEvent(inMC);
				break;
				case flash.events.MouseEvent.MOUSE_OVER:
					this.rolloverEvent(inMC);
				break;
				case flash.events.MouseEvent.MOUSE_OUT:
					this.rolloutEvent();
				break;
				default:
					this._debugger.warningTrace("Unexpected Mouse Event in Glyphs: " + event.type);
				break;
			}
		}
		
		public function resetScreen(event:Event):void {
			this.detailsTF.htmlText = this._glyphDetailsStr;	
		}
		
		/**
		*  Name:  	clickEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public function clickEvent(inMC:MovieClip):void {
			var tempMsg:String;	
			switch(inMC.buttonLabel)
			{
				case NAV_START:
			
					// Screen complete
					this.view.fadeInScreen();
					
					tempMsg = this.view.retrieveMessage(MSG_START);
					this.reportMouseEvent(tempMsg,TEMPLATE_START);		
					this._startButton.state = ButtonBase.BUTTON_HIDDEN;
					this.hideOverlay();
				break;
				case NAV_GLYPH:
					tempMsg = this.view.retrieveMessage(MSG_SELECTED);
					this.reportMouseEvent(tempMsg,TEMPLATE_SELECTION,inMC.parent[GlyphConst.GLYPH_ID]);
					if (!this._clicked)
					{
						tempMsg = this.glyphModel.toXMLString();
						this.reportMouseEvent(tempMsg,TEMPLATE_GLYPHS,inMC.parent[GlyphConst.GLYPH_ID]);
						tempMsg = this.axesObj[AXIS_COST].toXMLString() + this.axesObj[AXIS_DEPARTURE].toXMLString() + this.axesObj[AXIS_ARRIVAL].toXMLString();
						this.reportMouseEvent(tempMsg,TEMPLATE_AXIS,inMC.parent[GlyphConst.GLYPH_ID]);
						this.view.nextPage();
					}
					this._clicked = true;
				break;
				default:
					this._debugger.warningTrace("Unexpected Button Click in Glyphs: " + inMC.buttonLabel);
				break;
			}
		}
		
		/**
		*  Name:  	rolloutEvent
		*  Purpose:  An roll out has occurred with a button.
		*/
        public function rolloutEvent():void
		{
			this.targetTF.htmlText = _targetStr;
			this.detailsTF.htmlText = "";
		}


		/**
		*  Name:  	rolloverEvent
		*  Purpose:  An roll over event has occurred with a button.
		*/
        public function rolloverEvent(inMC:MovieClip):void
		{
			var tempMsg:String;

			switch(inMC.buttonLabel)
			{
				case NAV_GLYPH:
					// update the details
					tempMsg = this.view.retrieveMessage(MSG_OVER);
					this.detailsTF.htmlText = this.glyphObj[inMC.parent[GlyphConst.GLYPH_ID]].rolloverStr;
					this.targetTF.htmlText = this.glyphObj[inMC.parent[GlyphConst.GLYPH_ID]].targetStr;
					this.reportMouseEvent(tempMsg,TEMPLATE_ROLLOVER,inMC.parent[GlyphConst.GLYPH_ID]);
				break;
				case NAV_START:
					// do nothing
				break;
				default:
					this._debugger.warningTrace("Unexpected Button Rollover in Glyphs:  " + inMC.buttonLabel);
				break;
			}	
		}
		
		
		 
		/******************************************************************************************************
		**  Private
		******************************************************************************************************/

		// Returns the files contained here
		private function reportMouseEvent(inMsg:String,inTemplateStr:String,inID:String=""):void
		{
			var tempStr:String;
			tempStr = inTemplateStr;
			if (inID != "")
			{
				tempStr = tempStr.replace(this._idPattern,inID);
			}
			tempStr = tempStr.replace(this._dataPattern,this.view.recordEventTemplate(inMsg));
			this.view.recordEvent(tempStr);
		}
		
		// Returns the files contained here
		private function init():void
		{
			var fileXMLList:XMLList;

			this._viewBool = true;
			this.visible = true;
			
			fileXMLList = retrieveFiles();
			
			for each (var introFile:XML in fileXMLList)
			{
				var contentStr:String;		// Content included by the file reference
				var descStr:String;			// Content Description
				var fileIDStr:String;		// File reference
				var targetStr:String;		// Name of the target display area
				var tempStyle:Style; 		// Display area style
				var	styleObj:Object;		// Object containing the style parameters
				
				targetStr = introFile.@target.toString();
				fileIDStr = introFile.@content.toString();
				
				switch(fileIDStr)
				{
					case GLYPH_DEFINITION:
						this.glyphDef = new XML(this.view.model.retrieveFile(introFile.toString()));
					break;
					case GLYPH_OVER_DETAILS:
						/**
						** @tip This value doesn't go through the stripPrettyPrinting from the TextUtil.addTextField, because it assigned on rollover
						*/
						this._glyphDetailsTemplate = StringUtil.stripPrettyPrinting(this.view.model.retrieveFile(introFile.toString()).toString());
					break;
					case GLYPH_DISPLAY:									
						// Add the Display Area
						this.glyphData = new XML(this.view.model.retrieveFile(introFile.toString()));
						this.displayDAName = targetStr;
					case GLYPH_TARGETS:
						this.targetDAName = (fileIDStr == GLYPH_TARGETS) ? targetStr : this.targetDAName;
					case GLYPH_SCREEN:

						// Create Textfield
						contentStr = this.view.model.retrieveFile(introFile.toString()).toString();
						descStr = introFile.@desc.toString();
						tempStyle = this.view.model.retrieveStyle(introFile.@style);
						
						// Define the default values
						if (fileIDStr == GLYPH_SCREEN)
						{
							this.detailsDAName = targetStr;
							this._glyphDetailsStr = contentStr;
						}	

						// Add the Display Area	
						this.addDA(targetStr,contentStr,descStr,tempStyle);
						
						if (fileIDStr == GLYPH_DISPLAY)
						{
							//this.daObj[targetStr].addEventListener(flash.events.MouseEvent.MOUSE_OUT,resetScreen);
							this.daObj[targetStr].mouseEnabled = false;
							styleObj = tempStyle.getStyle(targetStr.toLowerCase());
							this.glyphMargin = styleObj[GLYPH_MARGIN];
						}
					break;
					case GLYPH_IMAGE:
					case GLYPH_OVERLAY:
					case GLYPH_INTRO:	
						contentStr = (fileIDStr == GLYPH_IMAGE) ? GLYPH_LABLED :
										this.view.model.retrieveFile(introFile.toString()).toString();
						// Create Overlay entries to be added later.
						descStr = introFile.@desc.toString();
						tempStyle = this.view.model.retrieveStyle(introFile.@style);
						this.addOverlayDA(fileIDStr,targetStr,contentStr,descStr,tempStyle);
					break;
					default:
						this.view.reportError(ScreenModel.GLYPH_CONTENT_TYPE,"Content = " + fileIDStr);
					break;
				}
				
				this.addTarget(fileIDStr,targetStr);				
			}
			
			// Add Overlay to hide the glyphs until loaded
			this.createOverlay();
			// Populate targets
			this.createSearchResults();
			// Add the Glyph Visualization
			this.deployScreen();
			// If this is the first screen fade in required
			this.view.fadeInScreen();
		}
		
		private function hideOverlay():void
		{
			var targetStr:String;		// Name of the target display area

			// Create Overlay DA
			for (var i=0; i < this.instrArr.length; i++)
			{
				targetStr = this.instrArr[i][OBJECT_TARGET];
				this.daObj[targetStr].hideDisplayArea();
			}
		}

		private function updateFieldString(inStr:String,inIndex:int,inNameStr:String,inValueStr:String,inColorStr:String):String
		{
			var fieldPattern:RegExp;
			var valuePattern:RegExp;	
			var colorPattern:RegExp;	
			var fieldStr:String;
			var valueStr:String;
			var colorStr:String;
			colorStr = GlyphConst.GLYPHS_FIELD_COLOR;
			colorPattern = new RegExp(colorStr.replace(this._indexPattern,inIndex),"g");			
			valueStr = GlyphConst.GLYPHS_FIELD_VALUE;
			valuePattern = new RegExp(valueStr.replace(this._indexPattern,inIndex),"g");
			fieldStr = GlyphConst.GLYPHS_FIELD_NAME;
			fieldPattern = new RegExp(fieldStr.replace(this._indexPattern,inIndex),"g");
			inStr = inStr.replace(valuePattern,inValueStr);
			inStr = inStr.replace(fieldPattern,inNameStr);
			inStr = inStr.replace(colorPattern,inColorStr);
			return inStr;
		}

		// This should probably be moved elsewhere
		private function getTargetValue(inObj:Object,inID:String):String
		{
			var tempStr:String;
				switch(inID)
				{
					case "3":
						tempStr = "cheapest";
					break;					
					case "4":
						tempStr = "shortest";
					break;
					case "6":
						tempStr = "fewest stops";
					break;
					case "1":
					case "2":
					case "5":
					default:
						tempStr = inObj[inID].value;
					break;
				}
			return tempStr;
		}
		private function createSearchResults():void
		{
			var tempHTML:String;
			var tempObj:Object;
			tempHTML = this.targetTF.htmlText;
			this.glyphModel = new GlyphModel(this.glyphDef,this.glyphData);	
			tempObj = this.glyphModel.getTargetValues();
			
			for (var fieldID:String in tempObj)
			{
				tempHTML = this.updateFieldString(tempHTML,int(fieldID),tempObj[fieldID].label,tempObj[fieldID].value,tempObj[fieldID].color);
			}		
			this.targetTF.htmlText = _targetStr = StringUtil.replaceTabs(tempHTML);
		}

		private function createOverlay():void
		{
			var contentStr:String;		// Content included by the file reference
			var descStr:String;			// Content Description
			var targetStr:String;		// Name of the target display area
			var tempStyle:Style; 		// Display area style

			// Create Overlay DA
			for (var i=0; i < this.instrArr.length; i++)
			{
				targetStr = this.instrArr[i][OBJECT_TARGET];
				contentStr = this.instrArr[i][OBJECT_CONTENT];
				descStr = this.instrArr[i][OBJECT_DESC];
				tempStyle = this.instrArr[i][OBJECT_STYLE];					
				// Add the Display Area	
				this.addDA(targetStr,contentStr,descStr,tempStyle);
			}

			// Create a matching Transition Overlay
			this.addStartButton();
		}
		
		private function deployScreen():void
		{	
			// Display the glyphs for the flight schedule
			this.createAxes(this.targetObj[GLYPH_DISPLAY]);	
			this.displayGlyphs(this.targetObj[GLYPH_DISPLAY]);
			this._addedGlyphs = true;
		}
		
		private function addStartButton():void
		{
			this._startButton = new ButtonRectangle();
			this.addChild(this._startButton);
			// Center the button and place near the bottom
			this._startButton.x = (this.parent.width / 2) - (this._startButton.width /2);
			this._startButton.y = this.parent.height - (this._startButton.height + 10);
			
			this._startButton.style = this.view.model.retrieveStyle(ScreenView.DEFAULT_STYLESHEET);
			this._startButton.buttonLabel = NAV_START;
			this._startButton.addButtonListener(this.mouseEvent);
			this._startButton.hideButton();
		}
		
		// Returns the files contained here
		private function addTarget(in_DA:String,in_target:String):void
		{
			this.targetObj[in_DA] = in_target;
			this.targetObj[in_target] = in_DA;
		}
		
		// Returns the files contained here
		private function addOverlayDA(inFileID:String,targetStr:String,inContent:String,inDesc:String,inStyle:Style):void		
		{
			var tempIndex:uint;
			tempIndex = GLYPH_OVERLAY_INDEX[inFileID];
	
			if (!this.instrArr[tempIndex])
			{
				this.instrArr[tempIndex] = new Object();
				this.instrArr[tempIndex][OBJECT_TARGET] = targetStr;
				this.instrArr[tempIndex][OBJECT_CONTENT] = inContent;
				this.instrArr[tempIndex][OBJECT_DESC] = inDesc;
				this.instrArr[tempIndex][OBJECT_STYLE] = inStyle;
			}
			else
			{
				this.view.reportError(ScreenModel.GLYPH_CONTENT_TYPE,"Overlay index already used = " + inFileID);
			}
		}
		
		// Returns the files contained here
		private function retrieveFiles():XMLList
		{
			return this.screen..file;
		}
	
		private function addDA(targetStr:String,inContent:String,inDesc:String,inStyle:Style):void
		{
			var defXML:XML; 		// definition for the display area
			var styleObj:Object; 	// Object containing Stylesheet information
			var tempDA:DisplayArea; // Display area
			var tempTF:TextField;	// TextField defined	
		
			if (inStyle.hasStyle(targetStr.toLowerCase()))
			{
				if ((targetStr != null) && (this.daObj[targetStr] == null))
				{
					// Target Display Area
					defXML = this.view.model.retrieveDef(targetStr);	
					styleObj = inStyle.getStyle(targetStr.toLowerCase());

					this.addDisplayArea(targetStr,defXML,inDesc,styleObj);
				
					if (inContent != GLYPH_LABLED)
					{
						// Add TextField to the Display Area
						tempTF = this.addTextField(inContent,inStyle);
						tempTF.width = this.daObj[targetStr].display_width();
						if (targetStr == this.detailsDAName)
						{
							this.detailsTF = tempTF;
							this.detailsTF.wordWrap = false;
						} else if (targetStr == this.targetDAName)
						{
							this.targetTF = tempTF;
							this.targetTF.wordWrap = false;
						}
						this.daObj[targetStr].addDisplayObject(tempTF);
					} else
					{
						var tempDO:Bitmap;
						tempDO = ImageUtil.duplicateImage(this.view.model.retrieveFile(GLYPH_LABLED) as Bitmap);
						this.daObj[targetStr].addDisplayObject(tempDO);
						
						this._labeledGlyph = targetStr;					
						this.daObj[targetStr].addEventListener(Event.ENTER_FRAME, this.onLabeled);
					}
				} else if (targetStr == null)
				{
					throw new Error("Glyphs Screen Display failed: Requires target display object definition");
				}
			} else
			{
				this.view.reportError(ScreenModel.STYLE_SCREEN_NOTFOUND,"Flight_Schedule->addDA:  Missing CSS style for = " + targetStr.toLowerCase());
			}
		}

		private function defineAxisValues(inFieldStr:String,inLowest:Number,inHighest:Number):void
		{
			// Get the field's target value
			this.axesObj[inFieldStr].label = inFieldStr;
			this.axesObj[inFieldStr].target_value = this.glyphModel.getFieldTarget(inFieldStr);

			// The axis low and high values
			this.axesObj[inFieldStr].axis_begin = inLowest;
			this.axesObj[inFieldStr].axis_end = inHighest;
			
			// Define actual value range
			this.axesObj[inFieldStr].statistics = this.glyphModel.getFieldStats(inFieldStr);			
		}
		
		private function defineTimeScale(inFieldStr:String):void
		{
			var range:int;
			var range_begin:Number;
			var range_end:Number;
			var dateValue:Date;		
			
			// Define Beginning based upon range defined for the departure
			range = this.glyphModel.getFieldStart(AXIS_DEPARTURE);
			dateValue = DateUtil.addTimeUnit(new Date(this.glyphModel.getFieldTarget(AXIS_DEPARTURE)),range,DateUtil.HOURS);
			range_begin = dateValue.time;
			
			// Define End based upon the range defined for the arrival
			range = this.glyphModel.getFieldEnd(AXIS_ARRIVAL);
			dateValue = DateUtil.addTimeUnit(new Date(this.glyphModel.getFieldTarget(AXIS_ARRIVAL)),range,DateUtil.HOURS);
			range_end = dateValue.time
		
			switch(inFieldStr)
			{
				case AXIS_ARRIVAL:
					this.defineAxisValues(AXIS_ARRIVAL,range_begin,range_end);
				break;
				case AXIS_DEPARTURE:
					this.defineAxisValues(AXIS_DEPARTURE,range_begin,range_end);
				break;
				default:
					this._debugger.warningTrace("FlightSchedule: defineTimeScale -> Unrecognized axis definitation " + inFieldStr);
				break;
			}
		}
		
		private function defineCostScale()
		{
			this.defineAxisValues(AXIS_COST,this.glyphModel.getFieldEnd(AXIS_COST),this.glyphModel.getFieldStart(AXIS_COST));
		}
		
		private function addAxis(inFieldStr:String,inStyle:String,targetStr:String)
		{
 			var defXML:XML; 	// definition for the display area
			var maskStr:String; // The mask used to format the date values of the date axis
			
			// If first Axis initiate the Object, otherwise assign the new Axis to the associative array
			this.axesObj = (this.axesObj) ? this.axesObj : new Object();
			
			// This provides the style name: defXML.attribute("name") in Axis
			// Used with the this._style to retrieve the Style definition
			defXML = this.view.model.retrieveDef(inFieldStr);		

			switch(inFieldStr)
			{
				case AXIS_ARRIVAL:
				case AXIS_DEPARTURE:
					this.axesObj[inFieldStr] = new DateAxis(defXML,this._style,inFieldStr);
					this.defineTimeScale(inFieldStr);
					this.axesObj[inFieldStr].axis_offset = this.axesObj[AXIS_DEPARTURE].axis_offset;
					// Future concern adding vertical guidelines
				//	this.axesObj[inFieldStr].guide_length = this.axesObj[AXIS_COST].axis_height;
				break;
				case AXIS_COST:
				default:
					this.axesObj[inFieldStr] = new Axis(defXML,this._style,inFieldStr);
					this.defineCostScale();					
				break;
			}
			//this.axesObj[inFieldStr].align_axis = inAlign;
			this.axesObj[inFieldStr].label_color = this.glyphModel.getLabelColor(inFieldStr);
			
			try
			{
				this.axesObj[inFieldStr].drawAxis();
			} catch (e:Error)
			{
				this.view.reportError(ScreenModel.DEFAULT_ERROR,("Flight_Schedule:  drawAxis failed = " + e.message));
				(DebugUtil.getInstance()).errorTrace(e.getStackTrace());
			}
			// Ensure that the axis doesn't interfere with the mouse events of the glyphs
			this.axesObj[inFieldStr].mouseEnabled = false;
			
			this.daObj[targetStr].addDisplayObject(this.axesObj[inFieldStr]);
		}
		
		private function createAxes(targetStr:String):void
		{
	
			this._style = this.view.model.retrieveStyle(this.retrieveStyleName(targetStr));
			
			// Vertical Axis
			this.addAxis(AXIS_COST,AXIS_LABEL_COST,targetStr);
			
			// Horizontal Axis
			this.addAxis(AXIS_DEPARTURE,AXIS_LABEL_DEPARTURE,targetStr);			

			// Horizontal Axis
			this.addAxis(AXIS_ARRIVAL,AXIS_LABEL_ARRIVAL,targetStr);
			
			// Add the date lines
			this.axesObj[AXIS_COST].convertGuideLines(this.axesObj[AXIS_ARRIVAL].guide_lines,this.axesObj[AXIS_ARRIVAL].axis_orientation);
		}
		
		// Returns the files contained here
		private function retrieveStyleName(targetStr:String):String
		{
			return this.screen..file.(attribute("target")== targetStr).@style;
		}	
		private function displayGlyphs(targetStr:String):void
		{
			var glyphSize:Array;
			var countGlyphs:uint;
			var glyphTable:Array;
			countGlyphs = 0;
			
			// Establish glyph manager
			this._taskGlyph = this.view.model.retrieveDef(TASK_GLYPH);			
			this._glyphManager = new ScheduleGlyphManager();
			this._glyphManager.setDef(this._taskGlyph);
			
			glyphSize = new Array();
			
			// Set up the display

			glyphTable = this.glyphModel.getGlyphTable();
			
 			for (var i:int=0; i < glyphTable.length; i++)
			{
				var indexStr:String;
				var tempPoint:Point;
				var tempGlyph:ScheduleGlyph;
				indexStr = glyphTable[i][GlyphConst.GLYPH_ID];
 				countGlyphs++;
				tempGlyph = this._glyphManager.getGlyph(i) as ScheduleGlyph;
				tempGlyph.glyphCount = glyphTable.length;
				this.addGlyph(glyphTable[i],tempGlyph);
				
				// Get positioning from the axes
				tempPoint = this.axesObj[AXIS_DEPARTURE].getPoint(this.glyphModel.parseFieldValue(AXIS_DEPARTURE,glyphTable[i][AXIS_DEPARTURE]));
				this.glyphObj[indexStr].addPoint(GlyphConst.HORIZONTAL_START,this.axesObj[AXIS_DEPARTURE],tempPoint);
				tempPoint = this.axesObj[AXIS_ARRIVAL].getPoint(this.glyphModel.parseFieldValue(AXIS_ARRIVAL,glyphTable[i][AXIS_ARRIVAL]));
				this.glyphObj[indexStr].addPoint(GlyphConst.HORIZONTAL_END,this.axesObj[AXIS_ARRIVAL],tempPoint);
				tempPoint = this.axesObj[AXIS_COST].getPoint(glyphTable[i][AXIS_COST]);
				this.glyphObj[indexStr].addPoint(Resizable.VERTICAL,this.axesObj[AXIS_COST],tempPoint);				
				// Add to Stage
				this.daObj[targetStr].addDisplayObject(this.glyphObj[indexStr]);
				this.glyphObj[indexStr].assigned = true;
 			}
 
			if (countGlyphs != this.glyphModel.glyphCount())
			{
				this.view.reportError(ScreenModel.GLYPH_CONTENT_TYPE,"The number of glyphs added does not match those parsed.");
			} else
			{
				this.daObj[targetStr].showDisplayArea();
			}
 		}
		
		private function addGlyph(glyphData:Object, inGlyph:ScheduleGlyph):void
		{
			var indexStr:String;	// Glyph Unique identifier
			var tempArr:Array;		// Array
			indexStr = glyphData[GlyphConst.GLYPH_ID];
			
			this.glyphObj = (this.glyphObj) ? this.glyphObj : new Object();
			this.glyphObj[indexStr] = inGlyph;
			this.glyphObj[indexStr].reset();		
			this.glyphObj[indexStr].detailsTF = this.detailsTF;
			this.glyphObj[indexStr].rolloverStr = this._glyphDetailsTemplate;			
			this.glyphObj[indexStr].targetTF = this.targetTF;		
			this.glyphObj[indexStr].targetStr = this.targetTF.htmlText;			
			this.glyphObj[indexStr].id = indexStr;
			this.glyphObj[indexStr].label = NAV_GLYPH;
			this.glyphObj[indexStr].style = this.view.model.retrieveStyle(ScreenView.DEFAULT_STYLESHEET);
	
			// add later the detailed description for accessibility, makeAccessible
			this.glyphObj[indexStr].addGlyphListener(this.mouseEvent);
			
			//Assign Name and Default Colors
			this.glyphObj[indexStr].name = indexStr;
			this.glyphObj[indexStr].defaultColors = this.glyphModel.getDefaultColors();
			
			// Assign the Meter configurations
			tempArr = this.glyphModel.glyphField(glyphData);
			this.glyphObj[indexStr].assignMeters(tempArr);			
		}

	}			
}