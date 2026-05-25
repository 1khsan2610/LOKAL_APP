# Frontend Issues & Task Tracking

**Project**: LOKAL App - Frontend  
**Date Created**: May 17, 2026  
**Status**: Core features DONE, Integration IN PROGRESS

---

## 📊 Overall Progress

| Category | Status |
|----------|--------|
| **Flutter 3.19 Setup** | ⚠️ PARTIAL (SDK ^3.0.0 - Check version) |
| **Riverpod + Dio Setup** | ✅ DONE (100%) |
| **Clean Architecture** | ✅ DONE (90%) |
| **Design System** | ✅ DONE (100%) - Poppins font, Green/Orange colors |
| **Bottom Navigation (5 tabs)** | ✅ DONE (100%) - Beranda, Peta, Keranjang, Dompet, Profil |
| **Login UI + OTP UI** | ✅ DONE (100%) - Complete with validation & error handling |
| **Splash Screen** | ✅ DONE (100%) - Role-based auto-routing |
| **Loading States** | ✅ DONE (95%) - Spinners, error widgets, empty states |
| **3-Role Registration** | ✅ DONE (95%) |
| **OTP Auth Integration** | ✅ DONE (90%) |
| **UI/UX Screens** | ✅ DONE (100%) |
| **Navigation System** | ✅ DONE (100%) |
| **Backend Integration** | 🔄 IN PROGRESS (10%) |
| **Error Handling** | 🔄 IN PROGRESS (40%) |
| **Testing** | ⏳ NOT STARTED (0%) |

---

## 🎯 Task Assignment

### **👨‍💻 Naufal Al Faros**

#### ✅ COMPLETED TASKS

- [x] **NFR-001**: Implement Consumer Home Screen UI
  - Status: DONE
  - Description: Featured UMKM showcase, product categories, search functionality
  - Completion: 100%

- [x] **NFR-002**: Implement Authentication Screens (Login/Signup)
  - Status: DONE
  - Description: Phone entry, OTP verification, login flow
  - Completion: 100%

- [x] **NFR-003**: Setup Role-Based Navigation System
  - Status: DONE
  - Description: Consumer, Producer, Admin navigation routes
  - Completion: 100%

#### 🔄 IN PROGRESS / TODO TASKS

- [ ] **NFR-004**: Integrate Backend API - Authentication
  - Status: IN PROGRESS
  - Priority: 🔴 HIGH
  - Description: Connect login/signup to backend API
  - Files to modify:
    - `lib/services/api_service.dart`
    - `lib/providers/auth_provider.dart`
  - Acceptance Criteria:
    - Phone verification works with real backend
    - OTP validation via API
    - JWT token handling
    - Secure token storage
  - Estimated: 3-4 days

- [ ] **NFR-005**: Implement Error Handling & Loading States
  - Status: TODO
  - Priority: 🔴 HIGH
  - Description: Add try-catch blocks, loading indicators, error dialogs
  - Files to modify:
    - `lib/screens/auth/*.dart`
    - `lib/services/api_service.dart`
  - Acceptance Criteria:
    - Network errors handled gracefully
    - Loading indicators on all API calls
    - User-friendly error messages
    - Retry mechanisms
  - Estimated: 2-3 days

- [ ] **NFR-006**: Backend Integration - Products Provider
  - Status: TODO
  - Priority: 🔴 HIGH
  - Description: Connect product listing to real API
  - Files to modify:
    - `lib/providers/products_provider.dart`
    - `lib/services/api_service.dart`
  - Acceptance Criteria:
    - Fetch products from backend
    - Pagination support
    - Search/filter functionality
    - Category filter
  - Estimated: 3-4 days

- [ ] **NFR-007**: Form Validation Enhancement
  - Status: TODO
  - Priority: 🟡 MEDIUM
  - Description: Add comprehensive input validation across all forms
  - Files to modify:
    - `lib/screens/products/product_upload_screen.dart`
    - `lib/screens/auth/*.dart`
  - Acceptance Criteria:
    - Real-time validation
    - Clear error messages
    - Field highlighting on errors
  - Estimated: 2 days

---

### **👩‍💻 Kiara Evi**

#### ✅ COMPLETED TASKS

- [x] **KER-001**: Implement Producer Home Screen
  - Status: DONE
  - Description: Store dashboard, product management, order tracking
  - Completion: 100%

- [x] **KER-002**: Implement Admin Dashboard
  - Status: DONE
  - Description: Overview statistics, UMKM management, product verification
  - Completion: 100%

- [x] **KER-003**: Implement Image Upload Feature
  - Status: DONE
  - Description: Multi-photo upload, image picker, preview functionality
  - Completion: 100%

