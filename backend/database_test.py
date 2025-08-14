#!/usr/bin/env python3
"""
Database Test Utility
Tests all database operations and functionality
"""

import os
import sys
from pathlib import Path
import logging
from datetime import datetime, date
from decimal import Decimal

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Add the backend directory to Python path
backend_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(backend_dir))

try:
    from database import SessionLocal, User, WeatherData, engine
    logger.info("✅ Database modules imported successfully")
except ImportError as e:
    logger.error(f"❌ Failed to import database modules: {e}")
    sys.exit(1)

class DatabaseTester:
    """Database testing utility"""
    
    def __init__(self):
        self.session = SessionLocal()
        self.test_results = []
    
    def test_database_connection(self):
        """Test basic database connection"""
        try:
            # Test engine connection
            with engine.connect() as conn:
                from sqlalchemy import text
                result = conn.execute(text("SELECT 1"))
                row = result.fetchone()
                assert row is not None and row[0] == 1
            logger.info("✅ Database connection test passed")
            self.test_results.append(("Connection", "PASS"))
            return True
        except Exception as e:
            logger.error(f"❌ Database connection test failed: {e}")
            self.test_results.append(("Connection", "FAIL"))
            return False
    
    def test_user_operations(self):
        """Test user CRUD operations"""
        try:
            # Test user creation
            test_user = User(
                name="Test User",
                phone_number="+254700000001",
                password="testpass123"
            )
            self.session.add(test_user)
            self.session.commit()
            logger.info("✅ User creation test passed")
            
            # Test user retrieval
            retrieved_user = self.session.query(User).filter_by(phone_number="+254700000001").first()
            assert retrieved_user is not None
            assert getattr(retrieved_user, "name", None) == "Test User"
            logger.info("✅ User retrieval test passed")
            
            # Test user update
            setattr(retrieved_user, "name", "Updated Test User")
            self.session.commit()
            updated_user = self.session.query(User).filter_by(phone_number="+254700000001").first()
            if updated_user is None:
                raise AssertionError("Updated user not found after update")
            # Ensure we are comparing the actual value, not a SQLAlchemy column
            updated_name = getattr(updated_user, "name", None)
            if updated_name != "Updated Test User":
                raise AssertionError(f"User name was not updated, found: {updated_name}")
            logger.info("✅ User update test passed")
            
            # Clean up test user
            self.session.delete(updated_user)
            self.session.commit()
            logger.info("✅ User deletion test passed")
            
            self.test_results.append(("User Operations", "PASS"))
            return True
            
        except Exception as e:
            logger.error(f"❌ User operations test failed: {e}")
            self.test_results.append(("User Operations", "FAIL"))
            return False
    
    def test_weather_data_operations(self):
        """Test weather data CRUD operations"""
        try:
            # Test weather data creation
            test_weather = WeatherData(
                date=date.today(),
                location="machakos",
                temperature=25.5,
                rain=0.0
            )
            self.session.add(test_weather)
            self.session.commit()
            logger.info("✅ Weather data creation test passed")
            
            # Test weather data retrieval
            retrieved_weather = self.session.query(WeatherData).filter_by(location="machakos").first()
            if retrieved_weather is None:
                raise AssertionError("Weather data not found for location 'machakos'")
            # Ensure we are comparing the actual value, not a SQLAlchemy column
            retrieved_temp = getattr(retrieved_weather, "temperature", None)
            if retrieved_temp != 25.5:
                raise AssertionError(f"Expected temperature 25.5, found: {retrieved_temp}")
            logger.info("✅ Weather data retrieval test passed")
            
            # Test weather data update
            setattr(retrieved_weather, "temperature", 26.0)
            self.session.commit()
            updated_weather = self.session.query(WeatherData).filter_by(location="machakos").first()
            if updated_weather is None:
                raise AssertionError("Updated weather data not found after update")
            updated_temp = getattr(updated_weather, "temperature", None)
            if updated_temp != 26.0:
                raise AssertionError(f"Weather temperature was not updated, found: {updated_temp}")
            logger.info("✅ Weather data update test passed")
            
            # Clean up test weather data
            self.session.delete(updated_weather)
            self.session.commit()
            logger.info("✅ Weather data deletion test passed")
            
            self.test_results.append(("Weather Data Operations", "PASS"))
            return True
            
        except Exception as e:
            logger.error(f"❌ Weather data operations test failed: {e}")
            self.test_results.append(("Weather Data Operations", "FAIL"))
            return False
    
    def test_database_constraints(self):
        """Test database constraints and validations"""
        try:
            # Test unique phone number constraint
            user1 = User(name="User 1", phone_number="+254700000002", password="pass1")
            user2 = User(name="User 2", phone_number="+254700000002", password="pass2")  # Same phone number
            
            self.session.add(user1)
            self.session.commit()
            
            try:
                self.session.add(user2)
                self.session.commit()
                # If we get here, the constraint failed
                logger.error("❌ Unique phone number constraint test failed")
                self.test_results.append(("Constraints", "FAIL"))
                return False
            except Exception:
                # Expected exception for duplicate phone number
                logger.info("✅ Unique phone number constraint test passed")
                self.session.rollback()
            
            # Clean up
            self.session.delete(user1)
            self.session.commit()
            
            self.test_results.append(("Constraints", "PASS"))
            return True
            
        except Exception as e:
            logger.error(f"❌ Database constraints test failed: {e}")
            self.test_results.append(("Constraints", "FAIL"))
            return False
    
    def test_database_performance(self):
        """Test database performance with bulk operations"""
        try:
            # Test bulk insert
            users = []
            for i in range(10):
                user = User(
                    name=f"Bulk User {i}",
                    phone_number=f"+2547000000{i:03d}",
                    password=f"pass{i}"
                )
                users.append(user)
            
            self.session.add_all(users)
            self.session.commit()
            logger.info("✅ Bulk insert test passed")
            
            # Test bulk query
            all_users = self.session.query(User).filter(User.name.like("Bulk User%")).all()
            assert len(all_users) == 10
            logger.info("✅ Bulk query test passed")
            
            # Clean up
            for user in all_users:
                self.session.delete(user)
            self.session.commit()
            logger.info("✅ Bulk delete test passed")
            
            self.test_results.append(("Performance", "PASS"))
            return True
            
        except Exception as e:
            logger.error(f"❌ Database performance test failed: {e}")
            self.test_results.append(("Performance", "FAIL"))
            return False
    
    def run_all_tests(self):
        """Run all database tests"""
        logger.info("🧪 Starting database tests...")
        
        tests = [
            self.test_database_connection,
            self.test_user_operations,
            self.test_weather_data_operations,
            self.test_database_constraints,
            self.test_database_performance
        ]
        
        passed = 0
        total = len(tests)
        
        for test in tests:
            if test():
                passed += 1
        
        # Print test summary
        logger.info("\n" + "="*50)
        logger.info("📊 DATABASE TEST SUMMARY")
        logger.info("="*50)
        
        for test_name, result in self.test_results:
            status_icon = "✅" if result == "PASS" else "❌"
            logger.info(f"{status_icon} {test_name}: {result}")
        
        logger.info(f"\n🎯 Results: {passed}/{total} tests passed")
        
        if passed == total:
            logger.info("🎉 All database tests passed!")
            return True
        else:
            logger.error(f"❌ {total - passed} test(s) failed!")
            return False
    
    def cleanup(self):
        """Clean up test data"""
        try:
            # Clean up any remaining test data
            test_users = self.session.query(User).filter(User.name.like("Test%")).all()
            test_users.extend(self.session.query(User).filter(User.name.like("Bulk%")).all())
            
            for user in test_users:
                self.session.delete(user)
            
            test_weather = self.session.query(WeatherData).filter(WeatherData.location == "machakos").all()
            for weather in test_weather:
                self.session.delete(weather)
            
            self.session.commit()
            logger.info("🧹 Test data cleanup completed")
            
        except Exception as e:
            logger.error(f"❌ Cleanup failed: {e}")
        finally:
            self.session.close()

def main():
    """Main test function"""
    logger.info("🚀 Starting database testing...")
    
    tester = DatabaseTester()
    
    try:
        success = tester.run_all_tests()
        if success:
            logger.info("🎉 Database testing completed successfully!")
            return 0
        else:
            logger.error("❌ Database testing failed!")
            return 1
    finally:
        tester.cleanup()

if __name__ == "__main__":
    sys.exit(main()) 