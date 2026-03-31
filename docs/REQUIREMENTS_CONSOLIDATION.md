# 📦 Requirements Consolidation Documentation

## Overview
This document explains the consolidation of multiple `requirements.txt` files into a single, comprehensive file for the ANGA project.

## Previous State (Confusing)
The project had **4 different `requirements.txt` files**:

1. **`requirements.txt`** (root) - 98 dependencies including ML libraries
2. **`backend/requirements.txt`** - 12 basic dependencies  
3. **`backend/anga-ussd/requirements.txt`** - 4 USSD-specific dependencies
4. **`models/AI-Farming-Assistant-App/requirements.txt`** - 5 AI assistant dependencies

## Current State (Consolidated)
**Single source of truth**: `backend/requirements.txt`

### What's Included:
- ✅ **Core Web Framework**: FastAPI, Uvicorn, Flask, Gunicorn
- ✅ **API & Validation**: Pydantic, Requests, Python-dotenv
- ✅ **AI & ML**: Groq, Pandas, Scikit-learn, Prophet, NumPy, Matplotlib, Plotly
- ✅ **Database**: SQLAlchemy
- ✅ **Additional ML**: Altair, CmdStanPy, Holidays, PyArrow, Streamlit, Tornado, Tqdm

## Benefits of Consolidation:
1. **No Confusion**: Single file for Docker to use
2. **Complete Dependencies**: All necessary packages included
3. **Version Control**: Specific versions to prevent conflicts
4. **Maintainability**: Easy to update and manage

## Docker Usage:
The Dockerfile uses `backend/requirements.txt` as the single source:
```dockerfile
COPY requirements.txt .
RUN pip install -r requirements.txt
```

## Future Updates:
- Always update `backend/requirements.txt` only
- Remove or archive the other requirements files
- Document any new dependencies here

## Files to Consider Removing:
- `requirements.txt` (root) - redundant
- `backend/anga-ussd/requirements.txt` - consolidated
- `models/AI-Farming-Assistant-App/requirements.txt` - consolidated

---
*Last updated: July 26, 2025* 