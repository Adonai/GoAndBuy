import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

GroupBox {
    anchors.fill: parent
    anchors.margins: mainWidget.height / 100

    Column {
        id: prefContainer
        anchors.fill: parent
        spacing: 5

        add: Transition { NumberAnimation { property: "y"; easing.type: Easing.OutBounce; from: mainWidget.height; duration: 400 } }
        move: Transition { NumberAnimation { property: "y"; easing.type: Easing.OutElastic; duration: 2000 } }

        GroupBox {
            title: qsTr("Main preferences")
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                anchors.fill: parent

                Text {
                    text: qsTr("Phone number to track")
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                }

                TextField {
                    id: phonesPreference
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainWidget.height / 16
                    text: AndroidPrefs.phones
                    validator: RegExpValidator { regExp: /[\d;]+/ }
                    placeholderText: qsTr("Phone number to track")
                    onTextChanged: AndroidPrefs.writeParams()

                    Binding {
                       target: AndroidPrefs
                       property: "phones"
                       value: phonesPreference.text
                    }
                }

                Text {
                    text: qsTr("Buy string to search for")
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                }

                TextField {
                    id: buyStringPreference
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainWidget.height / 16
                    text: AndroidPrefs.buyString
                    placeholderText: qsTr("Buy string")
                    onTextChanged: AndroidPrefs.writeParams()

                    Binding {
                       target: AndroidPrefs
                       property: "buyString"
                       value: buyStringPreference.text
                    }
                }

                Text {
                    text: qsTr("Items priority for SMS")
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                }

                PriorityButton {
                    id: priorityPreference
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Layout.preferredHeight: mainWidget.height / 16
                    currentPriority: AndroidPrefs.smsPriority

                    onCurrentPriorityChanged: AndroidPrefs.writeParams()

                    Binding {
                       target: AndroidPrefs
                       property: "smsPriority"
                       value: priorityPreference.currentPriority
                    }
                }
            }
        }

        GroupBox {
            title: qsTr("Items sync preferences")
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                anchors.fill: parent

                Button {
                    id: syncStarter
                    text: qsTr("Send sync to other app")
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainWidget.height / 16
                    onClicked: ItemHandler.sendSync()
                }

                Button {
                    id: syncReceiver
                    text: qsTr("Receive sync from other app")
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainWidget.height / 16
                    onClicked: ItemHandler.waitSync()
                }

                ExclusiveGroup {
                    id: syncModePreference
                    onCurrentChanged: AndroidPrefs.writeParams()
                }

                RadioButton {
                    id: rb1
                    text: qsTr("Replace items")
                    Layout.fillWidth: true
                    exclusiveGroup: syncModePreference
                    onCheckedChanged: if(checked) AndroidPrefs.syncMode = "1"

                    Binding {
                        target: rb1
                        property: "checked"
                        value: true
                        when: AndroidPrefs.syncMode === "1"
                    }
                }

                RadioButton {
                    id: rb2
                    text: qsTr("Append items")
                    Layout.fillWidth: true
                    exclusiveGroup: syncModePreference
                    onCheckedChanged: if(checked) AndroidPrefs.syncMode = "2"

                    Binding {
                        target: rb2
                        property: "checked"
                        value: true
                        when: AndroidPrefs.syncMode === "2"
                    }
                }

                RadioButton {
                    id: rb3
                    text: qsTr("Append not existing items")
                    Layout.fillWidth: true
                    exclusiveGroup: syncModePreference
                    onCheckedChanged: if(checked) AndroidPrefs.syncMode = "3"

                    Binding {
                        target: rb3
                        property: "checked"
                        value: true
                        when: AndroidPrefs.syncMode === "3"
                    }
                }
            }
        }
    }

    Rectangle {
        id: waiter
        anchors.fill: parent
        color: "#AA000000"
        visible: false

        Rectangle {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            color: "white"
            radius: mainWidget.width / 25
            height: mainWidget.height / 4
            width: mainWidget.width / 1.5

            Text {
                text: qsTr("Please wait...")
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap
            }

            Button {
                text: qsTr("Cancel")
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: mainWidget.width / 20
                onClicked:  ItemHandler.stopSync()
            }
        }

        onVisibleChanged: {
            if(visible) smoothAppear.start()
        }

        NumberAnimation { id: smoothAppear; target: waiter; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutQuad }
    }

    Connections {
        target: ItemHandler
        onSyncCompleted: {
            prefContainer.enabled = true
            waiter.visible = false
        }
        onSyncStarted: {
            prefContainer.enabled = false
            waiter.visible = true
        }
    }
}
