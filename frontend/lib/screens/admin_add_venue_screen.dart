import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
import '../models/review.dart';
import '../models/tag.dart';
import '../models/venue.dart';
import '../services/api_client.dart';
import '../services/auth_exception.dart';
import '../theme/gri_theme.dart';
import '../utils/maps_url_parser.dart';

class AdminAddVenueScreen extends StatefulWidget {
  const AdminAddVenueScreen({this.venue, super.key});

  final Venue? venue;

  bool get isEditing => venue != null;

  @override
  State<AdminAddVenueScreen> createState() => _AdminAddVenueScreenState();
}

class _AdminAddVenueScreenState extends State<AdminAddVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();

  late final TextEditingController _nameController;
  late final TextEditingController _mapsUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _extraImageUrlsController;

  MapsCoordinates? _parsedCoordinates;

  late String _area;
  late String _priceBand;
  final Set<String> _selectedTagIds = {};
  List<Tag> _productTags = const [];
  bool _isLoadingTags = true;
  bool _isSubmitting = false;
  bool _isLoadingReviews = false;
  String? _error;
  String? _reviewsError;
  String? _deletingReviewId;
  List<Review> _venueReviews = const [];

  static const _priceBands = ['₺', '₺₺', '₺₺₺'];

  @override
  void initState() {
    super.initState();
    final venue = widget.venue;
    _nameController = TextEditingController(text: venue?.name ?? '');
    final initialMapsUrl = venue?.mapsUrl?.isNotEmpty == true
        ? venue!.mapsUrl!
        : venue != null
            ? buildGoogleMapsUrl(lat: venue.lat, lng: venue.lng)
            : '';
    _mapsUrlController = TextEditingController(text: initialMapsUrl);
    _descriptionController = TextEditingController(text: venue?.description ?? '');
    final gallery = venue?.galleryImages ?? const [];
    _imageUrlController = TextEditingController(text: gallery.isNotEmpty ? gallery.first : venue?.imageUrl ?? '');
    _extraImageUrlsController = TextEditingController(
      text: gallery.length > 1 ? gallery.skip(1).join('\n') : '',
    );
    _parsedCoordinates = parseGoogleMapsUrl(initialMapsUrl);
    _area = venue?.area ?? VenueFilters.locations.first;
    _priceBand = venue?.priceBand ?? '₺₺';
    if (venue != null) {
      _selectedTagIds.addAll(venue.tagIds);
    }
    _loadTags();
    if (widget.isEditing) {
      _loadVenueReviews();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapsUrlController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _extraImageUrlsController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _api.fetchTags();
      if (!mounted) return;
      setState(() {
        _productTags = tags.where((tag) => tag.type == TagType.product).toList();
        _isLoadingTags = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = '$err';
        _isLoadingTags = false;
      });
    }
  }

  void _onMapsUrlChanged(String value) {
    setState(() => _parsedCoordinates = parseGoogleMapsUrl(value));
  }

  Future<void> _loadVenueReviews() async {
    final venue = widget.venue;
    if (venue == null) return;

    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });
    try {
      final reviews = await _api.fetchAdminVenueReviews(venue.id);
      if (!mounted) return;
      setState(() => _venueReviews = reviews);
    } catch (err) {
      if (!mounted) return;
      setState(() => _reviewsError = '$err');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _confirmDeleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu sil'),
        content: const Text('Bu yorum kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: GriColors.errorText),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingReviewId = review.id);
    try {
      await _api.deleteReview(review.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum silindi.')),
      );
      await _loadVenueReviews();
    } on AuthException catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
    } finally {
      if (mounted) setState(() => _deletingReviewId = null);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTagIds.isEmpty) {
      setState(() => _error = 'En az bir kategori seçin.');
      return;
    }

    final mapsUrl = _mapsUrlController.text.trim();
    final coordinates = parseGoogleMapsUrl(mapsUrl);
    if (coordinates == null) {
      setState(() => _error = 'Google Maps linkinden konum okunamadı.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final extraImageUrls = _extraImageUrlsController.text
          .split(RegExp(r'[\n,]+'))
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();
      final payload = (
        name: _nameController.text.trim(),
        area: _area,
        lat: coordinates.lat,
        lng: coordinates.lng,
        description: _descriptionController.text.trim(),
        tagIds: _selectedTagIds.toList(),
        priceBand: _priceBand,
        imageUrl: _imageUrlController.text.trim(),
        imageUrls: extraImageUrls,
        mapsUrl: mapsUrl,
      );

      if (widget.isEditing) {
        await _api.updateVenue(
          venueId: widget.venue!.id,
          name: payload.name,
          area: payload.area,
          lat: payload.lat,
          lng: payload.lng,
          description: payload.description,
          tagIds: payload.tagIds,
          priceBand: payload.priceBand,
          imageUrl: payload.imageUrl,
          imageUrls: payload.imageUrls,
          mapsUrl: payload.mapsUrl,
        );
      } else {
        await _api.createVenue(
          name: payload.name,
          area: payload.area,
          lat: payload.lat,
          lng: payload.lng,
          description: payload.description,
          tagIds: payload.tagIds,
          priceBand: payload.priceBand,
          imageUrl: payload.imageUrl,
          imageUrls: payload.imageUrls,
          mapsUrl: payload.mapsUrl,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Mekan güncellendi.' : 'Mekan başarıyla eklendi.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() => _error = err.message);
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = '$err');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriColors.bg,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Mekan Düzenle' : 'Mekan Ekle'),
        backgroundColor: GriColors.bg,
        foregroundColor: GriColors.primary,
        elevation: 0,
      ),
      body: _isLoadingTags
          ? const Center(child: CircularProgressIndicator(color: GriColors.muted))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(GriSpacing.sp6),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('MEKAN ADI'),
                    const SizedBox(height: GriSpacing.sp2),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Örn: Kütüphane Kafe'),
                      validator: (v) =>
                          v == null || v.trim().length < 2 ? 'Mekan adı gerekli' : null,
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    _label('SEMT'),
                    const SizedBox(height: GriSpacing.sp2),
                    Wrap(
                      spacing: GriSpacing.sp2,
                      children: VenueFilters.locations.map((area) {
                        final selected = _area == area;
                        return ChoiceChip(
                          label: Text(area),
                          selected: selected,
                          onSelected: (_) => setState(() => _area = area),
                          selectedColor: GriColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? GriColors.onPrimary : GriColors.secondary,
                          ),
                          side: BorderSide(
                            color: selected ? GriColors.primary : GriColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GriRadii.full),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    _label('KATEGORİ'),
                    const SizedBox(height: GriSpacing.sp2),
                    Wrap(
                      spacing: GriSpacing.sp2,
                      runSpacing: GriSpacing.sp2,
                      children: _productTags.map((tag) {
                        final selected = _selectedTagIds.contains(tag.id);
                        return FilterChip(
                          label: Text(tag.name),
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _selectedTagIds.add(tag.id);
                              } else {
                                _selectedTagIds.remove(tag.id);
                              }
                            });
                          },
                          selectedColor: GriColors.primary,
                          checkmarkColor: GriColors.onPrimary,
                          labelStyle: TextStyle(
                            color: selected ? GriColors.onPrimary : GriColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: selected ? GriColors.primary : GriColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GriRadii.full),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    _label('FİYAT'),
                    const SizedBox(height: GriSpacing.sp2),
                    Wrap(
                      spacing: GriSpacing.sp2,
                      children: _priceBands.map((band) {
                        final selected = _priceBand == band;
                        return ChoiceChip(
                          label: Text(band),
                          selected: selected,
                          onSelected: (_) => setState(() => _priceBand = band),
                          selectedColor: GriColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? GriColors.onPrimary : GriColors.secondary,
                          ),
                          side: BorderSide(
                            color: selected ? GriColors.primary : GriColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GriRadii.full),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    _label('GOOGLE MAPS LİNKİ'),
                    const SizedBox(height: GriSpacing.sp2),
                    TextFormField(
                      controller: _mapsUrlController,
                      keyboardType: TextInputType.url,
                      onChanged: _onMapsUrlChanged,
                      decoration: const InputDecoration(
                        hintText: 'https://www.google.com/maps/...',
                        prefixIcon: Icon(Icons.map_outlined, color: GriColors.muted),
                      ),
                      validator: validateGoogleMapsUrl,
                    ),
                    if (_parsedCoordinates != null) ...[
                      const SizedBox(height: GriSpacing.sp2),
                      Text(
                        'Konum: ${_parsedCoordinates!.lat.toStringAsFixed(5)}, '
                        '${_parsedCoordinates!.lng.toStringAsFixed(5)}',
                        style: GriTheme.caption(),
                      ),
                    ],
                    const SizedBox(height: GriSpacing.sp5),
                    _label('AÇIKLAMA'),
                    const SizedBox(height: GriSpacing.sp2),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Mekan hakkında kısa açıklama',
                      ),
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    _label('FOTOĞRAF URL'),
                    const SizedBox(height: GriSpacing.sp2),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        hintText: 'https://... (kapak fotoğrafı)',
                      ),
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    _label('EK FOTOĞRAF URL\'LERİ'),
                    const SizedBox(height: GriSpacing.sp2),
                    TextFormField(
                      controller: _extraImageUrlsController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Her satıra bir URL (isteğe bağlı)',
                      ),
                    ),
                    if (widget.isEditing) ...[
                      const SizedBox(height: GriSpacing.sp8),
                      Text('Mekan Yorumları', style: GriTheme.h3()),
                      const SizedBox(height: GriSpacing.sp3),
                      _buildVenueReviewsSection(),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: GriSpacing.sp4),
                      Container(
                        padding: const EdgeInsets.all(GriSpacing.sp3),
                        decoration: BoxDecoration(
                          color: GriColors.errorBg,
                          borderRadius: BorderRadius.circular(GriRadii.md),
                        ),
                        child: Text(
                          _error!,
                          style: GriTheme.body().copyWith(color: GriColors.errorText),
                        ),
                      ),
                    ],
                    const SizedBox(height: GriSpacing.sp8),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: GriColors.primary,
                        foregroundColor: GriColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GriRadii.full),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: GriColors.onPrimary,
                              ),
                            )
                          : Text(widget.isEditing ? 'Güncelle' : 'Kaydet'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: Theme.of(context).inputDecorationTheme.labelStyle);
  }

  Widget _buildVenueReviewsSection() {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: GriSpacing.sp4),
        child: Center(child: CircularProgressIndicator(color: GriColors.muted)),
      );
    }

    if (_reviewsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_reviewsError!, style: GriTheme.caption().copyWith(color: GriColors.errorText)),
          TextButton(onPressed: _loadVenueReviews, child: const Text('Tekrar dene')),
        ],
      );
    }

    if (_venueReviews.isEmpty) {
      return Text('Bu mekana ait yorum yok.', style: GriTheme.caption());
    }

    return Column(
      children: [
        for (var i = 0; i < _venueReviews.length; i++) ...[
          _AdminVenueReviewTile(
            review: _venueReviews[i],
            isDeleting: _deletingReviewId == _venueReviews[i].id,
            onDelete: () => _confirmDeleteReview(_venueReviews[i]),
          ),
          if (i < _venueReviews.length - 1) const SizedBox(height: GriSpacing.sp3),
        ],
      ],
    );
  }
}

class _AdminVenueReviewTile extends StatelessWidget {
  const _AdminVenueReviewTile({
    required this.review,
    required this.isDeleting,
    required this.onDelete,
  });

  final Review review;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GriSpacing.sp4),
      decoration: BoxDecoration(
        color: GriColors.onPrimary,
        borderRadius: BorderRadius.circular(GriRadii.lg),
        border: Border.all(color: GriColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${review.displayName} (@${review.username})',
                  style: GriTheme.h3().copyWith(fontSize: 14),
                ),
              ),
              _ReviewStatusChip(status: review.status),
            ],
          ),
          const SizedBox(height: GriSpacing.sp2),
          Text(review.text, style: GriTheme.body()),
          const SizedBox(height: GriSpacing.sp3),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: isDeleting ? null : onDelete,
              icon: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, size: 18),
              label: const Text('Sil'),
              style: TextButton.styleFrom(foregroundColor: GriColors.errorText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStatusChip extends StatelessWidget {
  const _ReviewStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved' => ('Onaylı', GriColors.primary),
      'pending' => ('Bekliyor', GriColors.secondary),
      'rejected' => ('Reddedildi', GriColors.errorText),
      _ => (status, GriColors.muted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GriRadii.full),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GriTheme.caption().copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
