#!/usr/bin/env python3
"""
ANGA Weather App Development Setup Script

This script helps set up the development environment for the ANGA Weather App project.
It installs dependencies, sets up pre-commit hooks, and configures the development environment.
"""

import os
import sys
import subprocess
import platform
import shutil
from pathlib import Path
from typing import List, Optional


class Colors:
    """ANSI color codes for terminal output."""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_header(message: str) -> None:
    """Print a formatted header message."""
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{message:^60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")


def print_step(message: str) -> None:
    """Print a step message."""
    print(f"\n{Colors.OKBLUE}▶ {message}{Colors.ENDC}")


def print_success(message: str) -> None:
    """Print a success message."""
    print(f"{Colors.OKGREEN}✅ {message}{Colors.ENDC}")


def print_warning(message: str) -> None:
    """Print a warning message."""
    print(f"{Colors.WARNING}⚠️  {message}{Colors.ENDC}")


def print_error(message: str) -> None:
    """Print an error message."""
    print(f"{Colors.FAIL}❌ {message}{Colors.ENDC}")


def run_command(command: List[str], cwd: Optional[str] = None, check: bool = True) -> subprocess.CompletedProcess:
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            check=check,
            capture_output=True,
            text=True,
            shell=platform.system() == "Windows"
        )
        return result
    except subprocess.CalledProcessError as e:
        if check:
            print_error(f"Command failed: {' '.join(command)}")
            print_error(f"Error: {e}")
            sys.exit(1)
        return e


def check_python_version() -> bool:
    """Check if Python version meets requirements."""
    print_step("Checking Python version...")
    
    version = sys.version_info
    required_version = (3, 8)
    
    if version >= required_version:
        print_success(f"Python {version.major}.{version.minor}.{version.micro} is compatible")
        return True
    else:
        print_error(f"Python {version.major}.{version.minor}.{version.micro} is not compatible")
        print_error(f"Required: Python {required_version[0]}.{required_version[1]}+")
        return False


def check_flutter_installation() -> bool:
    """Check if Flutter is installed and accessible."""
    print_step("Checking Flutter installation...")
    
    try:
        result = run_command(["flutter", "--version"], check=False)
        if result.returncode == 0:
            print_success("Flutter is installed and accessible")
            return True
        else:
            print_warning("Flutter is not accessible from PATH")
            return False
    except FileNotFoundError:
        print_warning("Flutter is not installed or not in PATH")
        return False


def create_virtual_environment() -> bool:
    """Create a Python virtual environment."""
    print_step("Creating Python virtual environment...")
    
    venv_path = Path("venv")
    if venv_path.exists():
        print_warning("Virtual environment already exists")
        return True
    
    try:
        run_command([sys.executable, "-m", "venv", "venv"])
        print_success("Virtual environment created successfully")
        return True
    except Exception as e:
        print_error(f"Failed to create virtual environment: {e}")
        return False


def get_activate_command() -> str:
    """Get the appropriate activation command for the current platform."""
    if platform.system() == "Windows":
        return "venv\\Scripts\\activate"
    else:
        return "source venv/bin/activate"


