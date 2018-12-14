import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string url
    property string program_name

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
            id: episodes
            source: url
            query: "$.episodes"
            more_query: "$.pagination.nextpage"
            Component.onCompleted: {
                appWin.reactivated.connect(episodes.refresh())
            }
        }


        PushUpMenu {
            visible: episodes.more_url !== ""
            MenuItem {
                id: more
                text: "Mer"
                onClicked: episodes.more()
            }
        }

        model: episodes.model
        anchors.fill: parent
        header: PageHeader {
            title: program_name
        }
        delegate: BackgroundItem {
            id: delegate
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    x: Theme.horizontalPageMargin
                    text: title
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    Component.onCompleted:  {
                        text = new Date(parseInt(publishdateutc.substr(6))).toLocaleString(Locale);
                    }

                    x: Theme.horizontalPageMargin
                    text: ""
                    font.pixelSize: Theme.fontSizeTiny
                }
            }


            onClicked:  {
                //console.log()
                pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                               {name: program.name,
                                title: title,
                                imageurl: imageurl,
                                url: model.listenpodfile ? model.listenpodfile.url : model.broadcast.broadcastfiles[0].url,
                                id: program.id,
                                downloadurl: model.downloadpodfile ? model.downloadpodfile.url : undefined});
            }
        }
        VerticalScrollDecorator {}
    }

}
