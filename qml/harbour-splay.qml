import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: appWin
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.Portrait


    Item {
        id: db
        property var db_conn
        property ListModel favourites_model : ListModel { id: favouritesModel }

        Component.onCompleted: {
            db_conn = LocalStorage.openDatabaseSync("SPlayDB", "1.0", "S'Play storage", 100000)
            db_conn.transaction(function (tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Favourites (id INT UNIQUE, name STRING)');
            });
            updateFavourites();
        }

        function isFavourite(id) {
            var is_fav = false
            db_conn.transaction(function (tx) {
                var res = tx.executeSql('SELECT id FROM Favourites WHERE id=?', [id] );
                console.log("isfav", res.rows.length !== 0);
                is_fav = res.rows.length !== 0;
            });
            return is_fav;
        }
        function setFavourite(id, name) {
            console.log("setvfav", id);
            db_conn.transaction(function (tx) {
                tx.executeSql('INSERT INTO Favourites VALUES(?, ?)', [id, name] );
            });
            updateFavourites();
        }
        function unsetFavourite(id) {
            console.log("unsetvfav", id);
            db_conn.transaction(function (tx) {
                tx.executeSql('DELETE FROM Favourites WHERE id=?', [id] );
            });
            updateFavourites();
        }
        function updateFavourites() {
            favourites_model.clear();
            db_conn.transaction(function (tx) {
                var rs = tx.executeSql('SELECT * FROM Favourites');
                for (var i = 0; i < rs.rows.length; i++) {
                    console.log("fav!", rs.rows.item(i).id, rs.rows.item(i).name);
                    favourites_model.append(rs.rows.item(i));
                }
            })
        }
    }

    MediaPlayer {
        property string name
        property string title
        property string imageurl
        property string downloadurl
        property int id

        id: globalMedia
        autoLoad: true
        onStatusChanged: {console.log(status); if( status === MediaPlayer.Loaded ) {play()}}
    }

}
