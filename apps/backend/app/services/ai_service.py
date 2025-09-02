from groq import Groq
import os
from dotenv import load_dotenv
from typing import Optional, Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
DEFAULT_MODEL = "llama3-70b-8192"

# Initialize Groq client
client = None
if GROQ_API_KEY:
    try:
        client = Groq(api_key=GROQ_API_KEY)
        logger.info("✅ Groq client initialized successfully")
    except Exception as e:
        logger.error(f"❌ Failed to initialize Groq client: {e}")
        client = None
else:
    logger.warning("⚠️ GROQ_API_KEY not found in environment variables")

# Comprehensive system prompts for different farming scenarios
system_prompts = {
    "Smart Farming Advice": """You are an expert AI farming assistant specializing in agricultural best practices, 
weather-based farming decisions, and sustainable agriculture. You provide practical, actionable advice to farmers 
based on current weather conditions, seasonal patterns, and modern farming techniques.

Your expertise includes:
- Crop selection and timing based on weather forecasts
- Soil management and irrigation strategies
- Pest and disease management
- Sustainable farming practices
- Weather-adaptive farming techniques
- Market timing and crop planning

Always provide specific, practical advice that farmers can implement immediately. Consider local weather conditions, 
seasonal factors, and sustainable practices in your recommendations.""",

    "Weather-Based Farming": """You are a weather-aware farming consultant who helps farmers make decisions based on 
current and forecasted weather conditions. You analyze weather patterns and provide specific recommendations for:

- Planting and harvesting timing
- Irrigation scheduling
- Crop protection measures
- Field preparation activities
- Livestock management during weather events
- Equipment and resource planning

Base your advice on weather data including temperature, rainfall, humidity, and seasonal patterns.""",

    "Crop Management": """You are a crop management specialist providing expert advice on:

- Optimal planting times for different crops
- Crop rotation strategies
- Fertilization and soil management
- Pest and disease prevention
- Harvest timing and techniques
- Post-harvest handling and storage
- Market timing and crop selection

Provide specific, actionable recommendations based on current conditions and best practices.""",

    "Sustainable Agriculture": """You are a sustainable agriculture expert promoting environmentally friendly farming practices:

- Organic farming methods
- Water conservation techniques
- Soil health improvement
- Biodiversity enhancement
- Integrated pest management
- Renewable energy in agriculture
- Waste reduction and recycling
- Climate-smart agriculture

Focus on practices that maintain long-term soil health, reduce environmental impact, and ensure economic viability.""",

    "Emergency Weather Response": """You are an emergency response advisor for weather-related agricultural crises:

- Flood damage assessment and recovery
- Drought mitigation strategies
- Storm damage prevention and repair
- Heat stress management for crops and livestock
- Emergency crop protection measures
- Resource allocation during weather events
- Insurance and financial planning

Provide immediate, practical steps for farmers facing weather emergencies.""",
}

def generate_response(prompt: str, use_case: str = "Smart Farming Advice") -> str:
    """
    Generate AI-powered farming advice using Groq LLM.
    
    Args:
        prompt (str): User's farming question or concern
        use_case (str): Type of farming advice needed
        
    Returns:
        str: AI-generated response with farming advice
    """
    if not prompt or prompt.strip() == "":
        return "❌ Please provide a specific farming question or concern."
    
    # Check if we have a valid client
    if not client or not GROQ_API_KEY or GROQ_API_KEY == "gsk_demo_key_for_testing_only":
        # Return fallback responses for testing
        logger.warning("⚠️ Using fallback responses - no valid API key or client")
        return _get_fallback_response(prompt, use_case)
    
    # Get the appropriate system prompt
    system_prompt = system_prompts.get(use_case, system_prompts["Smart Farming Advice"])
    
    try:
        logger.info(f"🤖 Generating response for use case: {use_case}")
        response = client.chat.completions.create(
            model=DEFAULT_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ],
            max_tokens=1000,
            temperature=0.7
        )
        answer = response.choices[0].message.content if response.choices and response.choices[0].message else None
        if answer is None:
            return "❌ No response generated from AI model."
        
        # Check if the answer contains an API key (security check)
        if answer and (answer.startswith("gsk_") or "gsk_" in answer):
            logger.warning("⚠️ API key detected in response - using fallback")
            return _get_fallback_response(prompt, use_case)
        
        logger.info("✅ Response generated successfully")
        return answer
        
    except Exception as e:
        error_msg = f"❌ Error generating response: {str(e)}"
        logger.error(error_msg)
        # Return fallback response on error
        return _get_fallback_response(prompt, use_case)

