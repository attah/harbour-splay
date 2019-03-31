import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: barButton
    height: implicitHeight+2*Theme.paddingMedium

    property alias text: label.text
    property bool attention: false
    property color baseColor: Theme.highlightBackgroundColor
    property color attentionColor: "red"
    highlightedColor: Theme.rgba(Theme.highlightBackgroundFromColor(attention ? attentionColor : baseColor, Theme.colorScheme),
                                 Theme.highlightBackgroundOpacity)

    function _color(alpha) {
        alpha = attention ? alpha*0.75 : alpha*0.25
        return Theme.rgba(attention ? attentionColor : baseColor, alpha)
    }

    Rectangle {
        x: -1
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: _color(1) }
            GradientStop { position: 0.2; color: _color(0.6) }
            GradientStop { position: 0.8; color: _color(0.4) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Label {
        id: label
        x: Theme.paddingMedium
        text: parent.text
        anchors.verticalCenter: parent.verticalCenter
        color: barButton.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        source: "image://theme/icon-m-right"
    }

}
