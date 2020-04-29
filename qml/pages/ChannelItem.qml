import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: channelItem
    property string imageUrl
    property int channelId
    property string channelName
    property var rightnow: timekeeper.rightnow[channelId]

    onRightnowChanged: {
        if (!rightnow)
        {
            nowPlaying.text = channelName
            return
        }

        var now = new Date();
        timekeeper.endtimes[channelId] = new Date(now.valueOf()+60*1000);
        timekeeper.rightnow[channelId] = rightnow

        if(rightnow.channel.currentscheduledepisode)
        {
            nowPlaying.text = rightnow.channel.currentscheduledepisode.title
        }
        else
        {
            nowPlaying.text = channelName
        }

        if(rightnow.channel.nextscheduledepisode)
        {
            timekeeper.endtimes[channelId] = new Date(parseInt(rightnow.channel.nextscheduledepisode.starttimeutc.substr(6)));
            nextPlaying.text = Qt.formatTime(timekeeper.endtimes[channelId], "hh:mm: ")+rightnow.channel.nextscheduledepisode.title
        }
    }

    Timer {
        id: refreshTimer
        running: channelItem.visible
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            var now = new Date();
            var nextChange = timekeeper.endtimes[channelId] ? timekeeper.endtimes[channelId] : 0
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
        anchors.left: channelImage.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: channelItem.height*1/3
        truncationMode: TruncationMode.Fade
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
