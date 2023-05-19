# kvKit-Swift

![Swift 5.2](https://img.shields.io/badge/swift-5.2-green.svg)
![Linux](https://img.shields.io/badge/os-linux-green.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg)
![iOS](https://img.shields.io/badge/os-iOS-green.svg)

A collection of general purpose auxiliaries on Swift. For example:

- Specific collections.
- Task dispatching.
- Mathematical auxiliaries.
- UI.
- Bonjour.
- Compression.
- WebKit tasks.


## Supported Platforms

This package contains both crossplatform code and platform specific code.


## Getting Started

### Swift Tools 5.2+

#### Package Dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/keyvariable/kvKit-Swift.git", from: "3.2.1"),
]
```

#### Target Dependencies:

```swift
dependencies: [
    .product(name: "kvKit", package: "kvKit-Swift"),
]
```

### Xcode

Documentation: [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).


## Authors

- Svyatoslav Popov ([@sdpopov-keyvariable](https://github.com/sdpopov-keyvariable), [info@keyvar.com](mailto:info@keyvar.com)).
