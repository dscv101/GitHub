{ ... }:
{
  xdg.configFile."niri/config.kdl".text = ''
    layout {
      gaps 8
      border 2
    }

    input { focus-follows-mouse false }

    monitor "DP-1" {
      scale 1.0
      mode 1920x1080@60.00Hz
      transform normal
      vrr off
      primary true
    }

    # Startup apps
    spawn "ghostty"
    spawn "code"

    binds {
      # launchers
      "SUPER+ENTER" => spawn "ghostty"
      "SUPER+Space" => spawn "fuzzel"
      "SUPER+E"     => spawn "code"

      # focus
      "SUPER+H"     => focus left
      "SUPER+J"     => focus down
      "SUPER+K"     => focus up
      "SUPER+L"     => focus right
      "SUPER+TAB"   => focus next
      "SUPER+SHIFT+TAB" => focus previous

      # move/resize
      "SUPER+SHIFT+H" => move left
      "SUPER+SHIFT+J" => move down
      "SUPER+SHIFT+K" => move up
      "SUPER+SHIFT+L" => move right
      "SUPER+CTRL+H"  => resize decrease-width
      "SUPER+CTRL+L"  => resize increase-width
      "SUPER+CTRL+J"  => resize increase-height
      "SUPER+CTRL+K"  => resize decrease-height

      # layout
      "SUPER+F"     => fullscreen
      "SUPER+SHIFT+Space" => toggle-floating
      "SUPER+Q"     => close-window

      # workspaces 1..9
      "SUPER+1" => switch-workspace 1
      "SUPER+2" => switch-workspace 2
      "SUPER+3" => switch-workspace 3
      "SUPER+4" => switch-workspace 4
      "SUPER+5" => switch-workspace 5
      "SUPER+6" => switch-workspace 6
      "SUPER+7" => switch-workspace 7
      "SUPER+8" => switch-workspace 8
      "SUPER+9" => switch-workspace 9

      "SUPER+SHIFT+1" => move-to-workspace 1
      "SUPER+SHIFT+2" => move-to-workspace 2
      "SUPER+SHIFT+3" => move-to-workspace 3
      "SUPER+SHIFT+4" => move-to-workspace 4
      "SUPER+SHIFT+5" => move-to-workspace 5
      "SUPER+SHIFT+6" => move-to-workspace 6
      "SUPER+SHIFT+7" => move-to-workspace 7
      "SUPER+SHIFT+8" => move-to-workspace 8
      "SUPER+SHIFT+9" => move-to-workspace 9

      # screenshots / clipboard
      "PRINT"       => spawn "grimshot save active ~/Pictures/Screenshots"
      "SHIFT+PRINT" => spawn "grimshot save area ~/Pictures/Screenshots"
      "CTRL+PRINT"  => spawn "grimshot copy area"
    }
  '';
}
