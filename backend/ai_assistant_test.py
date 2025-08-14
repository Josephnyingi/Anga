#!/usr/bin/env python3
"""
🧪 AI Assistant Test Utility
Tests the AI Farming Assistant integration and functionality.
"""

import sys
import os
from pathlib import Path
import requests
import json
from datetime import datetime

# Add the project root to the path
project_root = Path(__file__).resolve().parents[1]
sys.path.append(str(project_root))

# Add the assistant path
assistant_path = project_root / "models" / "AI-Farming-Assistant-App"
sys.path.append(str(assistant_path))

def test_assistant_core():
    """Test the assistant_core.py module directly"""
    print("🧪 Testing Assistant Core Module...")
    print("-" * 40)
    
    try:
        from assistant_core import generate_response, get_available_use_cases, test_connectivity
        
        # Test connectivity
        print("📡 Testing connectivity...")
        connectivity_result = test_connectivity()
        print(f"   Status: {connectivity_result['status']}")
        print(f"   Message: {connectivity_result['message']}")
        print(f"   API Key Configured: {connectivity_result['api_key_configured']}")
        print(f"   Client Initialized: {connectivity_result['client_initialized']}")
        
        # Test use cases
        print("\n📋 Testing use cases...")
        use_cases = get_available_use_cases()
        print(f"   Available use cases: {len(use_cases)}")
        for use_case, description in use_cases.items():
            print(f"   - {use_case}: {description}")
        
        # Test response generation (if available)
        if connectivity_result['status'] == 'working':
            print("\n🤖 Testing response generation...")
            test_prompt = "What should I plant this season given the current weather?"
            response = generate_response(test_prompt, "Weather-Based Farming")
            print(f"   Prompt: {test_prompt}")
            print(f"   Response: {response[:100]}...")
            
            if not response.startswith("❌"):
                print("   ✅ Response generation successful!")
            else:
                print("   ❌ Response generation failed!")
        else:
            print("\n⚠️ Skipping response generation test due to connectivity issues")
        
        return True
        
    except ImportError as e:
        print(f"❌ Failed to import assistant_core: {e}")
        return False
    except Exception as e:
        print(f"❌ Error testing assistant core: {e}")
        return False

def test_api_endpoints(base_url="http://localhost:8000"):
    """Test the API endpoints"""
    print(f"\n🌐 Testing API Endpoints at {base_url}...")
    print("-" * 40)
    
    endpoints = [
        ("/health", "GET", "Health Check"),
        ("/assistant/status", "GET", "AI Assistant Status"),
        ("/assistant/use-cases", "GET", "AI Use Cases"),
        ("/assistant/ask", "POST", "AI Assistant Query"),
    ]
    
    results = {}
    
    for endpoint, method, description in endpoints:
        try:
            print(f"📡 Testing {description} ({method} {endpoint})...")
            
            if method == "GET":
                response = requests.get(f"{base_url}{endpoint}", timeout=10)
            elif method == "POST" and endpoint == "/assistant/ask":
                data = {
                    "query": "What should I plant this season?",
                    "use_case": "Weather-Based Farming"
                }
                response = requests.post(
                    f"{base_url}{endpoint}", 
                    json=data, 
                    headers={"Content-Type": "application/json"},
                    timeout=30
                )
            else:
                response = requests.post(f"{base_url}{endpoint}", timeout=10)
            
            if response.status_code == 200:
                result = response.json()
                print(f"   ✅ Success (Status: {response.status_code})")
                if endpoint == "/health":
                    print(f"   AI Assistant Available: {result.get('ai_assistant_available', 'N/A')}")
                    print(f"   ML Models Loaded: {result.get('ml_models_loaded', 'N/A')}")
                elif endpoint == "/assistant/status":
                    print(f"   Status: {result.get('status', 'N/A')}")
                    print(f"   Message: {result.get('message', 'N/A')}")
                elif endpoint == "/assistant/use-cases":
                    use_cases = result.get('use_cases', {})
                    print(f"   Available Use Cases: {len(use_cases)}")
                elif endpoint == "/assistant/ask":
                    answer = result.get('answer', '')
                    print(f"   Answer: {answer[:100]}...")
                
                results[endpoint] = {"status": "success", "data": result}
            else:
                print(f"   ❌ Failed (Status: {response.status_code})")
                print(f"   Error: {response.text}")
                results[endpoint] = {"status": "error", "error": response.text}
                
        except requests.exceptions.ConnectionError:
            print(f"   ❌ Connection Error - Is the server running at {base_url}?")
            results[endpoint] = {"status": "connection_error"}
        except Exception as e:
            print(f"   ❌ Error: {e}")
            results[endpoint] = {"status": "error", "error": str(e)}
    
    return results

def test_environment_setup():
    """Test environment setup"""
    print("🔧 Testing Environment Setup...")
    print("-" * 40)
    
    # Check .env file
    env_file = project_root / ".env"
    if env_file.exists():
        print("✅ .env file found")
        with open(env_file, 'r') as f:
            content = f.read()
            if "GROQ_API_KEY" in content:
                print("✅ GROQ_API_KEY found in .env")
            else:
                print("⚠️ GROQ_API_KEY not found in .env")
    else:
        print("⚠️ .env file not found")
        print("   Create a .env file with your GROQ_API_KEY")
    
    # Check assistant path
    if assistant_path.exists():
        print("✅ Assistant path exists")
        assistant_core_file = assistant_path / "assistant_core.py"
        if assistant_core_file.exists():
            print("✅ assistant_core.py found")
        else:
            print("❌ assistant_core.py not found")
    else:
        print("❌ Assistant path does not exist")
    
    # Check requirements
    requirements_file = assistant_path / "requirements.txt"
    if requirements_file.exists():
        print("✅ requirements.txt found")
        with open(requirements_file, 'r') as f:
            requirements = f.read()
            if "groq" in requirements:
                print("✅ groq dependency found")
            else:
                print("❌ groq dependency not found")
    else:
        print("❌ requirements.txt not found")

def main():
    """Main test function"""
    print("🧪 AI Assistant Integration Test")
    print("=" * 50)
    print(f"Timestamp: {datetime.now().isoformat()}")
    print(f"Project Root: {project_root}")
    print(f"Assistant Path: {assistant_path}")
    print("=" * 50)
    
    # Test environment setup
    test_environment_setup()
    
    # Test assistant core
    core_success = test_assistant_core()
    
    # Test API endpoints
    api_results = test_api_endpoints()
    
    # Summary
    print("\n📊 Test Summary")
    print("=" * 50)
    print(f"Assistant Core: {'✅ PASS' if core_success else '❌ FAIL'}")
    
    api_success_count = sum(1 for result in api_results.values() if result.get('status') == 'success')
    api_total_count = len(api_results)
    print(f"API Endpoints: {api_success_count}/{api_total_count} ✅ PASS")
    
    if api_success_count == api_total_count:
        print("\n🎉 All tests passed! AI Assistant is working correctly.")
    else:
        print("\n⚠️ Some tests failed. Check the configuration and try again.")
    
    print("\n📝 Next Steps:")
    print("1. If tests failed, check your .env file and GROQ_API_KEY")
    print("2. Make sure the FastAPI server is running")
    print("3. Verify all dependencies are installed")
    print("4. Check the logs for detailed error messages")

if __name__ == "__main__":
    main() 