import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import qs.Common
import qs.Widgets

Popup {
    id: root
    modal: true
    focus: true
    width: 420
    height: 480
    anchors.centerIn: parent
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside


    // Kill the default Material dim/shadow behind the popup
    Overlay.modal: Item {}
    Overlay.modeless: Item {}

    // Force Material to not inject its own accent/shadow styling
    Material.theme: Material.Dark
    Material.background: Theme.surfaceContainer
    Material.accent: Theme.primary

    property var aiService: null

    // Local editable copy of the notes, split into lines
    property var lines: []

    function loadLines() {
        const raw = aiService ? (aiService.notesList || "") : "";
        lines = raw.length > 0 ? raw.split("\n").filter(l => l.trim().length > 0) : [];
    }

    function commitLines() {
        if (!aiService) return;
        aiService.updateNotes(lines.join("\n"));
    }

    onOpened: loadLines()

    background: Rectangle {
        color: Theme.surfaceContainer
        radius: Theme.cornerRadius
        border.color: Theme.outlineMedium
        border.width: 3
        layer.enabled: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        StyledText {
            text: I18n.tr("Notes about you")
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Medium
            Layout.fillWidth: true
        }

        ListView {
            id: notesListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.spacingXS
            model: root.lines

            signal removeRequested(int idx)

            delegate: RowLayout {
                width: notesListView.width
                spacing: Theme.spacingXS

                StyledText {
                    text: "- "+modelData
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    font.pixelSize: Theme.fontSizeMedium
                    leftPadding: Theme.spacingS
                }

                DankActionButton {
                    iconName: "close"
                    buttonSize: 22
                    iconSize: 14
                    backgroundColor: "transparent"
                    // onClicked: {
                    //     console.log("[NotesDialog] delete clicked, index=", index, "lines=", JSON.stringify(root.lines))
                    //     const copy = root.lines.slice();
                    //     copy.splice(index, 1);
                    //     root.lines = copy;
                    //     root.commitLines();
                    // }
                    onClicked: notesListView.removeRequested(index)
                }
            }
            onRemoveRequested: idx => {
                const copy = root.lines.slice();
                copy.splice(idx, 1);
                root.lines = copy;
                root.commitLines();
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXS

            TextField {
                id: newNoteInput
                Layout.fillWidth: true
                // Layout.topMargin: Theme.spacingS   // breathing room above the input, separate from the list
                placeholderText: I18n.tr("Add a note…")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                placeholderTextColor: Theme.surfaceVariantText

                // leftPadding: Theme.spacingS
                // rightPadding: Theme.spacingS
                // topPadding: Theme.spacingXS
                // bottomPadding: Theme.spacingXS

                background: Rectangle {
                    color: Theme.surfaceContainerHigh
                    radius: Theme.cornerRadius
                    border.color: newNoteInput.activeFocus ? Theme.outlineMedium : Theme.outlineMedium
                    border.width: 1
                }
                onAccepted: addButton.clicked()
            }

            DankActionButton {
                id: addButton
                iconName: "add"
                buttonSize: 28
                iconSize: 16
                onClicked: {
                    const text = newNoteInput.text.trim();
                    if (!text) return;
                    const copy = root.lines.slice();
                    copy.push(text);
                    root.lines = copy;
                    root.commitLines();
                    newNoteInput.text = "";
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight

            DankActionButton {
                iconName: "check"
                buttonSize: 28
                iconSize: 16
                onClicked: root.close()
            }
        }
    }
}