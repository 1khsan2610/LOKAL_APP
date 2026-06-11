<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Order;
use App\Models\UmkmProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Exception;

class AdminController extends Controller
{
    /**
     * Check if user is admin
     */
    protected function isAdmin(Request $request): bool
    {
        return auth('sanctum')->check() && auth('sanctum')->user()?->role === 'admin';
    }

    /**
     * Get admin dashboard statistics
     */
    public function dashboardStats(Request $request): JsonResponse
    {
        try {
            if (!$this->isAdmin($request)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }

            $totalUsers = User::where('role', '!=', 'admin')->count();
            $totalConsumers = User::where('role', 'consumer')->count();
            $totalUmkm = User::where('role', 'umkm')->count();
            $totalOrders = Order::count();
            $totalRevenue = Order::where('status', 'completed')->sum('total_price');
            $pendingUmkm = UmkmProfile::where('status', 'pending_verification')->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'users' => [
                        'total' => $totalUsers,
                        'consumers' => $totalConsumers,
                        'umkm' => $totalUmkm,
                    ],
                    'orders' => [
                        'total' => $totalOrders,
                        'total_revenue' => $totalRevenue,
                    ],
                    'pending' => [
                        'umkm_verification' => $pendingUmkm,
                    ],
                ],
            ], 200);
        } catch (Exception $e) {
            \Log::error('Admin dashboard error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error fetching dashboard data: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all users with pagination
     */
    public function users(Request $request): JsonResponse
    {
        try {
            if (!$this->isAdmin($request)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }

            $perPage = $request->query('per_page', 20);
            $search = $request->query('search', '');
            $role = $request->query('role', '');

            $query = User::where('role', '!=', 'admin');

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('phone_number', 'like', "%{$search}%");
                });
            }

            if ($role && in_array($role, ['consumer', 'umkm'])) {
                $query->where('role', $role);
            }

            $users = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $users->items(),
                'pagination' => [
                    'total' => $users->total(),
                    'per_page' => $users->perPage(),
                    'current_page' => $users->currentPage(),
                    'last_page' => $users->lastPage(),
                ],
            ], 200);
        } catch (Exception $e) {
            \Log::error('Admin get users error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error fetching users: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Deactivate user account
     */
    public function deactivateUser(Request $request, string $userId): JsonResponse
    {
        try {
            if (!$this->isAdmin($request)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }

            $user = User::find($userId);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not found.',
                ], 404);
            }

            if ($user->role === 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot deactivate admin accounts.',
                ], 422);
            }

            $user->delete(); // Soft delete

            \Log::info('User deactivated by admin', [
                'user_id' => $user->id,
                'admin_id' => auth('sanctum')->id(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User account deactivated successfully.',
            ], 200);
        } catch (Exception $e) {
            \Log::error('Deactivate user error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error deactivating user: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get pending UMKM verification list
     */
    public function pendingUmkm(Request $request): JsonResponse
    {
        try {
            if (!$this->isAdmin($request)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }

            $perPage = $request->query('per_page', 20);

            $umkms = UmkmProfile::with('user')
                ->where('status', 'pending_verification')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $umkms->items(),
                'pagination' => [
                    'total' => $umkms->total(),
                    'per_page' => $umkms->perPage(),
                    'current_page' => $umkms->currentPage(),
                    'last_page' => $umkms->lastPage(),
                ],
            ], 200);
        } catch (Exception $e) {
            \Log::error('Get pending UMKM error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error fetching pending UMKM: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Approve UMKM verification
     */
    public function approveUmkm(Request $request, string $umkmId): JsonResponse
    {
        try {
            if (!$this->isAdmin($request)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }

            $umkm = UmkmProfile::find($umkmId);

            if (!$umkm) {
                return response()->json([
                    'success' => false,
                    'message' => 'UMKM not found.',
                ], 404);
            }

            $umkm->update([
                'status' => 'active',
                'is_verified' => true,
                'verified_at' => now(),
            ]);

            \Log::info('UMKM verified by admin', [
                'umkm_id' => $umkm->id,
                'admin_id' => auth('sanctum')->id(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'UMKM verified successfully.',
                'data' => $umkm,
            ], 200);
        } catch (Exception $e) {
            \Log::error('Approve UMKM error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error approving UMKM: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reject UMKM verification
     */
    public function rejectUmkm(Request $request, string $umkmId): JsonResponse
    {
        try {
            if (!$this->isAdmin($request)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Admin access required.',
                ], 403);
            }

            $validated = $request->validate([
                'reason' => 'required|string|min:10',
            ]);

            $umkm = UmkmProfile::find($umkmId);

            if (!$umkm) {
                return response()->json([
                    'success' => false,
                    'message' => 'UMKM not found.',
                ], 404);
            }

            $umkm->update([
                'status' => 'rejected',
                'is_verified' => false,
                'rejection_reason' => $validated['reason'],
                'rejected_at' => now(),
            ]);

            \Log::info('UMKM rejected by admin', [
                'umkm_id' => $umkm->id,
                'admin_id' => auth('sanctum')->id(),
                'reason' => $validated['reason'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'UMKM rejected successfully.',
                'data' => $umkm,
            ], 200);
        } catch (Exception $e) {
            \Log::error('Reject UMKM error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error rejecting UMKM: ' . $e->getMessage(),
            ], 500);
        }
    }
}