def _get_fallback_response(prompt: str, use_case: str) -> str:
    """
    Provide fallback responses when AI service is unavailable.
    
    Args:
        prompt (str): User's question
        use_case (str): Type of advice needed
        
    Returns:
        str: Fallback response
    """
    prompt_lower = prompt.lower()
    
    # Smart Farming Advice fallbacks
    if "crop" in prompt_lower and "grow" in prompt_lower:
        return """🌱 **Crop Growing Advice for Machakos Region:**

**Best Crops for Machakos:**
• Maize (corn) - Main staple crop
• Beans - Good for soil nitrogen
• Sweet potatoes - Drought resistant
• Sorghum - Heat tolerant
• Green grams - High value crop

**Planting Tips:**
• Plant during rainy seasons (March-May, October-December)
• Use certified seeds for better yields
• Practice crop rotation to maintain soil health
• Consider intercropping maize with beans

**Soil Management:**
• Test soil pH before planting
• Add organic matter (compost, manure)
• Use terraces to prevent soil erosion
• Practice conservation agriculture

💡 **Tip:** Start with maize and beans as they're well-suited for the Machakos climate and soil conditions."""

    elif "weather" in prompt_lower or "rain" in prompt_lower:
        return """🌤️ **Weather-Based Farming for Machakos:**

**Current Weather Considerations:**
• Machakos has a semi-arid climate
• Two rainy seasons: March-May (long rains) and October-December (short rains)
• Average temperature: 18-25°C
• Annual rainfall: 600-800mm

**Weather-Adaptive Strategies:**
• Plant drought-resistant crops (sorghum, millet)
• Use mulching to retain soil moisture
• Practice rainwater harvesting
• Monitor weather forecasts regularly

**Seasonal Planning:**
• **Long Rains (March-May):** Plant maize, beans, vegetables
• **Short Rains (October-December):** Plant quick-maturing crops
• **Dry Seasons:** Focus on irrigation and soil preparation

🌧️ **Rainwater Harvesting Tips:**
• Build water pans and dams
• Use roof catchment systems
• Practice contour farming
• Plant trees for windbreaks"""

    elif "soil" in prompt_lower or "fertilizer" in prompt_lower:
        return """🌿 **Soil Management & Fertilization:**

**Machakos Soil Characteristics:**
• Generally sandy loam to clay loam
• Often low in organic matter
• pH ranges from 5.5 to 7.0
• Prone to erosion

**Soil Improvement:**
• Add organic matter (compost, farmyard manure)
• Practice crop rotation
• Use cover crops (pigeon peas, lablab)
• Implement terracing on slopes

**Fertilization Guide:**
• **Organic:** Compost, manure, green manure
• **Inorganic:** NPK fertilizers (17-17-17)
• **Application:** Apply before planting and during growth
• **Rate:** Follow soil test recommendations

**Erosion Control:**
• Build terraces on slopes
• Plant grass strips
• Use contour farming
• Maintain ground cover"""

    elif "pest" in prompt_lower or "disease" in prompt_lower:
        return """🦗 **Pest & Disease Management:**

**Common Pests in Machakos:**
• Fall armyworm (maize)
• Aphids (beans, vegetables)
• Cutworms (seedlings)
• Stalk borers (maize)

**Disease Prevention:**
• Use disease-resistant varieties
• Practice crop rotation
• Remove infected plants
• Maintain field hygiene

**Natural Pest Control:**
• Plant repellent crops (marigolds, onions)
• Use neem extracts
• Encourage beneficial insects
• Practice intercropping

**Monitoring:**
• Regular field inspections
• Use pheromone traps
• Monitor weather conditions
• Keep records of pest outbreaks

🌱 **Integrated Pest Management (IPM):**
• Combine cultural, biological, and chemical methods
• Use pesticides as last resort
• Follow safety guidelines
• Rotate pesticide types"""

    else:
        return f"""🤖 **AI Farming Assistant - Demo Mode**

**Your Question:** {prompt}

**Use Case:** {use_case}

**Demo Response:**
This is a demonstration of the AI Farming Assistant. In production, you would receive personalized farming advice based on your specific question and local conditions.

**For Machakos Region, consider:**
• Semi-arid climate with two rainy seasons
• Focus on drought-resistant crops
• Practice soil conservation
• Use rainwater harvesting
• Monitor weather forecasts

**To get real AI advice:**
1. Get a GROQ API key from https://console.groq.com/
2. Add it to your .env file
3. Restart the backend server

💡 **Quick Tips:**
• Plant maize and beans during rainy seasons
• Use terraces to prevent soil erosion
• Practice crop rotation
• Consider drought-resistant varieties

Would you like specific advice about crops, weather, soil, or pest management?"""

def get_available_use_cases() -> Dict[str, str]:
    """
    Get available use cases for the AI assistant.
    
    Returns:
        Dict[str, str]: Dictionary of use case names and descriptions
    """
    return {
        "Smart Farming Advice": "General farming advice and best practices",
        "Weather-Based Farming": "Weather-dependent farming decisions",
        "Crop Management": "Crop-specific advice and management",
        "Sustainable Agriculture": "Environmentally friendly farming practices",
        "Emergency Weather Response": "Emergency response for weather crises"
    }

def test_connectivity() -> Dict[str, Any]:
    """
    Test the AI assistant connectivity and configuration.
    
    Returns:
        Dict[str, Any]: Test results and status information
    """
    result = {
        "api_key_configured": bool(GROQ_API_KEY),
        "client_initialized": bool(client),
        "available_use_cases": list(system_prompts.keys()),
        "default_model": DEFAULT_MODEL,
        "status": "unknown"
    }
    
    if not GROQ_API_KEY:
        result["status"] = "no_api_key"
        result["message"] = "GROQ_API_KEY not found in environment variables"
    elif not client:
        result["status"] = "client_error"
        result["message"] = "Failed to initialize Groq client"
    else:
        try:
            # Test with a simple prompt
            test_response = generate_response("Hello, this is a test message.", "Smart Farming Advice")
            if test_response.startswith("❌"):
                result["status"] = "api_error"
                result["message"] = test_response
            else:
                result["status"] = "working"
                result["message"] = "AI Assistant is working correctly"
        except Exception as e:
            result["status"] = "test_error"
            result["message"] = f"Test failed: {str(e)}"
    
    return result

if __name__ == "__main__":
    # Test the assistant when run directly
    print("🧪 Testing AI Farming Assistant...")
    test_result = test_connectivity()
    print(f"Status: {test_result['status']}")
    print(f"Message: {test_result['message']}")
    
    if test_result['status'] == 'working':
        print("\n📝 Testing response generation...")
        test_response = generate_response(
            "What should I plant this season given the current weather?", 
            "Weather-Based Farming"
        )
        print(f"Response: {test_response}") 