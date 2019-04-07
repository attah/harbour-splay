/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *               - Now with pagination support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Copyright (c) 2018 Anton Thomasson (antonthomasson ... gmail)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string more_query: ""
    property string more_url: ""
    signal more

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {more_url = ""; get(source)}
    onJsonChanged: updateJSONModel()
    // onQueryChanged: updateJSONModel() borked by pagination logic
    onMore: get(more_url)

    function get(what) {
        console.log(what)

        var xhr = new XMLHttpRequest;
        xhr.open("GET", what);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                json = xhr.responseText;
        }
        xhr.send();
    }

    function refresh() {
        console.log("refresh");
        more_url = ""; //reset pagination
        get(source);
    }

    function updateJSONModel() {

        if(more_url === "")
            jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);

        for ( var key in objectArray ) {
            var jo = objectArray[key];
            jsonModel.append( jo );
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( more_query !== "") {
            var qjs = JSONPath.jsonPath(objectArray, more_query)
            console.log(qjs)
            if (qjs[0] === undefined)
                more_url = ""
            else
                more_url = qjs[0]
        }
        if ( jsonPathQuery === "" )
            return objectArray;
        return JSONPath.jsonPath(objectArray, jsonPathQuery);
    }
}
