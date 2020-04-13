import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView

        PullDownMenu {
            visible: globalMedia.source != ""
            MenuItem {
                text: qsTr("Nu spelas")
                onClicked: pageStack.push(Qt.resolvedUrl("PlayPage.qml"), {now_playing: true})
            }
        }

        JSONListModel {
            id: programs
            source: "https://api.sr.se/api/v2/channels/?format=json&size=20"
            query: "$.channels"
            more_query: "$.pagination.nextpage"
        }

        model: programs.model
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Kanaler")
        }

        PushUpMenu {
            visible: programs.more_url !== ""
            MenuItem {
                id: more
                text: qsTr("Mer")
                onClicked: programs.more()
            }
        }

        delegate: ChannelItem {
            height: Theme.itemSizeLarge
            width: parent.width

            imageUrl: image
            channelId: id
            channelName: name

        }

        VerticalScrollDecorator {}
    }

}
