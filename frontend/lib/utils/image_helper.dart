import '../services/api_service.dart';

String resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';

  // The storage proxy route is inside the API prefix
  // Route::get('/image/{path}...) in api.php is at {base}/image/{path}
  final base = ApiService.baseUrl;
  final storageProxy = '$base/image/';
  
  // If it's already a complete proxy URL, return as-is
  if (trimmed.startsWith(storageProxy)) return trimmed;
  
  // Try parsing as URI to detect scheme
  final uri = Uri.tryParse(trimmed);
  
  if (uri != null && uri.hasScheme) {
    // It's an absolute URL with scheme (http/https/file/etc)
    final lower = trimmed.toLowerCase();
    final storageIndex = lower.indexOf('/storage/');
    
    if (storageIndex >= 0) {
      // Extract path after '/storage/' and proxy through API
      final path = trimmed.substring(storageIndex + '/storage/'.length);
      return '$storageProxy$path';
    }
    
    // If it's already http/https and not a storage URL, return as-is
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
  }

  // Handle relative paths (starting with /)
  if (trimmed.startsWith('/storage/')) {
    final path = trimmed.substring('/storage/'.length);
    return '$storageProxy$path';
  }
  
  // Handle relative paths (storage/ without leading /)
  if (trimmed.startsWith('storage/')) {
    final path = trimmed.substring('storage/'.length);
    return '$storageProxy$path';
  }
  
  // For any other case, assume it's a relative path under storage/
  // This handles cases where the URL is just a filename or partial path
  return '$storageProxy$trimmed';
}

