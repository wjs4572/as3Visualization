package org.wsimpson.visualization.experiment.screen
/*
** Title:	GlyphGrid.as
** Purpose: Interactive for selecting data from tabular rows.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
   import fl.controls.listClasses.CellRenderer;

	// Adobe Formatting
	import flash.text.TextFormat;
	
	// Adobe UI
    import fl.controls.DataGrid;
    import fl.controls.dataGridClasses.DataGridColumn;
	import fl.data.DataProvider;	
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
	import org.wsimpson.ui.datagrid.ColRenderer;
	import org.wsimpson.ui.DisplayArea;
	import org.wsimpson.ui.Overlay;
	import org.wsimpson.ui.screen.ExtendedScreen;
	import org.wsimpson.ui.screen.Screen;	
	
	// Style Definitions
	import org.wsimpson.styles.Style;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.button.ButtonRectangle;	
	import org.wsimpson.visualization.experiment.infoglyph.GlyphModel;
	import org.wsimpson.visualization.experiment.ScreenModel;	
	import org.wsimpson.visualization.experiment.ScreenView;
	
	public class GlyphGrid extends ExtendedScreen
	{
		// Contant values
		public static const DEFAULT_ROWCOUNT = 10;					// Number of grid rows to display by default
		public static const DEFAULT_ROWHEIGHT = 10;					// Height of the grid rows to display by default
		public static const COL_WIDTH = "width";					// Screen Resources files
		public static const SHORT_RANK = "rank";					// Screen Resources files
		public static const GRID_DEFINITION = "grid definitions";	// Screen Resources files
		public static const GRID_DISPLAY = "grid display";			// Screen Resources files
		public static const GRID_TARGETS = "grid targets";			// Screen Resources files
		public static const GRID_OVERLAY = "overlay background";	// Screen Resources files
		public static const GRID_INTRO = "overlay instructions";	// Screen Resources files
		public static const GRID_IMAGE = "overlay image";			// Screen Resources files
		public static const GRID_LEGEND = "grid_legend";			// Screen Resources files
		public static const GRID_MARGIN = "margin";					// Grid Style
		public static const MSG_START = "grid_start";				// Grid specific start
		public static const MSG_OVER = "grid_sort";					// Grid specific mouse action
		public static const MSG_SELECTED = "grid_row_selected";		// Grid row selected
		
		// Data Grid Styles
		public static const DATAGRID_BODY_CSS = 
			"Task_Display_Grid_Body";								// The text format of the datagrid body text 
		public static const DATAGRID_HEADER_CSS = 
			"Task_Display_Grid_Header";								// The text format of the datagrid header text 
		public static const DATAGRID_HEADER_TF = 
			"headerTextFormat";										// The text format of the datagrid header text 
		public static const DATAGRID_CELLRENDERER = 
			"cellRenderer";											// The text format of the datagrid body text 
		public static const DATAGRID_TF = 
			"textFormat";											// The text format of the datagrid body text 
		public static const TARGET_DO = 
			"Task_Display_Grid";									// The target display object
			
		// Overlay Index
		public static const GRID_OVERLAY_INDEX = {"overlay background":0, "overlay instructions":1, "overlay image":2};
		
		// UI
		public static const NAV_GLYPH = "Glyph";					// Glyph Selected button (use with CSS)
		public static const NAV_START = "Start";					// Navigation button (use with CSS)
		public static const INTR_STYLE = "Instructions Style";		// Screen layout tranition definition name	
		public static const INTR_TEXT = "Instructions Text";		// Screen layout tranition definition name
		public static const OBJECT_STYLE = "style";					// Data Structure entry
		public static const OBJECT_DESC = "description";			// Data Structure entry
		public static const OBJECT_CONTENT = "content";				// Data Structure entry
		public static const OBJECT_TARGET = "target";				// Data Structure entry
		
		// Private Instance Variables
 		private	var _debugger:DebugUtil;			// Output and diagnostic window
		private var glyphArr:Array;					// Array of Glyphs
		private var instrArr:Array;					// Instructions text display
		private var glyphModel:GlyphModel;			// Data model for displaying the glyphs
		private var dataGrid:DataGrid;				// DataGrid
		private var glyph_overObj:Object;			// Associative Array of Glyphs
		private var targetObj:Object;				// Associative Array of Glyphs
		private var attrPos:Positions;				// Maintains orientation of elements to each other.	
		private	var startButton:ButtonRectangle;	// Start Button
 		private var view:ScreenView;				// The View of MVC
		private	var glyphDetailsStr:String;			// Default details HTML
		private	var gridDetailsTemplate:String;		// Template for rollover details HTML
		private	var displayDAName:String;			// Definition name for the DA displaying the display
		private	var displayStyle:Style;				// Display values
		private	var detailsDAName:String;			// Definition name for the DA displaying the details
		private	var targetDAName:String;			// Definition name for the DA displaying the details
		private var orientationStr:String;			// Supported orientations of the sliders		
		private	var detailsTF:TextField;			// Details to display
 		private var overlayText:TextField;			// Textfield for the overlay
		private	var targetTF:TextField;				// Details to display
		private var offsetX:uint;					// Creates the grid arrangement
        private var offsetY:uint;					// Creates the grid arrangement
		private	var screen:XML;						// References the active stage
		private	var gridDef:XML;					// Glyph definition
		private	var gridData:XML;					// Glyph data
		private	var glyphMargin:String;				// Glyph margin (Note this is used as a percentage)
		private var rowCount:Number;				// Number of rows
		private var rowHeight:Number;				// Number of rows

		// XML Definition
		private static const TEMPLATE_GRID = 
			"\t<grid>\n\t\t<data>\n\t\t\t{MESSAGE}\n\t\t</data>\n\t</grid>";
		private static const TEMPLATE_START = 
			"\t<start>\n\t\t{MESSAGE}\n\t</start>";
		private static const TEMPLATE_SELECTION = 
			"\t<selection id=\"{ID}\">\n\t\t{MESSAGE}\n\t</selection>";
		private static const GLYPHS_ID = "{ID}";						// Field to replace
		private static const GLYPHS_MSG = "{MESSAGE}";					// Field to replace	
		private static const GLYPHS_FIELD_INDEX = "{INDEX}";			// Field to replace
		private static const GLYPHS_FIELD_NAME = "{FIELD_{INDEX}}";		// Field to replace
		private static const GLYPHS_FIELD_VALUE = "{VALUE_{INDEX}}";	// Field to replace

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
		public function GlyphGrid(inView:ScreenView,screenXML:XML)
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
			
			// Define Grid Defaults
			this.rowCount = DEFAULT_ROWCOUNT;
			this.rowHeight = DEFAULT_ROWHEIGHT;			
			
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
		*  Name:  	onLabeled
		*  Purpose:  When the overlay has completed drawing display the start button.
		*/				
		private function onLabeled(event:Event):void
		{
			this.dataGrid.removeEventListener(Event.ENTER_FRAME, this.onLabeled);
		
			// Start the task
			this.startButton.showButton();
		}
		
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
					if (this.contains(this.daObj[targetStr]))
					{
						this.removeChild(this.daObj[targetStr]);
					}
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
				case flash.events.MouseEvent.MOUSE_OUT:
					// Do nothing
				break;
				default:
					this._debugger.warningTrace("Unexpected Mouse Event in Glyphs: " + event.type);
				break;
			}
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
				default:
					this._debugger.warningTrace("Unexpected Button Click in Glyphs: " + inMC.buttonLabel);
				break;
			}
		}
		
		/**
		*  Name:  	gridEvent
		*  Purpose:  An click event has occurred with the grid.
		*/
        public function gridEvent(event:Event):void {
			var tempMsg:String;
			tempMsg = this.view.retrieveMessage(MSG_SELECTED);
			this.reportMouseEvent(tempMsg,TEMPLATE_SELECTION,event.target.selectedItem.id);
			tempMsg = this.glyphModel.toXMLString();
			this.reportMouseEvent(tempMsg,TEMPLATE_GRID,event.target.selectedItem.id);
			this.view.nextPage();
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
					case GRID_DEFINITION:
						// Field definitions for the grid
						this.gridDef = new XML(this.view.model.retrieveFile(introFile.toString()));	
					break;
 					case GRID_DISPLAY:									
						// Add the Data displayed by the DataGrid
						this.gridData = new XML(this.view.model.retrieveFile(introFile.toString()));				
						this.displayDAName = targetStr;

					case GRID_TARGETS:
						this.targetDAName = (fileIDStr == GRID_TARGETS) ? targetStr : this.targetDAName;
				
						// Create Textfield
						//contentStr = (fileIDStr == GRID_DISPLAY) ? "" : StringUtil.stripReturns(this.view.model.retrieveFile(introFile.toString()).toString());
						contentStr = this.view.model.retrieveFile(introFile.toString()).toString();
						descStr = introFile.@desc.toString();
						tempStyle = this.view.model.retrieveStyle(introFile.@style);
						
						// Add the Display Area	
						this.addDA(targetStr,contentStr,descStr,tempStyle);
						
						if (fileIDStr == GRID_DISPLAY)
						{
							var tempObj:Object;
							this.displayStyle = tempStyle;
							tempObj = this.displayStyle.getStyle(targetStr.toLowerCase());
							this.glyphMargin = tempObj[GRID_MARGIN];
						}
					break;
					case GRID_IMAGE:
					case GRID_OVERLAY:
					case GRID_INTRO:	
						contentStr = 	(fileIDStr == GRID_IMAGE) ? GRID_LEGEND :
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

			// Add the DataGrid Visualization
			this.deployScreen();
			
			// Populate targets
			this.createSearchResults();
			
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
				if (this.daObj[targetStr] != null)
				{
					this.daObj[targetStr].hideDisplayArea();
				} else
				{
					this.view.reportError(ScreenModel.DEFAULT_ERROR,"GlyphGrid:  Missing Display Object:  " + targetStr);
					throw new Error("Missing Display Object:  " + targetStr);
				}
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
				tempHTML = this.updateFieldString(tempHTML,int(fieldID),tempObj[fieldID].label,tempObj[fieldID].value);
			}		
			this.targetTF.htmlText = StringUtil.replaceTabs(tempHTML);
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
			//this.view.fadeInScreen();
			this.addStartButton();
		}
		
		private function deployScreen():void
		{
			// Create a matching Transition Overlay
			this.glyphModel = new GlyphModel(this.gridDef,this.gridData,true);
			this.displayGlyphs(this.targetObj[GRID_DISPLAY]);			
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
			tempIndex = GRID_OVERLAY_INDEX[inFileID];
	
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

			// TODO:  This needs some refactoring
			if (inStyle.hasStyle(inTarget.toLowerCase()))
			{
				if ((inTarget != null) && (this.daObj[inTarget] == null))
				{
					// Target Display Area
					defXML = this.view.model.retrieveDef(inTarget);
					if (defXML != null)
					{
						if (inTarget == TARGET_DO)
						{
							this.rowCount = (defXML.@["rowCount"]) ? defXML.@["rowCount"] : this.rowCount;
							this.rowHeight = (defXML.@["rowHeight"]) ? defXML.@["rowHeight"] : this.rowHeight;
						}
						styleObj = inStyle.getStyle(inTarget.toLowerCase());				
						this.addDisplayArea(inTarget,defXML,inDesc,styleObj);
						
						if ((inContent != GRID_LEGEND) && (inContent != ""))
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
								this.targetTF.wordWrap = false;
							}
							this.daObj[inTarget].addDisplayObject(tempTF);
						} else if (inContent != "")
						{
							var tempDO:Bitmap;
							tempDO = ImageUtil.duplicateImage(this.view.model.retrieveFile(GRID_LEGEND) as Bitmap);
							this.daObj[inTarget].addDisplayObject(tempDO);						
						}
					} else
					{
						this.view.reportError(ScreenModel.DEFAULT_ERROR,"GlyphGrid:  Missing Display Object definition:  " + inTarget);
					}
				} else if (inTarget == null)
				{
					throw new Error("Glyphs Screen Display failed: Requires target display object definition");
				}
			} else
			{
				this.view.reportError(ScreenModel.STYLE_SCREEN_NOTFOUND,"GlyphGrid:  Missing CSS style for = " + inTarget.toLowerCase());
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
			var glyphTable:Array
			var tempArr:Array;
			var gridMargin:uint;
			var dataTable:DataProvider;
			var tempTF:TextFormat;
			
			countGlyphs = 0;
			gridMargin = int(this.glyphMargin);
			displayObj = new Object();
			displayObj.height = this.daObj[targetStr].cell_height;
			displayObj.width = this.daObj[targetStr].cell_width;
			
			// Set up the display
			glyphTable = this.glyphModel.getGlyphTable();
			
			dataTable = new DataProvider(glyphTable);

			// Create the DataGrid
			this.dataGrid = new DataGrid();
			
			// Add listener
			this.dataGrid.addEventListener(Event.CHANGE, gridEvent);
			this.dataGrid.addEventListener(Event.ENTER_FRAME, onLabeled);
			
			// Define Styles
			tempTF = this.displayStyle.getStyleTextFormat(DATAGRID_HEADER_CSS.toLowerCase());					
			this.dataGrid.setStyle(DATAGRID_HEADER_TF,tempTF);

			//this.dataGrid.setStyle(DATAGRID_CELLRENDERER, ColRenderer);
			tempTF = this.displayStyle.getStyleTextFormat(DATAGRID_BODY_CSS.toLowerCase());					
			this.dataGrid.setRendererStyle("textFormat",tempTF);
	
			this.dataGrid.rowCount = this.rowCount;
			this.dataGrid.rowHeight = this.rowHeight;

			this.dataGrid.setSize(displayObj.width,displayObj.height);
			this.dataGrid.columns = this.glyphModel.getFields();
			// Define the grid columns
			this.defineColumns();
			this.dataGrid.dataProvider = dataTable;
			this.daObj[targetStr].addDisplayObject(this.dataGrid);
			this.daObj[targetStr].showDisplayArea();
		}
		
		private function defineColumns():void
		{
			for (var i:uint=0; i < this.dataGrid.columns.length; i++)
			{
				var tempCol:DataGridColumn;
				var styleName:String;
				tempCol = this.dataGrid.columns[i];
				styleName = this.displayDAName + "_" + tempCol.dataField;
				styleName = styleName.replace(/ /g,"_");
				if (this.glyphModel.getType(tempCol.dataField) == GlyphModel.TYPE_NUMERIC)
				{
					tempCol.sortOptions = Array.NUMERIC;
				}
				tempCol.headerText = (tempCol.dataField.indexOf(GlyphModel.RANK_LABEL) > 0) ? SHORT_RANK : tempCol.dataField;				
				if (this.displayStyle.hasStyle(styleName.toLowerCase()))
				{
					var tempObj:Object;
					tempObj = this.displayStyle.getStyle(styleName.toLowerCase());
					//org.wsimpson.ui.datagrid.ColRenderer
					tempCol.cellRenderer = ColRenderer;
					tempCol.width = tempObj[COL_WIDTH];
				} else
				{
					this.view.reportError(ScreenModel.STYLE_SCREEN_NOTFOUND,"Missing CSS style for = " + styleName);
				}
			}
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
		

	}			
}