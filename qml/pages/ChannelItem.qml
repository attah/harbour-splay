import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: channelItem
    property string imageUrl
    property int channelId
    property string channelName
    property var rightnow
    property var nextChange: 0
    property int initialized: 0

    onRightnowChanged: {
        var now = new Date();
        nextChange = new Date(now.valueOf()+60*1000);

        if(rightnow.channel.nextscheduledepisode)
        {
            nextChange = new Date(parseInt(rightnow.channel.nextscheduledepisode.starttimeutc.substr(6)));
            nextPlaying.text = Qt.formatTime(nextChange, "hh:mm: ")+rightnow.channel.nextscheduledepisode.title
        }

        if(rightnow.channel.currentscheduledepisode)
        {
            nowPlaying.text = rightnow.channel.currentscheduledepisode.title
        }
    }

    Timer {
        id: refreshTimer
        running: channelItem.visible
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            var now = new Date();
            if (now > nextChange)
            {
                getRightnow();
            }
        }

    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                       {name: rightnow.channel.name,
                        imageurl: channelItem.imageUrl,
                        url: "https://sverigesradio.se/topsy/direkt/srapi/"+channelId+".mp3",
                        download_url: ""});

    }

    Image {
        id: channelImage

        width: parent.height
        height: parent.height
        anchors.left: parent.left

        source: channelItem.imageUrl
    }
    Label {
        id: nowPlaying
        text: channelName
        anchors.left: channelImage.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: channelItem.height*1/3
        truncationMode: TruncationMode.Fade

        onTextChanged: {
            if(initialized>1)
            {
                nextPlaying.opacity = 0.0
                nowPlaying.opacity = 0.0
                rotateInAnimation.start()
            }
            initialized++
        }

    }
    Label {
        id: nextPlaying
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        anchors.left: channelImage.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: channelItem.height*2/3
        truncationMode: TruncationMode.Fade
    }


    ParallelAnimation {
        id: rotateInAnimation

        NumberAnimation { target: nowPlaying.anchors; property: "verticalCenterOffset"; from: channelItem.height*2/3; to: channelItem.height*1/3; duration: 666 }
//        NumberAnimation { target: nowPlaying.font; property: "pixelSize"; from: Theme.fontSizeExtraSmall; to: Theme.fontSizeSmall; duration: 666 }
        NumberAnimation { target: nowPlaying; property: "opacity"; from: 0.0; to: 1.0; duration: 666 }
        NumberAnimation { target: nextPlaying.anchors; property: "verticalCenterOffset"; from: channelItem.height*4/5; to: channelItem.height*2/3; duration: 666 }
        NumberAnimation { target: nextPlaying; property: "opacity"; from: 0.0; to: 1.0; duration: 666 }

    }

    function getRightnow() {

        var xhr = new XMLHttpRequest;
        xhr.open("GET", "http://api.sr.se/api/v2/scheduledepisodes/rightnow?channelid="+channelId+"&format=json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {
                rightnow = JSON.parse(xhr.responseText)
            }

        }
        xhr.send();
    }
}
