# POI+
#### iOS App

POI+ is a simple and straightforward iPhone app that can add or edit exisiting nodes, ways and relations in [OpenStreetMap](http://openstreetmap.org)

You can find the app on the [App Store](https://itunes.apple.com/us/app/poi+-open-street-map-poi-editor/id518401562?ls=1&mt=8)

## Project Setup
`git clone git@github.com:davidchiles/osm-poi-editor-iOS.git
cd osm-poi-editor-iOS/
git submodule update --init --recursive`

change `OPEAPIConstants_example.h` to `OPEAPIConstants.h`

To use bing as a tile source or make edits to OpenStreetMap fill in the necessary fields in `OPEAPIConstants.h`

## Localization

Translate at [Transifex](https://www.transifex.com/projects/p/poi/resource/localizablestrings/)

![localization Progress](https://www.transifex.com/projects/p/poi/resource/localizablestrings/chart/image_png)

## Thrid-party Libraries

- [MBProgressHUD](https://github.com/jdg/MBProgressHUD)
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [gtm-oauth2](http://code.google.com/p/gtm-oauth2/)
- [TBXML](https://github.com/71squared/TBXML)
- [MapBox iOS SDK](https://github.com/mapbox/mapbox-ios-sdk)
- [Magical Record](https://github.com/magicalpanda/MagicalRecord)

## License
This software is available under the terms of the GNU GPLv3. [Full license terms](http://www.gnu.org/licenses/gpl.html)