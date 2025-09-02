#!/usr/bin/env python3
"""
Database Initialization Script
Creates all database tables and performs initial setup
"""

import os
import sys
from pathlib import Path
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Add the backend directory to Python path
backend_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(backend_dir))

try:
    from database import Base, engine, SessionLocal, User, WeatherData
    logger.info("✅ Database modules imported successfully")
except ImportError as e:
    logger.error(f"❌ Failed to import database modules: {e}")
    sys.exit(1)

def init_database():
    """Initialize the database with all tables"""
    try:
        # Create all tables
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Database tables created successfully!")
        
        # Test database connection
        with SessionLocal() as db:
            # Test query to ensure database is working
            user_count = db.query(User).count()
            weather_count = db.query(WeatherData).count()
            logger.info(f"✅ Database connection test passed!")
            logger.info(f"   • Users table: {user_count} records")
            logger.info(f"   • Weather data table: {weather_count} records")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Database initialization failed: {e}")
        return False

def create_sample_data():
    """Create sample data for testing"""
    try:
        with SessionLocal() as db:
            # Check if sample data already exists
            existing_users = db.query(User).count()
            if existing_users > 0:
                logger.info("ℹ️ Sample data already exists, skipping...")
                return True
            
            # Create sample user
            sample_user = User(
                name="Test Farmer",
                phone_number="+254700000000",
                password="test123"
            )
            db.add(sample_user)
            db.commit()
            
            logger.info("✅ Sample data created successfully!")
            return True
            
    except Exception as e:
        logger.error(f"❌ Failed to create sample data: {e}")
        return False

def main():
    """Main initialization function"""
    logger.info("🚀 Starting database initialization...")
    
    # Check if database file exists
    db_file = Path("weather.db")
    if db_file.exists():
        logger.info(f"📁 Database file found: {db_file}")
    else:
        logger.info("📁 Creating new database file...")
    
    # Initialize database
    if not init_database():
        logger.error("❌ Database initialization failed!")
        sys.exit(1)
    
    # Create sample data
    create_sample_data()
    
    logger.info("🎉 Database initialization completed successfully!")
    logger.info("📊 Database is ready for use!")

if __name__ == "__main__":
    main()
