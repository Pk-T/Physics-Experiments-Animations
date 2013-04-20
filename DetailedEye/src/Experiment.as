package
{
import flash.display.Sprite;
import flash.ui.Mouse;
import pie.graphicsLibrary.*;
import pie.uiElements.*;
import flash.events.*;

public class Experiment
{
	
/* TestProject Framework Handle */
private var pieHandle:PIE;
private var imageLoader:PIEimage;
private var testFrame:Sprite, testFrame2:Sprite;


/* This section contains Physics Parameters */
private var PIEaspectRatio:Number;
private var worldOriginX:Number;
private var worldOriginY:Number;
private var worldWidth:Number;
private var worldHeight:Number;

/* UI Panel Object*/
private var quizButton:PIEbutton;
private var submitQuiz:PIEbutton, diagButton:PIEbutton;
private var oldX:Number, oldY:Number;
private var instructionLabel:PIElabel;
private var nameParts:PIEbutton, selectPart:PIEbutton;
/*Quiz Objects*/
private var qQuiz:Array, qAns:Array, quizTitle:PIElabel;
private var imageLoad:Array;
private var ansBox:Array;
private var showAnsButton:PIEbutton;
private var quizBox:PIEroundedRectangle;

/* This section contains Drawing Objects*/

/* Display Parameters */
private var displayBColor:uint;
private var displayFColor:uint;
private var UIpanelBColor:uint;
private var UIpanelFColor:uint;
private var eyeTitle:PIElabel;
private var newImageLoader:PIEimage;

//Interactive session:Test 1 Variables and Objects
private var test1Title:PIElabel;
private var testEye:PIEimage;
private var partLabel:Array;

//Interactive session:Test2 Variables and objects
private var test2Title:PIElabel;
private var rectHighlight:Array, identifyLabel:PIElabelledInput, partNameLabel:PIElabel;
private var parts:Array;


public function Experiment(pie:PIE)
{
    /* Store handle of PIE Framework */
    pieHandle = pie;
    /* Call a PIE framework function to set the dimensions of the drawing area, right panel and bottom panel */
    /* We will reserve 100% width and 100%height for the drawing area */
    pieHandle.PIEsetDrawingArea(0.87,1.0);
	
    /* Set the foreground ande background colours for the three areas */
    /* (Different panels are provided and you can set individually as well) */
    displayBColor = 0XFFFFFF;
    displayFColor = 0X000000;
    UIpanelBColor = 0XFFFFFF;
    UIpanelFColor = 0XFFFFFF;
	
    pieHandle.PIEsetDisplayColors(displayBColor, displayFColor);
    pieHandle.PIEsetUIpanelColors(UIpanelBColor, UIpanelFColor);
	//pieHandle.PIEsetControlColors(UIpanelBColor, UIpanelFColor);

	
    /* Set the Experiment Details */
    pieHandle.showExperimentName("Detailed Eye");
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
	
}


/**
 *
 * This function is called by the PIE framework to reset the experiment to default values
 * It defines the values of all the global (static) variables
 *
 */
public function resetExperiment():void
{
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
   // pieHandle.PIEsetApplicationBoundaries(worldOriginX,worldOriginY,worldWidth,worldHeight);
}

public function nextFrame():void
{
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

	/*Load both images:Labelled and Unlabelled diagram*/
	imageLoader = new PIEimage(pieHandle, 50, 130, 551, 323, imageLocation.eyeImgPtr);
	newImageLoader = new PIEimage(pieHandle, 50, 130, 551, 323, imageLocation.blankEyeImgPtr);
	newImageLoader.changeBorderColor(0xFFFFFF);
	pieHandle.addDisplayChild(imageLoader);

	//Define few parts of the eye for quiz
	parts= new Array("Pupil", "Ciliary Muscles", "Cornea", "Optic Nerve", "Retina");
	
	partLabel = new Array(5);
	
	//Create two separate frames
	testFrame = new Sprite();
	testFrame2 = new Sprite();
	
	//Display title
	eyeTitle = new PIElabel(pieHandle, "Labelled Eye Diagram",20, 0xFFFFFF, 0x0000FF);
	pieHandle.addDisplayChild(eyeTitle);
	eyeTitle.x = 250;
	eyeTitle.y = 40;
	
	quizButton = new PIEbutton(pieHandle, "Quiz");
	quizButton.width = 70;
	quizButton.height = 30;
	quizButton.addClickListener(validateQuizPanel);
	pieHandle.addUIpanelChild(quizButton);
	quizButton.x = 10;
	quizButton.y = 30;
	
	for (var i:Number = 0; i < 5; i++)
	{
		partLabel[i] = new PIElabelledInput(pieHandle, String(i+1), "", 0, 16, 0xFFFFFF);
	}
	
	
	//Draw clickable parts
	rectHighlight = new Array(5);
	rectHighlight[0] = new PIErectangle(pieHandle, 50, 278, 80, 50, 0x00FF00);
	rectHighlight[1] = new PIErectangle(pieHandle, 330, 130, 50, 50, 0x00FF00);	
	rectHighlight[2] = new PIErectangle(pieHandle, 130, 330, 30, 50, 0x00FF00);
	rectHighlight[3] = new PIErectangle(pieHandle, 450, 320, 120, 50, 0x00FF00);	
	rectHighlight[4] = new PIErectangle(pieHandle, 420, 250, 40, 50, 0x00FF00);
	
	var text:String = "Name the parts shown in the figure.Green:Correct Answer";
	test1Title = new PIElabel(pieHandle, text, 15, 0xFFFFFF, 0x0000FF);

	var partName:String = "Pupil";
	identifyLabel = new PIElabelledInput(pieHandle, "", partName, 0, 15, 0xFFFFFF);
	
	text = "Click on the rectangle to identify given part name.\nClick on label to change part name or Test2 to try again.";
	test2Title = new PIElabel(pieHandle, text, 15, 0xFFFFFF, 0x0000FF);
	
	partNameLabel = new PIElabel(pieHandle, "Identify: ", 15, 0xFFFFFF, 0xFF0000);

	var qTitle:String = "Drag the options below to their correct functions";
	quizTitle = new PIElabel(pieHandle, qTitle ,20, 0xFFFFFF, 0x0000FF);
	
	quizBox = new PIEroundedRectangle(pieHandle, 10, 80, 600, 370, 0xFFFFFF);

	nameParts = new PIEbutton(pieHandle, "Test 1");
	pieHandle.addUIpanelChild(nameParts);
	nameParts.width = 70;
	nameParts.height = 30;
	nameParts.x = 10;
	nameParts.y = 70;
	nameParts.addClickListener(	createTest1);

    selectPart = new PIEbutton(pieHandle, "Test 2");
	pieHandle.addUIpanelChild(selectPart);
	selectPart.width = 70;
	selectPart.height = 30;
	selectPart.x = 10;
	selectPart.y = 110;
	selectPart.addClickListener(createTest2);
	
	text = "*:To restart \nselect option\nagain";
	instructionLabel = new PIElabel(pieHandle, text, 13, 0xFFFFFF, 0x000000);
	pieHandle.addUIpanelChild(instructionLabel);
	instructionLabel.x = 5;
	instructionLabel.y = 330;
	createquizFrame();

	

}

//Create Interactive sessions
private function createTest1():void
{
	
	showDiagram();
	testFrame.visible = true;
	if(partNameLabel != null)
	partNameLabel.visible = false;
	identifyLabel.visible = false;
	eyeTitle.visible = false;
	newImageLoader.visible = true;
	imageLoader.visible = false;

	testFrame.addChild(test1Title);
	test1Title.x = worldWidth ;
	test1Title.y = 50;
	test1Title.visible = true;
	
	testFrame.addChild(newImageLoader);
	
	for (var i:Number = 0; i < 5; i++)
	{
		partLabel[i].visible = true;
		testFrame.addChild(partLabel[i]);
		partLabel[i].addChangeListener(verifyAnswer);

	}
	
	partLabel[0].x = 0;
	partLabel[0].y = 278;
	
	partLabel[1].x = 270;
	partLabel[1].y = 145;
	
	partLabel[2].x = 420;
	partLabel[2].y = 285;
	
	partLabel[3].x = 0;
	partLabel[3].y = 355;
	
	partLabel[4].x = 0;
	partLabel[4].y = 308;

	pieHandle.addDisplayChild(testFrame);

}

/*Check if the answer is correct*/
private function verifyAnswer(hel:Object):void
{
	
	if (partLabel[0].getInputText().toLowerCase() == "pupil")
	{
		partLabel[0].setDisplayOnly(true);
		partLabel[0].setTextBColor(0x00FF00);
		
	}
	if (partLabel[1].getInputText().toLowerCase() == "cilliary muscles")
	{
		partLabel[1].setDisplayOnly(true);
		partLabel[1].setTextBColor(0x00FF00);

	}
	if (partLabel[2].getInputText().toLowerCase() == "optic nerve")
	{
		partLabel[2].setDisplayOnly(true);
		partLabel[2].setTextBColor(0x00FF00);

	}
	if (partLabel[3].getInputText().toLowerCase() == "cornea")
	{
		partLabel[3].setDisplayOnly(true);
		partLabel[3].setTextBColor(0x00FF00);

	}
	if (partLabel[4].getInputText().toLowerCase() == "iris")
	{
		partLabel[4].setDisplayOnly(true);
		partLabel[4].setTextBColor(0x00FF00);

	}
}

/*Create Interactive session 2*/
private function createTest2():void
{
	showDiagram();
	eyeTitle.visible = false;
	newImageLoader.visible = true;
	imageLoader.visible = false;
	testFrame.visible = false;
	testFrame2.visible = true;
	
	testFrame2.addChild(newImageLoader);
	testFrame2.addChild(test2Title);
	test2Title.visible = true;
	test2Title.x = 20 ;
	test2Title.y = 10;
	
	rectHighlight[0].changeFillOpacity(0.01);
	rectHighlight[0].changeBorderColor(0x000000);
	testFrame2.addChild(rectHighlight[0]);
			
	rectHighlight[1].changeFillOpacity(0.02);
	rectHighlight[1].changeBorderColor(0x000000);
	testFrame2.addChild(rectHighlight[1]);		
	
	rectHighlight[2].changeFillOpacity(0.03);
	rectHighlight[2].changeBorderColor(0x000000);
	testFrame2.addChild(rectHighlight[2]);		
	
	rectHighlight[3].changeFillOpacity(0.04);
	rectHighlight[3].changeBorderColor(0x000000);
	testFrame2.addChild(rectHighlight[3]);
	
	rectHighlight[4].changeFillOpacity(0.05);
	rectHighlight[4].changeBorderColor(0x000000);
	testFrame2.addChild(rectHighlight[4]);
	
	for (var i:Number = 0; i < 5; i++)
	{
		rectHighlight[i].addEventListener(MouseEvent.MOUSE_OVER, changeMouseShape);
		rectHighlight[i].addEventListener(MouseEvent.MOUSE_DOWN,checkAns);
	}
		
	partNameLabel.visible = true;

	testFrame2.addChild(partNameLabel);
	partNameLabel.y = 80;
		
	identifyLabel.visible = true;
	identifyLabel.x = 60;
	identifyLabel.y = 80;
	identifyLabel.buttonMode = true;
	identifyLabel.setDisplayOnly(true);
	identifyLabel.addEventListener(MouseEvent.MOUSE_OVER, changeMouseShape);
	identifyLabel.addEventListener(MouseEvent.MOUSE_DOWN,changePartName);
	testFrame2.addChild(identifyLabel);
	pieHandle.addDisplayChild(testFrame2);
	
}

/*Check answer for interactive session 2*/
private function checkAns(event:MouseEvent):void
{
	var ans:Number = event.currentTarget.getFillOpacity() * 100 - 1;
	var tempPart:String = identifyLabel.getInputText().toLowerCase();
	if (parts[ans].toLowerCase() == tempPart)
	{
		event.currentTarget.changeFillColor(0x00FF00);
		event.currentTarget.changeFillOpacity(1);
		do{
		var part:String = parts[Math.ceil(Math.random() * 10) % 5].toLowerCase();
	identifyLabel.setInputText(part);
		}while (tempPart == part);
		event.currentTarget.removeEventListener(MouseEvent.MOUSE_DOWN, checkAns);
		event.currentTarget.removeEventListener(MouseEvent.MOUSE_OVER, changeMouseShape);

	}
	else
	{
		event.currentTarget.changeFillColor(0xFF0000);

	}
}

private function changeMouseShape(e:MouseEvent):void
{
	Mouse.cursor = "button";
}

private function changePartName(event:MouseEvent):void
{
	var part:String = parts[Math.ceil(Math.random() * 10) % 5];
	identifyLabel.setInputText(part);
}

/*Validate the quiz panel.Show the hidden objects of the quiz*/
private function validateQuizPanel():void
{
	//Validate the quiz panel
	imageLoader.visible = false;
	newImageLoader.visible = false;
	eyeTitle.visible = false;
	
	if (testFrame != null)
		testFrame.visible = false;
		
	if (testFrame2 != null)
		testFrame2.visible = false;
		
	if(test1Title != null)
		test1Title.visible = false;
	
	if(test2Title != null)
		test2Title.visible = false;
	
	quizTitle.x = 50;
	quizTitle.y = 40;
	quizTitle.visible = true;
	
	for ( var i:Number = 0; i < 5; i++)
	{
		partLabel[i].visible = false;
		qQuiz[i].visible = true;
		ansBox[i].visible = true;
		imageLoad[i].visible = true;
		ansBox[i].changeFillColor(0xFFFFFF);
	}
	qQuiz[0].x = 40;
	qQuiz[0].y = 100;
		
	qQuiz[1].x = 40;
	qQuiz[1].y = 160;
	
	qQuiz[2].x = 40;
	qQuiz[2].y = 220;
	
	qQuiz[3].x = 40;
	qQuiz[3].y = 280;
	
	qQuiz[4].x = 40;
	qQuiz[4].y = 340;
	
	imageLoad[0].changeLocation(50,500);
	imageLoad[1].changeLocation(130,500);
	imageLoad[2].changeLocation(250,500);
	imageLoad[3].changeLocation(420,500);
	imageLoad[4].changeLocation(570, 500);
	
	submitQuiz.visible = true;
	diagButton.visible = true;
	
	quizBox.visible = true;
	showAnsButton.visible = true;

	
}

//Show initial home screen:Diagram of detailed eye
private function showDiagram():void
{
	//Restore the initial home screen
	if (imageLoader != null) {	imageLoader.visible = true; }
	if(newImageLoader!= null){	newImageLoader.visible = false;}
	if(eyeTitle!= null){ 	eyeTitle.visible = true;}
	
	if(test1Title!= null){	test1Title.visible = false;}
	if(test2Title!= null){	test2Title.visible = false;}
	
	if(quizTitle!= null){	quizTitle.visible = false;}
	
	if(quizBox!= null){	quizBox.visible = false;}
	if ( qQuiz != null)
	{
		for (var i:Number = 0; i < 5; i++)
		{
			qQuiz[i].visible = false;
			ansBox[i].visible = false;
			imageLoad[i].visible = false;
		}
	}
	
	if (testFrame2 != null) { testFrame2.visible = false; }
	if (testFrame != null) { testFrame.visible = false; }
	if(submitQuiz != null){submitQuiz.visible = false;}
	
	
	if(showAnsButton!= null){showAnsButton.visible = false;}

}

/*Create quiz session:Match the following*/
private function createquizFrame():void
{
	pieHandle.addDisplayChild(quizTitle);

	quizTitle.visible = false;
	quizBox.visible = false;
	quizBox.changeBorderColor(0x0000FF);
	pieHandle.addDisplayChild(quizBox);
	
	//Questions presented as function of the eye parts
	var que:Array = new Array(5);
	que[0] = new String("Dark muscular diaphragm that\ncontrols the size of the pupil"); 
	que[1] = new String("Cause refraction and \nacts as protective layer"); 
	que[2] = new String("Controls accommodation for viewing \nobjects at varying distances"); 
	que[3] = new String("Carries the impulses generated by the retina \nto the brain to be turned into images \nin the brain."); 
	que[4] = new String("\nControls the amount of light entering the eye"); 

	//Adding the questions to the display panel
	qQuiz = new Array(5);
	qQuiz[0] = new PIElabel(pieHandle, que[0], 13, 0xFFFFFF, 0x000000);
	qQuiz[1] = new PIElabel(pieHandle, que[1], 13, 0xFFFFFF, 0x000000);
	qQuiz[2] = new PIElabel(pieHandle, que[2], 13, 0xFFFFFF, 0x000000);
	qQuiz[3] = new PIElabel(pieHandle, que[3], 13, 0xFFFFFF, 0x000000);
	qQuiz[4] = new PIElabel(pieHandle, que[4], 13, 0xFFFFFF, 0x000000);
	
	
	//Containers of the answers
	ansBox = new Array(5);
	ansBox[0] = new PIErectangle(pieHandle, 330, 105, 200, 40, 0xFFFFFF);
	ansBox[1] = new PIErectangle(pieHandle, 330, 165, 200, 40, 0xFFFFFF);
	ansBox[2] = new PIErectangle(pieHandle, 330, 225, 200, 40, 0xFFFFFF);
	ansBox[3] = new PIErectangle(pieHandle, 330, 285, 200, 40, 0xFFFFFF);
	ansBox[4] = new PIErectangle(pieHandle, 330, 345, 200, 40, 0xFFFFFF);
	
	for (var i:Number = 0; i < 5; i++)
	{
		ansBox[i].visible = false;
		ansBox[i].changeBorderColor(0x00FF00);
		pieHandle.addDisplayChild(ansBox[i]);
		pieHandle.addDisplayChild(qQuiz[i]);
		qQuiz[i].visible = false;
	}
	//Adding the options of the questions
	imageLoad = new Array(5);
	imageLoad[0] = new PIEimage(pieHandle, 50, 500, 42, 26, imageLocation.irisImgPtr);
	imageLoad[1] = new PIEimage(pieHandle, 130, 500, 79, 26, imageLocation.corneaImgPtr);
	imageLoad[2] = new PIEimage(pieHandle, 250, 500, 130, 25, imageLocation.ciliaryImgPtr);
	imageLoad[3] = new PIEimage(pieHandle, 420, 500, 102, 26, imageLocation.opticImgPtr);
	imageLoad[4] = new PIEimage(pieHandle, 550, 500, 66, 25, imageLocation.pupilImgPtr);
	
	for (i = 0 ; i < 5; i++)
	{
		imageLoad[i].changeBorder(4, 0xFF0000, 1);
		imageLoad[i].addEventListener(MouseEvent.MOUSE_OVER, changeShape);
		imageLoad[i].addEventListener(MouseEvent.MOUSE_DOWN, changeBorder);
		imageLoad[i].addEventListener(MouseEvent.MOUSE_UP, releaseO);	
		pieHandle.addDisplayChild(imageLoad[i]);
		imageLoad[i].visible = false;
	
	}
	
	//Buttons for user interaction
	submitQuiz = new PIEbutton(pieHandle, "Submit");
	submitQuiz.width = 70;
	submitQuiz.height = 30;
	submitQuiz.addClickListener(evaluateQuiz);
	pieHandle.addUIpanelChild(submitQuiz);

	submitQuiz.x  = 10;
	submitQuiz.y = 190;
	submitQuiz.visible = false;
		
	diagButton = new PIEbutton(pieHandle, "Diagram");
	diagButton.width = 70;
	diagButton.height = 30;
	diagButton.x = 10;
	diagButton.y = 150;
	diagButton.addClickListener(showDiagram);
	pieHandle.addUIpanelChild(diagButton);
	
	showAnsButton = new PIEbutton(pieHandle, "Answers");
	showAnsButton.width = 70;
	showAnsButton.height = 30;
	showAnsButton.x = 10;
	showAnsButton.y = 230;
	showAnsButton.addClickListener(showAnswer);
	pieHandle.addUIpanelChild(showAnsButton);
	showAnsButton.visible = false;
}

//Show the answers of the quiz interactive session
public function showAnswer():void
{
	//Put correct answers in their position
	var rect:PIErectangle;
	for (var i:Number = 0; i < 5; i++)
	{
	rect = ansBox[i];

	var X:Number = rect.getPIErectangleX();
	var Y:Number = rect.getPIErectangleY();
	imageLoad[i].x = X - 50 + rect.width / 2;
	imageLoad[i].y = Y - 10 + rect.height / 2;
	rect.changeFillOpacity(1);
	rect.changeFillColor(0x00FF00);
	
	imageLoad[i].removeEventListener(MouseEvent.MOUSE_DOWN, changeBorder, false);
	imageLoad[i].removeEventListener(MouseEvent.MOUSE_UP, releaseO, false);
	
	
	}
}
public function changeShape(event:MouseEvent):void
{
	//Change the shape of the mouse cursor when on top of option
	event.currentTarget.buttonMode = true;
}
public function changeBorder(event:MouseEvent):void
{
	//Store old values to restore the object to its original position
	oldX = event.currentTarget.x;
	oldY = event.currentTarget.y;
	event.currentTarget.startDrag(true);

	event.currentTarget.changeBorderColor(0x0000FF);
}


public function releaseO(event:MouseEvent):void
{
	//Stop the drag and fix the object
	event.currentTarget.stopDrag();
	if ( oldY - event.currentTarget.y > 20)
	{
	event.currentTarget.changeLocation(event.stageX, event.stageY);
	checkOption(event.stageX, event.stageY, event.currentTarget);
	}
	else
	{
		event.currentTarget.x = oldX;
		event.currentTarget.y = oldY;
		event.currentTarget.changeBorderColor(0xFF0000);
	}

}

public function checkOption(imageX:Number, imageY:Number,newLoader:Object):void
{
	//Check if the option is in any answer container
	var rect:PIErectangle;
	for (var i:Number = 0; i < 5; i++)
	{
	rect = ansBox[i];
	var X:Number = rect.getPIErectangleX();
	var Y:Number = rect.getPIErectangleY();
	if (newLoader.x > X && newLoader.y > Y-20 && newLoader.x < (X+rect.width+30) && newLoader.y <(Y + rect.height+20))
	{
		rect.changeFillOpacity(0.1);

		newLoader.x = X-50+rect.width/2;
		newLoader.y = Y-10+rect.height/2;
		rect.changeFillColor(0x00FF00);
	}
	else 
	{
			
	}
	}
}

public function evaluateQuiz():void
{
	//Evaluate the quiz and show the result
	var rect:PIErectangle;
	for (var i:Number = 0; i < 5; i++)
	{
	rect = ansBox[i];
	var X:Number = rect.getPIErectangleX();
	var Y:Number = rect.getPIErectangleY();
	if (imageLoad[i].x > X && imageLoad[i].y > Y && imageLoad[i].x < (X+rect.width) && imageLoad[i].y <(Y + rect.height))
	{
		rect.changeFillOpacity(1);


		rect.changeFillColor(0x00FF00);
	}
	else
	{
		rect.changeFillOpacity(1);
		rect.changeFillColor(0xFF0000);
	}
	}

}
}   /* End of Class experiment */

}
