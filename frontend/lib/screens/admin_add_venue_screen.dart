import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
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

  MapsCoordinates? _parsedCoordinates;

  late String _area;
  late String _priceBand;
  final Set<String> _selectedTagIds = {};
  List<Tag> _productTags = const [];
  bool _isLoadingTags = true;
  bool _isSubmitting = false;
  String? _error;

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
    _imageUrlController = TextEditingController(text: venue?.imageUrl ?? '');
    _parsedCoordinates = parseGoogleMapsUrl(initialMapsUrl);
    _area = venue?.area ?? VenueFilters.locations.first;
    _priceBand = venue?.priceBand ?? '₺₺';
    if (venue != null) {
      _selectedTagIds.addAll(venue.tagIds);
    }
    _loadTags();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapsUrlController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
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
      final payload = (
        name: _nameController.text.trim(),
        area: _area,
        lat: coordinates.lat,
        lng: coordinates.lng,
        description: _descriptionController.text.trim(),
        tagIds: _selectedTagIds.toList(),
        priceBand: _priceBand,
        imageUrl: _imageUrlController.text.trim(),
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
                        hintText: 'https://...',
                      ),
                    ),
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
}