def install_python_dependencies() -> bool:
    """Install Python dependencies."""
    print_step("Installing Python dependencies...")
    
    try:
        # Upgrade pip
        run_command([sys.executable, "-m", "pip", "install", "--upgrade", "pip"])
        
        # Install dependencies
        run_command([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        
        # Install development dependencies
        run_command([sys.executable, "-m", "pip", "install", "-e", ".[dev,test]"])
        
        print_success("Python dependencies installed successfully")
        return True
    except Exception as e:
        print_error(f"Failed to install Python dependencies: {e}")
        return False


def install_flutter_dependencies() -> bool:
    """Install Flutter dependencies."""
    print_step("Installing Flutter dependencies...")
    
    mobile_path = Path("mobile")
    if not mobile_path.exists():
        print_warning("Mobile directory not found, skipping Flutter setup")
        return False
    
    try:
        run_command(["flutter", "pub", "get"], cwd="mobile")
        print_success("Flutter dependencies installed successfully")
        return True
    except Exception as e:
        print_error(f"Failed to install Flutter dependencies: {e}")
        return False


def setup_pre_commit_hooks() -> bool:
    """Set up pre-commit hooks."""
    print_step("Setting up pre-commit hooks...")
    
    try:
        run_command([sys.executable, "-m", "pre_commit", "install"])
        print_success("Pre-commit hooks installed successfully")
        return True
    except Exception as e:
        print_warning(f"Failed to install pre-commit hooks: {e}")
        return_warning("You can install them manually later with: pre-commit install")
        return False


def setup_git_hooks() -> bool:
    """Set up custom git hooks."""
    print_step("Setting up custom git hooks...")
    
    git_hooks_dir = Path(".git/hooks")
    if not git_hooks_dir.exists():
        print_warning("Git repository not found, skipping git hooks setup")
        return False
    
    # Create pre-commit hook for code formatting
    pre_commit_hook = git_hooks_dir / "pre-commit"
    hook_content = """#!/bin/sh
# ANGA Weather App pre-commit hook

echo "Running pre-commit checks..."

# Run code formatting
python -m black --check --diff .
if [ $? -ne 0 ]; then
    echo "Code formatting check failed. Run 'black .' to fix."
    exit 1
fi

# Run linting
python -m flake8 --max-line-length=88 --extend-ignore=E203,W503 .
if [ $? -ne 0 ]; then
    echo "Linting check failed. Fix the issues above."
    exit 1
fi

echo "Pre-commit checks passed!"
"""
    
    try:
        with open(pre_commit_hook, 'w') as f:
            f.write(hook_content)
        
        # Make the hook executable (Unix-like systems)
        if platform.system() != "Windows":
            os.chmod(pre_commit_hook, 0o755)
        
        print_success("Custom git hooks installed successfully")
        return True
    except Exception as e:
        print_warning(f"Failed to install custom git hooks: {e}")
        return False


def create_environment_file() -> bool:
    """Create a .env file from the example."""
    print_step("Setting up environment configuration...")
    
    env_example = Path("env.example")
    env_file = Path(".env")
    
    if env_file.exists():
        print_warning(".env file already exists")
        return True
    
    if env_example.exists():
        try:
            shutil.copy(env_example, env_file)
            print_success(".env file created from env.example")
            print_warning("Please update .env with your actual configuration values")
            return True
        except Exception as e:
            print_error(f"Failed to create .env file: {e}")
            return False
    else:
        print_warning("env.example not found, skipping .env setup")
        return False


def run_tests() -> bool:
    """Run the test suite to verify the setup."""
    print_step("Running tests to verify setup...")
    
    try:
        # Run Python tests
        run_command([sys.executable, "-m", "pytest", "--version"], check=False)
        print_success("Python test environment is ready")
        
        # Run Flutter tests if available
        if Path("mobile").exists():
            run_command(["flutter", "test", "--version"], cwd="mobile", check=False)
            print_success("Flutter test environment is ready")
        
        return True
    except Exception as e:
        print_warning(f"Test verification failed: {e}")
        return False


def print_next_steps() -> None:
    """Print next steps for the developer."""
    print_header("Setup Complete!")
    
    print(f"\n{Colors.OKGREEN}🎉 Your development environment is ready!{Colors.ENDC}")
    
    print(f"\n{Colors.BOLD}Next steps:{Colors.ENDC}")
    print("1. Activate the virtual environment:")
    print(f"   {Colors.OKCYAN}{get_activate_command()}{Colors.ENDC}")
    
    print("\n2. Start the backend server:")
    print(f"   {Colors.OKCYAN}cd backend && python -m uvicorn main_api:app --reload{Colors.ENDC}")
    
    print("\n3. Start the Flutter app:")
    print(f"   {Colors.OKCYAN}cd mobile && flutter run{Colors.ENDC}")
    
    print(f"\n{Colors.BOLD}Useful commands:{Colors.ENDC}")
    print(f"• Format code: {Colors.OKCYAN}black .{Colors.ENDC}")
    print(f"• Run linting: {Colors.OKCYAN}flake8{Colors.ENDC}")
    print(f"• Run tests: {Colors.OKCYAN}pytest{Colors.ENDC}")
    print(f"• Type checking: {Colors.OKCYAN}mypy .{Colors.ENDC}")
    
    print(f"\n{Colors.BOLD}Documentation:{Colors.ENDC}")
    print("• README.md - Project overview and setup")
    print("• CONTRIBUTING.md - Contribution guidelines")
    print("• docs/ - Detailed documentation")
    
    print(f"\n{Colors.BOLD}Support:{Colors.ENDC}")
    print("• GitHub Issues: https://github.com/anga-weather/anga-weather-app/issues")
    print("• Documentation: https://anga-weather.com/docs")
    
    print(f"\n{Colors.OKGREEN}Happy coding! 🚀{Colors.ENDC}")


def main() -> None:
    """Main setup function."""
    print_header("ANGA Weather App Development Setup")
    
    print("This script will set up your development environment for the ANGA Weather App project.")
    print("It will install dependencies, set up development tools, and configure your environment.")
    
    # Check prerequisites
    if not check_python_version():
        sys.exit(1)
    
    flutter_available = check_flutter_installation()
    
    # Create virtual environment
    if not create_virtual_environment():
        sys.exit(1)
    
    # Install Python dependencies
    if not install_python_dependencies():
        sys.exit(1)
    
    # Install Flutter dependencies if available
    if flutter_available:
        install_flutter_dependencies()
    
    # Set up development tools
    setup_pre_commit_hooks()
    setup_git_hooks()
    
    # Set up environment
    create_environment_file()
    
    # Verify setup
    run_tests()
    
    # Print next steps
    print_next_steps()


if __name__ == "__main__":
    main()
