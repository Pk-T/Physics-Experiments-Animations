package Lens
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import pie.uiElements.*;
import pie.graphicsLibrary.*;

/*
 * Lens Class
 * All PIE sprite classes are created by the experiment class
 * All PIE sprite methods are invoked with user space co-ordinates
 * All PIE sprite methods talk to the experiment object in user space co-ordinates
 * All graphics and location points are in stage co-ordinates
 * The PIE classes use PIE transformations to translate betseen user space and stage co-ordinates
 * The Experiment class methods always pass PIE Handle to the methods
 *
 */
public class LensTest extends PIEsprite
{
/*
 * Lens Display Objects for stretch and drag operations
 */
private var leftStretch:PIErectangle;
private var rightStretch:PIErectangle;
private var topStretch:PIErectangle;
private var bottomStretch:PIErectangle;
private var middleDrag:PIErectangle;

private var chosenStretch:PIErectangle;

private var aPIEstretchBegin:Function;
private var aPIEstretchEnd:Function;
private var aPIEgrab:Function;
private var aPIEdrag:Function;
private var aPIEdrop:Function;
private var stretchable:Boolean;
private var draggable:Boolean;

/*
 * Lens specific Parameters (in user co-ordinate space)
 */ 
private var aOrigin:Point;
private var aLensHeight:Number;
private var aLeftRadius:Number;
private var aRightRadius:Number;
private var aLensFocalLength:Number;

private var dOrigin:Point;
private var dLensHeight:Number;
private var dLeftRadius:Number;
private var dRightRadius:Number;

private var dLeftThickness:Number;
private var dRightThickness:Number;

private var dLeftTopX:Number;
private var dRightTopX:Number;

private var maxThickness:Number;
private var minThickness:Number;

private var regularLens:Boolean;
/*
 * Constructor for LensTest class 
 * Parameters: (parentPie:PIE, centerX:Number, centerY:Number, lensH:Number, lRadius:Number, rRadius:Number, fillColor:uint)
 * parentPie  - handle to the PIE Object
 * centerX   - X Coordinates of center of lens
 * centerY   - Y Coordinates of center of lens
 * lensH - height of lens
 * lRadius - Radius of Left  Face (+ve is convex)
 * rRadius - Radius of Right Face (+ve is convex)
 * fillColor  - Fill color
 */
public function LensTest(parentPie:PIE, centerX:Number, centerY:Number, lensH:Number, lRadius:Number, rRadius:Number, fillColor:uint):void
{
    /* Store Original Parameters */
    this.pie          = parentPie;
    aOrigin           = new Point(centerX, centerY);
    this.setRoot(aOrigin);
    this.aLensHeight  = lensH;
    this.aLeftRadius  = lRadius;
    this.aRightRadius = rRadius;

    this.changeFill(fillColor, 1.0);
    this.changeBorder(1, 0xFF0000, 1.0);
    this.setPIEborder(false);

    this.stretchable = false;
    this.draggable   = false;
    this.regularLens = false;
    if (lRadius == rRadius) { this.regularLens = true; }

    this.aLensFocalLength = (lRadius * rRadius) / (lRadius + rRadius);

    this.maxThickness = lensH * 0.4;
    this.minThickness = 5;

    /* Set default values of PIE sprite */
    this.enablePIEtransform();
    this.setPIEvisible();

    /* Create and Initialise the elements */
    this.adjustLensDimensions();
    this.PIEcreateElements();
}

/*
 * Adjust Lens Dimensions()
 * This function computes the locations for drawing the lens and the stretch/drag areas
 */
private function adjustLensDimensions():void
{
var lThickness:Number;

    /* First set the Lens Boundaries */
    lThickness = this.dLeftRadius - Math.sqrt((this.dLeftRadius * this.dLeftRadius) - ((this.dLensHeight * this.dLensHeight) * 0.25));
    if (this.aLeftRadius < 0)
    {
        this.dLeftThickness = -3;
        this.dLeftTopX = -(lThickness + 3);
    }
    else
    {
        this.dLeftThickness = -lThickness;
        this.dLeftTopX = 0;
    }
    lThickness = this.dRightRadius - Math.sqrt((this.dRightRadius * this.dRightRadius) - ((this.dLensHeight * this.dLensHeight) * 0.25));
    if (this.aRightRadius < 0)
    {
        this.dRightThickness = 3;
        this.dRightTopX = (lThickness + 3);
    }
    else
    {
        this.dRightThickness = lThickness;
        this.dRightTopX = 0;
    }
}

private function adjustFocalLength():void
{
    this.dLeftRadius  = (((this.dLensHeight * this.dLensHeight) * 0.25) + (this.dLeftThickness * this.dLeftThickness)) / (2 * -this.dLeftThickness);
    this.dRightRadius = (((this.dLensHeight * this.dLensHeight) * 0.25) + (this.dRightThickness * this.dRightThickness)) / (2 * this.dRightThickness);
    this.aLensFocalLength = pie.PIEdisplayToApplicationW((this.dLeftRadius * this.dRightRadius) / (this.dLeftRadius + this.dRightRadius));
}

private function PIEcreateElements():void
{
    /* Invisible Left Stretch Rectangle */
    leftStretch = new PIErectangle(this.pie, (this.dLeftThickness - 3), (-3), 6, 6, this.PIEfColor);
    leftStretch.disablePIEtransform();
    leftStretch.setPIEvisible();
    this.addChild(leftStretch);

    /* Invisible Right Stretch Rectangle */
    rightStretch = new PIErectangle(this.pie, (this.dRightThickness - 3), (-3), 6, 6, this.PIEfColor);
    rightStretch.disablePIEtransform();
    rightStretch.setPIEvisible();
    this.addChild(rightStretch);

    /* Invisible Top Stretch Rectangle */
    topStretch = new PIErectangle(this.pie, Math.min(this.dLeftTopX, -3), ((-this.dLensHeight / 2) - 3), Math.max((this.dRightTopX-this.dLeftTopX), 6), 6, this.PIEfColor);
    topStretch.disablePIEtransform();
    topStretch.setPIEvisible();
    this.addChild(topStretch);

    /* Invisible Bottom Stretch Rectangle */
    bottomStretch = new PIErectangle(this.pie, Math.min(this.dLeftTopX, -3), ((this.dLensHeight / 2) - 3), Math.max((this.dRightTopX-this.dLeftTopX), 6), 6, this.PIEfColor);
    bottomStretch.disablePIEtransform();
    bottomStretch.setPIEvisible();
    this.addChild(bottomStretch);

    /* Invisible Middle Drag Rectangle */
    middleDrag = new PIErectangle(this.pie, (this.dLeftThickness / 2), ((-this.dLensHeight / 4)), (this.dRightThickness - this.dLeftThickness) / 2, (this.dLensHeight / 2), this.PIEfColor);
    middleDrag.disablePIEtransform();
    this.addChild(middleDrag);
}

private function adjustElements():void
{
    /* Invisible Left Stretch Rectangle */
    if (leftStretch != null) leftStretch.changeLocation((this.dLeftThickness - 3), (-3));

    /* Invisible Right Stretch Rectangle */
    if (rightStretch != null) rightStretch.changeLocation((this.dRightThickness - 3), (-3));

    /* Invisible Top Stretch Rectangle */
    if (topStretch != null) topStretch.changeLocation(Math.min(this.dLeftTopX, -3), ((-this.dLensHeight / 2) - 3));
    if (topStretch != null) topStretch.changeSize(Math.max((this.dRightTopX - this.dLeftTopX), 6), 6);

    /* Invisible Bottom Stretch Rectangle */
    if (bottomStretch != null) bottomStretch.changeLocation(Math.min(this.dLeftTopX, -3), ((this.dLensHeight / 2) - 3));
    if (bottomStretch != null) bottomStretch.changeSize(Math.max((this.dRightTopX - this.dLeftTopX), 6), 6);

    /* Invisible Middle Drag Rectangle */
    if (middleDrag != null) middleDrag.changeLocation((this.dLeftThickness / 2), ((-this.dLensHeight / 4)));
    if (middleDrag != null) middleDrag.changeSize((this.dRightThickness - this.dLeftThickness) / 2, (this.dLensHeight) / 2);

    /* Create Graphics */
    if (this.isPIEvisible()) this.PIEcreateGraphics();
}

/*
 * Manage Listeners
 */
/*
 * Add Stretch Listener(aStretch:Function)
 * aStretch : Aplication Stretch Handler
 */
public function addStretchListeners(aStretchBegin:Function, aStretchEnd:Function):void
{
    if (this.regularLens)
    {
        this.aPIEstretchBegin = aStretchBegin;
        this.aPIEstretchEnd   = aStretchEnd;

        leftStretch.addDragAndDropListeners(this.handleLGrab, this.handleHDrag, this.handleHDrop);
        rightStretch.addDragAndDropListeners(this.handleRGrab, this.handleHDrag, this.handleHDrop);
        topStretch.addDragAndDropListeners(this.handleTGrab, this.handleVDrag, this.handleVDrop);
        bottomStretch.addDragAndDropListeners(this.handleBGrab, this.handleVDrag, this.handleVDrop);
    }
}
public function handleLGrab(clickX:Number, clickY:Number):void
{
    this.chosenStretch = leftStretch;
    transformAndStretchBegin(clickX, clickY);
}
public function handleRGrab(clickX:Number, clickY:Number):void
{
    this.chosenStretch = rightStretch;
    transformAndStretchBegin(clickX, clickY);
}
public function handleTGrab(clickX:Number, clickY:Number):void
{
    this.chosenStretch = topStretch;
    transformAndStretchBegin(clickX, clickY);
}
public function handleBGrab(clickX:Number, clickY:Number):void
{
    this.chosenStretch = bottomStretch;
    transformAndStretchBegin(clickX, clickY);
}
public function transformAndStretchBegin(clickX:Number, clickY:Number):void
{
var newPoint:Point;

    if (this.isPIEtransformEnabled())
    {
        newPoint = pie.PIEdisplayToApplication(new Point(clickX, clickY));
        clickX = newPoint.x;
        clickY = newPoint.y;
    }
    if (this.aPIEstretchBegin != null) this.aPIEstretchBegin(clickX, clickY);
}
public function handleHDrag(mouseX:Number, mouseY:Number, displacementX:Number, displacementY:Number):void
{
var newLeftThickness:Number;

    if (this.chosenStretch == this.leftStretch) { newLeftThickness  =  this.dLeftThickness + displacementX; }
    else if (this.chosenStretch == this.rightStretch) { newLeftThickness  =  this.dLeftThickness - displacementX; }

    // if (((2 * this.dLeftThickness) > this.minThickness) && ((2 * this.dLeftThickness) < this.minThickness))
    {
       this.dLeftThickness = newLeftThickness;
       this.dRightThickness = -newLeftThickness;
       this.adjustFocalLength();
       this.adjustElements();
    }
}
public function handleVDrag(mouseX:Number, mouseY:Number, displacementX:Number, displacementY:Number):void
{
var newLensHeight:Number;

    if (this.chosenStretch == this.topStretch) { this.dLensHeight = this.dLensHeight - 2 * displacementY; }
    else if (this.chosenStretch == this.bottomStretch) { this.dLensHeight = this.dLensHeight + 2 * displacementY; }

    this.adjustLensDimensions();
    this.adjustElements();
}
public function handleHDrop(mouseX:Number, mouseY:Number, displacementX:Number, displacementY:Number):void
{
    this.handleHDrag(mouseX, mouseY, displacementX, displacementY);
    if (this.isPIEtransformEnabled())
    {
        displacementX = pie.PIEdisplayToApplicationW(displacementX);
    }
    if (this.aPIEstretchEnd != null) this.aPIEstretchEnd(aOrigin.x, aOrigin.y, displacementX, 0);
}
public function handleVDrop(mouseX:Number, mouseY:Number, displacementX:Number, displacementY:Number):void
{
    this.handleVDrag(mouseX, mouseY, displacementX, displacementY);
    if (this.isPIEtransformEnabled())
    {
        displacementY = pie.PIEdisplayToApplicationH(displacementY);
    }
    if (this.aPIEstretchEnd != null) this.aPIEstretchEnd(aOrigin.x, aOrigin.y, 0, displacementY);
}
/*
 * Add Drag Listener(aDrag:Function)
 * aDrag : Aplication Drag Handler
 */
public function addDragListeners(aGrab:Function, aDrag:Function, aDrop:Function):void
{
    this.aPIEgrab = aGrab;
    this.aPIEdrag = aDrag;
    this.aPIEdrop = aDrop;
    middleDrag.addDragAndDropListeners(this.handleMGrab, this.handleMDrag, this.handleMDrop);
}
public function handleMGrab(clickX:Number, clickY:Number):void
{
var newPoint:Point;

    if (this.isPIEtransformEnabled())
    {
        newPoint = pie.PIEdisplayToApplication(new Point(clickX, clickY));
        clickX = newPoint.x;
        clickY = newPoint.y;
    }
    if (this.aPIEgrab != null) this.aPIEgrab(clickX, clickY);
}
public function handleMDrag(mouseX:Number, mouseY:Number, displacementX:Number, displacementY:Number):void
{
    dOrigin.x = dOrigin.x + displacementX;
    if (this.isPIEtransformEnabled())
    {
        aOrigin = pie.PIEdisplayToApplication(new Point(dOrigin.x, dOrigin.y));
        displacementX = pie.PIEdisplayToApplicationW(displacementX);
    }
    else
    {
        aOrigin.x = dOrigin.x;
    }
    this.changeLocation(aOrigin.x, aOrigin.y);
    if (this.aPIEdrag != null) this.aPIEdrag(aOrigin.x, aOrigin.y, displacementX, 0);
}
public function handleMDrop(mouseX:Number, mouseY:Number, displacementX:Number, displacementY:Number):void
{
    this.handleMDrag(mouseX, mouseY, displacementX, displacementY);
    if (this.isPIEtransformEnabled())
    {
        displacementX = pie.PIEdisplayToApplicationW(displacementX);
    }
    if (this.aPIEdrop != null) this.aPIEdrag(aOrigin.x, aOrigin.y, displacementX, 0);
}

/* Height */
public function getHeight():Number
{
    return(this.aLensHeight);
}
/* Right Radius */
public function getRightRadius():Number
{
    return(this.aRightRadius);
}
/* Left Radius */
public function getLeftRadius():Number
{
    return(this.aLeftRadius);
}
/* Focal Length */
public function getFocalLength():Number
{
    return(this.aLensFocalLength);
}

/*
 * Override PIEsprite methods
 */
/* Visiblity Control Methods */
public override function setPIEvisible():void
{
    super.setPIEvisible();
    if (leftStretch != null) leftStretch.setPIEvisible();
    if (rightStretch != null) rightStretch.setPIEvisible();
    if (topStretch != null) topStretch.setPIEvisible();
    if (bottomStretch != null) bottomStretch.setPIEvisible();
    if (middleDrag != null) middleDrag.setPIEvisible();
    this.PIEcreateGraphics();
}
public override function setPIEinvisible():void
{
    super.setPIEinvisible();
    if (leftStretch != null) leftStretch.setPIEinvisible();
    if (rightStretch != null) rightStretch.setPIEinvisible();
    if (topStretch != null) topStretch.setPIEinvisible();
    if (bottomStretch != null) bottomStretch.setPIEinvisible();
    if (middleDrag != null) middleDrag.setPIEinvisible();
    this.graphics.clear();
}

/* Transform Control Methods */
public override function enablePIEtransform():void
{
    super.enablePIEtransform();
    this.transformAtoD();
}
public override function disablePIEtransform():void
{
    super.disablePIEtransform();
    this.transformAtoD();
}

/*
 * This method transforms all variables from application co-ordinates to display co-ordinates
 * It calls two separate methods to change location and graphics (drawing) variables
 */
private function transformAtoD():void
{
    this.transformALtoD();
    this.transformADtoD();
}

/*
 * This method transforms the location variables from application co-ordinates to display co-ordinates
 * The graphics is not changed
 */
private function transformALtoD():void
{
    if (isPIEtransformEnabled())
    {
        dOrigin  = pie.PIEapplicationToDisplay(aOrigin);
    }
    else
    {
        dOrigin  = aOrigin;
    }

    /* Change Position */
    this.x = this.dOrigin.x;
    this.y = this.dOrigin.y;
}

/*
 * This method transforms the size (drawing) variables from application co-ordinates to display co-ordinates
 * The graphics is changed appropriately
 */
private function transformADtoD():void
{
    if (isPIEtransformEnabled())
    {
        this.dLensHeight  = pie.PIEapplicationToDisplayW(this.aLensHeight);
        this.dLeftRadius  = pie.PIEapplicationToDisplayW(this.aLeftRadius);
        this.dRightRadius = pie.PIEapplicationToDisplayW(this.aRightRadius);
    }
    else
    {
        this.dLensHeight  = this.aLensHeight;
        this.dLeftRadius  = this.aLeftRadius;
        this.dRightRadius = this.aRightRadius;
    }

    /* Adjust Drag and Drop Elements */
    this.adjustLensDimensions();
    this.adjustElements();

    /* Draw if necessary */
    if (this.isPIEvisible()) this.PIEcreateGraphics();
}

/*
 * Draw Lens
 * Parameters: (void)
 */
public override function PIEcreateGraphics():void
{
var perimeter:uint;
var steps:uint;
var startAngle:Number;
var iAngle:Number;
var nextX:Number;
var nextY:Number;
var center:Number;
var theta:Number;

    this.graphics.clear();
    if (this.PIEborder) this.graphics.lineStyle(this.PIEbWidth, this.PIEbColor, this.PIEbOpacity);
    if (this.PIEfill) this.graphics.beginFill(this.PIEfColor, this.PIEfOpacity);

    /* Draw Left Arc */
    center = this.dLeftRadius + this.dLeftThickness;
    theta  = Math.abs(Math.asin((this.dLensHeight / 2) / this.dLeftRadius));
    perimeter = (2 * theta) * Math.abs(this.dLeftRadius);
    steps = perimeter / 5;
    if (dLeftRadius > 0)
    {   /* Convex Surface */
        startAngle = Math.PI + theta;
        iAngle = -(2 * theta) / steps;
    }
    else
    {   /* Concave Surface */
        startAngle = -theta;
        iAngle = (2 * theta) / steps;
    }
    nextX = center + this.dLeftRadius * Math.cos(startAngle);
    nextY = this.dLeftRadius * Math.sin(startAngle);
    this.graphics.moveTo(nextX, nextY);
	
    while (steps > 0 && dLeftRadius > 0)
    {
        startAngle = startAngle + iAngle;
        nextX = center + this.dLeftRadius * Math.cos(startAngle);
        nextY = this.dLeftRadius * Math.sin(startAngle);
        this.graphics.lineTo(nextX, nextY);
        /* Increment for next */
        steps--;
    }
    /* Draw Right Arc */
    center = -this.dRightRadius + this.dRightThickness;
    theta  = Math.abs(Math.asin((this.dLensHeight / 2) / this.dRightRadius));
    perimeter = (2 * theta) * Math.abs(this.dLeftRadius);
    steps = perimeter / 5;
    if (dRightRadius > 0)
    {   /* Convex Surface */
        startAngle = -theta;
        iAngle = (2 * theta) / steps;
    }
    else
    {   /* Concave Surface */
        startAngle = Math.PI + theta;
        iAngle = -(2 * theta) / steps;
    }
    nextX = center + this.dRightRadius * Math.cos(startAngle);
    nextY = this.dRightRadius * Math.sin(startAngle);
    this.graphics.moveTo(nextX, nextY);
    while (steps > 0)
    {
        startAngle = startAngle + iAngle;
        nextX = center + this.dRightRadius * Math.cos(startAngle);
        nextY = this.dRightRadius * Math.sin(startAngle);
        this.graphics.lineTo(nextX, nextY);
        /* Increment for next */
        steps--;
    }

    if (this.PIEfill) this.graphics.endFill();
}

/*
 * Change Lens Location
 * Parameters: (topLeftX:Number , topLeftY:Number) 
 * centerX   - X Coordinates of top left corner
 * centerY   - Y Coordinates of top left corner
 */
public override function changeLocation(centerX:Number, centerY:Number):void
{
    /* Store Changed Location */
    aOrigin = new Point(centerX, centerY);
    this.setRoot(aOrigin);
    transformALtoD();
}

/*
 * Change lens Height
 * Parameters: (lHeight:Number)
 * lHeight - Height of lens
 */
public function changeHeight(lHeight:Number):void
{
    /* Store Changed Location */
    this.aLensHeight = lHeight;
    transformADtoD();
}

}   /* End of Class LensTest */

}

