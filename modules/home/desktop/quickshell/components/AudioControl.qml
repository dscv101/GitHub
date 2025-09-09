import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
  id: audioControl
  
  property string volumeInfo: ""
  property bool isMuted: false
  
  width: 100
  height: parent.height
  color: "#313244"
  radius: 8
  
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    
    onClicked: function(mouse) {
      if (mouse.button === Qt.LeftButton) {
        // Toggle mute
        Process {
          command: ["pamixer", "-t"]
          running: true
        }
      } else if (mouse.button === Qt.RightButton) {
        // Open pavucontrol
        Process {
          command: ["pavucontrol"]
          running: true
        }
      }
    }
    
    onWheel: function(wheel) {
      if (wheel.angleDelta.y > 0) {
        // Volume up
        Process {
          command: ["pamixer", "-i", "5"]
          running: true
        }
      } else {
        // Volume down
        Process {
          command: ["pamixer", "-d", "5"]
          running: true
        }
      }
      // Trigger volume update
      volumeTimer.restart()
    }
  }
  
  Text {
    anchors.centerIn: parent
    text: audioControl.volumeInfo
    color: audioControl.isMuted ? "#6c7086" : "#cba6f7"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12
  }
  
  // Volume monitoring
  Process {
    id: volumeProcess
    command: ["sh", "-c", "pamixer --get-volume && pamixer --get-mute"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let lines = text.trim().split('\n')
        if (lines.length >= 2) {
          let volume = lines[0]
          let muted = lines[1] === "true"
          
          audioControl.isMuted = muted
          
          if (muted) {
            audioControl.volumeInfo = " "
          } else {
            let vol = parseInt(volume)
            let icon = ""
            if (vol === 0) {
              icon = ""
            } else if (vol < 50) {
              icon = ""
            } else {
              icon = ""
            }
            audioControl.volumeInfo = volume + "% " + icon
          }
        }
      }
    }
  }
  
  Timer {
    id: volumeTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: volumeProcess.running = true
  }
}
