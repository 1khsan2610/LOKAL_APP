const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));

// In-memory database (untuk demo, ganti dengan database nyata)
const db = {
  users: [
    {
      id: '1',
      phone: '08123456789',
      name: 'John Doe',
      email: 'john@example.com',
      avatar: null,
      role: 'consumer',
      isVerified: true,
      address: 'Jl. Test No. 123',
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      createdAt: new Date(),
      updatedAt: new Date()
    }
  ],
  products: [
    {
      id: 'prod_1',
      umkmId: 'umkm_1',
      name: 'Keripik Singkong Premium',
      description: 'Keripik singkong crispy dengan bumbu pilihan',
      price: 25000,
      recommendedPrice: 30000,
      stock: 100,
      category: 'Snacks',
      images: ['https://via.placeholder.com/400?text=Keripik+Singkong'],
      rating: 4.5,
      reviewCount: 25,
      attributes: null,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    },
    {
      id: 'prod_2',
      umkmId: 'umkm_1',
      name: 'Bakso Sapi Gurih',
      description: 'Bakso sapi dengan kuah kaldu pilihan',
      price: 35000,
      recommendedPrice: 40000,
      stock: 50,
      category: 'Food',
      images: ['https://via.placeholder.com/400?text=Bakso+Sapi'],
      rating: 4.8,
      reviewCount: 35,
      attributes: null,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    }
  ],
  umkms: [
    {
      id: 'umkm_1',
      userId: '1',
      name: 'Usaha Lokal Sejahtera',
      description: 'UMKM yang menjual produk lokal berkualitas',
      logo: 'https://via.placeholder.com/200?text=Logo+UMKM',
      banner: null,
      address: 'Jl. Bisnis No. 456',
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      phone: '08987654321',
      website: null,
      category: 'Food & Beverage',
      rating: 4.6,
      reviewCount: 50,
      productCount: 2,
      followerCount: 150,
      nibNumber: null,
      siupNumber: null,
      isVerified: true,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    }
  ],
  notifications: [
    {
      id: 'notif_1',
      userId: '1',
      type: 'order',
      title: 'Pesanan Diterima',
      message: 'Pesanan Anda telah diterima oleh penjual',
      data: { orderId: 'order_1' },
      isRead: false,
      createdAt: new Date()
    }
  ]
};

// ============ AUTH ROUTES ============
app.post('/api/auth/login', (req, res) => {
  const { phone, password } = req.body;
  
  if (!phone) {
    return res.status(400).json({ message: 'Phone required' });
  }

  const user = db.users.find(u => u.phone === phone);
  
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  res.json({
    data: {
      user,
      accessToken: 'token_' + uuidv4(),
      refreshToken: 'refresh_' + uuidv4()
    }
  });
});

app.post('/api/auth/register', (req, res) => {
  const { phone, password, role } = req.body;
  
  if (!phone || !password) {
    return res.status(400).json({ message: 'Phone and password required' });
  }

  const newUser = {
    id: uuidv4(),
    phone,
    name: null,
    email: null,
    avatar: null,
    role: role || 'consumer',
    isVerified: false,
    address: null,
    city: null,
    latitude: null,
    longitude: null,
    createdAt: new Date(),
    updatedAt: new Date()
  };

  db.users.push(newUser);

  res.status(201).json({
    data: {
      user: newUser,
      accessToken: 'token_' + uuidv4(),
      refreshToken: 'refresh_' + uuidv4()
    }
  });
});

app.post('/api/auth/verify-otp', (req, res) => {
  const { phone, otp, role } = req.body;
  
  if (!phone || !otp) {
    return res.status(400).json({ message: 'Phone and OTP required' });
  }

  res.json({
    data: {
      verified: true,
      accessToken: 'token_' + uuidv4(),
      refreshToken: 'refresh_' + uuidv4()
    }
  });
});

// ============ USER ROUTES ============
app.get('/api/users/profile', (req, res) => {
  const user = db.users[0]; // Return first user as current user
  
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  res.json({ data: user });
});

app.put('/api/users/profile', (req, res) => {
  const { name, email, address, city, latitude, longitude } = req.body;
  const user = db.users[0];

  if (name) user.name = name;
  if (email) user.email = email;
  if (address) user.address = address;
  if (city) user.city = city;
  if (latitude) user.latitude = latitude;
  if (longitude) user.longitude = longitude;
  user.updatedAt = new Date();

  res.json({ data: user });
});

