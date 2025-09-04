_: {
  # Tailscale (+ SSH)
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = ["--ssh" "--accept-routes" "--advertise-tags=tag:nix-dev"];
  };
}
