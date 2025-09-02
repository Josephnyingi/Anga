# ANGA API Architecture

## 🎯 Overview

ANGA uses a **Unified API** approach where all features are consolidated into a single, comprehensive API endpoint.

## 🏗️ API Structure

### ✅ Production API (MAIN)
- **File:** `backend/main_api.py`
- **Purpose:** Unified API with ALL features
- **Status:** ✅ **ACTIVE** - Use this for production

### ⚠️ Legacy APIs (DEPRECATED)
- **File:** `backend/assistant_api.py`
- **Purpose:** AI assistant only
- **Status:** ❌ **DEPRECATED** - Do not use

- **File:** `backend/weather_api.py` (if exists)
- **Purpose:** Weather only
- **Status:** ❌ **DEPRECATED** - Do not use

## 🚀 Deployment Configuration

### Docker Environment Variables
```yaml
# docker-compose.yml
environment:
  - API_ENTRY_POINT=main_api:app  # ✅ Unified API
  - API_VERSION=unified
  - API_TYPE=production
```

### Dockerfile Configuration
```dockerfile
# ✅ CORRECT - Uses unified API
ARG API_ENTRY_POINT=main_api:app
ENV API_ENTRY_POINT=${API_ENTRY_POINT}
CMD ["sh", "-c", "uvicorn $API_ENTRY_POINT --host 0.0.0.0 --port 8000"]
```

## 📋 Available Endpoints

### AI Assistant
- `POST /assistant/ask` - Ask AI farming questions
- `GET /assistant/use-cases` - Get available use cases
- `GET /assistant/status` - Check AI assistant status

### Weather
- `POST /predict/` - Get weather predictions
- `GET /live_weather/` - Get live weather data
- `POST /save_prediction/` - Save weather predictions

### User Management
- `POST /users/` - Create new user
- `POST /login/` - User login

### System
- `GET /health` - Health check
- `GET /env/status` - Environment status

## 🔧 Development Guidelines

### ✅ DO
- Use `main_api.py` for all new features
- Add endpoints to the unified API
- Update this documentation when adding features
- Use environment variables for configuration

### ❌ DON'T
- Create separate API files
- Use legacy APIs (`assistant_api.py`, `weather_api.py`)
- Modify Dockerfile to use legacy APIs
- Forget to update documentation

## 🚨 Troubleshooting

### If you see "assistant_api:app" in Dockerfile:
```bash
# ❌ WRONG
CMD ["uvicorn", "assistant_api:app", "--host", "0.0.0.0", "--port", "8000"]

# ✅ CORRECT
CMD ["sh", "-c", "uvicorn $API_ENTRY_POINT --host 0.0.0.0 --port 8000"]
```

### If mobile app can't connect:
1. Check that unified API is running
2. Verify endpoints match `/assistant/ask` (not `/ask`)
3. Ensure CORS is enabled

## 📝 Migration Guide

### From Legacy to Unified
1. Update Dockerfile to use `main_api:app`
2. Update mobile app endpoints:
   - `/ask` → `/assistant/ask`
   - `/use-cases` → `/assistant/use-cases`
3. Test all features
4. Remove legacy files

## 🔍 Monitoring

### Health Check
```bash
curl http://localhost:8000/health
```

### API Status
```bash
curl http://localhost:8000/env/status
```

### Startup Logs
Look for:
```
🚀 Starting ANGA Unified API v2.0.0
📋 Available endpoints:
✅ Unified API is ready!
```

## 📞 Support

If you encounter issues:
1. Check this documentation
2. Verify API_ENTRY_POINT environment variable
3. Ensure main_api.py is being used
4. Check startup logs for errors

---

**Remember: Always use the Unified API (`main_api.py`) for production!** 🚀 