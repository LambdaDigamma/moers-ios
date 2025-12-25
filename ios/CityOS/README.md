# EFAAPI

Request transit data of german public transport services using the EFA-XML format.
This package can deal with EFA-XML format.

> This package is only in its first stages. 
> Not all features are implemented yet, so feel free to contribute.

## Installation

This package contains two separate libraries. `EFAAPI` contains all necessary code to perform transit requests.
`EFAUI` provides some basic SwiftUI views and view models to present results of
responses from the `EFAAPI` library. `EFAUI` depends on the other library because it uses types of it.

Install `EFAAPI` with Swift Package Manager:

```swift
dependencies: [
    .package(name: "EFAAPI", url: "https://github.com/LambdaDigamma/efaapi-ios", .upToNextMajor(from: "1.0.0")),
]
```

## Getting started

### Setup your environment

To get started you first need to create an environment and a  for your transit provider.
This is a bit longer because of the networking setup needed for this package.

```swift
let environment = ServerEnvironment(scheme: "https", host: "openservice-test.vrr.de", pathPrefix: "/static02")

let resetGuard = ResetGuardLoader()
let applyEnvironment = ApplyEnvironmentLoader(environment: environment)
let session = URLSession(configuration: .default)
let sessionLoader = URLSessionLoader(session)

let loader = (resetGuard --> applyEnvironment --> printLoader --> sessionLoader)!
let service = DefaultTransitService(loader: loader)
```

There are two implementations of the `TransitService` protocol. 
Use the `DefaultTransitService` to load real-time data from your selected provider or use the `StaticTransitService` for testing or mocking context.
Also the used networking structure makes it easy to mock a response with a mocked loader instead of the example networking configuration.
See the tests of this package to learn how to do it.

It's recommended to only use one instance of `TransitService` so just inject this service everywhere where you need it.

### Your first transit request

The most basic request is the so called `StopFinderRequest`. 
It's used to find a location based on a given name and returns stops, streets, crossings, points of interest, etc.
You can also specify an `ObjectFilter` to limit your search to return only a specific set of location types.

```swift
// Find streets and stops of name "Musterstraße"
transitService.findTransitLocation(for: "Musterstraße", filtering: [.streets, .stops])
```

It returns a failable Combine publisher of an array of `TransitLocation` which you have to handle. 
You can think of them like view models, because it's likely that you want to show them in some kind of list right away.

> You don't want to get view models? Just use raw requests which return the pure API data.


## Supported data providers

Some public transport services use this format as their data exchange format.
Feel free to add services that can be used with this package.

**You have to consult the licence agreements of each provider.**

* Verkehrsverbund Rhein-Ruhr ([Endpoint & Licence](https://www.opendata-oepnv.de/ht/de/organisation/verkehrsverbuende/vrr/openvrr/api))
