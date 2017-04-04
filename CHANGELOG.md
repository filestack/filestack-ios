## 0.3.7 (2017-04-04)

### Fixed:

- Removed AFNetworkingActivityLogger dependency

## 0.3.6 (2017-03-20)

### Added:

- ```upload``` method for multi-part uploads.

## 0.3.5 (2017-01-16)

### Fixed:

- Conflicting nullability specifier on return types.

## 0.3.4 (2017-01-12)

### Added:

- ```internalURL``` property to FSBlob. Used by FSPicker only.

## 0.3.3 (2017-01-10)

### Added:

- ```remove```, ```pickURL``` and ```download``` methods now accept ```FSSecurity``` object as parameter.

## 0.3.2 (2016-05-27)

### Added:

- Export method used by ```FSPicker```.

## 0.3.1 (2016-05-16)

### Fixed:
- FSStoreOptions's ```path``` property, should now work as intended.

## 0.3.0 (2016-05-06)

### Added:
- ```FSPicker``` specific methods.

## 0.2.10 (2016-03-04)

### Changed:
- Remove use of accessors in init methods.
- Use ```copy``` instead of ```strong``` for classes with mutable counterparts.

## 0.2.7 (2016-02-19)

### Added:

- ```store:withOptions:completionHandler:``` now also accepts ```progress``` argument.

## 0.2.6 (2016-02-18)

### Added

- FSURLScreenshot and FSASCII available properties and initializers after backend changes.

## 0.2.5 (2016-02-18)

### Added:

- FSTransformation tests.

### Fixed:

- ```[FSStatOptions toQueryParameters]``` should now properly set filename and mimetype.

## 0.2.4 (2016-02-17)

### Added:

- Complete FSTransforms tests.

### Fixed:

- Few transformations' properties are now of correct type and correctly serialized to query string.

## 0.2.3 (2016-02-16)

### Added:

- Part of the missing transformations tests.

### Fixed:

- Few transformations' properties are now of correct type and correctly serialized to query string.

## 0.2.0 (2016-02-12)

### Initial Filestack's Transformations release.

## 0.1.4 (2016-02-03)

### Fixed:

- completionHandler parameter is now optional in all of Filestack's methods (passing ```nil``` won't crash the lib).

## 0.1.3 (2016-02-03)

### Fixed:

- FSBlob's ```writeable``` should now properly return ```0```, ```1``` or ```nil``` value.

## 0.1.2 (2016-02-03)

### Initial release
