import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property int category_id
    property string category_name

    SilicaListView {
        id: listView

        header: SearchField {
            id: searchField
            width: parent.width
            placeholderText: qsTr("Sök")
            anchors.verticalCenter: parent.verticalCenter

            onTextChanged: {
                results.source = "https://api.sr.se/api/v2/episodes/search/?format=json&query="+text
            }

            Component.onCompleted: {
                console.log("foc!")
                searchField.forceActiveFocus()
            }
        }

        JSONListModel {
            id: results
            query: "$.episodes"
            more_query: "$.pagination.nextpage"
        }


        PushUpMenu {
            visible: results.more_url !== ""
            MenuItem {
                id: more
                text: qsTr("Mer")
                onClicked: results.more()
            }
        }

        currentIndex: -1
        model: results.model
        anchors.fill: parent

        delegate: ListItem {
            id: delegate

            Column {
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    x: Theme.horizontalPageMargin
                    text: program.name
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    Component.onCompleted:  {
                        text = title+" "+new Date(parseInt(publishdateutc.substr(6))).toLocaleString(Locale);
                    }

                    x: Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeTiny
                }
            }

            function hasBroadcast() {
                console.log(model.broadcast != undefined  && model.broadcast.broadcastfiles.length)
                return model.broadcast != undefined && model.broadcast.broadcastfiles.length
            }

            onClicked:  {
                console.log("pushing program", id)
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
                MenuItem {
                    text: qsTr("Gå till program")
                    onClicked: pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),
                                              {url:  "https://api.sr.se/api/v2/episodes/index?format=json&size=20&programid="+program.id,
                                               program_name: program.name,
                                               program_id: program.id});
                }
                MenuItem {
                    text: qsTr("Ladda ner")
                    enabled: model.downloadpodfile
                    onClicked: {
                        Qt.openUrlExternally(model.downloadpodfile.url)
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }

}
