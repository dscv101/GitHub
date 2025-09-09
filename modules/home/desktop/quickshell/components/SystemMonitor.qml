import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
  id: systemMonitor
  
  property string cpuUsage: ""
  property string memoryUsage: ""
  property string diskUsage: ""
  property string temperature: ""
  
  width: 320
  height: parent.height
  color: "transparent"
  
  Row {
    anchors.fill: parent
    spacing: 4
    
    // CPU usage
    Rectangle {
      width: 80
      height: parent.height
      color: "#313244"
      radius: 8
      
      MouseArea {
        anchors.fill: parent
        onClicked: {
          Process {
            command: ["btop"]
            running: true
          }
        }
      }
      
      Text {
        anchors.centerIn: parent
        text: systemMonitor.cpuUsage
        color: "#89b4fa"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
      }
    }
    
    // Memory usage
    Rectangle {
      width: 80
      height: parent.height
      color: "#313244"
      radius: 8
      
      MouseArea {
        anchors.fill: parent
        onClicked: {
          Process {
            command: ["btop"]
            running: true
          }
        }
      }
      
      Text {
        anchors.centerIn: parent
        text: systemMonitor.memoryUsage
        color: "#a6e3a1"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
      }
    }
    
    // Disk usage
    Rectangle {
      width: 80
      height: parent.height
      color: "#313244"
      radius: 8
      
      MouseArea {
        anchors.fill: parent
        onClicked: {
          Process {
            command: ["baobab"]
            running: true
          }
        }
      }
      
      Text {
        anchors.centerIn: parent
        text: systemMonitor.diskUsage
        color: "#f5c2e7"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
      }
    }
    
    // Temperature
    Rectangle {
      width: 80
      height: parent.height
      color: "#313244"
      radius: 8
      
      Text {
        anchors.centerIn: parent
        text: systemMonitor.temperature
        color: "#fab387"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
      }
    }
  }
  
  // System monitoring processes
  
  // CPU usage
  Process {
    id: cpuProcess
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: systemMonitor.cpuUsage = text.trim() + "% "
    }
  }
  
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: cpuProcess.running = true
  }
  
  // Memory usage
  Process {
    id: memoryProcess
    command: ["sh", "-c", "free | grep Mem | awk '{printf \"%.0f\", $3/$2 * 100.0}'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: systemMonitor.memoryUsage = text.trim() + "% "
    }
  }
  
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: memoryProcess.running = true
  }
  
  // Disk usage
  Process {
    id: diskProcess
    command: ["sh", "-c", "df -h / | awk 'NR==2{print $5}'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: systemMonitor.diskUsage = text.trim() + " "
    }
  }
  
  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: diskProcess.running = true
  }
  
  // Temperature
  Process {
    id: tempProcess
    command: ["sh", "-c", "sensors 2>/dev/null | grep 'Core 0' | awk '{print $3}' | cut -d'+' -f2 | cut -d'°' -f1 || echo '0'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let temp = text.trim()
        if (temp && temp !== "0") {
          systemMonitor.temperature = temp + "°C "
        } else {
          systemMonitor.temperature = ""
        }
      }
    }
  }
  
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: tempProcess.running = true
  }
}
