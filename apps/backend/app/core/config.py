"""
Configuration management for ANGA backend.
"""
import os
from typing import Optional
from pydantic import BaseSettings, validator


class Settings(BaseSettings):
    """Application settings."""
    
    # Application
    app_name: str = "ANGA Weather App"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # API
    api_v1_str: str = "/api/v1"
    secret_key: str
    access_token_expire_minutes: int = 30
    
    # Database
    database_url: str
    database_test_url: Optional[str] = None
    
    # External APIs
    open_meteo_api_url: str = "https://api.open-meteo.com/v1"
    groq_api_key: str
    groq_api_url: str = "https://api.groq.com/openai/v1"
    
    # Redis
    redis_url: Optional[str] = None
    
    # CORS
    backend_cors_origins: list = ["http://localhost:3000", "http://localhost:8080"]
    
    # USSD
    ussd_service_url: Optional[str] = None
    
    @validator("backend_cors_origins", pre=True)
    def assemble_cors_origins(cls, v):
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Global settings instance
settings = Settings()
