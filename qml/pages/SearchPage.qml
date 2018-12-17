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
                onClicked: programs.more()
            }
        }

        currentIndex: -1
        model: results.model
        anchors.fill: parent

        delegate: BackgroundItem {
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
                pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),
                               {url:  "https://api.sr.se/api/v2/episodes/index?format=json&size=20&programid="+id,
                                program_name: name});

            }
        }
        VerticalScrollDecorator {}
    }

}
