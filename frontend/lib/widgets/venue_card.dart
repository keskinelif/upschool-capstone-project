import 'package:flutter/material.dart';

import '../models/venue.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({
    required this.venue,
    super.key,
  });

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(venue.name),
        subtitle: Text('${venue.area} · ${venue.priceBand}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
