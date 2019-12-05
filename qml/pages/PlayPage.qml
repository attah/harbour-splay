import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool now_playing: false
    property string name : now_playing ? globalMedia.name : ""
    property string title : now_playing ? globalMedia.title : ""
    property string imageurl : now_playing ? globalMedia.imageurl : ""
    property string url : now_playing ? globalMedia.source : ""
    property string downloadurl : now_playing ? globalMedia.downlaodurl : ""
    property string description: now_playing ? globalMedia.description : ""
    property int program_id: now_playing ? globalMedia.program_id : 0
    property int episode_id: now_playing ? globalMedia.episode_id : 0


    SilicaFlickable {
        anchors.fill: parent

        Component.onCompleted: {
            if(url != globalMedia.source) {
                globalMedia.stop()
                globalMedia.source = url
                globalMedia.name = name
                globalMedia.title = title
                globalMedia.imageurl = imageurl
                globalMedia.program_id = program_id
                globalMedia.episode_id = episode_id
                globalMedia.description = description
                globalMedia.seek(db.getProgress(episode_id))
                globalMedia.play()
                console.log("media updated", url, globalMedia.source)
            }
        }
        PageHeader {
            id: header
            title: name
        }


         Column {
             id: column
             spacing: Theme.paddingLarge
             width: page.orientation === Orientation.Portrait ? parent.width : parent.width/2
             anchors.top: header.bottom
             anchors.left: parent.left


             Label {
                 id: title_label
                 text: title
                 property bool going_left: true
                 property int pad: Theme.paddingLarge
                 property int right_position: pad
                 property int left_position: parent.width - title_label.width - pad
                 property int scroll_distance: title_label.width - parent.width + 2*pad

                 font.pixelSize: Theme.fontSizeSmall

                 x: page.orientation === Orientation.Portrait ? dyn_x : right_position
                 property int dyn_x: right_position-1
                 Component.onCompleted: {
                     if (title_label.width > parent.width) {
                         going_left = true
                         dyn_x = left_position
                     }
                 }
                 Behavior on dyn_x {
                     enabled: page.orientation === Orientation.Portrait
                     NumberAnimation { duration: 33 * title_label.scroll_distance }
                 }
                 onXChanged: {
                     if (!going_left && dyn_x === right_position) {
                         dyn_x = left_position;
                         going_left = true;
                     }
                     else if (going_left  && dyn_x === left_position) {
                         dyn_x = right_position;
                         going_left = false;
                     }
                 }

             }

             Label {
                id: descriptionLabel
                visible: false
                width: parent.width-2*Theme.paddingLarge
                height: parent.width*0.8
                x: Theme.paddingLarge
                text: description
                wrapMode: Text.WordWrap
                MouseArea {
                   anchors.fill: parent
                   onClicked: {descriptionLabel.visible = false; coverimage.visible = true}
                }
             }
             Image {
                 id: coverimage
                 source: imageurl
                 width: Math.min(page.width*0.8, page.height*0.7)
                 height: width
                 anchors.horizontalCenter: parent.horizontalCenter

                 MouseArea {
                    anchors.fill: parent
                    onClicked: {if(description !== "") {
                                coverimage.visible = false;
                                descriptionLabel.visible = true
                               }
                    }
                 }
             }

        }
         Column {
             id: column2
             spacing: Theme.paddingLarge
             width: page.orientation === Orientation.Portrait ? parent.width : parent.width/2
             anchors.bottom: parent.bottom
             anchors.right: parent.right
             anchors.bottomMargin: 2*Theme.paddingLarge

             Row {
                 width: parent.width
                 anchors.horizontalCenter: parent.horizontalCenter

                 IconButton {
                     id: downloadpod
                     visible: program_id !== 0
                     icon.source: "image://theme/icon-m-cloud-download"
                     onClicked: {console.log(downloadurl); Qt.openUrlExternally(downloadurl)}
                     width: parent.width / 2
                     anchors.verticalCenter: parent.verticalCenter
                     enabled: downloadurl !== "" ? true : false
                 }

                 IconButton {
                     id: favourite
                     visible: program_id !== 0
                     property bool is_favourite: db.isFavourite(program_id)
                     icon.source: is_favourite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                     onClicked: { is_favourite ? db.unsetFavourite(program_id) : db.setFavourite(program_id, name); is_favourite = db.isFavourite(program_id)}
                     width: parent.width / 2
                     anchors.verticalCenter: parent.verticalCenter
                 }
             }

             Slider {
                 id: progressSlider

                 visible: globalMedia.duration !== 0
                 minimumValue: 0
                 maximumValue: globalMedia.duration
                 width: parent.width
                 handleVisible: true

                 value: globalMedia.position

                 onSliderValueChanged: {
                         down && globalMedia.seek(sliderValue)
                 }

             }

             Row {
                 anchors.horizontalCenter: parent.horizontalCenter

                 Label {
                     id: positionLabel
                     anchors.verticalCenter: parent.verticalCenter

                     text: globalMedia.duration !== 0 ?  (globalMedia.duration >= 60*60*1000
                                                          ? Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, globalMedia.position), "hh:mm:ss")
                                                          : Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, globalMedia.position), "mm:ss"))
                                                      : ""
                 }
                 Label {
                     anchors.verticalCenter: parent.verticalCenter

                     font.pixelSize: Theme.fontSizeLarge
                     text: globalMedia.duration !== 0 ? " / " : qsTr("Live!")
                 }
                 Label {
                     anchors.verticalCenter: parent.verticalCenter

                     id: durationLabel
                     text: globalMedia.duration !== 0 ?  (globalMedia.duration >= 60*60*1000
                                                          ? Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, globalMedia.duration), "hh:mm:ss")
                                                          : Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, globalMedia.duration), "mm:ss"))
                                                      : ""
                 }
             }

             Row {
                 width: parent.width

                 IconButton {
                     id: previous
                     icon.source: "image://theme/icon-m-previous"
                     onClicked: globalMedia.goBackward()
                     width: parent.width / 3
                     anchors.verticalCenter: parent.verticalCenter
                 }


                 IconButton {
                     id: play
                     icon.source: globalMedia.playbackState === 1 ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
                     onClicked: globalMedia.togglePlaying()
                     width: parent.width / 3
                     anchors.verticalCenter: parent.verticalCenter
                 }

                 IconButton {
                     id: next
                     icon.source: "image://theme/icon-m-next"
                     onClicked: globalMedia.goForward()
                     width: parent.width / 3
                     anchors.verticalCenter: parent.verticalCenter
                 }
             }
             LongPhonePadding {
                 padding: Screen.height*0.15
             }

         }
    }
}
