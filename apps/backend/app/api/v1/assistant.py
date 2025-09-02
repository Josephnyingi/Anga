from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field, validator
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import sys
import os
import logging
from typing import Optional
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Step 1: Add assistant path to sys.path
assistant_path = os.path.abspath("../models/AI-Farming-Assistant-App")
sys.path.append(assistant_path)

# Step 2: Import the response generator
try:
    from assistant_core import generate_response
except ImportError as e:
    logger.error(f"Failed to import assistant_core: {e}")
    raise ImportError("❌ Could not import `generate_response()` from assistant_core.py")

# Step 3: Init FastAPI app
app = FastAPI(
    title="ANGA - AI Farming Assistant API",
    description="An API endpoint to ask farming & climate questions via LLM",
    version="1.0.0"
)

# Step 4: Enable CORS with proper security
# In production, replace with your actual frontend domain
ALLOWED_ORIGINS = [
    "http://localhost:3000",  # React dev server
    "http://localhost:8080",  # Flutter web
    "http://127.0.0.1:8080",  # Flutter web alternative
    # Add your production domain here
    # "https://yourdomain.com"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

# Step 5: Define schema with validation
class Question(BaseModel):
    query: str = Field(..., min_length=1, max_length=1000, description="The farming question to ask")
    use_case: str = Field(default="Smart Farming Advice", max_length=100, description="The use case context")

    @validator('query')
    def validate_query(cls, v):
        if not v.strip():
            raise ValueError('Query cannot be empty')
        return v.strip()

    @validator('use_case')
    def validate_use_case(cls, v):
        allowed_cases = [
            "Smart Farming Advice",
            "Weather Analysis", 
            "Crop Management",
            "Soil Health",
            "Pest Control"
        ]
        if v not in allowed_cases:
            raise ValueError(f'Use case must be one of: {", ".join(allowed_cases)}')
        return v

# Step 6: Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": time.time()}

# Step 7: Main endpoint with proper error handling
@app.post("/ask")
async def ask_ai_farming_assistant(data: Question):
    try:
        logger.info(f"Received question: {data.query[:50]}... (use_case: {data.use_case})")
        
        # Generate response
        answer = generate_response(data.query, data.use_case)
        
        if not answer or not answer.strip():
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="AI assistant returned an empty response"
            )
        
        logger.info("Successfully generated response")
        return {
            "answer": answer,
            "query": data.query,
            "use_case": data.use_case,
            "timestamp": time.time()
        }
        
    except Exception as e:
        logger.error(f"Error processing question: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process your question: {str(e)}"
        )

# Step 8: Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error occurred"}
    )
   
