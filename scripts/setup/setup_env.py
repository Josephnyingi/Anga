#!/usr/bin/env python3
"""
🔧 Environment Setup Script for ANGA Weather App
This script helps you set up your .env file and configure environment variables.
"""

import os
import sys
from pathlib import Path
import shutil

def create_env_file():
    """Create .env file from template"""
    project_root = Path(__file__).resolve().parent
    env_template = project_root / "env.example"
    env_file = project_root / ".env"
    
    print("🔧 Setting up environment variables...")
    print("-" * 50)
    
    # Check if .env already exists
    if env_file.exists():
        print("⚠️ .env file already exists!")
        response = input("Do you want to overwrite it? (y/N): ").lower().strip()
        if response != 'y':
            print("❌ Setup cancelled. Keeping existing .env file.")
            return False
    
    # Check if env.example exists
    if not env_template.exists():
        print("❌ env.example file not found!")
        print("Please ensure env.example exists in the project root.")
        return False
    
    try:
        # Copy env.example to .env
        shutil.copy2(env_template, env_file)
        print("✅ .env file created successfully!")
        
        # Read the created file to show what was copied
        with open(env_file, 'r') as f:
            content = f.read()
        
        print("\n📋 Environment variables configured:")
        print("-" * 30)
        
        # Parse and display the variables
        for line in content.split('\n'):
            if line.strip() and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                if 'API_KEY' in key or 'SECRET' in key:
                    # Mask sensitive values
                    masked_value = value[:8] + '*' * (len(value) - 8) if len(value) > 8 else '***'
                    print(f"   {key}={masked_value}")
                else:
                    print(f"   {key}={value}")
        
        print("\n✅ Environment setup complete!")
        print("\n📝 Next steps:")
        print("1. Review the .env file and update any values as needed")
        print("2. Ensure your GROQ_API_KEY is valid")
        print("3. Run the AI assistant test: python backend/ai_assistant_test.py")
        print("4. Start the backend server: uvicorn backend.main_api:app --host 0.0.0.0 --port 8000 --reload")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creating .env file: {e}")
        return False

def validate_env_file():
    """Validate the .env file configuration"""
    project_root = Path(__file__).resolve().parent
    env_file = project_root / ".env"
    
    print("\n🔍 Validating environment configuration...")
    print("-" * 50)
    
    if not env_file.exists():
        print("❌ .env file not found!")
        return False
    
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv(env_file)
    
    # Check required variables
    required_vars = {
        'GROQ_API_KEY': 'AI Assistant API key',
        'API_HOST': 'API host address',
        'API_PORT': 'API port number',
        'DATABASE_URL': 'Database connection URL',
        'SECRET_KEY': 'Application secret key',
    }
    
    missing_vars = []
    valid_vars = []
    
    for var, description in required_vars.items():
        value = os.getenv(var)
        if value:
            if var == 'GROQ_API_KEY':
                # Check if it's not the placeholder
                if value != 'your_groq_api_key_here':
                    valid_vars.append(f"✅ {var}: {description}")
                else:
                    missing_vars.append(f"⚠️ {var}: {description} (still has placeholder value)")
            else:
                valid_vars.append(f"✅ {var}: {description}")
        else:
            missing_vars.append(f"❌ {var}: {description} (missing)")
    
    # Display results
    if valid_vars:
        print("✅ Valid configuration:")
        for var in valid_vars:
            print(f"   {var}")
    
    if missing_vars:
        print("\n⚠️ Issues found:")
        for var in missing_vars:
            print(f"   {var}")
        
        print("\n🔧 To fix these issues:")
        print("1. Edit the .env file manually")
        print("2. Or run this script again to recreate it")
        print("3. Get your GROQ API key from: https://console.groq.com/")
        
        return False
    
    print("\n🎉 All environment variables are properly configured!")
    return True

def test_ai_assistant():
    """Test AI assistant with current environment"""
    print("\n🧪 Testing AI Assistant with current environment...")
    print("-" * 50)
    
    try:
        # Import and test the assistant
        sys.path.append(str(Path(__file__).resolve().parent / "models" / "AI-Farming-Assistant-App"))
        from assistant_core import test_connectivity
        
        result = test_connectivity()
        
        print(f"Status: {result['status']}")
        print(f"Message: {result['message']}")
        print(f"API Key Configured: {result['api_key_configured']}")
        print(f"Client Initialized: {result['client_initialized']}")
        
        if result['status'] == 'working':
            print("✅ AI Assistant is working correctly!")
            return True
        else:
            print("❌ AI Assistant has issues. Check the configuration.")
            return False
            
    except ImportError as e:
        print(f"❌ Could not import AI assistant: {e}")
        return False
    except Exception as e:
        print(f"❌ Error testing AI assistant: {e}")
        return False

def main():
    """Main setup function"""
    print("🌦️ ANGA Weather App - Environment Setup")
    print("=" * 60)
    print(f"Project Root: {Path(__file__).resolve().parent}")
    print("=" * 60)
    
    # Step 1: Create .env file
    env_created = create_env_file()
    
    if not env_created:
        print("\n❌ Environment setup failed!")
        return
    
    # Step 2: Validate configuration
    env_valid = validate_env_file()
    
    if not env_valid:
        print("\n⚠️ Environment validation failed!")
        print("Please fix the issues above and run the script again.")
        return
    
    # Step 3: Test AI assistant
    ai_working = test_ai_assistant()
    
    # Final summary
    print("\n📊 Setup Summary")
    print("=" * 30)
    print(f"Environment File: {'✅ Created' if env_created else '❌ Failed'}")
    print(f"Configuration: {'✅ Valid' if env_valid else '❌ Invalid'}")
    print(f"AI Assistant: {'✅ Working' if ai_working else '❌ Issues'}")
    
    if env_created and env_valid and ai_working:
        print("\n🎉 Setup completed successfully!")
        print("\n🚀 You can now:")
        print("1. Start the backend: uvicorn backend.main_api:app --host 0.0.0.0 --port 8000 --reload")
        print("2. Run the mobile app")
        print("3. Test the AI assistant features")
    else:
        print("\n⚠️ Setup completed with issues.")
        print("Please resolve the issues above before proceeding.")

if __name__ == "__main__":
    main() 