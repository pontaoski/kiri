import QtQuick 2.9
import QtQuick.Controls 1.0
import QtQuick.Window 2.2
import QtWebEngine 1.8
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import Qt.labs.settings 1.0

Kirigami.ApplicationWindow {
    id: root

    title: webview.title + " - Kiri"

    Settings {
        id: kiriSettings
        property string homepage: "http://qt-project.org"
    }

    menuBar: Kirigami.ApplicationHeader {
        id: appHead
        RowLayout {
            anchors.fill: parent
            PlasmaComponents.ToolButton {
                iconSource: "arrow-left"
                enabled: webview.canGoBack
                onClicked: {
                    webview.goBack()
                }
            }
            PlasmaComponents.ToolButton {
                iconSource: "arrow-right"
                enabled: webview.canGoForward
                onClicked: {
                    webview.goForward()
                }
            }
            PlasmaComponents.ToolButton {
                iconSource: webview.loading ? "process-stop-symbolic" : "view-refresh-symbolic"
                onClicked: {
                    if (webview.loading == true) {
                        webview.stop()
                    } else {
                        webview.reload()
                    }
                }
            }
            PlasmaComponents.ToolButton {
                id: webIcon
                function displayIcon() {
                    if (webview.loading == true) {
                        return false
                    } else if (webview.icon == ""){
                        return false
                    } else {
                        return true
                    }
                }

                PlasmaCore.IconItem {
                    id: loader
                    anchors.centerIn: parent
                    visible: !webIcon.displayIcon()
                    source: "view-refresh-symbolic"
                    NumberAnimation {
                        running: webview.loading
                        id: loaderAnimation
                        target: loader
                        properties: "rotation"
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                Image {
                    scale: 0.5
                    visible: webIcon.displayIcon()
                    anchors.fill: parent
                    source: webview.icon != "" ? webview.icon : "tool_pagelayout"
                }
            }
            PlasmaComponents.TextField {
                id:   omnbox
                text: kiriSettings.homepage
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                onAccepted: {
                    webview.url = this.text
                }
                validator: RegExpValidator { regExp: /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/ }
            }
        }
    }
    globalDrawer: Kirigami.GlobalDrawer {
        id:    sidebar
        title: "Kiri"
        actions: [
            Kirigami.Action {
                iconSource: "go-home-symbolic"
                text: "Return to home"
                onTriggered: {
                    webview.url = kiriSettings.homepage
                }
            },
            Kirigami.Action {
                iconSource: "settings-configure"
                text:       "Configure Kiri"
                Kirigami.Action {
                    text: "Set Homepage"
                    onTriggered: {
                        homepagePromptDrawer.prompt()
                    }
                }
            }

        ]

        Row {
            Layout.alignment: Qt.AlignHCenter
            PlasmaComponents.ToolButton {
                iconSource: "zoom-in"
                onClicked: {
                    webview.zoomFactor = webview.zoomFactor + .1
                }
            }
            PlasmaComponents.Label {
                text: Math.round(webview.zoomFactor * 100) + "%"
            }
            PlasmaComponents.ToolButton {
                iconSource: "zoom-out"
                onClicked: {
                    webview.zoomFactor = webview.zoomFactor - .1
                }
            }
        }
    }
    Kirigami.OverlayDrawer {
        id:             homepagePromptDrawer
        edge:           Qt.BottomEdge
        contentItem: ColumnLayout {
                        Kirigami.Heading {
                            id: textPromptLabel
                            text: "Enter the URL for the homepage"
                        }
                        PlasmaComponents.TextField {
                            Layout.fillWidth: true
                            validator: RegExpValidator { regExp: /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/ }
                            onAccepted: {
                                kiriSettings.homepage = this.text
                                homepagePromptDrawer.close()
                            }
                        }
        }
        function prompt() {
            homepagePromptDrawer.open()
        }
    }

    WebEngineView {
        id: webview
        url: kiriSettings.homepage
        anchors.fill: parent
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if (schemaRE.test(request.url)) {
                request.action = WebEngineView.AcceptRequest;
            } else {
                request.action = WebEngineView.IgnoreRequest;
                // delegate request.url here
            }
        }
        onLoadingChanged: {
            omnbox.text = this.url
            omnbox.select(0,0)
        }
    }

    Rectangle {
        height: 4
        width: (webview.loadProgress / 100) * root.width
        visible: webview.loading
        color: Kirigami.Theme.hoverColor
        Behavior on width {
            NumberAnimation {
                duration:       250
                easing.type:    Easing.InOutQuad
            }
        }
    }
}
