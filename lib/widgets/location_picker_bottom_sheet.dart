import 'dart:async';

import 'package:flutter/material.dart';

import 'package:us/models/place_suggestion.dart';
import 'package:us/services/place_search_service.dart';

class LocationPickerBottomSheet extends StatefulWidget {
  const LocationPickerBottomSheet({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<LocationPickerBottomSheet> createState() =>
      _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<LocationPickerBottomSheet> {
  late final TextEditingController _controller;
  late final PlaceSearchService _searchService;
  Timer? _debounce;
  List<PlaceSuggestion> _results = const [];
  bool _isLoading = false;
  bool _hasApiKey = true;

  static const _apiKey = String.fromEnvironment('KAKAO_REST_API_KEY');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _searchService = PlaceSearchService();
    _hasApiKey = _apiKey.isNotEmpty;
    if (_controller.text.isNotEmpty) {
      _search(_controller.text, immediate: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchService.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value);
    });
  }

  Future<void> _search(String value, {bool immediate = false}) async {
    if (!_hasApiKey) {
      setState(() {
        _results = const [];
      });
      return;
    }
    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
      });
      return;
    }
    if (!immediate) {
      setState(() => _isLoading = true);
    }
    final results = await _searchService.search(value);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                Text(
                  '위치 추가하기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: false,
              onTap: () => _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              ),
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: '장소를 입력하세요',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF6B7280),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_hasApiKey)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Kakao REST API 키가 설정되지 않았습니다. --dart-define=KAKAO_REST_API_KEY=키 형태로 빌드에 전달하세요.',
                  style: TextStyle(color: Color(0xFFB45309)),
                ),
              ),
            if (_hasApiKey)
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is UserScrollNotification) {
                      FocusScope.of(context).unfocus();
                    }
                    return false;
                  },
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _results.isEmpty
                      ? const Center(child: Text('검색 결과가 없습니다.'))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0xFFE5E7EB),
                          ),
                          itemBuilder: (context, index) {
                            final place = _results[index];
                            return ListTile(
                              onTap: () => Navigator.of(context).pop(place),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              title: Text(
                                place.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (place.roadAddress.isNotEmpty)
                                    Text(
                                      place.roadAddress,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  if (place.address.isNotEmpty)
                                    Text(
                                      place.address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[500]),
                                    ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black26,
                              ),
                            );
                          },
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
