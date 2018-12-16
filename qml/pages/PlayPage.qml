import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property bool now_playing: false
    property string name : now_playing ? globalMedia.name : ""
    property string title : now_playing ? globalMedia.title : ""
    property string imageurl : now_playing ? globalMedia.imageurl : ""
    property string url : now_playing ? globalMedia.source : ""
    property string downloadurl : now_playing ? globalMedia.downlaodurl : ""
    property int id: now_playing ? globalMedia.id : ""

    SilicaFlickable {
        anchors.fill: parent

        Component.onCompleted: {
            if(url != globalMedia.source) {
                globalMedia.source = url
                globalMedia.name = name
                globalMedia.title = title
                globalMedia.imageurl = imageurl
                globalMedia.id = id
                console.log("media updated", url, globalMedia.source)
            }
        }

         Column {
             id: column
             spacing: Theme.paddingLarge
             width: parent.width
             PageHeader {
                 title: name
             }

             Label {
                 id: title_label
                 text: title
                 property bool going_left: true
                 property int pad: Theme.paddingLarge
                 property int right_position: pad
                 property int left_position: parent.width - title_label.width - pad
                 property int scroll_distance: title_label.width - parent.width + 2*pad

                 font.pixelSize: Theme.fontSizeSmall

                 x: right_position
                 Component.onCompleted: {
                     if (title_label.width > parent.width) {
                         going_left = true
                         x = left_position
                     }
                 }
                 Behavior on x {
                     NumberAnimation { duration: 33 * title_label.scroll_distance }
                 }
                 onXChanged: {
                     if (!going_left && x === right_position) {
                         x = left_position;
                         going_left = true;
                     }
                     else if (going_left  && x === left_position) {
                         x = right_position;
                         going_left = false;
                     }
                 }

             }



             Image {
                 source: imageurl
                 width: parent.width*0.8
                 height: parent.width*0.8
                 anchors.horizontalCenter: parent.horizontalCenter

             }

        }
         Column {
             id: column2
             spacing: Theme.paddingLarge
             width: parent.width
             anchors.bottom: parent.bottom
             anchors.bottomMargin: 2*Theme.paddingLarge

             Row {
                 width: parent.width
                 anchors.horizontalCenter: parent.horizontalCenter

                 IconButton {
                     id: downloadpod
                     visible: id !== 0
                     icon.source: "image://theme/icon-m-cloud-download"
                     onClicked: {console.log(downloadurl)}
                     width: parent.width / 2
                     anchors.verticalCenter: parent.verticalCenter
                     enabled: false // FIXME, enable when this does something \\ downloadurl !== "" ? true : false
                 }

                 IconButton {
                     id: favourite
                     visible: id !== 0
                     property bool is_favourite: db.isFavourite(id)
                     icon.source: is_favourite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                     onClicked: { is_favourite ? db.unsetFavourite(id) : db.setFavourite(id, name); is_favourite = db.isFavourite(id)}
                     width: parent.width / 2
                     anchors.verticalCenter: parent.verticalCenter
                 }
             }

             Slider {
                 id: progressSlider

                 visible: globalMedia.duration !== 0
                 maximumValue: globalMedia.duration
                 property bool sync: false
                 width: parent.width
                 handleVisible: true


                 onValueChanged: {
                     if (!sync)
                         globalMedia.seek(value)
                 }

                 Connections {
                     target: globalMedia
                     onPositionChanged: {
                         progressSlider.sync = true
                         progressSlider.value = globalMedia.position
                         progressSlider.sync = false
                     }
                 }
             }

             Row {
                 anchors.horizontalCenter: parent.horizontalCenter

                 Label {
                     id: positionLabel
                     anchors.verticalCenter: parent.verticalCenter

                     readonly property int minutes: Math.floor(globalMedia.position / 60000)
                     readonly property int seconds: Math.round((globalMedia.position % 60000) / 1000)

                     text: globalMedia.duration !== 0 ? Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss")) : ""
                 }
                 Label {
                     anchors.verticalCenter: parent.verticalCenter

                     font.pixelSize: Theme.fontSizeLarge
                     text: globalMedia.duration !== 0 ? " / " : "Live!"
                 }
                 Label {
                     anchors.verticalCenter: parent.verticalCenter

                     id: durationLabel
                     readonly property int minutes: Math.floor(globalMedia.duration / 60000)
                     readonly property int seconds: Math.round((globalMedia.duration % 60000) / 1000)

                     text: globalMedia.duration !== 0 ?  Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss")) : ""
                 }
             }

             Row {
                 width: parent.width

                 IconButton {
                     id: previous
                     icon.source: "image://theme/icon-m-previous"
                     onClicked: globalMedia.seek(globalMedia.position - 10000 > 0 ? globalMedia.position - 10000 : 0)
                     width: parent.width / 3
                     anchors.verticalCenter: parent.verticalCenter
                 }


                 IconButton {
                     id: play
                     icon.source: globalMedia.playbackState === 1 ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
                     onClicked: globalMedia.playbackState === 1 ? globalMedia.pause() : globalMedia.play()
                     width: parent.width / 3
                     anchors.verticalCenter: parent.verticalCenter
                 }

                 IconButton {
                     id: next
                     icon.source: "image://theme/icon-m-next"
                     onClicked: globalMedia.seek(globalMedia.position + 10000 < globalMedia.duration ? globalMedia.position + 10000 : globalMedia.duration)
                     width: parent.width / 3
                     anchors.verticalCenter: parent.verticalCenter
                 }
             }
         }
    }
}
