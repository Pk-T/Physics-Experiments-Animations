package
{
import pie.graphicsLibrary.*;
import pie.uiElements.*;
import Lens.LensTest;
import flash.events.*;

public class Experiment
{
/* TestProject Framework Handle */
private var pieHandle:PIE;

/**
 * This section contains Physics Parameters
 */
private var PIEaspectRatio:Number;
private var worldOriginX:Number;
private var worldOriginY:Number;
private var worldWidth:Number;
private var worldHeight:Number;

/**
 *
 * This section contains Drawing Objects
 *
 */
/* Display Parameters */
private var displayBColor:uint;
private var displayFColor:uint;
private var UIpanelBColor:uint;
private var UIpanelFColor:uint;
private var lensColor:uint;
private var arrowColor:uint;
private var sourceOColor:uint;
private var imageOColor:uint;

/**
 *
 * This section contains current state variables
 *
 */
/* Position Variables */
private var mainLensX:Number;
private var mainLensH:Number;
private var mainLensR:Number;
private var sourceOX:Number;
private var sourceOH:Number;
private  var imageOX:Number;
private var newimageOX:Number;
private var imageOH:Number;


/**
Experiment objects
 */
private var mainLens:LensTest; 
private var sourceO:PIEthickArrow; 
private var imageO:PIEthickArrow; 
[Embed(source = 'image/eye1.png')]
public static const eyeImagePtr:Class;

/* Ray Objects */
private var parallelRayS:PIEline;
private var parallelRayI:PIEline;
private var centerRayS:PIEline;
private var centerRayI:PIEline;
private var focusRayS:PIEline;
private var focusRayI:PIEline;
private var loadImage:PIEimage;


/*UI objects*/
private var focalLabel:PIElabel;
private var focalInputLabel:PIElabelledInput;
private var imageStatus:PIElabel;
private var imageStatusLabel:PIElabelledInput;
private var thickness:Number;
private var obDistLbl:PIElabel, obDistInpLbl:PIElabelledInput;
private var descriptionLabelTop:PIElabel, descriptionLabelBottom:PIElabel;
private var focalLength:Number,newFocalLength:Number;
	
public function Experiment(pie:PIE)
{
    /* Store handle of PIE Framework */
    pieHandle = pie;

    /* Call a PIE framework function to set the dimensions of the drawing area, right panel and bottom panel */
    /* We will reserve 100% width and 100%height for the drawing area */
    pieHandle.PIEsetDrawingArea(1.0,1.0);
	
    /* Set the foreground ande background colours for the three areas */
    /* (Different panels are provided and you can set individually as well) */
    displayBColor = 0XFFFFFF;
    displayFColor = 0X000000;
    UIpanelBColor = 0XFFFFFF;
    UIpanelFColor = 0XCCCCCC;
    pieHandle.PIEsetDisplayColors(displayBColor, displayFColor);
    pieHandle.PIEsetUIpanelColors(UIpanelBColor, UIpanelFColor);
	//pieHandle.PIEsetControlColors(UIpanelBColor, UIpanelFColor);
	
	
    /* Set the Experiment Details */
    pieHandle.showExperimentName("Power Accomodation of EYE");
    pieHandle.showDeveloperName("Piyush Tiwari");

    /* Initialise World Origin and Boundaries */
    this.resetWorld();

    /* define the position of all the global (static) variables */
    /* Code in a single Function (recommended) for reuse */
    this.resetExperiment();
	pieHandle.PIEcreatePauseButton();
	pieHandle.PIEcreateResetButton();
	pieHandle.ResetControl.addClickListener(resetExp);
    /* The PIE framework provides default pause/play/reset buttons in the bottom panel */
    /* If you need any more experiment control button such as next frame etc., call the function code here */
    /* Create Experiment Objects */
    createExperimentObjects();
	
	/* Create UI Objects */
	createUIObjects();
	 
}

/**
 *
 * This function is called by the PIE framework to reset the experiment to default values
 * It defines the values of all the global (static) variables
 *
 */
public function resetExperiment():void
{
    /* Initialise Physics Parameters */
    mainLensX = 0.0;
    mainLensH = 19.0;
    mainLensR = 20.0;

    sourceOX   = -70.0;
    sourceOH   = -5.0;
    
	imageOX = 31;
	pieHandle.PIEresumeTimer();
	/*Assuming the distance b/w lens and cornea to be 31cm
	 * calculate the focal length*/
	focalLength = ( -sourceOX * imageOX) / ( -sourceOX + imageOX);
	
	if ((sourceOX - mainLensX) > 0) this.focalLength = -this.focalLength;
    this.calculateImagePosition();
    this.calculateRayPositions();

}

/*Reset the experiment called by the Reset button*/
public function resetExp():void
{
    /* Initialise Physics Parameters */
    mainLensX = 0.0;
    mainLensH = 19.0;
    mainLensR = 20.0;

    sourceOX   = -70.0;
    sourceOH   = -5.0;
    sourceO.changeArrow(sourceOX, 0, sourceOX, sourceOH);
	imageOX = 31;
	imageO.changeArrow(imageOX, 0, imageOX, imageOH);
	/*Assuming the distance b/w lens and cornea to be 31cm
	 * calculate the focal length*/
	pieHandle.PIEresumeTimer();

	focalLength = ( -sourceOX * imageOX) / ( -sourceOX + imageOX);
	
	if ((sourceOX - mainLensX) > 0) this.focalLength = -this.focalLength;

    this.calculateImagePosition();
    this.calculateRayPositions();

}

/*Calculate image position based on the position of the object position*/
public function calculateImagePosition():void
{
    newimageOX    = mainLensX + (focalLength * (sourceOX - mainLensX)) / (focalLength + (sourceOX - mainLensX));
    imageOH    = (imageOX - mainLensX) * sourceOH / (sourceOX - mainLensX);
    if (Math.abs(this.imageOH) <= (worldHeight / 2))
    {    /* Draw Parallel Rays */
        if (imageO != null) { imageO.changeArrow(imageOX, 0, imageOX, imageOH); imageO.setPIEvisible();  }
    }
	
	else
	{
		if (imageO != null) { imageO.setPIEinvisible(); }
	}
	
}

/*Draw ray diagram*/
public function calculateRayPositions():void
{
    if ((this.mainLensH / 2) > Math.abs(this.sourceOH))
    {    /* Draw Parallel Rays */
        if (parallelRayS != null) { parallelRayS.changeLine(sourceOX, sourceOH, sourceOX, sourceOH); parallelRayS.setPIEvisible(); imageO.setPIEinvisible(); }
        if (parallelRayI != null) { parallelRayI.changeLine(mainLensX, sourceOH, mainLensX, sourceOH); parallelRayI.setPIEvisible(); }
    }
	else
	{
		if (parallelRayS != null) parallelRayS.setPIEinvisible();
		if (parallelRayI != null) parallelRayI.setPIEinvisible();
	}
    
	/* Draw Center Rays */
    if (centerRayS != null) { centerRayS.changeLine(sourceOX, sourceOH, sourceOX, sourceOH); centerRayS.setPIEvisible(); }
    if (centerRayI != null) { centerRayI.changeLine(mainLensX, 0, mainLensX, 0); centerRayI.setPIEvisible(); }
	
    if ((this.mainLensH / 2) > Math.abs(this.imageOH))
    {    /* Draw Focus Rays */
        if (focusRayS != null) { focusRayS.changeLine(sourceOX, sourceOH, sourceOX, sourceOH); focusRayS.setPIEvisible(); }
        if (focusRayI != null) { focusRayI.changeLine(mainLensX, imageOH, mainLensX, imageOH); focusRayI.setPIEvisible(); }
    }
	else
	{
		if (focusRayS != null) focusRayS.setPIEinvisible();
		if (focusRayI != null) focusRayI.setPIEinvisible();
	}
}

/*
 * This function resets the world boundaries and adjusts display to match the world boundaries
 */
public function resetWorld():void
{
    /* get the PIE drawing area aspect ratio (width/height) to model the dimensions of our experiment area */
    PIEaspectRatio = pieHandle.PIEgetDrawingAspectRatio();

    /* Initialise World Origin and Boundaries */
    worldWidth   = 150;                            /* 250 centimeters Width */
    worldHeight  = worldWidth / PIEaspectRatio;   /* match world aspect ratio to PIE aspect ratio */
    worldOriginX = (-worldWidth/2);               /* Origin at center */
    worldOriginY = (-worldHeight/2);
    pieHandle.PIEsetApplicationBoundaries(worldOriginX,worldOriginY,worldWidth,worldHeight);
}

/**
 *
 * This function is called by the PIE framework after every system Timer Iterrupt
 *
 */
public function nextFrame():void
{
	/*Animate the ray diagram*/
	if ( parallelRayS.getPIEendX() < mainLensX)
	{
		parallelRayS.changeLine(sourceOX, sourceOH, parallelRayS.getPIEendX() + 1, sourceOH);
		imageO.setPIEinvisible();
	}
	if ( parallelRayI.getPIEendX() < imageOX && parallelRayS.getPIEendX() >= mainLensX )
	{
		parallelRayI.changeLine(mainLensX, sourceOH, parallelRayI.getPIEendX() + 1, imageOH);
	}
	if ( centerRayS.getPIEendX() < mainLensX &&  parallelRayI.getPIEendX() == imageOX) 
	{
		centerRayS.changeLine(sourceOX, sourceOH, centerRayS.getPIEendX() + 1, 0 );
	}
	if (centerRayS.getPIEendX() >= mainLensX && centerRayI.getPIEendX() < imageOX)
	{
		centerRayI.changeLine(mainLensX, 0, centerRayI.getPIEendX() + 1, imageOH);
	}
	if ( focusRayS.getPIEendX() < mainLensX && centerRayI.getPIEendX() == imageOX )
	{
		focusRayS.changeLine(sourceOX,sourceOH,focusRayS.getPIEendX()+1,imageOH);
	}
	
	if (focusRayI.getPIEendX() < imageOX && focusRayS.getPIEendX() >= mainLensX )
	{
		imageO.setPIEvisible();
		focusRayI.changeLine(mainLensX,imageOH,focusRayI.getPIEendX()+1,imageOH);
	}
}

/**
 *
 * This function is called to create the experiment objects
 * It calls the appropriate constructors to create drawing objects
 * It also sets callback variables to point to callback code
 *
 */
private function createExperimentObjects():void
{
	var centerLine:PIEline;

    /* Set Default Colors */
    lensColor    = 0xB8860B;
    arrowColor   = 0xAA0000;
    sourceOColor = 0x00FF00;
    imageOColor  = 0x0000FF;
	
	
	/*Display the image of an eye on the display panel*/
	var topLeftX:Number = -9, topLeftY:Number = -22;
	var maximumW:Number = 52, maximumH:Number = 75;

	loadImage = new PIEimage(pieHandle,topLeftX,topLeftY,maximumW,maximumH,eyeImagePtr);
	pieHandle.addDisplayChild(loadImage);
	loadImage.setPIEborder(false);
	
	/*Show description of cases of accomodation power of the eye lens*/
	var textTop:String = "As object nears the lens,\nthe lens gets thick.\n\nThus Focal Length:Decreases\n and Power:Increases";
	descriptionLabelTop = new PIElabel(pieHandle, textTop, 13, 0xFFFFFF, 0x000000);
	var textBottom:String = "As object distances from the lens,\nthe lens gets thin.\n\nThus Focal Length:Increases\n and Power:Decreases";
	descriptionLabelBottom = new PIElabel(pieHandle, textBottom, 13, 0xFFFFFF, 0x000000);
	pieHandle.addDisplayChild(descriptionLabelTop);
	pieHandle.addDisplayChild(descriptionLabelBottom);
	descriptionLabelTop.x = 500;
	descriptionLabelTop.y =  20;
	
	descriptionLabelBottom.x = 500;
	descriptionLabelBottom.y = 450;
  
    centerLine = new PIEline(pieHandle, -(worldWidth / 2), 0, worldWidth / 2, 0, 0x000000, 1, 1.0);
    pieHandle.addDisplayChild(centerLine);
   
	/* Create Lens */
    mainLens = new LensTest(pieHandle, mainLensX, 0, mainLensH, mainLensR, mainLensR, lensColor);
    mainLens.changeFill(lensColor,0.6);
    pieHandle.addDisplayChild(mainLens);
	
    /* Create Source and Image */
    sourceO = new PIEthickArrow(pieHandle, sourceOX, 0, sourceOX, sourceOH, arrowColor, 1.0);
    pieHandle.addDisplayChild(sourceO);
	sourceO.addGrabListener(changeArrowColor);
	sourceO.addDragListener(changeArrowPosition);
	sourceO.addDropListener(fixArrowPosition);
	
    imageO = new PIEthickArrow(pieHandle, imageOX, 0, imageOX, imageOH, arrowColor, 1.0);
    pieHandle.addDisplayChild(imageO);

    /* Create Rays */
    parallelRayS = new PIEline(pieHandle, sourceOX, sourceOH,sourceOX, sourceOH, sourceOColor, 1, 1.00);
    pieHandle.addDisplayChild(parallelRayS);
    parallelRayI = new PIEline(pieHandle, mainLensX, sourceOH, mainLensX, sourceOH, imageOColor, 1, 1.0);
    pieHandle.addDisplayChild(parallelRayI);
    centerRayS = new PIEline(pieHandle, sourceOX, sourceOH, sourceOX, sourceOH, sourceOColor, 1, 1.0);
    pieHandle.addDisplayChild(centerRayS);
    centerRayI = new PIEline(pieHandle, mainLensX, 0, mainLensX, 0, imageOColor, 1, 1.0);
    pieHandle.addDisplayChild(centerRayI);
    focusRayS = new PIEline(pieHandle, sourceOX, sourceOH, sourceOX, sourceOH, sourceOColor, 1, 1.0);
    pieHandle.addDisplayChild(focusRayS);
    focusRayI = new PIEline(pieHandle, mainLensX, imageOH, mainLensX, imageOH, imageOColor, 1, 1.0);

	if (Math.abs(imageOH) > (mainLensH / 2))
	{
		focusRayS.setPIEinvisible();
		focusRayI.setPIEinvisible();
	}
    pieHandle.addDisplayChild(focusRayI);
	
	
}

/*Change the colour of the object when grabbed*/
private function changeArrowColor(clickX:Number, clickY:Number):void
{
	sourceOColor = 0xFF0000;
}


/*Adjust height and width of the lens*/
private function adjustLens(heightLens:Number):void
{
	mainLens.changeHeight(heightLens);
	
}

private function calculateFocalLength():void
{
	
	focalLength = ( -sourceOX * imageOX) / ( -sourceOX + imageOX);
	focalInputLabel.setInputText(String(Math.round(focalLength * 100) / 100));
	focalInputLabel.setDisplayOnly(true);
	
	
}

/*Change the position of the object when dragged*/
private function changeArrowPosition(newX:Number, newY:Number, displacementX:Number, displacementY:Number):void
{
	if ( -(newX) > 15) 
	{
		sourceO.changeArrow(newX, 0, newX, sourceOH);
		sourceOX = newX;
		obDistInpLbl.setInputText(String( -Math.round(sourceOX * 100) / 100));
		obDistInpLbl.setDisplayOnly(true);
	}

	
	if (( -sourceOX) < 25 )
	{
		imageStatusLabel.setInputText("Blurred Image");
		imageStatusLabel.setDisplayOnly(true);
		adjustLens(22.5);
	}
	else
	{
		imageStatusLabel.setInputText("Clear Image");
		imageStatusLabel.setDisplayOnly(true);
		adjustLens((sourceOX/10)+25);
		
	}
	
	if ( -(sourceOX) > 15) 
	{
		pieHandle.PIEpauseTimer();
		calculateRayPositions();
		imageO.setPIEinvisible();
		calculateImagePosition();
		calculateFocalLength();
		pieHandle.PIEresumeTimer();
	}
	
}

private function fixArrowPosition(newX:Number, newY:Number, displacementX:Number, displacementY:Number):void
{
	this.changeArrowPosition(newX, newY, displacementX, displacementY);
}

/*Create UI objects*/
private function createUIObjects():void
	{
		//Adding the UI features
		
		focalLabel = new PIElabel(pieHandle, "Focal Length:", 15, 0xFFFFFF, 0x000000);
		focalInputLabel = new PIElabelledInput(pieHandle, "", String(Math.round(focalLength * 100) / 100), 0, 7, 0xFFFFFF);
		
		focalLabel.x = 20;
		focalLabel.y = 430;
		focalInputLabel.x = 120;
		focalInputLabel.y = 430;
		focalInputLabel.setDisplayOnly(true);
		pieHandle.addDisplayChild(focalLabel);
		pieHandle.addDisplayChild(focalInputLabel);
		
		
		imageStatus = new PIElabel(pieHandle, "Image Status:", 15, 0xFFFFFF, 0x000000);
		imageStatus.x = 20;
		imageStatus.y = 470;
		imageStatusLabel = new PIElabelledInput(pieHandle, "", "Clear Image", 0, 15, 0xFFFFFF);
		imageStatusLabel.setLabelSize(6.5);
		imageStatusLabel.setLabelItalic(true);
		imageStatusLabel.x = 120;
		imageStatusLabel.y = 470;
		pieHandle.addDisplayChild(imageStatusLabel);
		pieHandle.addDisplayChild(imageStatus);
		imageStatusLabel.setDisplayOnly(true);
		
		
		obDistInpLbl = new PIElabelledInput(pieHandle, "", "", 0, 7, 0xFFFFFF);
		obDistInpLbl.x = 90;
		obDistInpLbl.y = 60;

		obDistInpLbl.setInputText(String( -sourceOX));
		obDistInpLbl.setDisplayOnly(true);
		pieHandle.addDisplayChild(obDistInpLbl);
		
		obDistLbl = new PIElabel(pieHandle, "Object \nDistance:", 15, 0xFFFFFF, 0x000000);
		obDistLbl.x = 20;
		obDistLbl.y = 50;
		pieHandle.addDisplayChild(obDistLbl);
	}


}   /* End of Class experiment */

}
