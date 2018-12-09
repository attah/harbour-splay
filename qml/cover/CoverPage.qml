import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label
        anchors.centerIn: parent
        text: "S'Play"
    }
    Image {
        id: coverImage
        source: globalMedia.imageurl
        width: parent.width
        height: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
    }
    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: globalMedia.playbackState === 1 ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
            onTriggered: globalMedia.playbackState === 1 ? globalMedia.pause() : globalMedia.play()
        }
    }
}
