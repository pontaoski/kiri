import QtQuick 2.9
import QtQuick.Controls 1.0
import QtQuick.Window 2.2
import QtWebEngine 1.8
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Kirigami.ApplicationWindow {
    id: root

    title: webview.title
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
                iconSource: webview.loading ? "process-stop-symbolic" : "view-refresh"
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
                iconSource: webview.icon == "" ? "tool_pagelayout" : ""
                Image {
                    visible: webview.icon != ""
                    anchors.fill: parent
                    source: webview.icon != "" ? webview.icon : "tool_pagelayout"
                }
            }

            PlasmaComponents.TextField {
                text: "http://qt-project.org"
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                onAccepted: {
                    webview.url = this.text
                }
            }
            PlasmaComponents.ToolButton {
                id: menuBtn
                iconSource: "application-menu"
                onClicked: {
                    menu.visualParent = menuBtn
                    menu.open()
                }

                PlasmaComponents.ContextMenu {
                    id: menu
                    PlasmaComponents.MenuItem {
                        text: "Hopes and Dreams"
                    }
                }
            }
        }
    }
    WebEngineView {
        id: webview
        url: "http://qt-project.org"
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
    }
    Rectangle {
        height: 2
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
