# Lit Native

Reuse lit web components on native platforms.

## Supported Platforms

- iOS
- MacOS
- Android

## Getting Started

1. `npm run install`
2. `npm run build`
3. Open target folder (i.e. ios, android)
4. Run project

## Background

When you build and ship your site with web components you may want to reuse the self contained views in more places.

This does not "convert my site to an app" but rather let you recompose the app on the native side using native navigation structures and the web components for the views and content.

The content is fast and is loaded offline, there is no node js or js runtime for a bridge. The web view communicates directly with the native code on the platform. The native code can communicate back to the webview and this is done using events.

The idea is to progressively enhance your application by adding functionality where the events can be handled (i.e. in app purchase, push notifications).

This also unlocks the possibility of using WebGL for 3D applications or sandbox your app and only explicitly supporting the events you write.

The downside is the knowledge required for the native platforms (kotlin/swift) but the benefits are no framework, no dependencies and freedom to compose the app however needed.

## Screenshots

![](/screenshots/ios.png)
![](/screenshots/macos.png)
![](/screenshots/android.png)
