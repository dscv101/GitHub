{ pkgs, ... }:
{
  devShells.default = pkgs.mkShell {
    buildInputs = with pkgs; [
      # Version control
      git
      jujutsu
      
      # Development environment
      direnv
      devenv
      
      # Nix tooling
      alejandra
      statix
      deadnix
      nixfmt-rfc-style
      
      # Additional useful tools
      just
      sops
      age
    ];
    
    shellHook = ''
      echo "🚀 Development shell ready!"
      echo ""
      echo "Available commands:"
      echo "  nix fmt          - Format Nix files (alejandra)"
      echo "  statix check     - Check for Nix anti-patterns"
      echo "  deadnix          - Find dead Nix code"
      echo "  nix flake check  - Validate flake"
      echo "  just --list      - Show available just recipes"
      echo ""
    '';
  };
  
  formatter = pkgs.alejandra;
}
