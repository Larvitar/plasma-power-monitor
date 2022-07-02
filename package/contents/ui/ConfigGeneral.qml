import QtQuick 2.6
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_valueBatteryNumber: valueBatteryNumber.value
    property alias cfg_aliasFontSize: aliasFontSize.value
    property alias cfg_valueFontSize: valueFontSize.value
    property alias cfg_makeFontBold: makeFontBold.checked
    property alias cfg_showUnit: showUnit.checked
    property alias cfg_showDecimals: showDecimals.checked
    property alias cfg_alias: alias.text

    ColumnLayout {
        RowLayout {
            Label {
                id: updateIntervalLabel
                text: i18n("Update interval:")
            }
            SpinBox {
                id: updateInterval
                decimals: 1
                stepSize: 0.1
                minimumValue: 0.1
                suffix: i18nc("Abbreviation for seconds", "s")
            }
        }

        RowLayout {
            Label {
                id: valueBatteryNumberLabel
                text: i18n("Battery Number:")
            }
            SpinBox {
                id: valueBatteryNumber
                decimals: 0
                minimumValue: 0
                maximumValue: 9
            }
        }

        RowLayout {
            Label {
                id: valueFontSizeLabel
                text: i18n("Value Font Size:")
            }
            SpinBox {
                id: valueFontSize
                decimals: 0
                minimumValue: 2
                maximumValue: 100
            }
        }

        RowLayout {
            Label {
                id: aliasLabel
                text: i18n("Label:")
            }
            TextField {
                id: alias
            }
        }

        RowLayout {
            Label {
                id: aliasFontSizeLabel
                text: i18n("Label Font Size:")
            }
            SpinBox {
                id: aliasFontSize
                decimals: 0
                stepSize: 1
                minimumValue: 2
                maximumValue: 100
            }
        }

        CheckBox {
            id: makeFontBold 
            text: i18n("Bold Text")
        }

        CheckBox {
            id: showUnit 
            text: i18n("Show Unit")
        }

        CheckBox {
            id: showDecimals 
            text: i18n("Show Decimals")
        }
    }
}
