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

At the moment, Miniflutt is on an early development stage. Therefore, it implements a limited number
of features. They will be developed in the coming weeks or months, depending on my free time.

- Supports video playback.
- Articles are grouped categories / feeds.
- All articles from a category / feed can be marked as read.
- The original article can be opened in an external browser.

Limitations:

- Being online is required (no fetching for offline reading).
- Only unread articles are fetched, but read articles are kept until refresh.
- No sorting.
- No category, feed or user management.
- No favorites.
- No search.
- No themes.
