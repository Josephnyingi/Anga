#!/usr/bin/env python3
"""
🚀 GitHub Secrets Setup Script for ANGA Project

This script helps you set up GitHub Secrets for your ANGA project.
It generates secrets and provides instructions for adding them to GitHub.

Usage:
    python scripts/setup_github_secrets.py
"""

import os
import sys
import subprocess
import webbrowser
from pathlib import Path


def print_banner():
    """Print the setup banner."""
    print("🚀 ANGA Project - GitHub Secrets Setup")
    print("=" * 50)
    print()


def check_github_cli():
    """Check if GitHub CLI is installed."""
    try:
        subprocess.run(["gh", "--version"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def generate_secrets():
    """Generate secrets using the secret generator script."""
    print("🔐 Generating secrets...")
    try:
        result = subprocess.run([
            sys.executable, "scripts/generate_secrets.py"
        ], capture_output=True, text=True, check=True)
        
        print(result.stdout)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating secrets: {e}")
        return None


def open_github_secrets_page():
    """Open GitHub Secrets page in browser."""
    print("🌐 Opening GitHub Secrets page...")
    repo_url = "https://github.com/Josephnyingi/Anga/settings/secrets/actions"
    webbrowser.open(repo_url)
    print(f"📖 GitHub Secrets page: {repo_url}")


def print_manual_setup_instructions():
    """Print manual setup instructions."""
    print("📝 MANUAL SETUP INSTRUCTIONS")
    print("-" * 30)
    print()
    print("1. 🌐 Go to your GitHub repository settings:")
    print("   https://github.com/Josephnyingi/Anga/settings/secrets/actions")
    print()
    print("2. 🔑 Click 'New repository secret' for each secret:")
    print()
    print("   Required Secrets:")
    print("   - GROQ_API_KEY")
    print("   - OPENWEATHER_API_KEY")
    print("   - DATABASE_URL")
    print("   - SECRET_KEY")
    print("   - JWT_SECRET_KEY")
    print("   - AWS_ACCESS_KEY_ID")
    print("   - AWS_SECRET_ACCESS_KEY")
    print()
    print("   Optional Secrets:")
    print("   - SENTRY_DSN")
    print("   - MIXPANEL_TOKEN")
    print("   - FIREBASE_SERVER_KEY")
    print("   - SLACK_WEBHOOK_URL")
    print("   - ANDROID_KEYSTORE_PASSWORD")
    print("   - IOS_CERTIFICATE_PASSWORD")
    print()
    print("3. 📋 Copy the generated secrets from above")
    print("4. 💾 Paste them into the corresponding GitHub Secret fields")
    print("5. ✅ Save each secret")
    print()


def setup_environment_files():
    """Set up environment files."""
    print("📁 Setting up environment files...")
    
    # Create .env file from template
    env_template = Path("infrastructure/environments/env.template")
    env_file = Path(".env")
    
    if env_template.exists() and not env_file.exists():
        print("📝 Creating .env file from template...")
        with open(env_template, 'r') as template:
            content = template.read()
        
        with open(env_file, 'w') as env:
            env.write(content)
        
        print("✅ Created .env file")
        print("⚠️  Remember to update the values in .env file")
    else:
        print("ℹ️  .env file already exists or template not found")


def validate_setup():
    """Validate the setup."""
    print("🔍 Validating setup...")
    
    # Check if required files exist
    required_files = [
        "docs/GITHUB_SECRETS_SETUP.md",
        "infrastructure/environments/env.template",
        "scripts/generate_secrets.py",
        ".github/workflows/validate-secrets.yml"
    ]
    
    missing_files = []
    for file_path in required_files:
        if not Path(file_path).exists():
            missing_files.append(file_path)
    
    if missing_files:
        print("❌ Missing required files:")
        for file_path in missing_files:
            print(f"   - {file_path}")
        return False
    else:
        print("✅ All required files are present")
        return True


def main():
    """Main setup function."""
    print_banner()
    
    # Validate setup
    if not validate_setup():
        print("❌ Setup validation failed. Please ensure all files are present.")
        return
    
    # Generate secrets
    secrets_output = generate_secrets()
    if not secrets_output:
        print("❌ Failed to generate secrets")
        return
    
    # Set up environment files
    setup_environment_files()
    
    # Check if GitHub CLI is available
    if check_github_cli():
        print("✅ GitHub CLI is available")
        print("💡 You can use 'gh secret set' to add secrets programmatically")
    else:
        print("⚠️  GitHub CLI not found")
        print("💡 Install GitHub CLI for easier secret management:")
        print("   https://cli.github.com/")
    
    print()
    print("🎯 NEXT STEPS:")
    print("1. Copy the generated secrets above")
    print("2. Add them to GitHub Secrets (see instructions below)")
    print("3. Update your .env file with local development values")
    print("4. Test your CI/CD pipeline")
    print()
    
    # Ask if user wants to open GitHub Secrets page
    try:
        response = input("🌐 Open GitHub Secrets page in browser? (y/n): ").lower().strip()
        if response in ['y', 'yes']:
            open_github_secrets_page()
    except KeyboardInterrupt:
        print("\n👋 Setup interrupted by user")
        return
    
    print_manual_setup_instructions()
    
    print("🎉 Setup complete!")
    print()
    print("📚 Additional Resources:")
    print("- GitHub Secrets Documentation: https://docs.github.com/en/actions/security-guides/encrypted-secrets")
    print("- Environment Variables Guide: docs/GITHUB_SECRETS_SETUP.md")
    print("- CI/CD Pipeline Documentation: docs/CI_CD_PIPELINE.md")


if __name__ == "__main__":
    main()
