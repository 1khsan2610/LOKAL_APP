from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
import logging
from datetime import datetime
import asyncio
from enum import Enum

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="LOKAL_APP ML Service",
    description="Machine Learning service for price recommendations",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============ Models ============

class CompetitiveProduct(BaseModel):
    """Represents a competitive product in market analysis"""
    name: str
    seller: str
    price: float
    rating: Optional[float] = None
    distance_km: Optional[float] = None


class MarketAnalysis(BaseModel):
    """Market analysis data for price recommendation"""
    market_average_price: float = Field(..., description="Average price in market")
    market_price_range: Dict[str, float] = Field(..., description="Min and max prices")
    competitor_count: int = Field(..., description="Number of competitors found")
    demand_level: str = Field(..., description="LOW, MEDIUM, HIGH")
    price_trend: str = Field(..., description="INCREASING, STABLE, DECREASING")


class PriceRecommendationRequest(BaseModel):
    """Request model for price recommendation"""
    product_id: int = Field(..., description="Product ID")
    umkm_id: int = Field(..., description="UMKM business ID")
    product_name: str = Field(..., description="Product name")
    category: str = Field(..., description="Product category")
    current_price: float = Field(..., description="Current selling price")
    cost_price: float = Field(..., description="Cost/purchase price")
    stock_quantity: int = Field(..., description="Current stock")
    latitude: float = Field(..., description="UMKM latitude")
    longitude: float = Field(..., description="UMKM longitude")
    search_radius_km: float = Field(default=5, description="Search radius in kilometers")
    api_key: Optional[str] = Field(default=None, description="API authentication key")


class PriceRecommendationResponse(BaseModel):
    """Response model for price recommendation"""
    request_id: str = Field(..., description="Unique request ID")
    product_id: int
    recommended_price: float = Field(..., description="ML-recommended price")
    confidence_score: float = Field(..., ge=0, le=1, description="Confidence (0-1)")
    price_change_percentage: float = Field(..., description="Percentage change from current")
    recommendation_reason: str = Field(..., description="Why this price is recommended")
    market_analysis: MarketAnalysis
    competitive_products: List[CompetitiveProduct]
    suggested_profit_margin: float = Field(..., description="Suggested profit margin %")
    estimated_daily_sales: int = Field(..., description="Estimated daily sales at recommended price")
    analysis_timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())


class RequestStatusResponse(BaseModel):
    """Response for checking request status"""
    request_id: str
    status: str = Field(..., description="PENDING, PROCESSING, COMPLETED, FAILED")
    result: Optional[PriceRecommendationResponse] = None
    error_message: Optional[str] = None


# ============ Mock ML Logic ============

def calculate_price_recommendation(request: PriceRecommendationRequest) -> Dict[str, Any]:
    """
    Calculate price recommendation using ML algorithms
    
    In production, this would:
    1. Call external market data APIs
    2. Run ML model for price optimization
    3. Store results in database
    
    For now, returns mock data based on business rules
    """
    
    # Calculate profit margin
    margin_percentage = ((request.current_price - request.cost_price) / request.cost_price) * 100
    
    # Simulate market analysis (in production, call external APIs)
    market_avg = request.current_price * 1.05  # Assume 5% market average premium
    market_min = request.cost_price * 1.1
    market_max = request.current_price * 1.5
    
    # Determine demand level based on stock and category
    if request.stock_quantity > 100:
        demand_level = "HIGH"
    elif request.stock_quantity > 20:
        demand_level = "MEDIUM"
    else:
        demand_level = "LOW"
    
    # Recommend price based on margin and market conditions
    if margin_percentage < 20:
        recommended_price = request.cost_price * 1.35
        confidence = 0.85
    elif margin_percentage > 50:
        recommended_price = request.cost_price * 1.25
        confidence = 0.75
    else:
        recommended_price = market_avg
        confidence = 0.90
    
    # Ensure recommended price is within market range
    recommended_price = max(market_min, min(recommended_price, market_max))
    
    price_change = ((recommended_price - request.current_price) / request.current_price) * 100
    
    return {
        "recommended_price": round(recommended_price, 2),
        "confidence_score": min(confidence * (1 + (demand_level == "HIGH") * 0.05), 1.0),
        "price_change_percentage": round(price_change, 2),
        "market_avg": round(market_avg, 2),
        "market_min": round(market_min, 2),
        "market_max": round(market_max, 2),
        "demand_level": demand_level,
        "margin_percentage": round(margin_percentage, 2),
    }


# ============ Endpoints ============

