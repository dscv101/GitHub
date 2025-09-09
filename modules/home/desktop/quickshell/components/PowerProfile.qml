import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
  id: powerProfile
  
  property string currentProfile: ""
  property string profileIcon: ""
  property var availableProfiles: []
  property bool isSupported: false
  
  width: 100
  height: parent.height
  color: "#313244"
  radius: 8
  
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    
    onClicked: function(mouse) {
      if (mouse.button === Qt.LeftButton) {
        // Cycle through power profiles
        cycleProfile()
      } else if (mouse.button === Qt.RightButton) {
        // Open power settings (if available)
        Process {
          command: ["gnome-control-center", "power"]
          running: true
        }
      }
    }
  }
  
  Row {
    anchors.centerIn: parent
    spacing: 4
    
    Text {
      text: powerProfile.profileIcon
      color: getProfileColor()
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      anchors.verticalCenter: parent.verticalCenter
    }
    
    Text {
      text: powerProfile.currentProfile
      color: getProfileColor()
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      anchors.verticalCenter: parent.verticalCenter
    }
  }
  
  function getProfileColor() {
    switch (powerProfile.currentProfile) {
      case "performance":
        return "#f38ba8"  // Red for performance
      case "balanced":
        return "#f9e2af"  // Yellow for balanced
      case "power-saver":
        return "#a6e3a1"  // Green for power-saver
      default:
        return "#cdd6f4"  // Default text color
    }
  }
  
  function getProfileIcon(profile) {
    switch (profile) {
      case "performance":
        return "⚡"  // Lightning bolt for performance
      case "balanced":
        return "⚖"   // Balance scale for balanced
      case "power-saver":
        return "🔋"  // Battery for power-saver
      default:
        return "⚙"   // Gear for unknown/default
    }
  }
  
  function cycleProfile() {
    if (!powerProfile.isSupported || powerProfile.availableProfiles.length === 0) {
      return
    }
    
    let currentIndex = powerProfile.availableProfiles.indexOf(powerProfile.currentProfile)
    let nextIndex = (currentIndex + 1) % powerProfile.availableProfiles.length
    let nextProfile = powerProfile.availableProfiles[nextIndex]
    
    // Set the new power profile
    Process {
      command: ["powerprofilesctl", "set", nextProfile]
      running: true
      
      onFinished: {
        // Refresh profile status after setting
        profileTimer.restart()
      }
    }
  }
  
  // Check if power-profiles-daemon is available and get current profile
  Process {
    id: profileCheckProcess
    command: ["sh", "-c", "command -v powerprofilesctl >/dev/null 2>&1 && echo 'supported' || echo 'unsupported'"]
    running: true
    
    stdout: StdioCollector {
      onStreamFinished: {
        let result = text.trim()
        powerProfile.isSupported = (result === "supported")
        
        if (powerProfile.isSupported) {
          // Get available profiles
          Process {
            id: availableProfilesProcess
            command: ["powerprofilesctl", "list"]
            running: true
            
            stdout: StdioCollector {
              onStreamFinished: {
                // Parse available profiles from output
                let lines = text.trim().split('\n')
                let profiles = []
                
                for (let i = 0; i < lines.length; i++) {
                  let line = lines[i].trim()
                  if (line.includes('*')) {
                    // Current active profile (marked with *)
                    let profileName = line.replace('*', '').trim().replace(':', '')
                    powerProfile.currentProfile = profileName
                    powerProfile.profileIcon = getProfileIcon(profileName)
                    profiles.push(profileName)
                  } else if (line.includes(':')) {
                    // Available profile
                    let profileName = line.replace(':', '').trim()
                    if (profileName && !profiles.includes(profileName)) {
                      profiles.push(profileName)
                    }
                  }
                }
                
                powerProfile.availableProfiles = profiles
                
                // If we couldn't determine current profile, get it explicitly
                if (!powerProfile.currentProfile) {
                  getCurrentProfile()
                }
              }
            }
          }
        } else {
          // Fallback: try to detect other power management systems
          checkAlternativePowerManagement()
        }
      }
    }
  }
  
  function getCurrentProfile() {
    Process {
      id: currentProfileProcess
      command: ["powerprofilesctl", "get"]
      running: true
      
      stdout: StdioCollector {
        onStreamFinished: {
          let profile = text.trim()
          powerProfile.currentProfile = profile
          powerProfile.profileIcon = getProfileIcon(profile)
        }
      }
    }
  }
  
  function checkAlternativePowerManagement() {
    // Check for TLP (ThinkPad Power Management)
    Process {
      id: tlpCheckProcess
      command: ["sh", "-c", "command -v tlp-stat >/dev/null 2>&1 && echo 'tlp' || echo 'none'"]
      running: true
      
      stdout: StdioCollector {
        onStreamFinished: {
          let result = text.trim()
          if (result === "tlp") {
            // TLP is available, show TLP status
            powerProfile.isSupported = true
            powerProfile.currentProfile = "TLP"
            powerProfile.profileIcon = "⚙"
            powerProfile.availableProfiles = ["TLP"]
          } else {
            // No power management detected
            powerProfile.isSupported = false
            powerProfile.currentProfile = "N/A"
            powerProfile.profileIcon = "❌"
            powerProfile.availableProfiles = []
          }
        }
      }
    }
  }
  
  // Timer to periodically update power profile status
  Timer {
    id: profileTimer
    interval: 30000  // Update every 30 seconds
    running: powerProfile.isSupported
    repeat: true
    onTriggered: {
      if (powerProfile.isSupported) {
        getCurrentProfile()
      }
    }
  }
  
  // Tooltip/status information (for debugging)
  property string statusInfo: {
    if (!powerProfile.isSupported) {
      return "Power profiles not supported"
    } else {
      return "Current: " + powerProfile.currentProfile + 
             " | Available: " + powerProfile.availableProfiles.join(", ")
    }
  }
}
