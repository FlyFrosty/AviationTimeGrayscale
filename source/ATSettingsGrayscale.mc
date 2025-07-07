import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;


class ATGrayscaleSettings{

    function initialize() {
        //Don't know if brackets are needed
    }
}

class ATGrayscaleSettingsMenu extends WatchUi.Menu2 {

    var mySettings;

    function initialize () {
        Menu2.initialize(null);
        mySettings = new ATGrayscaleSettings();
        Menu2.setTitle("Option");
        //MenuItem(label, sub-label, identifier, options)
        Menu2.addItem(new WatchUi.MenuItem("Steps", null, "steps", null));
        Menu2.addItem(new WatchUi.MenuItem("Zulu", null, "zulu", null));
    }

}

class ATGrayscaleSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {


    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        
        if (id.equals("steps")) {
            timeOrStep = false;
        } else {
            timeOrStep = true;  //zulu time
        }
        Application.Properties.setValue("TimeStep", timeOrStep);
        onBack();
    }

}