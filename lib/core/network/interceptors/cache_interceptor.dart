import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';
import '../api_config.dart';

/// 简化的缓存项
class _CacheItem {
  final Response response;
  final DateTime expireTime;
  
  _CacheItem(this.response) : expireTime = DateTime.now().add(Duration(seconds: 30));
  
  bool get isExpired => DateTime.now().isAfter(expireTime);
}

/// 简化的缓存拦截器
/// 
/// 只缓存GET请求，2分钟过期
class CacheInterceptor extends Interceptor {
  final Map<String, _CacheItem> _cache = {};
  final int maxCacheSize;
  
  CacheInterceptor({this.maxCacheSize = 50});
  
  /// 创建短期缓存拦截器
  factory CacheInterceptor.shortTerm() => CacheInterceptor(maxCacheSize: 30);
  
  /// 创建长期缓存拦截器  
  factory CacheInterceptor.longTerm() => CacheInterceptor(maxCacheSize: 100);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 只缓存GET请求
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }
    
    final cacheKey = options.uri.toString();
    final cacheItem = _cache[cacheKey];
    
    // 检查缓存是否存在且未过期
    if (cacheItem != null && !cacheItem.isExpired) {
      if (ApiConfig.instance.enableLogging) {
        AppLogger.debug('💾 使用缓存: ${options.uri}');
      }
      
      handler.resolve(cacheItem.response);
      return;
    }
    
    // 清除过期缓存
    if (cacheItem != null && cacheItem.isExpired) {
      _cache.remove(cacheKey);
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 只缓存GET请求的成功响应
    if (response.requestOptions.method.toUpperCase() == 'GET' && 
        response.statusCode == 200) {
      
      final cacheKey = response.requestOptions.uri.toString();
      
      // 检查缓存大小限制
      if (_cache.length >= maxCacheSize) {
        _cache.remove(_cache.keys.first); // 移除最旧的
      }
      
      _cache[cacheKey] = _CacheItem(response);
      
      if (ApiConfig.instance.enableLogging) {
        AppLogger.debug('💾 缓存响应: ${response.requestOptions.uri}');
      }
    }
    
    handler.next(response);
  }
  
  /// 清除所有缓存
  void clearAllCache() {
    _cache.clear();
    if (ApiConfig.instance.enableLogging) {
      AppLogger.info('🗑️ 清除所有缓存');
    }
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    int validCount = 0;
    int expiredCount = 0;
    
    for (final item in _cache.values) {
      if (item.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }
    
    return {
      'total': _cache.length,
      'valid': validCount,
      'expired': expiredCount,
      'maxSize': maxCacheSize,
    };
  }
}
