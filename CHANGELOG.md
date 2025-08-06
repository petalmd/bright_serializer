# Changelog

> [!NOTE]
For newer versions see [GitHub releases](https://github.com/petalmd/bright_serializer/releases).

## 0.5.2 (2023-09-19)

* Handle nil in array ([#113](https://github.com/petalmd/bright_serializer/pull/113))

## 0.5.1 (2024-04-05)

* Better handle of ActiveSupport::Notifications defined? ([#111](https://github.com/petalmd/bright_serializer/pull/111))

## 0.5.0 (2024-03-24)

* Add active support dependencies and handle args and keyword ([#107](https://github.com/petalmd/bright_serializer/pull/107))
* Add support and build for Ruby 3.X ([#91](https://github.com/petalmd/bright_serializer/pull/91))
* Return nil when element to serialize is nil ([#105](https://github.com/petalmd/bright_serializer/pull/105))

## 0.4.1 (2022-04-10)

* Add deprecation warning for serialize nil object. See [issue #103](https://github.com/petalmd/bright_serializer/issues/103). ([v0.4.0...v0.4.1](https://github.com/petalmd/bright_serializer/compare/v0.4.0...v0.4.1))

## 0.4.0 (2022-11-10)

* Added relation helper methods `has_one`, `has_many`, `belongs_to` ([#49](https://github.com/petalmd/bright_serializer/pull/49))
* Performance improvements, save in instance attributes to serialize. ([#100](https://github.com/petalmd/bright_serializer/pull/100))
* Performance improvements, calculate attributes to serialize only once. ([#98](https://github.com/petalmd/bright_serializer/pull/98))
* Add instrumentation. ([#90](https://github.com/petalmd/bright_serializer/pull/90))

## 0.3.1 (2022-09-28)

* Performance improvements, use nil instead of empty set. ([#97](https://github.com/petalmd/bright_serializer/pull/97))
* Move specs out of lib. ([#96](https://github.com/petalmd/bright_serializer/pull/96))

## 0.3.0 (2022-05-26)

* Allow to evaluate entity values with a callable lambda. ([#88](https://github.com/petalmd/bright_serializer/pull/88))
* Fix `FrozenError (can't modify frozen Array)` when parsing entity. ([#83](https://github.com/petalmd/bright_serializer/pull/83))
* Added the support to use instance methods from a serializer class in the library ([#85](https://github.com/petalmd/bright_serializer/pull/85))
* Use real coveralls_reborn gem

## 0.2.5 (2021-03-08)

* When serializing an Hash, check present of the key before trying string ([#57](https://github.com/petalmd/bright_serializer/pull/57))

## 0.2.4 (2021-02-19)

* Try symbol and string keys when the object to serialize is an Hash ([#54](https://github.com/petalmd/bright_serializer/pull/54))

## 0.2.3 (2021-01-04)

* Update dependencies ([v0.2.2...v0.2.3](https://github.com/petalmd/bright_serializer/compare/v0.2.2...v0.2.3))

## 0.2.2 (2020-07-22)

* Run CI build on all supported Ruby versions ([#11](https://github.com/petalmd/bright_serializer/pull/11))
* Update Rubocop 0.78.0 => 0.88.0 and run auto-correction
* Deep transform entity keys ([#12](https://github.com/petalmd/bright_serializer/pull/12))

## 0.2.1 (2020-07-21)

* Handle set_key_transform inherited from a parent serializer ([#10](https://github.com/petalmd/bright_serializer/pull/10))

## 0.2.0 (2020-07-17)

* Add RubyGems version badge
* Handle inherit from a parent serializer
* Define entity in serializer for grape_swagger ([#9](https://github.com/petalmd/bright_serializer/pull/9))

## 0.1.1 (2020-07-13)

* Add description in gemspec file
* Add content in CHANGELOG.md

## 0.1.0 (2020-07-13)

* First release
