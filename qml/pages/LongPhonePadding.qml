import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property int padding: 0
    readonly property bool isLong: Screen.width*2 < Screen.height
    height: isPortrait && isLong ? padding : 0
    width: parent.width
}
