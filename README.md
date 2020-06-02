# Miniflutt

Miniflutt is an Android client for [Miniflux](https://miniflux.app/) feed reader. It is free and
open source, without any advertisement or tracking whatsoever.

## Getting Started

Miniflutt requires Miniflux version >= [2.0.21](https://miniflux.app/releases/2.0.21.html).

1. Install the latest APK from the
   [releases page](https://github.com/DocMarty84/miniflutt/releases).
2. In Miniflux, create an API key in Settings / API Keys.
3. Open the app, go to the Settings page
4. Add the server URL and the token (do **not** include the `/v1` part of the URL endpoint)
5. Save and refresh!

The unread articles should appear in the app.

## Features

Miniflutt is still in development but implements the most common features for an RSS reader. Keep in
mind that this is a personal project which is moving forward depending on my free time. At the
moment, the following is supported:

- Dark theme available on night mode
- Supports video playback.
- Download most common files (documents, images and videos)
- Articles are grouped by categories / feeds.
- All articles from a category / feed can be marked as read.
- The original article can be opened in an external browser.
- Fetch read and/or unread articles
- Sort by date
- Set favorites
- Search articles
- Feed and category management

Limitations:

- Being online is required (no fetching for offline reading).
- No user management.
