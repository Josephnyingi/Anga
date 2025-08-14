#!/usr/bin/env python3
"""
🔍 Environment Validator for ANGA Weather App
Validates environment variables and provides helpful error messages.
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dotenv import load_dotenv

class EnvironmentValidator:
    """Validates environment configuration for the ANGA Weather App"""
    
    def __init__(self):
        self.project_root = Path(__file__).resolve().parents[1]
        self.env_file = self.project_root / ".env"
        self.env_template = self.project_root / "env.example"
        
        # Load environment variables
        if self.env_file.exists():
            load_dotenv(self.env_file)
        
        # Define required environment variables
        self.required_vars = {
            'GROQ_API_KEY': {
                'description': 'AI Assistant API key',
                'type': 'api_key',
                'required': True,
                'validation': self._validate_api_key
            },
            'API_HOST': {
                'description': 'API host address',
                'type': 'string',
                'required': True,
                'default': '0.0.0.0'
            },
            'API_PORT': {
                'description': 'API port number',
                'type': 'integer',
                'required': True,
                'default': '8000',
                'validation': self._validate_port
            },
            'DATABASE_URL': {
                'description': 'Database connection URL',
                'type': 'string',
                'required': True,
                'default': 'sqlite:///./weather.db'
            },
            'SECRET_KEY': {
                'description': 'Application secret key',
                'type': 'string',
                'required': True,
                'default': 'anga_weather_secret_key_2024_secure_random_string_here'
            },
            'DEBUG_MODE': {
                'description': 'Debug mode flag',
                'type': 'boolean',
                'required': False,
                'default': 'true'
            },
            'LOG_LEVEL': {
                'description': 'Logging level',
                'type': 'string',
                'required': False,
                'default': 'INFO'
            }
        }
    
    def _validate_api_key(self, value: str) -> Tuple[bool, str]:
        """Validate API key format"""
        if not value or value == 'your_groq_api_key_here':
            return False, "API key is missing or has placeholder value"
        
        if not value.startswith('gsk_'):
            return False, "API key should start with 'gsk_'"
        
        if len(value) < 20:
            return False, "API key appears to be too short"
        
        return True, "API key format is valid"
    
    def _validate_port(self, value: str) -> Tuple[bool, str]:
        """Validate port number"""
        try:
            port = int(value)
            if 1 <= port <= 65535:
                return True, f"Port {port} is valid"
            else:
                return False, f"Port {port} is out of range (1-65535)"
        except ValueError:
            return False, f"'{value}' is not a valid port number"

    def validate_all(self) -> Dict[str, object]:
        """Validate all environment variables"""
        results = {
            'valid': True,
            'env_file_exists': self.env_file.exists(),
            'env_template_exists': self.env_template.exists(),
            'variables': {},
            'errors': [],
            'warnings': []
        }
        
        for var_name, config in self.required_vars.items():
            value = os.getenv(var_name)
            var_result = self._validate_variable(var_name, value, config)
            results['variables'][var_name] = var_result
            
            if not var_result['valid']:
                results['valid'] = False
                results['errors'].append(f"{var_name}: {var_result['message']}")
            elif var_result['warning']:
                results['warnings'].append(f"{var_name}: {var_result['warning']}")
        
        return results
    
    def _validate_variable(self, var_name: str, value: Optional[str], config: Dict) -> Dict:
        """Validate a single environment variable"""
        result = {
            'name': var_name,
            'value': value,
            'valid': False,
            'message': '',
            'warning': '',
            'description': config['description']
        }
        
        # Check if value exists
        if not value:
            if config.get('required', False):
                result['message'] = f"{config['description']} is missing"
                return result
            else:
                # Use default value for optional variables
                value = config.get('default', '')
                result['value'] = value
                result['warning'] = f"Using default value: {value}"
        
        # Apply custom validation if available
        if 'validation' in config:
            is_valid, message = config['validation'](value)
            if not is_valid:
                result['message'] = message
                return result
        
        # Type-specific validation
        if config['type'] == 'integer':
            if value is None:
                result['message'] = f"Value for '{var_name}' is missing"
                return result
            try:
                int(str(value))
            except (ValueError, TypeError):
                result['message'] = f"'{value}' is not a valid integer"
                return result
        elif config['type'] == 'boolean':
            if value is None or not hasattr(value, "lower") or value.lower() not in ['true', 'false', '1', '0']:
                result['message'] = f"'{value}' is not a valid boolean"
                return result

        result['valid'] = True
        result['message'] = "Valid"
        return result
    
    def get_setup_instructions(self) -> str:
        """Get setup instructions for missing environment variables"""
        instructions = []
        
        if not self.env_file.exists():
            instructions.append("1. Create a .env file in the project root")
            if self.env_template.exists():
                instructions.append("2. Copy env.example to .env: cp env.example .env")
            else:
                instructions.append("2. Create .env file with the following variables:")
        
        instructions.append("3. Add your GROQ API key:")
        instructions.append("   - Sign up at https://console.groq.com/")
        instructions.append("   - Get your API key from the console")
        instructions.append("   - Add it to .env: GROQ_API_KEY=your_actual_key_here")
        
        instructions.append("4. Review other variables and update as needed")
        instructions.append("5. Run the validation again")
        
        return "\n".join(instructions)
    
    def print_validation_report(self, results: Dict):
        """Print a formatted validation report"""
        print("🔍 Environment Validation Report")
        print("=" * 50)
        print(f"Environment File: {'✅ Found' if results['env_file_exists'] else '❌ Missing'}")
        print(f"Template File: {'✅ Found' if results['env_template_exists'] else '❌ Missing'}")
        print(f"Overall Status: {'✅ Valid' if results['valid'] else '❌ Invalid'}")
        print()
        
        # Print variable status
        for var_name, var_result in results['variables'].items():
            status = "✅" if var_result['valid'] else "❌"
            print(f"{status} {var_name}: {var_result['description']}")
            
            if not var_result['valid']:
                print(f"   Error: {var_result['message']}")
            elif var_result['warning']:
                print(f"   Warning: {var_result['warning']}")
        
        # Print errors
        if results['errors']:
            print(f"\n❌ Errors ({len(results['errors'])}):")
            for error in results['errors']:
                print(f"   • {error}")
        
        # Print warnings
        if results['warnings']:
            print(f"\n⚠️ Warnings ({len(results['warnings'])}):")
            for warning in results['warnings']:
                print(f"   • {warning}")
        
        # Print setup instructions if needed
        if not results['valid']:
            print(f"\n🔧 Setup Instructions:")
            print("-" * 30)
            print(self.get_setup_instructions())
    
    def create_env_file_from_template(self) -> bool:
        """Create .env file from template"""
        if not self.env_template.exists():
            print("❌ env.example template not found!")
            return False
        
        try:
            import shutil
            shutil.copy2(self.env_template, self.env_file)
            print("✅ .env file created from template!")
            return True
        except Exception as e:
            print(f"❌ Error creating .env file: {e}")
            return False

def main():
    """Main function for standalone validation"""
    validator = EnvironmentValidator()
    results = validator.validate_all()
    validator.print_validation_report(results)
    
    if not results['valid']:
        print(f"\n❌ Environment validation failed!")
        sys.exit(1)
    else:
        print(f"\n🎉 Environment validation passed!")
        if results['warnings']:
            print("Note: Some warnings were found, but the configuration is functional.")

if __name__ == "__main__":
    main() 