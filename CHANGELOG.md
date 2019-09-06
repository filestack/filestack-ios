Change Log
==========

Version 2.1.1 *(2019-09-06)*
----------------------------

- Updated Cocoapod and Carthage dependency on `FilestackSDK` to `~> 2.1`.

Version 2.1 *(2019-09-05)*
----------------------------

- Restored Objective-C support.
- Minor documentation fixes.

Version 2.0.1 *(2019-07-25)*
----------------------------

- Added `sdkClient` to `Client` so the internal FilestackSDK client is exposed.
- Renamed `UrlExtractor` to `URLExtractor`.
- Renamed any leftover function names containing `Url` to `URL`.
- Fixed some Swift 5 warnings.
- Refactored demo project.

Version 2.0 *(2019-07-15)*
----------------------------

- Added upload progress handler to picker. To use it, please implement `pickerReportedUploadProgress(picker:, progress:)` on the picker delegate. (issue #44.)
- Added the ability to set up allowed UTIs for files picked from cloud sources by setting `cloudSourceAllowedUTIs` with list of allowed UTIs in config object. (issue #43.)
- Fixed `pickerStoredFile(picker:,response:)` was potentially being called before the upload monitor view controller was dismissed. (issue #40.)
- Fixed that project did not build in Xcode 10 using Swift 4.2 (issue #38.)
- Fixed picking pictures from camera source when multifile upload is enabled in config (e.g. `maximumSelectionAllowed > 1`) (issue #37.)
- Changed `LocalSource` static variables so they are publicly accessible (PR #41.)
- Fixed freezing of the main thread after selecting a Video with a big size (PR #55.)
- Significantly optimized memory usage during asset selection and editing when either multifile selection or editing is enabled.
- Dropped support for iOS versions earlier than 11.0.
- Dropped support for Swift versions earlier than 4.2.

Version 1.5.2 *(2018-10-19)*
----------------------------

- Fixed bug with dismissing picker after selecting assets for upload and before upload view shows up.

Version 1.5.1 *(2018-09-04)*
----------------------------

- Added Stylizer that allows changing colors, fonts, texts, and images.

Version 1.5.0 *(2018-08-07)*
----------------------------

- Added Image Editor.

Version 1.4.2 *(2018-06-17)*
----------------------------

- Moved OHHTTPStubs to Cartfile.private.

Version 1.4.1 *(2018-06-12)*
----------------------------

- Added possibility to change modalPresentationStyle of picker.

Version 1.4 *(2018-06-12)*
----------------------------

- Added possibility to upload multiple files at once.
- Create custom photo picker.
- Updated FilestackSDK dependency.

Version 1.3 *(2018-01-24)*
----------------------------

- Added the ability to notify the picker's delegate every time a cloud file is stored or a local file is uploaded into the destination storage location.

Version 1.2 *(2017-12-19)*
----------------------------

- Updated code to Swift 4.0.
- Updated FilestackSDK dependency.
- Added storyboard and xcasset resources to podspec.

Version 1.1 *(2017-12-04)*
----------------------------

- Adding support for uploading files picked using Apple's document picker either programmatically or using our provided picker.

Version 1.0 *(2017-11-23)*
----------------------------

Initial release.