#### 🔄 IN PROGRESS / TODO TASKS

- [ ] **KER-004**: Backend Integration - Orders & Cart
  - Status: TODO
  - Priority: 🔴 HIGH
  - Description: Connect cart and order management to API
  - Files to modify:
    - `lib/services/api_service.dart`
    - `lib/providers/orders_provider.dart`
    - `lib/screens/cart/cart_screen.dart`
    - `lib/screens/orders/orders_screen.dart`
  - Acceptance Criteria:
    - Add to cart via API
    - Create order from cart
    - Order tracking with status updates
    - Order history display
    - Real-time order notifications
  - Estimated: 4-5 days

- [ ] **KER-005**: Backend Integration - Wallet & Payments
  - Status: TODO
  - Priority: 🔴 HIGH
  - Description: Implement wallet functionality and payment integration
  - Files to modify:
    - `lib/services/api_service.dart`
    - `lib/providers/wallet_provider.dart`
    - `lib/screens/wallet/wallet_screen.dart`
  - Acceptance Criteria:
    - Wallet balance display
    - Top-up functionality
    - Payment gateway integration
    - Transaction history
    - Balance updates real-time
  - Estimated: 3-4 days

- [ ] **KER-006**: Notifications System Integration
  - Status: TODO
  - Priority: 🟡 MEDIUM
  - Description: Connect Firebase notifications with backend
  - Files to modify:
    - `lib/services/notification_service.dart`
    - `lib/providers/notification_provider.dart`
    - `lib/screens/notifications/notifications_screen.dart`
  - Acceptance Criteria:
    - Push notifications received
    - Local notification display
    - Notification persistence
    - Mark as read functionality
  - Estimated: 2-3 days

- [ ] **KER-007**: Implement Profile Management
  - Status: TODO
  - Priority: 🟡 MEDIUM
  - Description: User profile update, preferences, settings
  - Files to modify:
    - `lib/services/api_service.dart`
    - `lib/screens/profile/*.dart`
  - Acceptance Criteria:
    - Edit profile information
    - Upload profile picture
    - Change password
    - Manage preferences
  - Estimated: 2-3 days

---

## 📋 Shared Tasks (Both Developers)

- [ ] **SHR-001**: Comprehensive Testing
  - Status: TODO
  - Priority: 🟡 MEDIUM
  - Description: Unit tests, widget tests, integration tests
  - Files: `test/` directory
  - Estimated: 3-4 days

- [ ] **SHR-002**: API Documentation & Constants
  - Status: IN PROGRESS
  - Priority: 🔴 HIGH
  - Description: Document all API endpoints and create constants
  - Files: `lib/config/constants.dart`
  - Estimated: 1 day

- [ ] **SHR-003**: Performance Optimization
  - Status: TODO
  - Priority: 🟡 MEDIUM
  - Description: Image optimization, caching, lazy loading
  - Estimated: 2-3 days

- [ ] **SHR-004**: Code Refactoring & Documentation
  - Status: TODO
  - Priority: 🟡 MEDIUM
  - Description: Add comments, improve code structure
  - Estimated: 2 days

---

## 🚨 Critical Issues

### 1. **API Service Not Connected** 🔴 CRITICAL
- **Status**: IN PROGRESS
- **Description**: `api_service.dart` exists but endpoints not implemented
- **Action Required**: Define all API endpoints with backend team
- **Assigned To**: Both (coordinate)

### 2. **No Error Handling** 🔴 CRITICAL
- **Status**: NOT STARTED
- **Description**: Missing try-catch blocks in providers
- **Action Required**: Add comprehensive error handling
- **Assigned To**: Naufal Al Faros

### 3. **Mock Data Still Used** 🟠 HIGH
- **Status**: IN PROGRESS
- **Description**: All screens using mock data, needs real API
- **Action Required**: Replace with real API calls
- **Assigned To**: Both (respective tasks)

---

## 📅 Timeline Estimate

| Phase | Duration | Status |
|-------|----------|--------|
| **Phase 1**: Core UI/Screens | DONE | ✅ |
| **Phase 2**: API Integration | 2-3 weeks | 🔄 |
| **Phase 3**: Error Handling & Testing | 1-2 weeks | ⏳ |
| **Phase 4**: Optimization & Polish | 1 week | ⏳ |

**Total Estimated Completion**: 4-6 weeks from now

---

## 📞 Coordination Notes

- **Weekly Sync**: Every Monday 10 AM
- **API Contract Review**: Complete before starting integration
- **Shared Folder**: `lib/services/` & `lib/config/` - coordinate changes
- **Communication**: Use GitHub Issues/PRs for detailed discussions

---

**Last Updated**: May 17, 2026  
**Next Review**: May 24, 2026
