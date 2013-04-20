package
{
import pie.graphicsLibrary.*;
import pie.uiElements.*;
import flash.events.*;
import Lens.LensTest;

public class Experiment
{

/* TestProject Framework Handle */
private var pieHandle:PIE;

/* This section contains Physics Parameters*/
private var PIEaspectRatio:Number;
private var worldOriginX:Number;
private var worldOriginY:Number;
private var worldWidth:Number;
private var worldHeight:Number;

/*This section contains Drawing Objects*/
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

/*Experiment Objects */
private var mainLens:LensTest; 
private var sourceO:PIEthickArrow; 
private var imageO:PIEthickArrow; 
[Embed(source = 'image/eye1.png')]
public static const eyeImagePtr:Class;
private var imageWidth:Number;

/* Ray Objects */
private var parallelRayS:PIEline;
private var parallelRayI:PIEline;
private var centerRayS:PIEline;
private var centerRayI:PIEline;
private var focusRayS:PIEline;
private var focusRayI:PIEline;
private var loadImage:PIEimage;


/*Corrective Lens object*/
private var convexLens:LensTest;
private var lensContainer:PIEroundedRectangle;
private var correctiveLensH:Number, correctiveLensR:Number, correctiveLensColor:uint;
private var parallelCorrR:PIEline, centerCorrR:PIEline, focusCorrR:PIEline;
private var rayEndS:Number;

/*UI objects*/
private var lensDefectButton:PIEradioButton, eyeDefectButton:PIEradioButton,normalEyeButton:PIEradioButton;
private var lensDefectLabel:PIElabel, eyeDefectLabel:PIElabel, displayTitle:PIElabel;
private var normalEyeLabel:PIElabel;
private var addLens:PIEbutton, corrLens:PIElabel;
private var instructionLabel:PIElabel,descriptionLabel:PIElabel;
private var corrLensName:PIElabel;


/*Display Objects:Display information about the experiment*/
private var focalLabel:PIElabel;
private var focalInputLabel:PIElabelledInput;
private var imageStatus:PIElabel;
private var imageStatusLabel:PIElabelledInput;
private var obDistLbl:PIElabel, obDistInpLbl:PIElabelledInput;
private var focalLength:Number,newFocalLength:Number;;
private var imageState:String;


public function Experiment(pie:PIE)
{
    /* Store handle of PIE Framework */
    pieHandle = pie;
	/* Call a PIE framework function to set the dimensions of the drawing area, right panel and bottom panel */
    /* We will reserve 100% width and 100%height for the drawing area */
    pieHandle.PIEsetDrawingArea(0.85,1.0);
	
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
    pieHandle.showExperimentName("Hypermetropia");
    pieHandle.showDeveloperName("Piyush Tiwari");

    /* Initialise World Origin and Boundaries */
    this.resetWorld();

    /* define the position of all the global (static) variables */
    /* Code in a single Function (recommended) for reuse */
    this.resetExperiment();

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
	rayEndS = mainLensX;
    sourceOX   = -70.0;
    sourceOH   = -5.0;
    
	imageOX = 31;
	/*Assuming the distance b/w lens and cornea to be 31cm
	 * calculate the focal length*/
	pieHandle.PIEresumeTimer();

	focalLength = ( -sourceOX * imageOX) / ( -sourceOX + imageOX);
	
	if ((sourceOX - mainLensX) > 0) this.focalLength = -this.focalLength;
    
	this.calculateImagePosition();
    this.calculateRayPositions();

}
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
	
	if (addLens.label == "Remove") 
	{
		addLens.label = "Add Lens";
		removeLens();
	}
    
	this.calculateImagePosition();
    this.calculateRayPositions();

}

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

public function calculateRayPositions():void
{
	var newPosition:Number = -20;
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
		if(focusCorrR != null) focusCorrR.setPIEvisible();
    }
	else
	{
		if (focusRayS != null) focusRayS.setPIEinvisible();
		if (focusRayI != null) focusRayI.setPIEinvisible();
		if (focusCorrR != null) focusCorrR.setPIEinvisible();
	}
	
	if (parallelCorrR != null)
	{
		parallelCorrR.changeLine(newPosition, sourceOH, newPosition, sourceOH);
		centerCorrR.changeLine(newPosition, -2, newPosition, -2);
		focusCorrR.changeLine(newPosition, imageOH + 1, newPosition, imageOH + 1);
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
	/*Ray animation without corrective lens*/
	if ( addLens.label == "Add Lens")
	{
		if ( parallelRayS.getPIEendX() < rayEndS)
		{
			parallelRayS.changeLine(sourceOX, sourceOH, parallelRayS.getPIEendX() + 1, sourceOH);
			imageO.setPIEinvisible();
		}
		if ( parallelRayI.getPIEendX() < imageOX && parallelRayS.getPIEendX() >= mainLensX )
		{
			parallelRayI.changeLine(mainLensX, sourceOH, parallelRayI.getPIEendX() + 1, imageOH);
		}
		if ( centerRayS.getPIEendX() < rayEndS &&  parallelRayI.getPIEendX() == imageOX) 
		{
			centerRayS.changeLine(sourceOX, sourceOH, centerRayS.getPIEendX() + 1, 0 );
		}
		if (centerRayS.getPIEendX() >= mainLensX && centerRayI.getPIEendX() < imageOX)
		{
			centerRayI.changeLine(mainLensX, 0, centerRayI.getPIEendX() + 1, imageOH);
		}
		if ( focusRayS.getPIEendX() < rayEndS && centerRayI.getPIEendX() == imageOX )
		{
			focusRayS.changeLine(sourceOX,sourceOH,focusRayS.getPIEendX()+1,imageOH);
		}
	
		if (focusRayI.getPIEendX() < imageOX && focusRayS.getPIEendX() >= mainLensX )
		{
			imageO.setPIEvisible();
			focusRayI.changeLine(mainLensX,imageOH,focusRayI.getPIEendX()+1,imageOH);
		}
	}
	
	/*Ray animation when corrective lens is added */
	else if (addLens.label == "Remove")
	{
		
		if ( parallelRayS.getPIEendX() < rayEndS)
		{
			parallelRayS.changeLine(sourceOX, sourceOH, parallelRayS.getPIEendX() + 1, sourceOH);
			imageO.setPIEinvisible();
		}
		if ( parallelCorrR.getPIEendX() < mainLensX && parallelRayS.getPIEendX() >= rayEndS )
		{
			parallelCorrR.changeLine(rayEndS, sourceOH, parallelCorrR.getPIEendX() + 1, sourceOH+1);
			
		}
		if ( parallelRayI.getPIEendX() < imageOX && parallelCorrR.getPIEendX() >= mainLensX )
		{
			parallelRayI.changeLine(mainLensX, sourceOH+1, parallelRayI.getPIEendX() + 1, imageOH);
		}
		if ( centerRayS.getPIEendX() < rayEndS &&  parallelRayI.getPIEendX() >= imageOX) 
		{
			centerRayS.changeLine(sourceOX, sourceOH, centerRayS.getPIEendX() + 1, -3 );
		}
		if ( centerCorrR.getPIEendX() < mainLensX && centerRayS.getPIEendX() >= rayEndS)
		{
			centerCorrR.changeLine(rayEndS, -3, centerCorrR.getPIEendX() + 1, 0);
		}
		if (centerCorrR.getPIEendX() >= mainLensX && centerRayI.getPIEendX() < imageOX)
		{
			centerRayI.changeLine(mainLensX, 0, centerRayI.getPIEendX() + 1, imageOH);
		}
		if ( focusRayS.getPIEendX() < rayEndS && centerRayI.getPIEendX() >= imageOX )
		{
			focusRayS.changeLine(sourceOX,sourceOH,focusRayS.getPIEendX()+1,imageOH+1);
		}
		if ( focusCorrR.getPIEendX() < mainLensX && focusRayS.getPIEendX() >= rayEndS )
		{
			focusCorrR.changeLine(rayEndS,imageOH+1,focusCorrR.getPIEendX()+1,imageOH+2);
		}
		
		if (focusRayI.getPIEendX() < imageOX && focusCorrR.getPIEendX() >= mainLensX )
		{
			imageO.setPIEvisible();
			focusRayI.changeLine(mainLensX,imageOH+2,focusRayI.getPIEendX()+1,imageOH);
		}
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
	
	imageState = "Clear Image";
    /* Set Default Colors */
    lensColor    = 0xB8860B;
    arrowColor   = 0xAA0000;
    sourceOColor = 0x00FF00;
    imageOColor  = 0x0000FF;
	
	pieHandle.PIEcreatePauseButton();
	pieHandle.PIEcreateResetButton();
	pieHandle.ResetControl.addClickListener(resetExp);
	

	/*Add image to the Display panel */
	var topLeftX:Number = -9, topLeftY:Number = -22;
	var maximumW:Number = 52, maximumH:Number = 75; 

	loadImage = new PIEimage(pieHandle,topLeftX,topLeftY,maximumW,maximumH,eyeImagePtr);
	pieHandle.addDisplayChild(loadImage);
	imageWidth = loadImage.width;
	loadImage.setPIEborder(false);
	
	/*Add horizontal line:Part of experiment object */
    centerLine = new PIEline(pieHandle, -(worldWidth / 2), 0, worldWidth / 2, 0, 0x000000, 1, 1.0);
    pieHandle.addDisplayChild(centerLine);
   
	//Lens Container and corrective lens 
	createLensContainer();
	
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
    imageO.setPIEinvisible();
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
	pieHandle.addDisplayChild(focusRayI);
	
	if (Math.abs(imageOH) > (mainLensH / 2))
	{
		focusRayS.setPIEinvisible();
		focusRayI.setPIEinvisible();
	}
	
	//Show some information about the experiment
	descriptionLabel = new PIElabel(pieHandle, "Hypermetropic Eye.\nFor Distance Objects\nImage forms on the retina", 15, 0xFFFFFF, 0xFF00FF);
	pieHandle.addDisplayChild(descriptionLabel);
	descriptionLabel.x = 400;
	descriptionLabel.y = 460;
	
	//Instructions for the experiment
	instructionLabel = new PIElabel(pieHandle, "*Remove corrective \nlens before \nchanging options", 10, 0xFFFFFF, 0x000000);
	pieHandle.addUIpanelChild(instructionLabel);
	instructionLabel.x = 7;
	instructionLabel.y = 400;
	
	//Title of the experiment
	displayTitle = new PIElabel(pieHandle, "Object:Long Distance", 20, 0xFFFFFF, 0x0000FF);
	
	
    /* */	
	pieHandle.addDisplayChild(displayTitle);
	displayTitle.x = 2 * worldWidth ;
	displayTitle.y = worldHeight / 2;
	
	/* */
	createDisplayLabels();
	
}

/* Show normal hypermetropic  eye:Distant Objects visible*/
private function normalEye(g:Number):void
{
	resetExp();
	adjustLens(19);
	loadImage.width = imageWidth;
	eyeDefectButton.mouseEnabled = true;
	imageStatusLabel.setInputText("Clear Image");
	displayTitle.text = "Object:Long distance";
	descriptionLabel.text = "Hypermetropic Eye.\nFor Distance Objects\nImage forms on the retina";
	
}

/* Demonstrate the eye defect:Eye ball shrinks*/
private function eyeDefect(value:Number):void
{
	resetExp();
	displayTitle.text = "Eye Defect";
	imageOX = 34;
	descriptionLabel.text = "Shrinking of eye ball.";
	imageStatusLabel.setInputText("Behind Retina");
	imageStatusLabel.setDisplayOnly(true);
	calculateRayPositions();
	calculateImagePosition();
	calculateFocalLength();
	adjustLens((sourceOX/10)+25);
	eyeDefectButton.mouseEnabled = false;
	loadImage.width = loadImage.width - imageWidth/10;
}

/*Demonstrate the lens defect: Eye Lens thin */
private function lensDefect(value:Number):void
{
	resetExp();
	displayTitle.text = "Lens Defect";
	imageStatusLabel.setInputText("Behind Retina");
	imageStatusLabel.setDisplayOnly(true);
	imageOX = 40;
	loadImage.width = imageWidth;
	descriptionLabel.text = "Thin Lens.Low Power";
	normalEyeButton.mouseEnabled = true;
	eyeDefectButton.mouseEnabled = true;
	//Eye lens fattens and creates image behind the eye
	adjustLens(17);
	calculateRayPositions();
	calculateImagePosition();
	calculateFocalLength();
	
	
}	

/* Create corrective lens and add it in UI Panel*/
private function createLensContainer():void
{
	correctiveLensColor = 0x0000FF;
	addLens = new PIEbutton(pieHandle, "Add Lens");
	addLens.width = 80;
	addLens.height = 30;
	addLens.x = 10;
	addLens.y = 240;
	pieHandle.addUIpanelChild(addLens);
	
	corrLens = new PIElabel(pieHandle, "Corrective \nLens",15,0xFFFFFF, 0x000000);
	pieHandle.addUIpanelChild(corrLens);
	corrLens.setLabelFColor(0x000000);
	corrLens.setLabelBColor(0xFFFFFF);
	corrLens.x = 10;
	corrLens.y = 20;
	
	var lensInfo:String = "Convex Lens\nPositive Power";
	corrLensName = new PIElabel(pieHandle, lensInfo, 13, 0xffffff, 0x0000FF);
	pieHandle.addUIpanelChild(corrLensName);
	corrLensName.x = 5;
	corrLensName.y = 200;
	convexLens = new LensTest(pieHandle, worldWidth/3, -worldHeight/4, mainLensH, mainLensR, mainLensR, correctiveLensColor);
	convexLens.changeFill(correctiveLensColor, 0.6);
	

	pieHandle.addUIpanelChild(convexLens);
	
	convexLens.x = 50;
	convexLens.y = 130;
	addLens.addClickListener(changeLensPosition);

}

/* Remove corrective lens*/
private function removeLens():void
{
	eyeDefectButton.mouseEnabled = true;
	lensDefectButton.mouseEnabled = true;
	if (displayTitle.text == "Eye Defect" || displayTitle.text == "Object:Long Distance")
	{
		imageOX = 31;
	}
	else
	{
			imageOX = 40;
	}
	addLens.label = "Add Lens";
	rayEndS = mainLensX;
	convexLens.x = 50;
	convexLens.y = 150;
	addLens.addClickListener(changeLensPosition);
	centerCorrR.visible = false;
	focusCorrR.visible = false;
	parallelCorrR.visible = false;
	imageStatusLabel.setDisplayOnly(true);
	imageStatusLabel.setInputText("Behind Retina");
	sourceOX = sourceO.getPIEendX();
	pieHandle.addUIpanelChild(convexLens);
	calculateRayPositions();
	calculateImagePosition();

	
}

/*Add corrective lens  */

public function changeLensPosition():void 
{
	var newPosition:Number = -20;
	addLens.label = "Remove";
	addLens.addClickListener(removeLens);
	pieHandle.addDisplayChild(convexLens);
	convexLens.changeLocation( newPosition, 0);

	eyeDefectButton.mouseEnabled = false;
	lensDefectButton.mouseEnabled = false;
		if (( -sourceOX) < 25)
	{
		sourceO.changeArrow(-25, 0, -25, sourceOH);
	}
	rayEndS = -20;
	
	parallelCorrR = new PIEline(pieHandle, newPosition, sourceOH, newPosition, sourceOH, 0xFF0000, 1, 1.00);
    pieHandle.addDisplayChild(parallelCorrR);
   
    centerCorrR = new PIEline(pieHandle, newPosition, -2, newPosition, -2, 0xFF0000, 1, 1.0);
    pieHandle.addDisplayChild(centerCorrR);
    
    focusCorrR = new PIEline(pieHandle, newPosition, imageOH+1, newPosition, imageOH+1, 0xFF0000, 1, 1.0);
    pieHandle.addDisplayChild(focusCorrR);
	if(displayTitle.text != "Eye Defect")
		imageOX = 31;
	else
	{
		imageOX = 26.5;
	}
	imageState = "On Retina";
	
	parallelRayI.changeLine(mainLensX,sourceOH,mainLensX, sourceOH);
	centerRayI.changeLine(mainLensX,0,mainLensX,0);
	focusRayI.changeLine(mainLensX, imageOH + 2, mainLensX, imageOH+2);

	parallelCorrR.changeLine(newPosition, sourceOH, newPosition, sourceOH);
	centerCorrR.changeLine(newPosition, -2, newPosition, -2);
	focusCorrR.changeLine(newPosition, imageOH + 1, newPosition, imageOH + 1);
	
	calculateRayPositions();
	calculateImagePosition();
	imageStatusLabel.setInputText("Clear Image");
	imageStatusLabel.setDisplayOnly(true);
	imageState = "Clear Image";

}

/*Change color of the object when it is grabbed*/
private function changeArrowColor(clickX:Number, clickY:Number):void
{
	sourceOColor = 0xFF0000;
}


/*Adjust lens according to accomodation power of eye*/
private function adjustLens(heightLens:Number):void
{
	mainLens.changeHeight(heightLens);
	
}

/*Calculate focal length after object changes position*/
private function calculateFocalLength():void
{
	
	focalLength = ( -sourceOX * imageOX) / ( -sourceOX + imageOX);
	focalInputLabel.setInputText(String(Math.round(focalLength * 100) / 100));

	
}

/*Change the arrow position*/
private function changeArrowPosition(newX:Number, newY:Number, displacementX:Number, displacementY:Number):void
{
	
	if((addLens.label == "Remove" && (-(newX) >25)) || (-(newX) > 8 && addLens.label == "Add Lens") )
	{
		sourceO.changeArrow(newX, 0, newX, sourceOH);
		sourceOX = newX;
		obDistInpLbl.setInputText(String( -Math.round(sourceOX * 100) / 100));
		obDistInpLbl.setDisplayOnly(true);
	
	}

	
	if (( -sourceOX) < 25 && imageState == "Clear Image")
	{
		imageStatusLabel.setInputText("Blurred Image");
		imageStatusLabel.setDisplayOnly(true);
		adjustLens(22.5);
	}
	else if( imageState == "On Retina")
	{
		imageStatusLabel.setInputText("Clear Image");
		imageStatusLabel.setDisplayOnly(true);
		adjustLens((sourceOX/10)+25);
		
	}
	else 
	{
		imageStatusLabel.setInputText("Behind Retina");
		imageStatusLabel.setDisplayOnly(true);
		adjustLens((sourceOX/10)+25);
	}
	
	if ((displayTitle.text == "Eye Defect" || displayTitle.text == "Lens Defect") && addLens.label == "Add Lens")
	{
		imageStatusLabel.setInputText("Behind Retina");
	}

	if(displayTitle.text != "Eye Defect" && displayTitle.text != "Lens Defect")
	{
		if (( -sourceOX) < 45 && addLens.label == "Add Lens" )
		{
			imageStatusLabel.setInputText("Behind Retina");
			imageStatusLabel.setDisplayOnly(true);
			imageOX = 36;
			displayTitle.text = "Object:Short Distance";
		}
		else
		{
			displayTitle.text = "Object:Long Distance";
			imageStatusLabel.setInputText("Clear Image");
			imageStatusLabel.setDisplayOnly(true);
			imageOX = 31;
		}
	}
	
	
	if((addLens.label == "Remove" && (-(sourceOX) >25)) || (-(sourceOX) > 8 && addLens.label == "Add Lens") )
	{
		pieHandle.PIEpauseTimer();
	calculateRayPositions();
	imageO.setPIEinvisible();
	calculateImagePosition();
	calculateFocalLength();
	pieHandle.PIEresumeTimer();
	}

}

/*Fix arrow position*/
private function fixArrowPosition(newX:Number, newY:Number, displacementX:Number, displacementY:Number):void
{
	this.changeArrowPosition(newX, newY, displacementX, displacementY);
}

/*Create UI Objects*/
private function createUIObjects():void
{
	
	eyeDefectButton = new PIEradioButton(pieHandle, "Button", "Eye Defect", 1);
	lensDefectButton = new PIEradioButton(pieHandle, "Button", "Lens Defect", 1);
    eyeDefectLabel = new PIElabel(pieHandle, "Eye Defect", 10, 0xFFFFFF, 0xFF0000);
	lensDefectLabel = new PIElabel(pieHandle, "Lens Defect", 10, 0xFFFFFF, 0xFF0000);
	normalEyeButton = new PIEradioButton(pieHandle, "Button", "Normal Eye", 1);
	normalEyeLabel = new PIElabel(pieHandle, "Distant Object", 10, 0xFFFFFF, 0xFF0000);
	
	eyeDefectButton.x = 10;
	eyeDefectButton.y = 300;
	eyeDefectLabel.x = 27;
	eyeDefectLabel.y = 294;
	
	lensDefectButton.x = 10;
	lensDefectButton.y = 330;
	lensDefectLabel.x = 27;
	lensDefectLabel.y = 324;

	normalEyeButton.x = 10;
	normalEyeButton.y = 354;
	normalEyeLabel.x = 27;
	normalEyeLabel.y = 354;
	
	normalEyeButton.addClickListener(normalEye);
	eyeDefectButton.addClickListener(eyeDefect);
	lensDefectButton.addClickListener(lensDefect);

	pieHandle.addUIpanelChild(eyeDefectButton);
	pieHandle.addUIpanelChild(lensDefectButton);
	pieHandle.addUIpanelChild(eyeDefectLabel);
	pieHandle.addUIpanelChild(lensDefectLabel);
	pieHandle.addUIpanelChild(normalEyeLabel);
	pieHandle.addUIpanelChild(normalEyeButton);
}

/*Create Display labels and objects*/
private function createDisplayLabels():void
{
		//Display Labels that show information about the experiment
		
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
