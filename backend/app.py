"""
LOKAL Platform Backend API - Flask Implementation
Mock backend untuk development dan testing
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import uuid
import json

app = Flask(__name__)
CORS(app)

# Mock Database
db = {
    'users': [
        {
            'id': '1',
            'phone': '08123456789',
            'name': 'John Doe',
            'email': 'john@example.com',
            'avatar': None,
            'role': 'consumer',
            'isVerified': True,
            'address': 'Jl. Test No. 123',
            'city': 'Jakarta',
            'latitude': -6.2088,
            'longitude': 106.8456,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
    ],
    'products': [
        {
            'id': 'prod_1',
            'umkmId': 'umkm_1',
            'name': 'Keripik Singkong Premium',
            'description': 'Keripik singkong crispy dengan bumbu pilihan',
            'price': 25000,
            'recommendedPrice': 30000,
            'stock': 100,
            'category': 'Snacks',
            'images': ['https://via.placeholder.com/400?text=Keripik+Singkong'],
            'rating': 4.5,
            'reviewCount': 25,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_2',
            'umkmId': 'umkm_1',
            'name': 'Bakso Sapi Gurih',
            'description': 'Bakso sapi dengan kuah kaldu pilihan',
            'price': 35000,
            'recommendedPrice': 40000,
            'stock': 50,
            'category': 'Food',
            'images': ['https://via.placeholder.com/400?text=Bakso+Sapi'],
            'rating': 4.8,
            'reviewCount': 35,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_3',
            'umkmId': 'umkm_1',
            'name': 'Tahu Goreng Crispy',
            'description': 'Tahu goreng dengan racikan rempah istimewa',
            'price': 15000,
            'recommendedPrice': 20000,
            'stock': 75,
            'category': 'Snacks',
            'images': ['https://via.placeholder.com/400?text=Tahu+Goreng'],
            'rating': 4.3,
            'reviewCount': 18,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_4',
            'umkmId': 'umkm_2',
            'name': 'Batik Mega Mendung',
            'description': 'Kain batik tradisional dengan motif mega mendung',
            'price': 250000,
            'recommendedPrice': 300000,
            'stock': 15,
            'category': 'Fashion',
            'images': ['https://via.placeholder.com/400?text=Batik+Mega'],
            'rating': 4.7,
            'reviewCount': 42,
            'attributes': {'size': ['M', 'L', 'XL']},
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_5',
            'umkmId': 'umkm_2',
            'name': 'Sarung Batik Premium',
            'description': 'Sarung batik asli dengan jahitan rapi',
            'price': 180000,
            'recommendedPrice': 220000,
            'stock': 25,
            'category': 'Fashion',
            'images': ['https://via.placeholder.com/400?text=Sarung+Batik'],
            'rating': 4.6,
            'reviewCount': 28,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_6',
            'umkmId': 'umkm_3',
            'name': 'Meja Kayu Jati',
            'description': 'Meja makan kayu jati solid dengan finishing natural',
            'price': 1500000,
            'recommendedPrice': 1800000,
            'stock': 5,
            'category': 'Furniture',
            'images': ['https://via.placeholder.com/400?text=Meja+Kayu'],
            'rating': 4.8,
            'reviewCount': 12,
            'attributes': {'size': ['4 seat', '6 seat', '8 seat']},
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_7',
            'umkmId': 'umkm_3',
            'name': 'Kursi Kayu Custom',
            'description': 'Kursi custom dengan desain sesuai keinginan',
            'price': 450000,
            'recommendedPrice': 550000,
            'stock': 20,
            'category': 'Furniture',
            'images': ['https://via.placeholder.com/400?text=Kursi+Kayu'],
            'rating': 4.5,
            'reviewCount': 15,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_8',
            'umkmId': 'umkm_4',
            'name': 'Kopi Arabika Gayo',
            'description': 'Kopi arabika premium dari Tanah Gayo, Aceh',
            'price': 95000,
            'recommendedPrice': 120000,
            'stock': 60,
            'category': 'Food & Beverage',
            'images': ['https://via.placeholder.com/400?text=Kopi+Gayo'],
            'rating': 4.9,
            'reviewCount': 55,
            'attributes': {'grind': ['Whole Bean', 'Medium Grind', 'Fine Grind']},
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_9',
            'umkmId': 'umkm_4',
            'name': 'Kopi Robusta Bandung',
            'description': 'Kopi robusta asli Bandung dengan cita rasa kuat',
            'price': 65000,
            'recommendedPrice': 85000,
            'stock': 80,
            'category': 'Food & Beverage',
            'images': ['https://via.placeholder.com/400?text=Kopi+Bandung'],
            'rating': 4.7,
            'reviewCount': 38,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_10',
            'umkmId': 'umkm_5',
            'name': 'Tas Tangan Kulit Asli',
            'description': 'Tas tangan dari kulit asli pilihan dengan desain elegan',
            'price': 350000,
            'recommendedPrice': 450000,
            'stock': 12,
            'category': 'Fashion',
            'images': ['https://via.placeholder.com/400?text=Tas+Tangan'],
            'rating': 4.8,
            'reviewCount': 48,
            'attributes': {'color': ['Brown', 'Black', 'Tan']},
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'prod_11',
            'umkmId': 'umkm_5',
            'name': 'Tas Laptop Kulit',
            'description': 'Tas laptop dari kulit asli dengan kompartemen lengkap',
            'price': 450000,
            'recommendedPrice': 550000,
            'stock': 8,
            'category': 'Fashion',
            'images': ['https://via.placeholder.com/400?text=Tas+Laptop'],
            'rating': 4.6,
            'reviewCount': 22,
            'attributes': None,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
    ],
    'umkms': [
        {
            'id': 'umkm_1',
            'userId': '1',
            'name': 'Usaha Lokal Sejahtera',
            'description': 'UMKM yang menjual produk lokal berkualitas',
            'logo': 'https://via.placeholder.com/200?text=Logo+UMKM',
            'banner': None,
            'address': 'Jl. Bisnis No. 456',
            'city': 'Jakarta',
            'latitude': -6.2088,
            'longitude': 106.8456,
            'phone': '08987654321',
            'website': None,
            'category': 'Food & Beverage',
            'rating': 4.6,
            'reviewCount': 50,
            'productCount': 3,
            'followerCount': 150,
            'nibNumber': None,
            'siupNumber': None,
            'isVerified': True,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'umkm_2',
            'userId': '2',
            'name': 'Batik Nusantara Indah',
            'description': 'Produk batik premium dengan desain eksklusif',
            'logo': 'https://via.placeholder.com/200?text=Batik+Logo',
            'banner': None,
            'address': 'Jl. Tekstil No. 123',
            'city': 'Jakarta',
            'latitude': -6.2150,
            'longitude': 106.8500,
            'phone': '08111222333',
            'website': None,
            'category': 'Fashion',
            'rating': 4.7,
            'reviewCount': 62,
            'productCount': 15,
            'followerCount': 200,
            'nibNumber': None,
            'siupNumber': None,
            'isVerified': True,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'umkm_3',
            'userId': '3',
            'name': 'Kerajinan Kayu Asli',
            'description': 'Furnitur kayu berkualitas tinggi dan custom design',
            'logo': 'https://via.placeholder.com/200?text=Kayu+Craft',
            'banner': None,
            'address': 'Jl. Industri No. 789',
            'city': 'Jakarta',
            'latitude': -6.2050,
            'longitude': 106.8400,
            'phone': '08222333444',
            'website': None,
            'category': 'Furniture',
            'rating': 4.5,
            'reviewCount': 45,
            'productCount': 20,
            'followerCount': 180,
            'nibNumber': None,
            'siupNumber': None,
            'isVerified': True,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'umkm_4',
            'userId': '4',
            'name': 'Kopi Specialty Lokal',
            'description': 'Kopi pilihan dari berbagai daerah Indonesia',
            'logo': 'https://via.placeholder.com/200?text=Kopi+Logo',
            'banner': None,
            'address': 'Jl. Nusantara No. 321',
            'city': 'Jakarta',
            'latitude': -6.2120,
            'longitude': 106.8480,
            'phone': '08333444555',
            'website': None,
            'category': 'Food & Beverage',
            'rating': 4.8,
            'reviewCount': 78,
            'productCount': 8,
            'followerCount': 250,
            'nibNumber': None,
            'siupNumber': None,
            'isVerified': True,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        },
        {
            'id': 'umkm_5',
            'userId': '5',
            'name': 'Tas Kulit Premium',
            'description': 'Tas kulit asli dengan craftsmanship terbaik',
            'logo': 'https://via.placeholder.com/200?text=Tas+Kulit',
            'banner': None,
            'address': 'Jl. Kreatif No. 567',
            'city': 'Jakarta',
            'latitude': -6.2110,
            'longitude': 106.8420,
            'phone': '08444555666',
            'website': None,
            'category': 'Fashion',
            'rating': 4.6,
            'reviewCount': 55,
            'productCount': 12,
            'followerCount': 170,
            'nibNumber': None,
            'siupNumber': None,
            'isVerified': True,
            'isActive': True,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
    ],
    'orders': [],
    'notifications': [
        {
            'id': 'notif_1',
            'userId': '1',
            'type': 'order',
            'title': 'Pesanan Diterima',
            'message': 'Pesanan Anda telah diterima oleh penjual',
            'data': {'orderId': 'order_1'},
            'isRead': False,
            'createdAt': datetime.now().isoformat()
        }
    ],
    'wallet': {
        'userId': '1',
        'coinBalance': 5000,
        'coinExpiring30Days': 500,
        'lastUpdated': datetime.now().isoformat(),
        'recentTransactions': []
    }
}

# ============ AUTH ROUTES ============

@app.route('/api/v1/auth/login', methods=['POST', 'OPTIONS'])
def login():
    if request.method == 'OPTIONS':
        return '', 200
    
    data = request.get_json()
    phone = data.get('phone')
    email = data.get('email')
    
    if not phone and not email:
        return jsonify({'message': 'Phone or email required', 'status': 'error'}), 400
    
    # Try to find by phone or email
    user = None
    if phone:
        user = next((u for u in db['users'] if u['phone'] == phone), None)
    elif email:
        user = next((u for u in db['users'] if u['email'] == email), None)
    
    if not user:
        # Create new user if doesn't exist
        new_user = {
            'id': str(uuid.uuid4()),
            'phone': phone,
            'name': None,
            'email': None,
            'avatar': None,
            'role': data.get('role', 'consumer'),
            'isVerified': False,
            'address': None,
            'city': None,
            'latitude': None,
            'longitude': None,
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
        db['users'].append(new_user)
        user = new_user
    
    return jsonify({
        'data': {
            'user': user,
            'accessToken': f'token_{uuid.uuid4()}',
            'refreshToken': f'refresh_{uuid.uuid4()}'
        },
        'status': 'success'
    }), 200

@app.route('/api/v1/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    phone = data.get('phone')
    
    if not phone:
        return jsonify({'message': 'Phone required', 'status': 'error'}), 400
    
    new_user = {
        'id': str(uuid.uuid4()),
        'phone': phone,
        'name': data.get('name'),
        'email': data.get('email'),
        'avatar': None,
        'role': data.get('role', 'consumer'),
        'isVerified': False,
        'address': None,
        'city': None,
        'latitude': None,
        'longitude': None,
        'createdAt': datetime.now().isoformat(),
        'updatedAt': datetime.now().isoformat()
    }
    
    db['users'].append(new_user)
    
    return jsonify({
        'data': {
            'user': new_user,
            'accessToken': f'token_{uuid.uuid4()}',
            'refreshToken': f'refresh_{uuid.uuid4()}'
        },
        'status': 'success'
    }), 201

@app.route('/api/v1/auth/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    phone = data.get('phone')
    otp = data.get('otp')
    
    if not phone or not otp:
        return jsonify({'message': 'Phone and OTP required', 'status': 'error'}), 400
    
    return jsonify({
        'data': {
            'verified': True,
            'accessToken': f'token_{uuid.uuid4()}',
            'refreshToken': f'refresh_{uuid.uuid4()}'
        },
        'status': 'success'
    }), 200

# ============ USER ROUTES ============

@app.route('/api/v1/users/profile', methods=['GET'])
def get_profile():
    user = db['users'][0] if db['users'] else None
    
    if not user:
        return jsonify({'message': 'User not found', 'status': 'error'}), 404
    
    return jsonify({'data': user, 'status': 'success'}), 200

@app.route('/api/v1/users/profile', methods=['PUT'])
def update_profile():
    data = request.get_json()
    user = db['users'][0] if db['users'] else None
    
    if not user:
        return jsonify({'message': 'User not found', 'status': 'error'}), 404
    
    if 'name' in data:
        user['name'] = data['name']
    if 'email' in data:
        user['email'] = data['email']
    if 'address' in data:
        user['address'] = data['address']
    if 'city' in data:
        user['city'] = data['city']
    if 'latitude' in data:
        user['latitude'] = data['latitude']
    if 'longitude' in data:
        user['longitude'] = data['longitude']
    
    user['updatedAt'] = datetime.now().isoformat()
    
    return jsonify({'data': user, 'status': 'success'}), 200

# ============ PRODUCT ROUTES ============

@app.route('/api/v1/products', methods=['GET'])
def get_products():
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 10))
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    min_price = request.args.get('minPrice')
    max_price = request.args.get('maxPrice')
    
    products = db['products'].copy()
    
    if search:
        products = [p for p in products if search.lower() in p['name'].lower()]
    
    if category:
        products = [p for p in products if p['category'] == category]
    
    if min_price:
        products = [p for p in products if p['price'] >= float(min_price)]
    
    if max_price:
        products = [p for p in products if p['price'] <= float(max_price)]
    
    start = (page - 1) * per_page
    paginated = products[start:start + per_page]
    
    return jsonify({
        'data': paginated,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': len(products),
            'total_pages': (len(products) + per_page - 1) // per_page
        },
        'status': 'success'
    }), 200

@app.route('/api/v1/products/categories', methods=['GET'])
def get_categories():
    categories = list(set(p['category'] for p in db['products']))
    return jsonify({
        'data': categories,
        'status': 'success'
    }), 200

@app.route('/api/v1/products/<product_id>', methods=['GET'])
def get_product(product_id):
    product = next((p for p in db['products'] if p['id'] == product_id), None)
    
    if not product:
        return jsonify({'message': 'Product not found', 'status': 'error'}), 404
    
    return jsonify({'data': product, 'status': 'success'}), 200

# ============ UMKM ROUTES ============

@app.route('/api/v1/umkms', methods=['GET'])
def get_umkms():
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 10))
    
    start = (page - 1) * per_page
    paginated = db['umkms'][start:start + per_page]
    
    return jsonify({
        'data': paginated,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': len(db['umkms']),
            'total_pages': (len(db['umkms']) + per_page - 1) // per_page
        },
        'status': 'success'
    }), 200

@app.route('/api/v1/umkms/<umkm_id>', methods=['GET'])
def get_umkm(umkm_id):
    umkm = next((u for u in db['umkms'] if u['id'] == umkm_id), None)
    
    if not umkm:
        return jsonify({'message': 'UMKM not found', 'status': 'error'}), 404
    
    # Get products for this UMKM
    products = [p for p in db['products'] if p['umkmId'] == umkm_id]
    
    return jsonify({
        'data': {
            **umkm,
            'products': products
        },
        'status': 'success'
    }), 200

# ============ ORDER ROUTES ============

@app.route('/api/v1/orders', methods=['GET'])
def get_orders():
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 10))
    
    start = (page - 1) * per_page
    paginated = db['orders'][start:start + per_page]
    
    return jsonify({
        'data': paginated,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': len(db['orders']),
            'total_pages': (len(db['orders']) + per_page - 1) // per_page
        },
        'status': 'success'
    }), 200

@app.route('/api/v1/orders', methods=['POST'])
def create_order():
    data = request.get_json()
    
    order = {
        'id': f'order_{uuid.uuid4()}',
        'userId': '1',
        'items': data.get('items', []),
        'subtotal': data.get('subtotal', 0),
        'tax': data.get('tax', 0),
        'shippingCost': data.get('shippingCost', 15000),
        'coinUsed': data.get('coinUsed', 0),
        'coinDiscount': data.get('coinDiscount', 0),
        'totalPrice': data.get('totalPrice', 0),
        'status': 'pending',
        'paymentMethod': data.get('paymentMethod'),
        'paymentId': None,
        'shippingAddress': data.get('shippingAddress'),
        'notes': data.get('notes'),
        'createdAt': datetime.now().isoformat(),
        'updatedAt': datetime.now().isoformat()
    }
    
    db['orders'].append(order)
    
    return jsonify({
        'data': order,
        'status': 'success'
    }), 201

@app.route('/api/v1/orders/<order_id>', methods=['GET'])
def get_order(order_id):
    order = next((o for o in db['orders'] if o['id'] == order_id), None)
    
    if not order:
        return jsonify({'message': 'Order not found', 'status': 'error'}), 404
    
    return jsonify({'data': order, 'status': 'success'}), 200

# ============ NOTIFICATION ROUTES ============

@app.route('/api/v1/notifications', methods=['GET'])
def get_notifications():
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 10))
    
    start = (page - 1) * per_page
    paginated = db['notifications'][start:start + per_page]
    
    return jsonify({
        'data': paginated,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': len(db['notifications']),
            'total_pages': (len(db['notifications']) + per_page - 1) // per_page
        },
        'status': 'success'
    }), 200

@app.route('/api/v1/notifications/<notif_id>/read', methods=['PUT'])
def mark_notification_read(notif_id):
    notif = next((n for n in db['notifications'] if n['id'] == notif_id), None)
    
    if not notif:
        return jsonify({'message': 'Notification not found', 'status': 'error'}), 404
    
    notif['isRead'] = True
    
    return jsonify({'data': notif, 'status': 'success'}), 200

# ============ WALLET ROUTES ============

@app.route('/api/v1/wallet', methods=['GET'])
def get_wallet():
    return jsonify({
        'data': db['wallet'],
        'status': 'success'
    }), 200

@app.route('/api/v1/wallet/transactions', methods=['GET'])
def get_wallet_transactions():
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 10))
    
    transactions = db['wallet'].get('recentTransactions', [])
    start = (page - 1) * per_page
    paginated = transactions[start:start + per_page]
    
    return jsonify({
        'data': paginated,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': len(transactions),
            'total_pages': (len(transactions) + per_page - 1) // per_page
        },
        'status': 'success'
    }), 200

# Alias endpoints for Flutter compatibility
@app.route('/api/v1/wallet/balance', methods=['GET', 'OPTIONS'])
def get_wallet_balance():
    return jsonify({
        'data': db['wallet'],
        'status': 'success'
    }), 200

@app.route('/api/v1/wallet/history', methods=['GET', 'OPTIONS'])
def get_wallet_history():
    page = int(request.args.get('page', 1))
    per_page = int(request.args.get('per_page', 10))
    
    transactions = db['wallet'].get('recentTransactions', [])
    start = (page - 1) * per_page
    paginated = transactions[start:start + per_page]
    
    return jsonify({
        'data': paginated,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': len(transactions),
            'total_pages': (len(transactions) + per_page - 1) // per_page
        },
        'status': 'success'
    }), 200

# ============ GEOLOCATION ROUTES ============

@app.route('/api/v1/umkm/nearby', methods=['GET', 'OPTIONS'])
def get_nearby_umkms():
    latitude = float(request.args.get('latitude', -6.2088))
    longitude = float(request.args.get('longitude', 106.8456))
    radius = float(request.args.get('radius', 5.0))
    
    # Simple distance calculation (Haversine simplified for mock data)
    def get_distance(lat1, lon1, lat2, lon2):
        from math import radians, cos, sin, asin, sqrt
        lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        km = 6371 * c
        return km
    
    nearby_umkms = []
    for umkm in db['umkms']:
        distance = get_distance(latitude, longitude, umkm['latitude'], umkm['longitude'])
        if distance <= radius:
            umkm_data = umkm.copy()
            umkm_data['distance'] = round(distance, 2)
            nearby_umkms.append(umkm_data)
    
    # Sort by distance
    nearby_umkms.sort(key=lambda x: x['distance'])
    
    return jsonify({
        'data': nearby_umkms,
        'total': len(nearby_umkms),
        'status': 'success'
    }), 200

# ============ HEALTH CHECK ============

@app.route('/api/v1/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'OK',
        'message': 'LOKAL Backend is running',
        'timestamp': datetime.now().isoformat()
    }), 200

# ============ ROOT ROUTE ============

@app.route('/', methods=['GET'])
def root():
    return jsonify({
        'message': 'LOKAL Platform Backend API',
        'version': '1.0.0',
        'status': 'running',
        'endpoints': {
            'auth': ['/api/v1/auth/login', '/api/v1/auth/register', '/api/v1/auth/verify-otp'],
            'users': ['/api/v1/users/profile'],
            'products': ['/api/v1/products', '/api/v1/products/<id>', '/api/v1/products/categories'],
            'umkms': ['/api/v1/umkms', '/api/v1/umkms/<id>'],
            'orders': ['/api/v1/orders', '/api/v1/orders/<id>'],
            'notifications': ['/api/v1/notifications', '/api/v1/notifications/<id>/read'],
            'wallet': ['/api/v1/wallet', '/api/v1/wallet/transactions'],
            'health': ['/api/v1/health']
        }
    }), 200

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'message': 'Endpoint not found',
        'status': 'error'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'message': 'Internal server error',
        'status': 'error',
        'error': str(error)
    }), 500

if __name__ == '__main__':
    print("""
    ╔════════════════════════════════════════╗
    ║  LOKAL BACKEND SERVER IS RUNNING       ║
    ║  URL: http://localhost:8000            ║
    ║  API: http://localhost:8000/api/v1     ║
    ╚════════════════════════════════════════╝
    """)
    app.run(debug=True, host='0.0.0.0', port=8000)
