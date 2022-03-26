import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property string url
    property string program_name
    property int program_id: 0

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
            id: pageheader
            title: program_name
            description: " " //to get some extra space
            IconButton {
                id: favourite
                parent: pageheader.extraContent
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -height/4

                Component.onCompleted: {
                    pageheader.extraContent.anchors.right = pageheader.right
                }

                visible: program_id != 0
                property bool is_favourite: db.isFavourite(program_id)
                icon.source: is_favourite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                onClicked: { is_favourite ? db.unsetFavourite(program_id) : db.setFavourite(program_id, program_name); is_favourite = db.isFavourite(program_id)}
            }

        }
        delegate: ListItem {
            id: delegate
            contentHeight: detailsColumn.implicitHeight+Theme.paddingSmall
            Column {
                id: detailsColumn
                width: parent.width
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width-2*Theme.horizontalPageMargin
                    text: title.replace(/\*([A-ZÅÄÖa-zåäö0-9]+)\*/g,"<b>$1</b>")
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

            function hasBroadcast() {
                console.log(model.broadcast != undefined  && model.broadcast.broadcastfiles.length)
                return model.broadcast != undefined && model.broadcast.broadcastfiles.length
            }

            function getFile() {
                return hasBroadcast() ? model.broadcast.broadcastfiles[0] : model.listenpodfile
            }


            onClicked:  {
                //console.log()
                pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                               {name: program.name,
                                title: title,
                                imageurl: imageurl,
                                url: hasBroadcast() ? model.broadcast.broadcastfiles[0].url : model.listenpodfile.url,
                                program_id: program.id,
                                episode_id: id,
                                downloadurl: model.downloadpodfile ? model.downloadpodfile.url : "",
                                description: model.description});
            }
            menu: ContextMenu {
                id: programMenu
                enabled: model.downloadpodfile
                MenuItem {
                    text: qsTr("Ladda ner")
                    onClicked: {
                        Qt.openUrlExternally(model.downloadpodfile.url)
                    }
                }
            }

        }
        VerticalScrollDecorator {}
    }

}
