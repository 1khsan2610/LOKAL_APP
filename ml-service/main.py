"""
ML Service - FastAPI untuk Rekomendasi Harga (F-05)
Layanan Machine Learning untuk memberikan saran harga produk serupa dalam radius 5 km.

Endpoint:
- GET  /health -> Status kesehatan service
- POST /predict -> Prediksi harga berdasarkan data produk
"""

from typing import Optional
from datetime import datetime

from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(
    title="LOKAL ML Service",
    description="ML Service untuk Rekomendasi Harga Produk UMKM",
    version="1.0.0"
)


# ─── Models ─────────────────────────────────────────────────────────

class ProductInput(BaseModel):
    """Input data produk untuk prediksi harga"""
    name: str = Field(..., max_length=150, description="Nama produk")
    category: str = Field(..., max_length=50, description="Kategori produk")
    price: Optional[float] = Field(None, ge=0, description="Harga produk saat ini (jika ada)")
    avg_rating: Optional[float] = Field(None, ge=0, le=5, description="Rata-rata rating produk")
    sold_count: Optional[int] = Field(None, ge=0, description="Jumlah terjual")
    latitude: Optional[float] = Field(None, ge=-90, le=90, description="Latitude UMKM")
    longitude: Optional[float] = Field(None, ge=-180, le=180, description="Longitude UMKM")
    nearby_products: Optional[list[dict]] = Field(
        None,
        description="Daftar produk serupa dalam radius 5 km (dari query backend)"
    )


class PriceRecommendation(BaseModel):
    """Output rekomendasi harga"""
    recommended_price: float = Field(..., description="Harga yang direkomendasikan")
    min_price: float = Field(..., description="Harga minimum yang disarankan")
    max_price: float = Field(..., description="Harga maksimum yang disarankan")
    confidence: float = Field(..., ge=0, le=1, description="Tingkat kepercayaan 0-1")
    reasoning: str = Field(..., description="Penjelasan rekomendasi harga")
    similar_products_count: int = Field(..., description="Jumlah produk serupa yang ditemukan")


class PredictResponse(BaseModel):
    """Response prediksi"""
    success: bool
    data: Optional[PriceRecommendation] = None
    message: Optional[str] = None


# ─── Helper Functions ──────────────────────────────────────────────

def analyze_market(nearby_products: list[dict]) -> tuple:
    """
    Analisis pasar dari produk serupa.
    Returns (avg_price, min_price, max_price, median_price, count, price_percentiles)
    """
    if not nearby_products:
        return (0, 0, 0, 0, 0, {})

    prices = []
    for p in nearby_products:
        price = p.get('price', 0)
        if price > 0:
            prices.append(price)

    if not prices:
        return (0, 0, 0, 0, 0, {})

    prices.sort()
    n = len(prices)

    avg_price = sum(prices) / n
    min_price = prices[0]
    max_price = prices[-1]
    median_price = prices[n // 2] if n % 2 == 1 else (prices[n//2 - 1] + prices[n//2]) / 2

    # Percentile-based pricing
    percentiles = {
        'p25': prices[int(n * 0.25)],
        'p50': median_price,
        'p75': prices[int(n * 0.75)],
    }

    return (avg_price, min_price, max_price, median_price, n, percentiles)


# ─── Endpoints ─────────────────────────────────────────────────────

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "service": "LOKAL ML Service",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat()
    }


@app.post("/predict", response_model=PredictResponse)
async def predict_price(product: ProductInput):
    """
    Prediksi / rekomendasi harga produk berdasarkan:
    1. Harga produk serupa dalam radius 5 km
    2. Kategori produk
    3. Rating dan jumlah terjual
    4. Market positioning
    
    Algoritma:
    - Jika ada produk serupa: gunakan median price dari sekitar ±10%
    - Jika tidak ada: gunakan rule-based pricing berdasarkan kategori
    """
    try:
        nearby = product.nearby_products or []
        
        # Filter hanya produk dengan kategori yang sama jika ada
        same_category = [p for p in nearby if p.get('category') == product.category] if product.category else nearby
        
        # Gunakan produk dari kategori yang sama, fallback ke semua produk nearby
        relevant_products = same_category if same_category else nearby
        
        avg_price, min_price, max_price, median_price, count, percentiles = analyze_market(relevant_products)
        
        if count > 0 and median_price > 0:
            # ── Ada data pasar ──────────────────────────────────────
            # Recommended price: median ± adjustments
            
            # Adjustment berdasarkan rating
            rating_adjust = 1.0
            if product.avg_rating and product.avg_rating >= 4.5:
                rating_adjust = 1.15
            elif product.avg_rating and product.avg_rating >= 4.0:
                rating_adjust = 1.05
            elif product.avg_rating and product.avg_rating <= 2.0:
                rating_adjust = 0.90
            
            # Adjustment berdasarkan popularitas (sold_count)
            sold_adjust = 1.0
            if product.sold_count and product.sold_count > 100:
                sold_adjust = 1.10
            elif product.sold_count and product.sold_count > 50:
                sold_adjust = 1.05
            elif product.sold_count and product.sold_count < 5:
                sold_adjust = 0.95

            # Harga rekomendasi
            recommended = median_price * rating_adjust * sold_adjust
            recommended = round(recommended / 1000) * 1000
            
            # Batasan range berdasarkan Q1 dan Q3
            p25 = percentiles.get('p25', min_price)
            p75 = percentiles.get('p75', max_price)
            
            suggested_min = max(min_price, int(p25 * 0.9))
            suggested_max = max(max_price, int(p75 * 1.1))
            recommended = max(suggested_min, min(recommended, suggested_max))
            
            confidence = min(0.9, 0.5 + (count * 0.02))
            
            reasoning = (
                f"Berdasarkan analisis {count} produk serupa di sekitar lokasi Anda "
                f"(kategori: {product.category}), harga pasar berkisar Rp "
                f"{min_price:,} - Rp {max_price:,} dengan harga rata-rata Rp {avg_price:,.0f}. "
                f"Harga yang direkomendasikan: Rp {recommended:,} "
                f"(rata-rata + penyesuaian rating & popularitas)."
            )
            
        else:
            # ── Tidak ada data pasar → Rule-based ──────────────────
            category_base_prices = {
                'makanan': 15000,
                'minuman': 10000,
                'fashion': 75000,
                'kerajinan': 50000,
                'aksesoris': 35000,
                'kesehatan': 25000,
                'elektronik': 100000,
                'peralatan_rumah': 45000,
                'buku': 30000,
                'lainnya': 25000,
            }
            
            base_price = category_base_prices.get(
                product.category.lower().replace(' ', '_'), 25000
            )
            
            recommended = base_price
            suggested_min = int(base_price * 0.5)
            suggested_max = int(base_price * 2.0)
            confidence = 0.3
            
            reasoning = (
                f"Tidak ditemukan produk serupa di sekitar lokasi Anda. "
                f"Berdasarkan kategori '{product.category}', harga awal yang disarankan "
                f"adalah Rp {recommended:,}. "
                f"Sebaiknya cek harga kompetitor secara manual untuk penyesuaian."
            )
        
        return PredictResponse(
            success=True,
            data=PriceRecommendation(
                recommended_price=int(recommended),
                min_price=int(suggested_min),
                max_price=int(suggested_max),
                confidence=round(confidence, 2),
                reasoning=reasoning,
                similar_products_count=count
            )
        )
        
    except Exception as e:
        return PredictResponse(
            success=False,
            message=f"Gagal memproses rekomendasi harga: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn
    import os
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)