@app.get("/health")
async def health_check():
    """Health check endpoint for Docker"""
    return {
        "status": "healthy",
        "service": "ML Service",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/price-recommendation")
async def get_price_recommendation(request: PriceRecommendationRequest) -> PriceRecommendationResponse:
    """
    Main endpoint: Get ML-based price recommendation
    
    Accepts product details and market parameters, returns recommended price
    with market analysis and competitive insights.
    """
    try:
        logger.info(f"Processing recommendation for product {request.product_id}")
        
        # Validate inputs
        if request.current_price <= 0:
            raise HTTPException(status_code=422, detail="Current price must be positive")
        
        if request.cost_price <= 0:
            raise HTTPException(status_code=422, detail="Cost price must be positive")
        
        if request.cost_price >= request.current_price:
            raise HTTPException(status_code=422, detail="Cost price must be less than current price")
        
        # Calculate recommendation
        ml_result = calculate_price_recommendation(request)
        
        # Simulate finding competitive products
        competitive_products = [
            CompetitiveProduct(
                name=f"{request.product_name} (Competitor 1)",
                seller="Seller A",
                price=ml_result["market_avg"] * 0.95,
                rating=4.5,
                distance_km=2.3
            ),
            CompetitiveProduct(
                name=f"{request.product_name} (Competitor 2)",
                seller="Seller B",
                price=ml_result["market_avg"],
                rating=4.2,
                distance_km=3.1
            ),
        ]
        
        # Simulate demand-based sales estimate
        base_sales = 10 if ml_result["demand_level"] == "HIGH" else (5 if ml_result["demand_level"] == "MEDIUM" else 2)
        estimated_sales = int(base_sales * (1 - (ml_result["price_change_percentage"] / 100)))
        estimated_sales = max(1, estimated_sales)  # Minimum 1 sale
        
        # Create response
        response = PriceRecommendationResponse(
            request_id=f"REQ-{request.product_id}-{int(datetime.utcnow().timestamp())}",
            product_id=request.product_id,
            recommended_price=ml_result["recommended_price"],
            confidence_score=ml_result["confidence_score"],
            price_change_percentage=ml_result["price_change_percentage"],
            recommendation_reason=f"Based on market analysis with {len(competitive_products)} competitors. Market average: Rp{ml_result['market_avg']:,.0f}. Current margin: {ml_result['margin_percentage']:.1f}%.",
            market_analysis=MarketAnalysis(
                market_average_price=ml_result["market_avg"],
                market_price_range={
                    "min": ml_result["market_min"],
                    "max": ml_result["market_max"]
                },
                competitor_count=len(competitive_products),
                demand_level=ml_result["demand_level"],
                price_trend="STABLE"  # Would be calculated from historical data
            ),
            competitive_products=competitive_products,
            suggested_profit_margin=ml_result["margin_percentage"] + 5,
            estimated_daily_sales=estimated_sales,
        )
        
        logger.info(f"Recommendation generated: {response.request_id}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in price recommendation: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@app.get("/api/price-recommendation/status/{request_id}")
async def get_recommendation_status(request_id: str) -> RequestStatusResponse:
    """
    Check status of an async recommendation request
    
    Returns current status and results if available
    """
    try:
        logger.info(f"Checking status for request {request_id}")
        
        # In production, query database for status
        # For now, simulate immediate completion
        return RequestStatusResponse(
            request_id=request_id,
            status="COMPLETED",
            result=None,  # Would fetch from DB in production
        )
        
    except Exception as e:
        logger.error(f"Error checking status: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@app.post("/api/price-recommendation/batch")
async def batch_price_recommendations(requests: List[PriceRecommendationRequest]) -> List[PriceRecommendationResponse]:
    """
    Batch process multiple price recommendations
    
    More efficient for analyzing multiple products at once
    """
    try:
        logger.info(f"Processing batch of {len(requests)} recommendations")
        
        results = []
        for req in requests:
            result = await get_price_recommendation(req)
            results.append(result)
        
        return results
        
    except Exception as e:
        logger.error(f"Error in batch processing: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@app.get("/api/stats")
async def get_service_stats():
    """
    Get service statistics and performance metrics
    """
    return {
        "service_name": "LOKAL_APP ML Service",
        "version": "1.0.0",
        "status": "operational",
        "recommendations_processed": 0,  # Would track in production
        "average_response_time_ms": 0,
        "uptime_seconds": 0,
    }


# ============ Error Handlers ============

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Custom HTTP exception handler"""
    return {
        "error": True,
        "status_code": exc.status_code,
        "detail": exc.detail,
        "timestamp": datetime.utcnow().isoformat()
    }


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """General exception handler"""
    logger.error(f"Unhandled exception: {str(exc)}")
    return {
        "error": True,
        "status_code": 500,
        "detail": "Internal server error",
        "timestamp": datetime.utcnow().isoformat()
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
