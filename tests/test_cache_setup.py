#!/usr/bin/env python3
"""
Test cache setup and configuration for nix-blazar.
Validates that cache configuration is properly set up.
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional


class CacheValidator:
    """Validates cache configuration and functionality."""
    
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.cache_name = "nix-blazar"
        self.errors: List[str] = []
        self.warnings: List[str] = []
    
    def run_command(self, cmd: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a command and return the result."""
        try:
            return subprocess.run(
                cmd,
                capture_output=capture_output,
                text=True,
                cwd=self.project_root,
                check=False
            )
        except Exception as e:
            self.errors.append(f"Failed to run command {' '.join(cmd)}: {e}")
            return subprocess.CompletedProcess(cmd, 1, "", str(e))
    
    def check_flake_config(self) -> bool:
        """Check if flake.nix has proper cache configuration."""
        print("🔍 Checking flake.nix cache configuration...")
        
        flake_path = self.project_root / "flake.nix"
        if not flake_path.exists():
            self.errors.append("flake.nix not found")
            return False
        
        content = flake_path.read_text()
        
        # Check for cache substituters
        if "nix-blazar.cachix.org" not in content:
            self.errors.append("Cache substituter not found in flake.nix")
            return False
        
        # Check for public key placeholder
        if "YOUR_CACHE_PUBLIC_KEY_HERE" in content:
            self.warnings.append("Public key placeholder found - needs to be replaced with actual key")
        
        print("✅ Flake configuration looks good")
        return True
    
    def check_nix_config(self) -> bool:
        """Check if modules/base/nix.nix has proper cache configuration."""
        print("🔍 Checking Nix base configuration...")
        
        nix_config_path = self.project_root / "modules" / "base" / "nix.nix"
        if not nix_config_path.exists():
            self.errors.append("modules/base/nix.nix not found")
            return False
        
        content = nix_config_path.read_text()
        
        # Check for cache substituters
        if "nix-blazar.cachix.org" not in content:
            self.errors.append("Cache substituter not found in nix.nix")
            return False
        
        # Check for public key placeholder
        if "YOUR_CACHE_PUBLIC_KEY_HERE" in content:
            self.warnings.append("Public key placeholder found in nix.nix - needs to be replaced")
        
        print("✅ Nix configuration looks good")
        return True
    
    def check_secrets_config(self) -> bool:
        """Check if sops secrets are configured for cache."""
        print("🔍 Checking secrets configuration...")
        
        secrets_path = self.project_root / "secrets" / "sops" / "default.nix"
        if not secrets_path.exists():
            self.errors.append("secrets/sops/default.nix not found")
            return False
        
        content = secrets_path.read_text()
        
        # Check for cache secrets
        if "CACHIX_AUTH_TOKEN" not in content:
            self.errors.append("CACHIX_AUTH_TOKEN not found in secrets configuration")
            return False
        
        if "CACHIX_SIGNING_KEY" not in content:
            self.errors.append("CACHIX_SIGNING_KEY not found in secrets configuration")
            return False
        
        print("✅ Secrets configuration looks good")
        return True
    
    def check_github_workflow(self) -> bool:
        """Check if GitHub Actions workflow exists for cache management."""
        print("🔍 Checking GitHub Actions workflow...")
        
        workflow_path = self.project_root / ".github" / "workflows" / "cache-management.yml"
        if not workflow_path.exists():
            self.errors.append("cache-management.yml workflow not found")
            return False
        
        content = workflow_path.read_text()
        
        # Check for cache-related steps
        if "cachix" not in content.lower():
            self.errors.append("Cachix steps not found in workflow")
            return False
        
        if "CACHIX_AUTH_TOKEN" not in content:
            self.errors.append("Cache authentication not configured in workflow")
            return False
        
        print("✅ GitHub Actions workflow looks good")
        return True
    
    def check_cache_scripts(self) -> bool:
        """Check if cache management scripts exist and are executable."""
        print("🔍 Checking cache management scripts...")
        
        script_path = self.project_root / "scripts" / "cache-manager.sh"
        if not script_path.exists():
            self.errors.append("cache-manager.sh script not found")
            return False
        
        if not script_path.is_file():
            self.errors.append("cache-manager.sh is not a file")
            return False
        
        # Check if executable
        if not (script_path.stat().st_mode & 0o111):
            self.warnings.append("cache-manager.sh is not executable")
        
        print("✅ Cache management scripts look good")
        return True
    
    def check_justfile_recipes(self) -> bool:
        """Check if justfile has cache management recipes."""
        print("🔍 Checking justfile cache recipes...")
        
        justfile_path = self.project_root / "justfile"
        if not justfile_path.exists():
            self.errors.append("justfile not found")
            return False
        
        content = justfile_path.read_text()
        
        # Check for cache recipes
        cache_recipes = [
            "cache-setup",
            "cache-push-packages",
            "cache-push-devshells",
            "cache-push-system",
            "cache-push-all",
            "cache-status"
        ]
        
        missing_recipes = []
        for recipe in cache_recipes:
            if recipe not in content:
                missing_recipes.append(recipe)
        
        if missing_recipes:
            self.errors.append(f"Missing cache recipes in justfile: {', '.join(missing_recipes)}")
            return False
        
        print("✅ Justfile cache recipes look good")
        return True
    
    def check_dependencies(self) -> bool:
        """Check if required dependencies are available."""
        print("🔍 Checking dependencies...")
        
        dependencies = ["nix", "jq"]
        missing_deps = []
        
        for dep in dependencies:
            result = self.run_command(["which", dep])
            if result.returncode != 0:
                missing_deps.append(dep)
        
        if missing_deps:
            self.warnings.append(f"Missing optional dependencies: {', '.join(missing_deps)}")
        
        # Check if cachix is available (optional for testing)
        result = self.run_command(["which", "cachix"])
        if result.returncode != 0:
            self.warnings.append("Cachix not installed - install with: nix profile install nixpkgs#cachix")
        
        print("✅ Dependencies check complete")
        return True
    
    def validate_all(self) -> bool:
        """Run all validation checks."""
        print("🚀 Starting cache configuration validation...\n")
        
        checks = [
            self.check_flake_config,
            self.check_nix_config,
            self.check_secrets_config,
            self.check_github_workflow,
            self.check_cache_scripts,
            self.check_justfile_recipes,
            self.check_dependencies,
        ]
        
        all_passed = True
        for check in checks:
            try:
                if not check():
                    all_passed = False
            except Exception as e:
                self.errors.append(f"Check failed with exception: {e}")
                all_passed = False
            print()  # Add spacing between checks
        
        return all_passed
    
    def print_summary(self) -> None:
        """Print validation summary."""
        print("=" * 60)
        print("📋 CACHE SETUP VALIDATION SUMMARY")
        print("=" * 60)
        
        if not self.errors and not self.warnings:
            print("✅ All checks passed! Cache setup looks good.")
            print("\n🚀 Next steps:")
            print("1. Replace YOUR_CACHE_PUBLIC_KEY_HERE with your actual cache public key")
            print("2. Add your Cachix credentials to secrets: just edit-secrets")
            print("3. Setup the cache: just cache-setup")
            print("4. Test cache functionality: just cache-push-all")
        else:
            if self.errors:
                print(f"❌ {len(self.errors)} error(s) found:")
                for i, error in enumerate(self.errors, 1):
                    print(f"   {i}. {error}")
                print()
            
            if self.warnings:
                print(f"⚠️  {len(self.warnings)} warning(s):")
                for i, warning in enumerate(self.warnings, 1):
                    print(f"   {i}. {warning}")
                print()
            
            if self.errors:
                print("🔧 Please fix the errors above before proceeding.")
            else:
                print("✅ No critical errors found. Warnings can be addressed as needed.")


def main():
    """Main test function."""
    project_root = Path(__file__).parent.parent
    validator = CacheValidator(project_root)
    
    success = validator.validate_all()
    validator.print_summary()
    
    return 0 if success or not validator.errors else 1


if __name__ == "__main__":
    sys.exit(main())
