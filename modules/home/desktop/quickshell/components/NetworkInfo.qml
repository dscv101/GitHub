import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
  id: networkInfo
  
  property string networkStatus: ""
  property string networkIcon: ""
  property bool isConnected: false
  
  width: 120
  height: parent.height
  color: "#313244"
  radius: 8
  
  MouseArea {
    anchors.fill: parent
    onClicked: {
      Process {
        command: ["nm-connection-editor"]
        running: true
      }
    }
  }
  
  Row {
    anchors.centerIn: parent
    spacing: 4
    
    Text {
      text: networkInfo.networkIcon
      color: networkInfo.isConnected ? "#94e2d5" : "#f38ba8"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      anchors.verticalCenter: parent.verticalCenter
    }
    
    Text {
      text: networkInfo.networkStatus
      color: networkInfo.isConnected ? "#94e2d5" : "#f38ba8"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      anchors.verticalCenter: parent.verticalCenter
    }
  }
  
  // Network monitoring
  Process {
    id: networkProcess
    command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' | head -1 | cut -d: -f2,3 || echo 'disconnected'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let result = text.trim()
        if (result === "disconnected" || result === "") {
          // Check for ethernet
          Process {
            id: ethProcess
            command: ["sh", "-c", "nmcli -t -f DEVICE,STATE dev | grep ethernet | grep connected | head -1 | cut -d: -f1"]
            running: true
            
            stdout: StdioCollector {
              onStreamFinished: {
                let ethResult = text.trim()
                if (ethResult !== "") {
                  networkInfo.isConnected = true
                  networkInfo.networkIcon = "󰊗"
                  networkInfo.networkStatus = "Ethernet"
                } else {
                  networkInfo.isConnected = false
                  networkInfo.networkIcon = "⚠"
                  networkInfo.networkStatus = "Disconnected"
                }
              }
            }
          }
        } else {
          // WiFi connected
          let parts = result.split(':')
          if (parts.length >= 2) {
            let ssid = parts[0]
            let signal = parts[1]
            networkInfo.isConnected = true
            networkInfo.networkIcon = ""
            networkInfo.networkStatus = ssid + " (" + signal + "%)"
          } else {
            networkInfo.isConnected = true
            networkInfo.networkIcon = ""
            networkInfo.networkStatus = result
          }
        }
      }
    }
  }
  
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: networkProcess.running = true
  }
}
