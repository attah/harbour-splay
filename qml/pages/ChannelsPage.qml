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
            title: "Kanaler"
        }

        PushUpMenu {
            visible: programs.more_url !== ""
            MenuItem {
                id: more
                text: "Mer"
                onClicked: programs.more()
            }
        }

        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.horizontalPageMargin
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked:  {
                pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                               {id: 0,
                                name: name,
                                title: tagline,
                                imageurl: image,
                                url: liveaudio.url,
                                downloadurl: ""});
            }
        }
        VerticalScrollDecorator {}
    }

}
