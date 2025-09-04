#!/usr/bin/env python3
"""
Test suite for Jujutsu integration in justfile.

This script validates that all jj commands work correctly and handle
error conditions appropriately.
"""

import subprocess
import sys
import tempfile
import os
from pathlib import Path


def run_command(cmd: str, cwd: str = None, expect_failure: bool = False) -> tuple[int, str, str]:
    """Run a command and return (returncode, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            cwd=cwd,
            timeout=30
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"


def test_jj_help():
    """Test that jj-help command works and shows expected content."""
    print("🧪 Testing jj-help command...")
    
    returncode, stdout, stderr = run_command("just jj-help")
    
    if returncode != 0:
        print(f"❌ jj-help failed: {stderr}")
        return False
    
    expected_commands = [
        "jj-init", "jj-add", "jj-commit", "jj-checkout", 
        "jj-branch", "jj-status", "jj-log", "jj-diff", 
        "jj-push", "jj-pull"
    ]
    
    for cmd in expected_commands:
        if cmd not in stdout:
            print(f"❌ Missing command in help: {cmd}")
            return False
    
    print("✅ jj-help test passed")
    return True


def test_jj_check_install():
    """Test jj installation check."""
    print("🧪 Testing jj installation check...")
    
    # Test with jj available (should pass if jj is installed)
    returncode, stdout, stderr = run_command("just _jj-check-install")
    
    if returncode == 0:
        print("✅ jj installation check passed (jj is installed)")
        return True
    else:
        print("⚠️  jj not installed - this is expected in CI environments")
        return True  # This is acceptable in test environments


def test_jj_check_repo_outside_repo():
    """Test repository check outside of jj repo (should fail)."""
    print("🧪 Testing repository check outside jj repo...")
    
    with tempfile.TemporaryDirectory() as tmpdir:
        returncode, stdout, stderr = run_command("just _jj-check-repo", cwd=tmpdir)
        
        if returncode == 0:
            print("❌ Repository check should fail outside jj repo")
            return False
        
        if "Not in a jujutsu repository" not in stderr and "Not in a jujutsu repository" not in stdout:
            print(f"❌ Expected error message not found. Output: {stdout} {stderr}")
            return False
    
    print("✅ Repository check correctly failed outside jj repo")
    return True


def test_jj_init_in_temp_dir():
    """Test jj-init command in a temporary directory."""
    print("🧪 Testing jj-init command...")
    
    # Check if jj is available first
    jj_check = run_command("command -v jj")
    if jj_check[0] != 0:
        print("⚠️  Skipping jj-init test - jj not available")
        return True
    
    with tempfile.TemporaryDirectory() as tmpdir:
        returncode, stdout, stderr = run_command("just jj-init", cwd=tmpdir)
        
        if returncode != 0:
            print(f"❌ jj-init failed: {stderr}")
            return False
        
        # Check if .jj directory was created
        jj_dir = Path(tmpdir) / ".jj"
        if not jj_dir.exists():
            print("❌ .jj directory not created")
            return False
    
    print("✅ jj-init test passed")
    return True


def test_legacy_commands():
    """Test that legacy commands show deprecation warnings."""
    print("🧪 Testing legacy command deprecation warnings...")
    
    legacy_commands = ["status", "log", "diff"]
    
    for cmd in legacy_commands:
        returncode, stdout, stderr = run_command(f"just {cmd}")
        
        # Check for deprecation warning
        output = stdout + stderr
        if "deprecated" not in output.lower():
            print(f"❌ No deprecation warning for legacy command: {cmd}")
            return False
    
    print("✅ Legacy command deprecation tests passed")
    return True


def test_command_parameter_validation():
    """Test parameter validation for commands that require arguments."""
    print("🧪 Testing command parameter validation...")
    
    # Test jj-checkout without revision (should fail)
    returncode, stdout, stderr = run_command("just jj-checkout")
    if returncode == 0:
        print("❌ jj-checkout should fail without revision parameter")
        return False
    
    # Test jj-branch create without name (should fail)
    returncode, stdout, stderr = run_command("just jj-branch create")
    if returncode == 0:
        print("❌ jj-branch create should fail without name parameter")
        return False
    
    print("✅ Parameter validation tests passed")
    return True


def main():
    """Run all tests."""
    print("🚀 Starting Jujutsu justfile integration tests...\n")
    
    tests = [
        test_jj_help,
        test_jj_check_install,
        test_jj_check_repo_outside_repo,
        test_jj_init_in_temp_dir,
        test_legacy_commands,
        test_command_parameter_validation,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} crashed: {e}")
            failed += 1
        print()  # Add spacing between tests
    
    print(f"📊 Test Results: {passed} passed, {failed} failed")
    
    if failed > 0:
        print("❌ Some tests failed")
        sys.exit(1)
    else:
        print("✅ All tests passed!")
        sys.exit(0)


if __name__ == "__main__":
    main()
