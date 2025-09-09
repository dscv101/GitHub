import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls

Row {
  id: systemTray
  
  spacing: 2
  
  // Create tray items for each system tray icon
  Repeater {
    model: SystemTray.items
    
    delegate: Rectangle {
      id: trayItem
      
      required property SystemTrayItem modelData
      
      width: 24
      height: 24
      color: "transparent"
      radius: 4
      
      // Hover effect
      Rectangle {
        anchors.fill: parent
        color: "#45475a"
        radius: 4
        opacity: parent.hovered ? 0.3 : 0
        
        Behavior on opacity {
          NumberAnimation { duration: 150 }
        }
      }
      
      property bool hovered: false
      
      // System tray icon
      Image {
        id: trayIcon
        anchors.centerIn: parent
        width: 16
        height: 16
        source: modelData.icon
        smooth: true
        
        // Fallback for missing icons
        Rectangle {
          anchors.fill: parent
          color: "#cdd6f4"
          radius: 2
          visible: trayIcon.status === Image.Error
          
          Text {
            anchors.centerIn: parent
            text: "?"
            color: "#1e1e2e"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.bold: true
          }
        }
      }
      
      // Mouse interaction
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        
        onEntered: trayItem.hovered = true
        onExited: trayItem.hovered = false
        
        onClicked: function(mouse) {
          if (mouse.button === Qt.LeftButton) {
            // Primary activation (left click)
            modelData.activate()
          } else if (mouse.button === Qt.RightButton) {
            // Secondary activation or context menu (right click)
            if (modelData.hasMenu) {
              // Display context menu at cursor position
              modelData.display(trayItem, mouse.x, mouse.y)
            } else {
              modelData.secondaryActivate()
            }
          } else if (mouse.button === Qt.MiddleButton) {
            // Middle click
            modelData.secondaryActivate()
          }
        }
        
        onWheel: function(wheel) {
          // Handle scroll wheel for volume controls, etc.
          let delta = wheel.angleDelta.y / 120 // Standard wheel delta
          modelData.scroll(delta, false) // vertical scroll
        }
      }
      
      // Tooltip (using the built-in tooltip system)
      ToolTip {
        id: tooltip
        visible: trayItem.hovered && (modelData.tooltipTitle || modelData.tooltipDescription)
        text: {
          let title = modelData.tooltipTitle || ""
          let desc = modelData.tooltipDescription || ""
          if (title && desc) {
            return title + "\n" + desc
          } else if (title) {
            return title
          } else if (desc) {
            return desc
          } else {
            return modelData.title || modelData.id || "System Tray Item"
          }
        }
        delay: 500
        timeout: 5000
        
        background: Rectangle {
          color: "#313244"
          border.color: "#45475a"
          border.width: 1
          radius: 6
        }
        
        contentItem: Text {
          text: tooltip.text
          color: "#cdd6f4"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 11
          wrapMode: Text.WordWrap
        }
      }
    }
  }
  
  // Show a placeholder when no tray items are available
  Rectangle {
    width: 60
    height: 24
    color: "#313244"
    radius: 8
    visible: SystemTray.items.length === 0
    
    Text {
      anchors.centerIn: parent
      text: "No Tray"
      color: "#6c7086"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 9
    }
  }
}
