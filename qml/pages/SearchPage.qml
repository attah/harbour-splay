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

            onTextChanged: {
                results.source = "https://api.sr.se/api/v2/episodes/search/?format=json&query="+text
            }
        }

        JSONListModel {
            id: results
            query: "$.episodes"
            more_query: "$.pagination.nextpage"
        }


        PushUpMenu {
            visible: programs.more_url !== ""
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
            onClicked:  {
                console.log("pushing program", id)
                pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                               {name: program.name,
                                title: title,
                                imageurl: imageurl,
                                url: model.listenpodfile ? model.listenpodfile.url : model.broadcast.broadcastfiles[0].url,
                                program_id: program.id,
                                episode_id: id,
                                downloadurl: model.downloadpodfile ? model.downloadpodfile.url : undefined,
                                description: model.description});


            }
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Gå till program")
                    onClicked: pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),
                                              {url:  "https://api.sr.se/api/v2/episodes/index?format=json&size=20&programid="+program.id,
                                               program_name: program.name});
                }
            }
        }
        VerticalScrollDecorator {}
    }

}
