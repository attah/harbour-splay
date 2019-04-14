import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

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

            property bool initialized: false
            Component.onCompleted: {
                initialized = true
            }
            onVisibleChanged: {
                if (visible && initialized)
                    refresh()
            }
        }


        PushUpMenu {
            visible: episodes.more_url !== ""
            MenuItem {
                id: more
                text: qsTr("Mer")
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
            height: detailsColumn.implicitHeight+Theme.paddingSmall
            Column {
                id: detailsColumn
                width: parent.width
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width-2*Theme.horizontalPageMargin
                    text: title
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: "WordWrap"
                }
                Label {
                    x: Theme.horizontalPageMargin
                    Component.onCompleted:  {
                        text = (getFile().duration >= 60*60
                                ? Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, getFile().duration*1000), "hh:mm:ss")
                                : Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, getFile().duration*1000), "mm:ss"))
                    }

                    text: ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeTiny
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width*2/5
                    Component.onCompleted:  {
                        text = new Date(parseInt(publishdateutc.substr(6))).toLocaleString(Locale);
                    }

                    text: ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeTiny
                }

            }

            function getFile() {
                return model.listenpodfile ? model.listenpodfile : model.broadcast.broadcastfiles[0]
            }

            onClicked:  {
                //console.log()
                pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                               {name: program.name,
                                title: title,
                                imageurl: imageurl,
                                url: getFile().url,
                                program_id: program.id,
                                episode_id: id,
                                downloadurl: model.downloadpodfile ? model.downloadpodfile.url : undefined,
                                description: model.description});
            }
        }
        VerticalScrollDecorator {}
    }

}
