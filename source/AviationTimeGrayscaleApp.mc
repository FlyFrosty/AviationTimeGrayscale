import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;


    var showBat;
    var clockColorSet = Graphics.COLOR_DK_BLUE;
    var clockShadSet = Graphics.COLOR_TRANSPARENT;
    var subColorSet = Graphics.COLOR_BLACK;
    var offSetAmmt = 130;
    var timeOrStep = true;

    var ForC;
    var backImg;

    var showNotes = true;
    var dispSecs = true;

    var oldClockColorNum =11;
    var oldClockShadNum = 0;
    var oldSubColorNum = 2;


class AviationTimeGrayscaleApp extends Application.AppBase {

    var view = null;
    var clockColorNum = 11;
    var clockShadNum;
    var subColorNum = 2;

    function initialize() {
        AppBase.initialize();
        backImg = WatchUi.loadResource(Rez.Drawables.Brushed);
        onSettingsChanged();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        view = new AviationTimeGrayscaleView();
        return [view, new AviationTimeGrayscaleDelegate(view) ];
    }

    function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        var menu = new ATGrayscaleSettingsMenu();
        return [menu, new ATGrayscaleSettingsMenuDelegate()];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {

        //Set Global Settings variables

        if (clockColorNum != null) {oldClockColorNum = clockColorNum;}
        if (clockShadNum != null) {oldClockShadNum = clockShadNum;}
        if (subColorNum != null) {oldSubColorNum = subColorNum;}

        clockColorNum = Properties.getValue("ClockColor");
        clockShadNum = Properties.getValue("ShadOpt");
        subColorNum = Properties.getValue("SubColor");
        showBat = Properties.getValue("DispBatt");
        showNotes = Properties.getValue("ShowNotes");
        dispSecs = Properties.getValue("SecOpt");
        timeOrStep = Properties.getValue("TimeStep");
        offSetAmmt = Properties.getValue("ZuluOffset");


        if (oldClockColorNum != clockColorNum || oldClockShadNum != clockShadNum 
            || oldSubColorNum != subColorNum) {
                colorsUpdated = true;
        } else {
                colorsUpdated = false;
        }
        

        if (colorsUpdated) {
            colorUpdate();  //Apply the changes
        }

        WatchUi.requestUpdate();
    }
    

        function colorUpdate(){
        //Get color settings

		    if (clockColorNum == 0) {
			    clockColorSet = Graphics.COLOR_WHITE;
            } else if (clockColorNum == 1) {
			    clockColorSet = Graphics.COLOR_LT_GRAY;
            } else if (clockColorNum == 2) {
				clockColorSet = Graphics.COLOR_DK_GRAY;
            } else if (clockColorNum == 3) {
				clockColorSet = Graphics.COLOR_BLACK;
            } else if (clockColorNum == 4) {
				clockColorSet = Graphics.COLOR_RED;
            } else if (clockColorNum == 5) {
			    clockColorSet = Graphics.COLOR_DK_RED;
            } else if (clockColorNum == 6) {
				clockColorSet = Graphics.COLOR_ORANGE;
            } else if (clockColorNum == 7) {
				clockColorSet = Graphics.COLOR_YELLOW;
            } else if (clockColorNum == 8) {
				clockColorSet = Graphics.COLOR_GREEN;
            } else if (clockColorNum == 9) {
			    clockColorSet = Graphics.COLOR_DK_GREEN;
            } else if (clockColorNum == 10) {
				clockColorSet = Graphics.COLOR_BLUE;
            } else if (clockColorNum == 11) {
				clockColorSet = Graphics.COLOR_DK_BLUE;
            } else if (clockColorNum == 12) {
				clockColorSet = Graphics.COLOR_PURPLE;
            } else {
				clockColorSet = Graphics.COLOR_PINK;
            }

            //Select shadowing
            if (clockShadNum == 0) {
                clockShadSet = Graphics.COLOR_TRANSPARENT;
            } else if (clockShadNum == 1) {
                clockShadSet = Graphics.COLOR_BLACK;
            } else if (clockShadNum == 2) {
                clockShadSet = Graphics.COLOR_WHITE;
             } else if (clockShadNum == 3) {
                clockShadSet = Graphics.COLOR_LT_GRAY;
            }

            //Select Sub items color
            if (subColorNum == 0) {
                subColorSet = Graphics.COLOR_LT_GRAY;
            } else if (subColorNum == 1) {
                subColorSet = Graphics.COLOR_DK_GRAY;
            } else if (subColorNum == 2) {
                subColorSet = Graphics.COLOR_BLACK;
            } else if (subColorNum == 3) {
                subColorSet = Graphics.COLOR_WHITE;
            } else if (subColorNum == 4) {
                subColorSet = Graphics.COLOR_RED;
            } else if (subColorNum == 5) {
                subColorSet = Graphics.COLOR_GREEN;
            } else if (subColorNum == 6) {
                subColorSet = Graphics.COLOR_BLUE;
            } else if (subColorNum == 7) {
                subColorSet = Graphics.COLOR_PINK;
            }

        }

}


function getApp() as AviationTimeGrayscaleApp {
    return Application.getApp() as AviationTimeGrayscaleApp;
}