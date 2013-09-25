package org.wsimpson.visualization.experiment.screen
/*
** Title:	Glyphs.as
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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;

	// Utitlies
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.ImageUtil;	
	import org.wsimpson.util.Positions;
	import org.wsimpson.util.StringUtil;
	
	// UI Classes
	import org.wsimpson.ui.ButtonBase;	
	import org.wsimpson.ui.DisplayArea;
	import org.wsimpson.ui.Overlay;
	import org.wsimpson.ui.screen.ExtendedScreen;
	import org.wsimpson.ui.screen.Screen;	
	
	// Style Definitions
	import org.wsimpson.styles.Style;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.button.ButtonRectangle;	
	import org.wsimpson.visualization.experiment.infoglyph.GlyphModel;
	import org.wsimpson.visualization.experiment.infoglyph.EnginesGlyph
	import org.wsimpson.visualization.experiment.ScreenModel;	
	import org.wsimpson.visualization.experiment.ScreenView;

	
	public class Glyphs extends ExtendedScreen
	{
		// Contant values
		public static const GLYPH_DEFINITION = "glyph definitions";	// Screen Resources files
		public static const GLYPH_OVER_DETAILS = "glyph over";		// Screen Resources files
		public static const GLYPH_DISPLAY = "glyph display";		// Screen Resources files
		public static const GLYPH_SCREEN = "glyph screen";			// Screen Resources files
		public static const GLYPH_TARGETS = "glyph targets";		// Screen Resources files
		public static const GLYPH_OVERLAY = "overlay background";	// Screen Resources files
		public static const GLYPH_INTRO = "overlay instructions";	// Screen Resources files
		public static const GLYPH_IMAGE = "overlay image";			// Screen Resources files
		public static const GLYPH_LABLED = "labeled_glyph";			// Screen Resources files
		public static const GLYPH_MARGIN = "margin";				// Glyph Style
		public static const MSG_START = "glyph_start";				// Glyph specific start
		public static const MSG_OVER = "glyph_over";				// Glyph specific mouse over
		public static const MSG_SELECTED = "glyph_selected";		// Glyph selected
		
		// Overlay Index
		public static const GLYPH_OVERLAY_INDEX = {"overlay background":0, "overlay instructions":1, "overlay image":2};
		
		// UI
		public static const NAV_GLYPH = "Glyph";					// Glyph Selected button (use with CSS)
		public static const NAV_START = "Start";					// Navigation button (use with CSS)
		public static const INTR_STYLE = "Instructions Style";		// Screen layout tranition definition name	
		public static const INTR_TEXT = "Instructions Text";		// Screen layout tranition definition name
		public static const OBJECT_STYLE = "style";					// Data Structure entry
		public static const OBJECT_DESC = "description";			// Data Structure entry
		public static const OBJECT_CONTENT = "content";				// Data Structure entry
		public static const OBJECT_TARGET = "target";				// Data Structure entry
		
 		private	var _debugger:DebugUtil;			// Output and diagnostic window
		private var glyphArr:Array;					// Array of Glyphs
		private var instrArr:Array;					// Instructions text display
		private var glyphModel:GlyphModel;			// Data model for displaying the glyphs
		private var glyphObj:Object;				// Associative Array of Glyphs
		private var glyph_overObj:Object;			// Associative Array of Glyphs
		private var targetObj:Object;				// Associative Array of Glyphs
		private var attrPos:Positions;				// Maintains orientation of elements to each other.	
		private	var startButton:ButtonRectangle;	// Start Button
 		private var view:ScreenView;				// The View of MVC
		private	var glyphDetailsStr:String;			// Default details HTML
		private	var glyphDetailsTemplate:String;	// Template for rollover details HTML
		private	var displayDAName:String;			// Definition name for the DA displaying the display
		private	var detailsDAName:String;			// Definition name for the DA displaying the details
		private	var targetDAName:String;			// Definition name for the DA displaying the details
		private var orientationStr:String;			// Supported orientations of the sliders		
		private	var detailsTF:TextField;			// Details to display
 		private var overlayText:TextField;			// Textfield for the overlay
		private	var targetTF:TextField;				// Details to display
		private var offsetX:uint;					// Creates the grid arrangement
        private var offsetY:uint;					// Creates the grid arrangement
		private	var screen:XML;						// References the active stage
		private	var glyphDef:XML;					// Glyph definition
		private	var glyphData:XML;					// Glyph data
		private	var glyphMargin:String;				// Glyph margin (Note this is used as a percentage)

		// XML Definition
		private static const TEMPLATE_GLYPHS = 
			"\t<glyphs>\n\t\t<data>\n\t\t\t{MESSAGE}\n\t\t</data>\n\t</glyphs>";
		private static const TEMPLATE_START = 
			"\t<start>\n\t\t{MESSAGE}\n\t</start>";
		private static const TEMPLATE_ROLLOVER = 
			"\t<rollover id=\"{ID}\">\n\t\t{MESSAGE}\n\t</rollover>";
			private static const TEMPLATE_SELECTION = 
			"\t<selection id=\"{ID}\">\n\t\t{MESSAGE}\n\t</selection>";
		private static const GLYPHS_ID = "{ID}";						// Field to replace
		private static const GLYPHS_MSG = "{MESSAGE}";					// Field to replace	
		private static const GLYPHS_FIELD_INDEX = "{INDEX}";			// Field to replace
		private static const GLYPHS_FIELD_NAME = "{FIELD_{INDEX}}";		// Field to replace
		private static const GLYPHS_FIELD_VALUE = "{VALUE_{INDEX}}";	// Field to replace
		private static const GLYPHS_FIELD_RANK = "{RANK_{INDEX}}";		// Field to replace

		// Patterns
		private var idPattern:RegExp;				// Regular Expression pattern
		private var indexPattern:RegExp;			// Regular Expression pattern
		private var dataPattern:RegExp;				// Regular Expression pattern
		
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
		public function Glyphs(inView:ScreenView,screenXML:XML)
		{
			super();
			this._debugger = DebugUtil.getInstance();
	
			// Define Patterns
			this.idPattern = new RegExp(GLYPHS_ID);
			this.indexPattern = new RegExp(GLYPHS_FIELD_INDEX);
			this.dataPattern = new RegExp(GLYPHS_MSG);
		
			// Set the stage
			this.view = inView;  // Need boundry object
			
			// Assign the display XML
			this.screen = screenXML;
			this.glyphDetailsStr = "";
			this.targetDAName = "";
			
			// Store for TextFields created
			this.targetObj = new Object();
			
			// Manages display order of the Overlay elements
			this.instrArr = new Array();
			
			// Position manager
			this.attrPos = new Positions();
			this.orientationStr = Positions.ROW;
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
		
		/**
		*  Name:  	onEnterFrame
		*  Purpose:  This event indicates that the screen has been loaded to the stage.
		*/				
		private function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			// Initialize the display
			this.init();
		}
		
		
		/**
		*  Name:  	leaveScreen
		*  Purpose:  The next or previous button, or the glyph has been selected.
		*/		
 		public override function leaveScreen():void
		{
			for (var targetStr:String in this.daObj)
			{
				if (this.daObj[targetStr])
				{
					this.daObj[targetStr].leaveStage();	
					this.removeChild(this.daObj[targetStr]);
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
					// Do nothing
				break;
				default:
					this._debugger.warningTrace("Unexpected Mouse Event in Glyphs: " + event.type);
				break;
			}
		}
		
		public function resetScreen(event:Event):void {
			this.detailsTF.htmlText = glyphDetailsStr;	
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
					tempMsg = this.view.retrieveMessage(MSG_START);
					this.reportMouseEvent(tempMsg,TEMPLATE_START);		
					this.startButton.state = ButtonBase.BUTTON_HIDDEN;
					this.hideOverlay();
				break;
				case NAV_GLYPH:
					tempMsg = this.view.retrieveMessage(MSG_SELECTED);
					this.reportMouseEvent(tempMsg,TEMPLATE_SELECTION,inMC.parent[EnginesGlyph.GLYPH_ID]);
					tempMsg = this.glyphModel.toXMLString();
					this.reportMouseEvent(tempMsg,TEMPLATE_GLYPHS,inMC.parent[EnginesGlyph.GLYPH_ID]);
					this.view.nextPage();
				break;
				default:
					this._debugger.warningTrace("Unexpected Button Click in Glyphs: " + inMC.buttonLabel);
				break;
			}
		}
		
		/**
		*  Name:  	rolloverEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public function rolloverEvent(inMC:MovieClip):void {
			var tempMsg:String;
			switch(inMC.buttonLabel)
			{
				case NAV_GLYPH:
					// update the details
					tempMsg = this.view.retrieveMessage(MSG_OVER);
					this.reportMouseEvent(tempMsg,TEMPLATE_ROLLOVER,inMC.parent[EnginesGlyph.GLYPH_ID]);
					this.detailsTF.htmlText = this.glyph_overObj[inMC.parent[EnginesGlyph.GLYPH_ID]];				
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
				tempStr = tempStr.replace(this.idPattern,inID);
			}
			tempStr = tempStr.replace(this.dataPattern,this.view.recordEventTemplate(inMsg));
			this.view.recordEvent(tempStr);
		}
		
		// Returns the files contained here
		private function init():void
		{
			var fileXMLList:XMLList;

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
						this.glyphDetailsTemplate = StringUtil.stripReturns(this.view.model.retrieveFile(introFile.toString()).toString());
					break;
					case GLYPH_DISPLAY:									
						// Add the Display Area
						this.glyphData = new XML(this.view.model.retrieveFile(introFile.toString()));
						this.displayDAName = targetStr;
					case GLYPH_TARGETS:
						this.targetDAName = (fileIDStr == GLYPH_TARGETS) ? targetStr : this.targetDAName;
					case GLYPH_SCREEN:
				
						// Create Textfield
						contentStr = StringUtil.stripReturns(this.view.model.retrieveFile(introFile.toString()).toString());
						descStr = introFile.@desc.toString();
						tempStyle = this.view.model.retrieveStyle(introFile.@style);
						
						// Define the default values
						if (fileIDStr == GLYPH_SCREEN)
						{
							this.detailsDAName = targetStr;
							this.glyphDetailsStr = contentStr;
						}	
						
						// Add the Display Area	
						this.addDA(targetStr,contentStr,descStr,tempStyle);
						
						if (fileIDStr == GLYPH_DISPLAY)
						{
							this.daObj[targetStr].addEventListener(flash.events.MouseEvent.MOUSE_OUT,resetScreen);
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

			// Add the Glyph Visualization
			this.deployScreen();
			
			// Populate targets
			this.createSearchResults();
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
		
		private function createSearchResults():void
		{
			var tempHTML:String;
			var tempObj:Object;
			tempHTML = this.targetTF.htmlText;
			tempObj = this.glyphModel.getTargetValues();
			for (var fieldID:String in tempObj)
			{
				tempHTML = this.updateFieldString(tempHTML,int(fieldID),this.glyphModel.getFieldLabel(fieldID),tempObj[fieldID]);
			}
			this.targetTF.htmlText = tempHTML;
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
//			this.view.fadeInScreen();
			this.addStartButton();
		}
		
		private function deployScreen():void
		{
			// Create a matching Transition Overlay
			this.glyphModel = new GlyphModel(this.glyphDef,this.glyphData);
			this.displayGlyphs(this.targetObj[GLYPH_DISPLAY]);
			this.startButton.showButton();					
		}		
		
		private function addStartButton():void
		{
			this.startButton = new ButtonRectangle();
			this.addChild(this.startButton);
			this.startButton.x = 512 - (this.startButton.width /2);
			this.startButton.y = 650;
			this.startButton.style = this.view.model.retrieveStyle(ScreenView.DEFAULT_STYLESHEET);
			this.startButton.buttonLabel = NAV_START;
			this.startButton.addButtonListener(this.mouseEvent);
			this.startButton.hideButton();
		}
		
		// Returns the files contained here
		private function addTarget(in_DA:String,in_target:String):void
		{
			this.targetObj[in_DA] = in_target;
			this.targetObj[in_target] = in_DA;
		}
		
		// Returns the files contained here
		private function addOverlayDA(inFileID:String,inTarget:String,inContent:String,inDesc:String,inStyle:Style):void		
		{
			var tempIndex:uint;
			tempIndex = GLYPH_OVERLAY_INDEX[inFileID];
	
			if (!this.instrArr[tempIndex])
			{
				this.instrArr[tempIndex] = new Object();
				this.instrArr[tempIndex][OBJECT_TARGET] = inTarget;
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
	
		private function addDA(inTarget:String,inContent:String,inDesc:String,inStyle:Style):void
		{
			var defXML:XML; 		// definition for the display area
			var styleObj:Object; 	// Object containing Stylesheet information
			var tempDA:DisplayArea; // Display area
			var tempTF:TextField;	// TextField defined			
			if (inStyle.hasStyle(inTarget.toLowerCase()))
			{
				if ((inTarget != null) && (this.daObj[inTarget] == null))
				{
					// Target Display Area
					defXML = this.view.model.retrieveDef(inTarget);	
					styleObj = inStyle.getStyle(inTarget.toLowerCase());
					this.addDisplayArea(inTarget,defXML,inDesc,styleObj);
					
					if (inContent != GLYPH_LABLED)
					{
						// Add TextField to the Display Area
						tempTF = this.addTextField(inContent,inStyle);
						tempTF.width = this.daObj[inTarget].display_width();
						if (inTarget == this.detailsDAName)
						{
							this.detailsTF = tempTF;
						} else if (inTarget == this.targetDAName)
						{
							this.targetTF = tempTF;
						}
						this.daObj[inTarget].addDisplayObject(tempTF);
					} else
					{
						var tempDO:Bitmap;
						tempDO = ImageUtil.duplicateImage(this.view.model.retrieveFile(GLYPH_LABLED) as Bitmap);
						this.daObj[inTarget].addDisplayObject(tempDO);
					}
				} else if (inTarget == null)
				{
					throw new Error("Glyphs Screen Display failed: Requires target display object definition");
				}
			} else
			{
				this.view.reportError(ScreenModel.STYLE_SCREEN_NOTFOUND,"Glyphs:  Missing CSS style for = " + inTarget.toLowerCase());
			}
		}
		
		private function displayGlyphs(targetStr:String):void
		{
			var gridSize:Array;
			var offsets:Array;
			var glyphSize:Array;
			var countGlyphs:uint;
			var colCount:uint;
			var displayObj:Object;
			var glyphTable:Array;
			countGlyphs = 0;
			displayObj = new Object();
			displayObj.height = this.daObj[targetStr].cell_height;
			displayObj.width = this.daObj[targetStr].cell_width;
			
			// Set up the display
			gridSize = Positions.findGridSize(displayObj,this.glyphModel.glyphCount());
			offsets = Positions.getOffsets(displayObj,gridSize);
			glyphSize = Positions.getElementArea(displayObj,gridSize);
			glyphTable = this.glyphModel.getGlyphTable();
			colCount = 0;
			for (var i:int=0; i < glyphTable.length; i++)
			{
				var orientationStr:String;
				var indexStr:String;
				indexStr = glyphTable[i][EnginesGlyph.GLYPH_ID];
				countGlyphs++;
				this.addGlyph(indexStr);
				this.addGlyphOver(indexStr);
				this.initGlyph(indexStr,glyphSize,glyphTable[i]);
				this.daObj[targetStr].addDisplayObject(this.glyphObj[indexStr]);
				colCount = (colCount == gridSize[1]) ? 0 : colCount;
				orientationStr = (colCount == 0) ? Positions.ROW : Positions.COLUMN;
				this.attrPos.addElement(this.glyphObj[indexStr],orientationStr,offsets[0],offsets[1]);
				colCount++;
			}
			this.attrPos.positionElements();
			this.applyMargins();
			if (countGlyphs != this.glyphModel.glyphCount())
			{
				this.view.reportError(ScreenModel.GLYPH_CONTENT_TYPE,"The number of glyphs added does not match those parsed.");
			} else
			{
				this.daObj[targetStr].showDisplayArea();
			}
		}

		private function applyMargins():void
		{
			for (var indexStr in glyphObj)
			{
				this.glyphObj[indexStr].margin = this.glyphMargin;	
			}
		}
		
		private function addGlyph(indexStr:String):void
		{
			this.glyphObj = (this.glyphObj) ? this.glyphObj : new Object();
			this.glyphObj[indexStr] = new EnginesGlyph();
			this.glyphObj[indexStr].id = indexStr;
			this.glyphObj[indexStr].label = NAV_GLYPH;
			// add later the detailed description for accessibility, makeAccessible
			this.glyphObj[indexStr].addGlyphListener(this.mouseEvent);	
		}

		private function addGlyphOver(indexStr:String):void
		{
			var tempStr:String;
			tempStr = this.glyphDetailsTemplate;

			// Assign the glyph id to the rollover details
			tempStr = tempStr.replace(this.idPattern,indexStr);
			// Iniitalize the rollover details
			this.glyph_overObj = (this.glyph_overObj) ? this.glyph_overObj : new Object();
			this.glyph_overObj[indexStr] = tempStr;
		}
		
		private function updateFieldString(inStr:String,inIndex:int,inNameStr:String,inValueStr:String):String
		{
			var fieldPattern:RegExp;
			var valuePattern:RegExp;		
			var fieldStr:String;
			var valueStr:String;
			valueStr = GLYPHS_FIELD_VALUE;
			valuePattern = new RegExp(valueStr.replace(this.indexPattern,inIndex),"g");
			fieldStr = GLYPHS_FIELD_NAME;
			fieldPattern = new RegExp(fieldStr.replace(this.indexPattern,inIndex),"g");
			inStr = inStr.replace(valuePattern,inValueStr);
			inStr = inStr.replace(fieldPattern,inNameStr);
			return inStr;
		}
		
		private function updateGlyphOver(inIndex:int,indexStr:String,inNameStr:String,inValueStr:String,inTypeStr:String):void
		{
			var rankPattern:RegExp;
			var tempStr:String;
			tempStr = this.glyph_overObj[indexStr];
			inValueStr = (inValueStr == "-1") ? "value outside range" : inValueStr;
			if (inTypeStr == GlyphModel.RANK_LABEL)
			{
				var rankStr:String;
				rankStr = GLYPHS_FIELD_RANK;
				rankPattern = new RegExp(rankStr.replace(this.indexPattern,inIndex),"g");
				tempStr = tempStr.replace(rankPattern,inValueStr);
			} else
			{
				tempStr = this.updateFieldString(tempStr,inIndex,inNameStr,inValueStr);
			}		
			this.glyph_overObj[indexStr] = tempStr;
		}
		
		private function initGlyph(indexStr:String,glyphSize:Array,glyphData:Object)
		{
			var tempArr:Array;
			tempArr = new Array();	

			// Assign Values
			for (var tempStr:String in glyphData)
			{
				var indexNum:int;
				var labelStr:String;
				var typeStr:String;
				typeStr = "";

				// Find Rank Value 
				indexNum = tempStr.indexOf(GlyphModel.RANK_LABEL);
				labelStr = (indexNum >= 0) ? tempStr.substr(0,indexNum) : tempStr;
				if (labelStr != "toString")
				{
					if (indexNum > 0)
					{
						// Pass the rank value to the glyph
						var dataArr:Array;
						dataArr = new Array();
						dataArr[0] = glyphData[tempStr];
						dataArr[1] = this.glyphModel.getColorArray(labelStr);
						tempArr[this.glyphModel.getFieldID(labelStr)] = dataArr;
						typeStr = GlyphModel.RANK_LABEL;
					}
					if ((labelStr != "valueArr") && (labelStr != "id"))
					{
						this.updateGlyphOver(this.glyphModel.getFieldID(labelStr),indexStr,labelStr,glyphData[tempStr],typeStr);
					}
				}
			}
			this.glyphObj[indexStr].maxSize = glyphSize;	
			this.glyphObj[indexStr].assignMeters(tempArr);
		}
	}			
}