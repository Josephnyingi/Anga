# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser \
    && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# ===========================================
# ANGA UNIFIED API CONFIGURATION
# ===========================================
# This Dockerfile runs the UNIFIED API (main_api.py) which includes:
# ✅ Weather predictions and live data
# ✅ AI farming assistant
# ✅ User management and authentication
# ✅ Database operations
# ✅ Health checks and monitoring
#
# LEGACY APIs (DO NOT USE):
# ❌ assistant_api.py (AI assistant only)
# ❌ weather_api.py (Weather only)
# ===========================================

# Get API entry point from environment or use unified API as default
ARG API_ENTRY_POINT=main_api:app
ENV API_ENTRY_POINT=${API_ENTRY_POINT}

# Run the application
CMD ["sh", "-c", "uvicorn $API_ENTRY_POINT --host 0.0.0.0 --port 8000"] 