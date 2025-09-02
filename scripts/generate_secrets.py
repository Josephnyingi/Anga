#!/usr/bin/env python3
"""
🔐 Secret Generation Script for ANGA Project

This script generates secure random secrets for the ANGA project.
Use these generated secrets in your GitHub Secrets and environment files.

Usage:
    python scripts/generate_secrets.py
"""

import secrets
import string
import base64
import os
from pathlib import Path


def generate_random_string(length: int = 32, include_symbols: bool = True) -> str:
    """Generate a cryptographically secure random string."""
    characters = string.ascii_letters + string.digits
    if include_symbols:
        characters += "!@#$%^&*()_+-=[]{}|;:,.<>?"
    
    return ''.join(secrets.choice(characters) for _ in range(length))


def generate_api_key(prefix: str = "", length: int = 32) -> str:
    """Generate an API key with optional prefix."""
    if prefix:
        return f"{prefix}_{generate_random_string(length)}"
    return generate_random_string(length)


def generate_jwt_secret() -> str:
    """Generate a JWT secret key."""
    return base64.urlsafe_b64encode(secrets.token_bytes(32)).decode('utf-8').rstrip('=')


def generate_database_url(host: str = "localhost", port: int = 5432, db_name: str = "anga") -> str:
    """Generate a database URL template."""
    username = "anga_user"
    password = generate_random_string(16, include_symbols=False)
    return f"postgresql://{username}:{password}@{host}:{port}/{db_name}"


def generate_redis_url(host: str = "localhost", port: int = 6379, password: str = None) -> str:
    """Generate a Redis URL."""
    if password is None:
        password = generate_random_string(16, include_symbols=False)
    
    return f"redis://:{password}@{host}:{port}"


def main():
    """Generate all required secrets for the ANGA project."""
    print("🔐 ANGA Project Secret Generator")
    print("=" * 50)
    print()
    
    # Core API Keys
    print("🔑 CORE API KEYS")
    print("-" * 20)
    print(f"GROQ_API_KEY={generate_api_key('gsk', 40)}")
    print(f"OPENWEATHER_API_KEY={generate_api_key('ow', 32)}")
    print()
    
    # Database & Infrastructure
    print("🗄️ DATABASE & INFRASTRUCTURE")
    print("-" * 30)
    print(f"DATABASE_URL={generate_database_url()}")
    print(f"REDIS_PASSWORD={generate_random_string(16, include_symbols=False)}")
    print(f"SECRET_KEY={generate_random_string(50)}")
    print(f"JWT_SECRET_KEY={generate_jwt_secret()}")
    print()
    
    # Cloud & Deployment
    print("☁️ CLOUD & DEPLOYMENT")
    print("-" * 25)
    print(f"AWS_ACCESS_KEY_ID=AKIA{generate_random_string(16, include_symbols=False).upper()}")
    print(f"AWS_SECRET_ACCESS_KEY={generate_random_string(40)}")
    print(f"DOCKER_HUB_USERNAME=anga-{generate_random_string(8, include_symbols=False).lower()}")
    print(f"DOCKER_HUB_TOKEN={generate_random_string(40)}")
    print()
    
    # Monitoring & Analytics
    print("📊 MONITORING & ANALYTICS")
    print("-" * 30)
    print(f"SENTRY_DSN=https://{generate_random_string(32)}@sentry.io/{generate_random_string(8)}")
    print(f"MIXPANEL_TOKEN={generate_random_string(32)}")
    print(f"FIREBASE_SERVER_KEY={generate_random_string(40)}")
    print()
    
    # Mobile App
    print("📱 MOBILE APP")
    print("-" * 15)
    print(f"ANDROID_KEYSTORE_PASSWORD={generate_random_string(16)}")
    print(f"ANDROID_KEY_ALIAS=anga_key")
    print(f"ANDROID_KEY_PASSWORD={generate_random_string(16)}")
    print(f"IOS_CERTIFICATE_PASSWORD={generate_random_string(16)}")
    print()
    
    # Third-Party Services
    print("🔗 THIRD-PARTY SERVICES")
    print("-" * 25)
    print(f"SLACK_WEBHOOK_URL=https://hooks.slack.com/services/{generate_random_string(24)}/{generate_random_string(24)}/{generate_random_string(24)}")
    print(f"EMAIL_SMTP_PASSWORD={generate_random_string(16)}")
    print(f"BACKUP_S3_BUCKET=anga-backup-{generate_random_string(8, include_symbols=False).lower()}")
    print()
    
    # Environment-specific URLs
    print("🌍 ENVIRONMENT-SPECIFIC URLS")
    print("-" * 35)
    print("STAGING_DATABASE_URL=" + generate_database_url("staging-db.anga.com", 5432, "anga_staging"))
    print("PRODUCTION_DATABASE_URL=" + generate_database_url("prod-db.anga.com", 5432, "anga_production"))
    print("STAGING_REDIS_URL=" + generate_redis_url("staging-redis.anga.com", 6379))
    print("PRODUCTION_REDIS_URL=" + generate_redis_url("prod-redis.anga.com", 6379))
    print()
    
    print("✅ Secret generation complete!")
    print()
    print("📝 NEXT STEPS:")
    print("1. Copy these secrets to your GitHub Secrets")
    print("2. Update your environment files")
    print("3. Never commit secrets to version control")
    print("4. Rotate secrets regularly")
    print()
    print("🔒 SECURITY REMINDERS:")
    print("- Use different secrets for each environment")
    print("- Store secrets securely (GitHub Secrets, AWS Secrets Manager)")
    print("- Rotate secrets every 90 days")
    print("- Monitor secret usage and access")


if __name__ == "__main__":
    main()
