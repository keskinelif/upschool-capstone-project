def normalize_venue_dict(venue: dict) -> dict:
    urls = list(venue.get("image_urls") or [])
    if not urls:
        primary = venue.get("image_url")
        if primary:
            urls = [primary]
    urls = [url.strip() for url in urls if isinstance(url, str) and url.strip()]
    venue["image_urls"] = urls
    venue["image_url"] = urls[0] if urls else None
    return venue
