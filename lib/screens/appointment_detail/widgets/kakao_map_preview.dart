import 'package:flutter/material.dart';

import 'package:us/theme/us_colors.dart';

class KakaoMapPreview extends StatelessWidget {
  const KakaoMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });

  final double latitude;
  final double longitude;
  final String placeName;

  static const _apiKey = String.fromEnvironment('KAKAO_REST_API_KEY');

  @override
  Widget build(BuildContext context) {
    if (_apiKey.isEmpty) {
      return _FallbackNotice(
        message: 'Kakao REST API 키가 설정되지 않아 지도를 표시할 수 없습니다.',
      );
    }

    final url = Uri.https('map.kakao.com', '/staticmap.do', {
      'appkey': _apiKey,
      'center': '${longitude.toStringAsFixed(6)},${latitude.toStringAsFixed(6)}',
      'level': '3',
      'width': '720',
      'height': '360',
      'scale': '2',
      'markers': '${longitude.toStringAsFixed(6)},${latitude.toStringAsFixed(6)}',
    }).toString();

    print(url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.network(
            url,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) => const _FallbackNotice(
              message: '지도를 불러오지 못했습니다.',
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.55), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.place_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placeName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: UsColors.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
