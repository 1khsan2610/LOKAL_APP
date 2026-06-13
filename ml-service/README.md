# ML Service Documentation

## Overview

This ML Service provides machine learning-based price recommendations for the LOKAL_APP platform. It analyzes market data, competitor pricing, and business metrics to suggest optimal product prices.

## Architecture

- **Framework**: FastAPI (Python)
- **Server**: Uvicorn
- **Port**: 8000
- **Database**: None (stateless - data handled by backend)

## Features

### 1. Price Recommendation Analysis
- Analyzes current pricing strategy
- Considers profit margins and cost prices
- Studies market averages and competitor prices
- Provides confidence scores
- Estimates daily sales impact

### 2. Market Analysis
- Identifies competing products
- Calculates market price ranges
- Assesses demand levels
- Determines price trends

### 3. Batch Processing
- Process multiple products efficiently
- Parallel computation support
- Optimized for UMKM workflows

## API Endpoints

### Health Check
```
GET /health
```
Returns service health status.

### Get Price Recommendation
```
POST /api/price-recommendation
```

**Request**:
```json
{
  "product_id": 123,
  "umkm_id": 456,
  "product_name": "Nasi Goreng",
  "category": "Food",
  "current_price": 25000,
  "cost_price": 10000,
  "stock_quantity": 50,
  "latitude": -6.2088,
  "longitude": 106.8456,
  "search_radius_km": 5,
  "api_key": "your-api-key"
}
```

**Response**:
```json
{
  "request_id": "REQ-123-1234567890",
  "product_id": 123,
  "recommended_price": 26500,
  "confidence_score": 0.88,
  "price_change_percentage": 6.0,
  "recommendation_reason": "Based on market analysis with 2 competitors. Market average: Rp26.000. Current margin: 150.0%.",
  "market_analysis": {
    "market_average_price": 26000,
    "market_price_range": {
      "min": 11000,
      "max": 37500
    },
    "competitor_count": 2,
    "demand_level": "HIGH",
    "price_trend": "STABLE"
  },
  "competitive_products": [
    {
      "name": "Nasi Goreng (Competitor 1)",
      "seller": "Seller A",
      "price": 24700,
      "rating": 4.5,
      "distance_km": 2.3
    }
  ],
  "suggested_profit_margin": 155.0,
  "estimated_daily_sales": 8,
  "analysis_timestamp": "2025-01-20T10:30:45.123456"
}
```

### Check Request Status
```
GET /api/price-recommendation/status/{request_id}
```

Returns the processing status of an async recommendation request.

### Batch Recommendations
```
POST /api/price-recommendation/batch
```

Process multiple products in one request.

### Service Statistics
```
GET /api/stats
```

Get service performance metrics and statistics.

## Development

### Installation

```bash
cd ml-service
pip install -r requirements.txt
```

### Running Locally

```bash
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Testing

```bash
# Health check
curl http://localhost:8000/health

# Price recommendation
curl -X POST http://localhost:8000/api/price-recommendation \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "umkm_id": 1,
    "product_name": "Test Product",
    "category": "General",
    "current_price": 50000,
    "cost_price": 20000,
    "stock_quantity": 100,
    "latitude": -6.2088,
    "longitude": 106.8456
  }'
```

## Configuration

### Environment Variables

- `ML_PORT`: Service port (default: 8000)
- `ML_HOST`: Service host (default: 0.0.0.0)
- `PYTHONUNBUFFERED`: Python output buffering (default: 1)

### Backend Integration

The backend communicates with this service via:
- URL: `http://ml-service:8000`
- Timeout: 30 seconds
- Fallback: Returns null if service unavailable

## Performance Considerations

- Response time: ~100-200ms per recommendation
- Batch processing: ~5-10ms per product after initial setup
- Memory usage: ~300MB typical
- Concurrent requests: 100+ supported

## Error Handling

All endpoints return error responses in the format:

```json
{
  "error": true,
  "status_code": 400,
  "detail": "Error description",
  "timestamp": "2025-01-20T10:30:45.123456"
}
```

Common status codes:
- 200: Success
- 422: Validation error (bad input)
- 500: Server error

## Future Enhancements

1. **Real ML Model Integration**
   - Train models on historical data
   - Use scikit-learn or TensorFlow
   - Implement cross-validation

2. **External API Integration**
   - Real market data APIs
   - Competitor price scraping
   - Geographic data services

3. **Advanced Features**
   - Time-series analysis
   - Seasonal adjustments
   - A/B testing frameworks
   - Price elasticity models

4. **Performance Optimization**
   - Caching layer (Redis)
   - Database persistence
   - Async processing
   - Model versioning

## Troubleshooting

### Service won't start
- Check Python version (3.11+)
- Verify port 8000 is available
- Check Docker network connectivity

### Slow responses
- Check backend service load
- Verify network latency
- Monitor system resources

### API errors
- Validate request schema
- Check API key if required
- Review service logs

## Support

For issues or feature requests, contact the LOKAL_APP development team.