// ============ PRODUCT ROUTES ============
app.get('/api/products', (req, res) => {
  const { page = 1, per_page = 10, search, category, minPrice, maxPrice } = req.query;

  let products = [...db.products];

  if (search) {
    products = products.filter(p => 
      p.name.toLowerCase().includes(search.toLowerCase())
    );
  }

  if (category) {
    products = products.filter(p => p.category === category);
  }

  if (minPrice) {
    products = products.filter(p => p.price >= parseFloat(minPrice));
  }

  if (maxPrice) {
    products = products.filter(p => p.price <= parseFloat(maxPrice));
  }

  const start = (page - 1) * per_page;
  const paginatedProducts = products.slice(start, start + parseInt(per_page));

  res.json({
    data: paginatedProducts,
    pagination: {
      page: parseInt(page),
      per_page: parseInt(per_page),
      total: products.length,
      total_pages: Math.ceil(products.length / per_page)
    }
  });
});

app.get('/api/products/categories', (req, res) => {
  const categories = [...new Set(db.products.map(p => p.category))];
  res.json({ data: categories });
});

app.get('/api/products/:id', (req, res) => {
  const product = db.products.find(p => p.id === req.params.id);

  if (!product) {
    return res.status(404).json({ message: 'Product not found' });
  }

  res.json({ data: product });
});

// ============ UMKM ROUTES ============
app.get('/api/umkms', (req, res) => {
  res.json({
    data: db.umkms,
    pagination: {
      page: 1,
      per_page: 10,
      total: db.umkms.length
    }
  });
});

app.get('/api/umkms/:id', (req, res) => {
  const umkm = db.umkms.find(u => u.id === req.params.id);

  if (!umkm) {
    return res.status(404).json({ message: 'UMKM not found' });
  }

  res.json({ data: umkm });
});

app.get('/api/umkms/:id/analytics', (req, res) => {
  res.json({
    data: {
      totalRevenue: 5000000,
      revenueGrowth: 15,
      totalOrders: 150,
      totalCustomers: 80,
      topProduct: {
        id: 'prod_1',
        name: 'Keripik Singkong',
        revenue: 1500000
      },
      averageRating: 4.6,
      dailyRevenue: [
        { date: new Date().toISOString().split('T')[0], revenue: 150000, orders: 10 }
      ],
      productSales: [
        { productId: 'prod_1', productName: 'Keripik Singkong', quantity: 100, revenue: 2500000 }
      ]
    }
  });
});

// ============ ORDER ROUTES ============
app.get('/api/orders', (req, res) => {
  const orders = [];
  res.json({
    data: orders,
    pagination: {
      page: 1,
      per_page: 10,
      total: 0
    }
  });
});

app.get('/api/orders/:id', (req, res) => {
  res.json({
    data: {
      id: req.params.id,
      userId: '1',
      items: [],
      subtotal: 0,
      tax: 0,
      shippingCost: 0,
      coinUsed: 0,
      coinDiscount: 0,
      totalPrice: 0,
      status: 'pending',
      paymentMethod: null,
      paymentId: null,
      shippingAddress: null,
      notes: null,
      createdAt: new Date(),
      updatedAt: new Date()
    }
  });
});

app.post('/api/orders', (req, res) => {
  const { items, shippingAddress, paymentMethod } = req.body;

  const order = {
    id: 'order_' + uuidv4(),
    userId: '1',
    items: items || [],
    subtotal: 0,
    tax: 0,
    shippingCost: 15000,
    coinUsed: 0,
    coinDiscount: 0,
    totalPrice: 0,
    status: 'pending',
    paymentMethod,
    paymentId: null,
    shippingAddress,
    notes: null,
    createdAt: new Date(),
    updatedAt: new Date()
  };

  res.status(201).json({ data: order });
});

// ============ NOTIFICATION ROUTES ============
app.get('/api/notifications', (req, res) => {
  res.json({
    data: db.notifications,
    pagination: {
      page: 1,
      per_page: 10,
      total: db.notifications.length
    }
  });
});

app.put('/api/notifications/:id/read', (req, res) => {
  const notif = db.notifications.find(n => n.id === req.params.id);

  if (!notif) {
    return res.status(404).json({ message: 'Notification not found' });
  }

  notif.isRead = true;
  res.json({ data: notif });
});

// ============ WALLET ROUTES ============
app.get('/api/wallet', (req, res) => {
  res.json({
    data: {
      userId: '1',
      coinBalance: 5000,
      coinExpiring30Days: 500,
      lastUpdated: new Date(),
      recentTransactions: []
    }
  });
});

app.get('/api/wallet/transactions', (req, res) => {
  res.json({
    data: [],
    pagination: {
      page: 1,
      per_page: 10,
      total: 0
    }
  });
});

// ============ HEALTH CHECK ============
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend is running' });
});

// ============ SERVE API TEST PAGE ============
app.get('/api-test.html', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/api-test.html'));
});

app.get('/api-test', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/api-test.html'));
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint not found' });
});

// Start Server
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║  LOKAL BACKEND SERVER IS RUNNING       ║
║  URL: http://localhost:${PORT}                ║
║  API: http://localhost:${PORT}/api            ║
║  Test: http://localhost:${PORT}/api-test.html ║
╚════════════════════════════════════════╝
  `);
});

module.exports = app;
