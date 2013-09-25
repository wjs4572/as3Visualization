package org.wsimpson.ui.cell

/*
** Title:	GradientCell.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.ColorUtil;
	import org.wsimpson.ui.cell.ColorCell;
	import flash.display.GradientType;
	
	public class GradientCell extends ColorCell
	{
        private var _debugger:DebugUtil;
        private var alphas:Array;
        private var colors:Array;
        private var ratios:Array;
        private var fillType:String;

		// Constructor
		public function GradientCell()
		{
			super();
			//this._debugger = DebugUtil.getInstance();
			//this.init();
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		
		/**
		*  Name:  	drawCircle
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/		
		public function drawGradientCircle():void {
			var halfSize:uint = Math.round(this.cellWidth/2);
			this.graphics.clear();			
			this.graphics.beginGradientFill(this.fillType,this.colors,this.alphas,this.ratios);
			this.graphics.drawEllipse(halfSize, halfSize, halfSize, halfSize);
			this.graphics.endFill();
			//this.refreshLayout();	
		}
		/**
		*  Name:  	drawEllipse
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/			
		public function drawGradientEllipse():void {
			this.graphics.clear();		
			this.graphics.beginGradientFill(this.fillType,this.colors,this.alphas,this.ratios);
			this.graphics.drawEllipse(0, 0, this.cellWidth, this.cellHeight);
			this.graphics.endFill();
			this.refreshLayout();
		}
		
		/**
		*  Name:  	drawRoundRect
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/	
		public function drawGradientRoundRect():void {
			this.graphics.clear();		
			this.graphics.beginGradientFill(this.fillType,this.colors,this.alphas,this.ratios);
			this.graphics.drawRoundRect(0, 0, this.cellWidth, this.cellHeight, this.cornerRadius);
			this.graphics.endFill();
			this.refreshLayout();
		}

		/**
		*  Name:  	drawRect
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/	
		public function drawGradientRect():void {
			this.graphics.clear();		
			this.graphics.beginGradientFill(this.fillType,this.colors,this.alphas,this.ratios);
			this.graphics.drawRect(0, 0, this.cellWidth, this.cellHeight);
			this.graphics.endFill();
			this.refreshLayout();
		}

		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/

	
        // private function init():void {
			// this.colors = [0x000000,0xfffff];
			// this.alphas = [0,100];
			// this.ratios = [0,(255/2)];
			// this.fillType = GradientType.LINEAR;
		// }
    }
}