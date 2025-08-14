#!/usr/bin/env python3
"""
🌦️ Comprehensive Backend Test Script
Tests all endpoints and features of the ANGA Weather API
"""

import requests
import json
import time
from datetime import datetime, timedelta

# Configuration
BASE_URL = "http://localhost:8000"
TEST_LOCATIONS = ["machakos", "vhembe"]

def print_header(title):
    """Print a formatted header"""
    print(f"\n{'='*60}")
    print(f"🧪 {title}")
    print(f"{'='*60}")

def print_success(message):
    """Print success message"""
    print(f"✅ {message}")

def print_error(message):
    """Print error message"""
    print(f"❌ {message}")

def print_warning(message):
    """Print warning message"""
    print(f"⚠️ {message}")

def test_health_endpoint():
    """Test the health endpoint"""
    print_header("Testing Health Endpoint")
    
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_success("Health endpoint is working!")
            print(f"   Status: {data.get('status')}")
            print(f"   Database: {data.get('database')}")
            print(f"   AI Assistant: {data.get('ai_assistant_available')}")
            print(f"   ML Models: {data.get('ml_models_loaded')}")
            return True
        else:
            print_error(f"Health endpoint returned status {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Health endpoint failed: {e}")
        return False

def test_environment_status():
    """Test environment status endpoint"""
    print_header("Testing Environment Status")
    
    try:
        response = requests.get(f"{BASE_URL}/env/status", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_success("Environment status endpoint is working!")
            print(f"   Environment Valid: {data.get('environment_valid')}")
            print(f"   GROQ API Key: {'✅ Configured' if data.get('groq_api_key_configured') else '❌ Missing'}")
            print(f"   Database URL: {'✅ Configured' if data.get('database_url_configured') else '❌ Missing'}")
            return True
        else:
            print_error(f"Environment status returned status {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Environment status failed: {e}")
        return False

def test_live_weather():
    """Test live weather endpoint"""
    print_header("Testing Live Weather Endpoint")
    
    for location in TEST_LOCATIONS:
        try:
            response = requests.get(f"{BASE_URL}/live_weather/?location={location}", timeout=10)
            if response.status_code == 200:
                data = response.json()
                print_success(f"Live weather for {location} is working!")
                print(f"   Temperature: {data.get('temperature', 'N/A')}°C")
                print(f"   Humidity: {data.get('humidity', 'N/A')}%")
                print(f"   Weather: {data.get('weather_description', 'N/A')}")
            else:
                print_error(f"Live weather for {location} returned status {response.status_code}")
        except Exception as e:
            print_error(f"Live weather for {location} failed: {e}")

def test_weather_prediction():
    """Test weather prediction endpoint"""
    print_header("Testing Weather Prediction Endpoint")
    
    # Test prediction for tomorrow
    tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
    
    for location in TEST_LOCATIONS:
        try:
            payload = {
                "date": tomorrow,
                "location": location
            }
            response = requests.post(f"{BASE_URL}/predict/", json=payload, timeout=10)
            if response.status_code == 200:
                data = response.json()
                print_success(f"Weather prediction for {location} on {tomorrow} is working!")
                print(f"   Predicted Temperature: {data.get('temperature', 'N/A')}°C")
                print(f"   Rain Probability: {data.get('rain_probability', 'N/A')}%")
            else:
                print_error(f"Weather prediction for {location} returned status {response.status_code}")
        except Exception as e:
            print_error(f"Weather prediction for {location} failed: {e}")

def test_ai_assistant_status():
    """Test AI assistant status endpoint"""
    print_header("Testing AI Assistant Status")
    
    try:
        response = requests.get(f"{BASE_URL}/assistant/status", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_success("AI Assistant status endpoint is working!")
            print(f"   Status: {data.get('status')}")
            print(f"   API Key Configured: {data.get('api_key_configured')}")
            print(f"   Message: {data.get('message', 'N/A')}")
            return True
        else:
            print_error(f"AI Assistant status returned status {response.status_code}")
            return False
    except Exception as e:
        print_error(f"AI Assistant status failed: {e}")
        return False

def test_ai_assistant_use_cases():
    """Test AI assistant use cases endpoint"""
    print_header("Testing AI Assistant Use Cases")
    
    try:
        response = requests.get(f"{BASE_URL}/assistant/use-cases", timeout=10)
        if response.status_code == 200:
            data = response.json()
            use_cases = data.get('use_cases', [])
            print_success(f"AI Assistant use cases endpoint is working!")
            print(f"   Available use cases: {len(use_cases)}")
            for use_case in use_cases[:3]:  # Show first 3
                print(f"   • {use_case}")
            if len(use_cases) > 3:
                print(f"   ... and {len(use_cases) - 3} more")
            return True
        else:
            print_error(f"AI Assistant use cases returned status {response.status_code}")
            return False
    except Exception as e:
        print_error(f"AI Assistant use cases failed: {e}")
        return False

def test_ai_assistant_query():
    """Test AI assistant query endpoint"""
    print_header("Testing AI Assistant Query")
    
    test_queries = [
        {
            "query": "What crops are best to plant in Machakos during the rainy season?",
            "use_case": "Smart Farming Advice"
        },
        {
            "query": "How can I prepare my farm for drought conditions?",
            "use_case": "Weather Adaptation"
        }
    ]
    
    for i, query_data in enumerate(test_queries, 1):
        try:
            response = requests.post(f"{BASE_URL}/assistant/ask", json=query_data, timeout=30)
            if response.status_code == 200:
                data = response.json()
                answer = data.get('answer', '')
                print_success(f"AI Assistant query {i} is working!")
                print(f"   Query: {query_data['query'][:50]}...")
                print(f"   Answer length: {len(answer)} characters")
                print(f"   Answer preview: {answer[:100]}...")
            else:
                print_error(f"AI Assistant query {i} returned status {response.status_code}")
                print(f"   Response: {response.text}")
        except Exception as e:
            print_error(f"AI Assistant query {i} failed: {e}")

def test_user_management():
    """Test user management endpoints"""
    print_header("Testing User Management")
    
    # Test user creation
    test_user = {
        "name": "Test User",
        "phone_number": "1234567890",
        "password": "testpassword123"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/users/", json=test_user, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_success("User creation endpoint is working!")
            print(f"   User ID: {data.get('id')}")
            print(f"   Name: {data.get('name')}")
        else:
            print_warning(f"User creation returned status {response.status_code}")
            print(f"   Response: {response.text}")
    except Exception as e:
        print_error(f"User creation failed: {e}")

def run_comprehensive_test():
    """Run all tests"""
    print_header("🌦️ ANGA Weather API Comprehensive Test")
    print(f"Testing backend at: {BASE_URL}")
    print(f"Test started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Track test results
    test_results = []
    
    # Run all tests
    tests = [
        ("Health Endpoint", test_health_endpoint),
        ("Environment Status", test_environment_status),
        ("Live Weather", test_live_weather),
        ("Weather Prediction", test_weather_prediction),
        ("AI Assistant Status", test_ai_assistant_status),
        ("AI Assistant Use Cases", test_ai_assistant_use_cases),
        ("AI Assistant Query", test_ai_assistant_query),
        ("User Management", test_user_management),
    ]
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            test_results.append((test_name, result))
        except Exception as e:
            print_error(f"Test {test_name} crashed: {e}")
            test_results.append((test_name, False))
    
    # Print summary
    print_header("Test Summary")
    passed = sum(1 for _, result in test_results if result)
    total = len(test_results)
    
    print(f"Tests Passed: {passed}/{total}")
    print(f"Success Rate: {(passed/total)*100:.1f}%")
    
    if passed == total:
        print_success("🎉 All tests passed! Backend is working perfectly!")
    elif passed >= total * 0.8:
        print_warning("⚠️ Most tests passed. Backend is mostly working.")
    else:
        print_error("❌ Many tests failed. Backend needs attention.")
    
    print(f"\nTest completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    run_comprehensive_test() 