import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.ActivityMonitor;
import Toybox.Complications;


var colorsUpdated = true;   //A Check to see if we need to run the updateColors

class AviationTimeGrayscaleView extends WatchUi.WatchFace {

    var alarmString = " ";       //No complications
    var dateString = " ";
    var stepString = "0";       //The number of steps to be displayed
    var noteString = " ";
    var anyNotes = false;

    var myEnvelope;
    var myClock;
    var myFeet;
    var feetW;

    var alSets = false;

    var ForC = false;

    var batString = " ";
    
    var stepId;
    var stepComp;
    var mSteps;             //For the non-complications watches

    var hasComps = false;
    var hasWx = false;
    var batComp, noteComp, wxComp;
    var wxNow = -99;

    var calcTime;           //Formatted local time

    var zuluTime;           //The 24 hour formatted corrected from zulu time
    var myZuluLabel;        //User selected offset from Z formatted for display
    
    var wxId;

    var batId, noteId;
    var batLoad;

    var noteSets;

    var batY = 0.33;        //Divide up the screen for press to complications
    var stepY = 0.66;
    var wHeight;
    var wWidth;
    var faceSize;

    var calId;              //Calendar info for new watches onlys
         
    var BIP = true;         //Burn In Protection
    var lowPowerMode = false;


