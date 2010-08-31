
# Soundcloud API Wrapper

A wrapper on the [SoundCloud](http://soundcloud.com) API for Mac OS & iOS (Cocoa & Cocoa touch). It comes with the [JSON framework](http://github.com/stig/json-framework). This wrapper supports the [OAuth2](http://oauth.net/2) version of the API.

Make sure to have a look at the [wiki](http://wiki.github.com/soundcloud/cocoa-api-wrapper/). You'll find the documentation for version 1 there.

*README will be updated in the next days.*

## Quickstart

- git clone git://github.com/soundcloud/cocoa-api-wrapper.git
- cd cocoa-api-wrapper
- git checkout oauth2
- git submodule update --recursive --init

In your Xcode project:

- drag SoundCloudAPI.xcodeproj into your project
- add it as a build depedency
- add "/tmp/SoundCloudAPI.dst/usr/local/include" && "/tmp/JSON.dst/usr/local/include" to your user header search path in the build settings

## Addapting from version 1

*It's quite easy. Instructions will follow within the next days*
