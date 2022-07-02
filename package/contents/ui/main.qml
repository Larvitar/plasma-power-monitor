/*
 * Copyright 2021  Atul Gopinathan  <leoatul12@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    id: main
    anchors.fill: parent
    
    //height and width, when the widget is placed in desktop
    width: 80
    height: 80

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    onParentWidthChanged: setWidgetSize()
    onParentHeightChanged: setWidgetSize()

    property string batPath: getBatPath()
    property bool powerNow: checkPowerNow(batPath)
    property double power: getPower(batPath)

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property double parentWidth: parent !== null ? parent.width : 0
    property double parentHeight: parent !== null ? parent.height : 0
    property double itemWidth: 0
    property double itemHeight: 0

    function setWidgetSize() {
        if (!parentHeight) {
            return
        }
        if (vertical) {
            itemWidth = parentWidth
        } else {
            itemWidth = parentHeight
        }
        itemHeight = itemWidth
    }

    //this function tries to find the exact path to battery file
    function getBatPath() {
        var path = "/sys/class/power_supply/BAT" + plasmoid.configuration.valueBatteryNumber + "/voltage_now";
        var req = new XMLHttpRequest();
        req.open("GET", path, false);
        req.send(null)
        if(req.responseText != "") {
            return "/sys/class/power_supply/BAT" + plasmoid.configuration.valueBatteryNumber;
        }
        return ""
    }

    //this function checks if the "/sys/class/power_supply/BAT[i]/power_now" file exists
    function checkPowerNow(fileUrl) {
        if(fileUrl == "") {
            return false
        }

        var path = fileUrl + "/power_now"
        var req = new XMLHttpRequest();

        req.open("GET", path, false);
        req.send(null);

        if(req.responseText == "") {
            return false
        }
        else {
            return true
        }
    }

    function displayPower(powerValue) {
        var power = powerValue;
        if(Number.isInteger(power)) {
            power += ".0"
        }

        if(!plasmoid.configuration.showDecimals) {
            power = Math.round(power)
        }
                
        if(plasmoid.configuration.showUnit) {
            power += "W"
        }

        return(power);
    }

    //Returns power usage in Watts, rounded off to 1 decimal.
    function getPower(fileUrl) {
        //if there is no BAT[i] file at all
        if(fileUrl == "") {
            return "0.0"
        }

        //in case the "power_now" file exists:
        if( main.powerNow == true) {
            var path = fileUrl + "/power_now"
            var req = new XMLHttpRequest();
            req.open("GET", path, false);
            req.send(null);

            var power = parseInt(req.responseText) / 1000000;
            return(Math.round(power*10)/10);
        }

        //if the power_now file doesn't exist, we collect voltage
        //and current and manually calculate power consumption
        var curUrl = fileUrl + "/current_now"
        var voltUrl = fileUrl + "/voltage_now"

        var curReq = new XMLHttpRequest();
        var voltReq = new XMLHttpRequest();

        curReq.open("GET", curUrl, false);
        voltReq.open("GET", voltUrl, false);

        curReq.send(null);
        voltReq.send(null);

        var power = (parseInt(curReq.responseText) * parseInt(voltReq.responseText))/1000000000000;
        //console.log(power.toFixed(1));
        return Math.round(power*10)/10; //toFixed() is apparently slow, so we use this way
    }

    Item {
        id: labels
        anchors.fill: parent

        PlasmaComponents.Label {
            id: aliasText
            anchors.fill: parent

            verticalAlignment: Text.AlignTop

            text: plasmoid.configuration.alias

            font.pixelSize: itemHeight * plasmoid.configuration.aliasFontSize * 0.01
            font.pointSize: -1
        }

        PlasmaComponents.Label {
            id: display

            anchors.bottom: aliasText.text === '' ? undefined : parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 1
            anchors.verticalCenter: aliasText.text === '' ? parent.verticalCenter : undefined
            anchors.fill: parent

            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignRight

            text: displayPower(main.power)

            font.pixelSize: itemHeight * plasmoid.configuration.valueFontSize * 0.01
            font.pointSize: -1
            font.bold: plasmoid.configuration.makeFontBold
        }
    }

    Timer {
        interval: plasmoid.configuration.updateInterval * 1000
        running: true
        repeat: true
        onTriggered: {
            main.power = getPower(main.batPath)
            display.text = displayPower(main.power)
        }
    }
}