    function initialize() {
        WatchFace.initialize();

        hasComps = (Toybox has :Complications); 
        lowPowerMode = (Toybox has :onPartialUpdate);
        hasWx = (Toybox has :Weather);

        ForC = System.getDeviceSettings().temperatureUnits;

        //Feet Bitmap define
        myFeet = WatchUi.loadResource(Rez.Drawables.feetGray); 
        feetW = myFeet.getWidth();

        if (Graphics.Dc has :drawBitmap2) {
            myEnvelope = WatchUi.loadResource(Rez.Drawables.envelope);
            myClock = WatchUi.loadResource(Rez.Drawables.clock); 
        } else {
            myEnvelope = WatchUi.loadResource(Rez.Drawables.envelopeGreen);
            myClock = WatchUi.loadResource(Rez.Drawables.clockGreen);
        }

        if (hasComps) {
            stepId = new Id(Complications.COMPLICATION_TYPE_STEPS);
            batId = new Id(Complications.COMPLICATION_TYPE_BATTERY);
            noteId = new Id(Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT);
            calId = new Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS);
            wxId = new Id(Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE);

            stepComp = Complications.getComplication(stepId);
            if (stepComp != null) {
                Complications.subscribeToUpdates(stepId);
            }

            batComp = Complications.getComplication(batId);
            if (batComp != null) {
                Complications.subscribeToUpdates(batId);  
            }

            noteComp = Complications.getComplication(noteId);
            if (noteComp != null) {
                Complications.subscribeToUpdates(noteId);
            }  

            wxComp = Complications.getComplication(wxId);
            if (wxComp != null) {
                Complications.subscribeToUpdates(wxId);
            }

            Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));         

        }   
    
    }

    function onComplicationChanged(compId as Complications.Id) as Void {

        if (compId == batId) {
            batLoad = (Complications.getComplication(batId)).value;
        
        } else if (compId == wxId) {
            wxNow = (Complications.getComplication(wxId)).value;
            if ((ForC != System.UNIT_METRIC) && (wxNow != null)) {
                wxNow = (wxNow * 9.0 / 5.0 + 32.0).toFloat();
            }

        } else if (compId == stepId) {
            mSteps = (Complications.getComplication(stepId)).value;

        } else if (compId == noteId) {
            noteSets = (Complications.getComplication(noteId)).value;

        } else {
            System.println("no valid comps");
        }
    }


    // Load your resources here
    function onLayout(dc as Dc) as Void {

        wHeight = dc.getHeight();           //used for touch scren areas
        wWidth = dc.getWidth();

        //Set Background Color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawBitmap(0, 0, backImg);


    }


    // Update the view
    function onUpdate(dc as Dc) as Void {

        //Set Background Color
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawBitmap(0, 0, backImg);

        if (lowPowerMode){
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();

            normalTime();
            calcZuluTime();

System.println(clockColorSet);
System.println(subColorSet);

            if (BIP) {
                if (clockColorSet !=0) {
                    dc.setColor(clockColorSet, Graphics.COLOR_BLACK);
                } else {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                }
                dc.drawText((wWidth / 2), (wHeight * 0.15), Graphics.FONT_NUMBER_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
                if (subColorSet != 0) { 
                    dc.setColor(subColorSet, Graphics.COLOR_BLACK);
                } else {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                }
                dc.drawText((wWidth / 2), (wHeight * 0.60), Graphics.FONT_MEDIUM, zuluTime, Graphics.TEXT_JUSTIFY_CENTER);
                BIP = false; 
            } else {
                if (clockColorSet !=0) {
                    dc.setColor(clockColorSet, Graphics.COLOR_BLACK);
                } else {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                }
                dc.drawText((wWidth / 2), (wHeight * 0.30), Graphics.FONT_NUMBER_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
                if (subColorSet != 0) { 
                    dc.setColor(subColorSet, Graphics.COLOR_BLACK);
                } else {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                }
                dc.drawText((wWidth / 2), (wHeight * 0.70), Graphics.FONT_MEDIUM, zuluTime, Graphics.TEXT_JUSTIFY_CENTER); 
                BIP = true;
            }
 
        } else {
            //Draw battery
                battDisp(dc);
                dc.drawText((wWidth/2), (0.08 * wHeight), Graphics.FONT_TINY, batString, Graphics.TEXT_JUSTIFY_CENTER);    
            //Draw Alarm
                alarmDisp();
                if (alSets != 0 && alSets != null){
                    try {
                        if (Graphics.Dc has :drawBitmap2) {
                            dc.drawBitmap2(wWidth * 0.64, wHeight * 0.11, myClock, {
                                :tintColor=>subColorSet
                            });
                        } else {
                            dc.drawBitmap(wWidth * 0.64, wHeight * 0.11, myClock);
                        }
                    } catch (e) {
                        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(wWidth * 0.7, wHeight * 0.1, Graphics.FONT_TINY, alarmString, Graphics.TEXT_JUSTIFY_LEFT);
                    }
                } else {
                    dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(wWidth * 0.7, wHeight * 0.1, Graphics.FONT_TINY, alarmString, Graphics.TEXT_JUSTIFY_LEFT);
                } 
            //Draw Time/Z Time/Steps
                mainZone(dc);
            //Draw Date
                dateDisp();
                dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
                dc.drawText(wWidth / 2, wHeight * 0.58, Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER);
            //Draw Notes if on
                if (showNotes) {
                    notesDisp();
                    if (anyNotes) {
                        try {
                            if (Graphics.Dc has :drawBitmap2) {
                                dc.drawBitmap2(wWidth / 4, wHeight * 0.1,myEnvelope, {
                                    :tintColor=>subColorSet
                                });
                            } else {
                                dc.drawBitmap(wWidth / 4, wHeight * 0.1,myEnvelope);
                            }
                        } catch (e) {
                            dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                            dc.drawText(wWidth / 4, wHeight * 0.1, Graphics.FONT_TINY, noteString, Graphics.TEXT_JUSTIFY_LEFT);
                        }
                    } else {
                        dc.drawText(wWidth / 4, wHeight * 0.1, Graphics.FONT_TINY, " ", Graphics.TEXT_JUSTIFY_LEFT);
                    }
                }
            //Draw Seconds Arc if on
                if (dispSecs && 
                    System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                    secondsDisplay(dc);
                }
        }
    }


    function normalTime() {
    //Created formated local time

        var clockTime = System.getClockTime();
        var hours = clockTime.hour;

        //Calc local time for 12 or 24 hour clock
        if (System.getDeviceSettings().is24Hour == true){      
            calcTime = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        } else {
            if (hours > 12) {
                hours = hours - 12;
            }
            calcTime = Lang.format("$1$:$2$", [hours, clockTime.min.format("%02d")]);
        }
    }

    function calcZuluTime() {
    //24 hour clock only
            
        var zTime = Time.Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        var myOffset = zTime.hour;
        var minOffset = zTime.min;

        //Offset to add or subtract
        var convLeftoverOffset = (offSetAmmt % 10) * 360;     //Convert any partial hour to seconds
        var convToOffset = ((offSetAmmt / 10) - 13) * 3600;    //Convert the hours part to seconds

        convToOffset = convToOffset + convLeftoverOffset; //Total Offset in seconds
            
        //Convert Zulu time to seconds
        var zuluToSecs =  (minOffset * 60) + (myOffset * 3600);

        //Combine the offset with the current zulu
        var convToSecs = convToOffset + zuluToSecs;

        //Keep the new offset time positive (no negative time)
        if (convToSecs <= 86400) {
            myOffset = ((86400 + convToSecs) - ((86400 + convToSecs)%3600)) / 3600;
        } else {
            myOffset = ((convToSecs) - ((86400 + convToSecs)%3600)) / 3600;
        }

        //Adjust mins and hours for clock rollovers due to add or sub 30 min
        minOffset = (convToSecs % 3600) / 60;

        if (minOffset < 0) {
            minOffset = minOffset + 60;
        }   

        //correct for hours within the 24 hour clock
        if (myOffset == 24) {
            myOffset = 0;
        } else if (myOffset < 0) {
            myOffset = myOffset + 24;
        } else if (myOffset >= 24) {
            myOffset = myOffset - 24;
        }

        zuluTime = Lang.format("$1$:$2$", [myOffset.format("%02d"), minOffset.format("%02d")]);  
    }   
    

    function makeZuluLabel() {    
    //If Zulu time, do the else part

        if (offSetAmmt != 130) {
            //Prep the label
            var myParams;
            var myFormat = "Set $1$+$2$";

            if (offSetAmmt % 10 != 0) {
                if ((offSetAmmt - 130) < 0) {
                    myParams = [((offSetAmmt / 10) - 12), (offSetAmmt % 10 * 6)];
                } else {
                    myParams = [((offSetAmmt / 10) - 13), (offSetAmmt % 10 * 6)];
                }
            } else {
                myParams = [((offSetAmmt / 10) - 13), "00"];
            }
                
            myZuluLabel = Lang.format(myFormat,myParams);

        } else {
            myZuluLabel = "Zulu";
        }      
    }
    
   
    //Main Time Area
    function mainZone(dc) {
    //Choose Main display, set colors and show
    if (timeOrStep == null) {timeOrStep = false;}

        //Normal display here  
        normalTime();
        dc.setColor(clockShadSet, Graphics.COLOR_TRANSPARENT);
            
        dc.drawText(((wWidth / 2) + 1), ((wHeight * 0.22) + 1), Graphics.FONT_NUMBER_THAI_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(clockColorSet, Graphics.COLOR_TRANSPARENT);
        dc.drawText((wWidth / 2), (wHeight * 0.22), Graphics.FONT_NUMBER_THAI_HOT, calcTime, Graphics.TEXT_JUSTIFY_CENTER);
        
        if (timeOrStep) {
            //Display Secondary time
            calcZuluTime();
            makeZuluLabel();

            dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
            dc.drawText(wWidth / 2, wHeight * 0.75, Graphics.FONT_LARGE, zuluTime, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(wWidth / 2, wHeight * 0.88, Graphics.FONT_SYSTEM_XTINY, myZuluLabel, Graphics.TEXT_JUSTIFY_CENTER);

        } else {
            //Display Steps
            if (feetW == null || feetW ==0) {
                feetW = myFeet.getWidth();
            }

            dc.drawBitmap((wWidth/2) - (feetW/2), wHeight*0.7, myFeet);
            stepsDisp();

            dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
            dc.drawText(wWidth / 2, wHeight * 0.75, Graphics.FONT_LARGE, stepString, Graphics.TEXT_JUSTIFY_CENTER);
        }

    }


    //Date Area
    function dateDisp() {

        var dateLoad = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        dateString = Lang.format("$1$, $2$ $3$", 
            [dateLoad.day_of_week,
            dateLoad.day,
            dateLoad.month]);
    }

        
    //Battery Display Area
    function battDisp(dc) {

        if (showBat == 2 && hasWx) {

            if ((hasComps && wxNow == null) || (!hasComps)) {
                var tempTemp = Weather.getCurrentConditions();
                if (tempTemp != null){    
                    wxNow = tempTemp.temperature; 
                    if ((ForC != System.UNIT_METRIC) && (wxNow != null)) {
                    wxNow = (wxNow * 9.0 / 5.0 + 32.0).toFloat();
                    }
                } 
            }
            
            dc.setColor(subColorSet, Graphics.COLOR_TRANSPARENT);
            if (wxNow != null) {
                if (ForC != System.UNIT_METRIC){
                    wxNow = wxNow.toNumber();
                    batString = Lang.format("$1$", [wxNow])+"°";
                } else {
                    batString = Lang.format("$1$", [wxNow.format("%.01f")])+"°";
                }
            } else {
                batString = "N/A";
            }

        } else if (showBat == 0) {
            if (!hasComps || batLoad == null) {
                batLoad = ((System.getSystemStats().battery) + 0.5).toNumber();
            }

            if (batLoad < 5.0) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            } else if (batLoad < 25.0) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
            }
            batString = Lang.format("$1$", [batLoad])+"%";

        } else {
            batString = " ";
        }
    }

    //Notifications Display Area
    function notesDisp() {

        if (hasComps == false || noteSets == null) {
            var tempNotes = System.getDeviceSettings();
            if (tempNotes != null) {
                noteSets = tempNotes.notificationCount;
            } else {
                noteSets = 0;
            }
        }

        if (noteSets != 0 && noteSets != null) {
            anyNotes = true;
            noteString = "N";
        } else {
            anyNotes = false;
            noteString = " ";
        }
    }


    function alarmDisp() {

        alSets = System.getDeviceSettings().alarmCount;

        if (alSets != 0 && alSets != null) {
            alarmString = "A";
        } else {
            alarmString = " ";
        }
    } 

    function secondsDisplay(dc) {

        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        var mRadius = centerX < centerY ? centerX - 4: centerY - 4;
        var clockTime = System.getClockTime();
        var mSeconds = clockTime.sec;

        var mPen = 4;

        var mArc = 90 - (mSeconds * 6);

        dc.setPenWidth(mPen);
        dc.setColor(clockColorSet, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, mRadius, Graphics.ARC_CLOCKWISE, 90, mArc);

    }

    function stepsDisp() {
    //Format Steps
        var stepLoad;  

        if (!hasComps || mSteps == null) {
            stepLoad = ActivityMonitor.getInfo();
            mSteps = stepLoad.steps;
        } 

        if ((mSteps != null) && (mSteps instanceof Toybox.Lang.Float)) {
            mSteps = (mSteps * 1000).toNumber(); //System converts to float at 10k. Reported system error
        } 

        stepString = Lang.format("$1$", [mSteps]);

    }

    function onExitSleep() {
        lowPowerMode = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() {
        lowPowerMode = true;
        WatchUi.requestUpdate();
    }
     
}

class AviationTimeGrayscaleDelegate extends WatchUi.WatchFaceDelegate
{
	var view;
	
	function initialize(v) {
		WatchFaceDelegate.initialize();
		view=v;	
	}

    function onPress(evt) {
        var c=evt.getCoordinates();
        var batY = 0.33 * view.wHeight;
        var stepY = 0.66 * view.wHeight;

        if (c[1] <= batY) {

            if (showBat == 0 && view.batId != null) {
                Complications.exitTo(view.batId);
                return true;
            } else if (showBat == 2 && view.wxId != null) {
                Complications.exitTo(view.wxId);
                return true;
            } else {
                return false;
            }

        } else if (c[1] > batY && c[1] <= stepY && view.calId != null) {
            Complications.exitTo(view.calId);
            return true;
        } else if (view.stepId != null) {
            Complications.exitTo(view.stepId);
            return true;
        } else {
            return false;
        }
    }
	
}
