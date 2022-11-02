# Networker

[![iOS Version](https://img.shields.io/badge/iOS_Version->=_14-brightgreen?logo=apple&logoColor=green)]()[![Swift Version](https://img.shields.io/badge/Swift_Version-5.0-brightgreen?logo=swift)](https://docs.swift.org/swift-book/)[![Supported devices](https://img.shields.io/badge/Supported_Devices-iPhone/iPad-brightgreen)]()
[![Dependency Manager](https://img.shields.io/badge/Dependency_Manager-SPM-brightgreen)](https://www.swift.org/package-manager/)

Networker is a complex API management solution built on Alamofire (https://github.com/Alamofire/Alamofire). The motivation was to create a scalable API manager focused on simplicity and the ability to cover all possible scenarios when building API infrastructure into a project.

# Key Features

1. Console logger for requests and responses
2. Single file endpoints declaration
3. Combine flow

# Installation 

## Swift Package Manager

Copy link and add it into:

``XCode -> Swift Packages -> Add Package Dependecy``

If you have Package.swift, simple copy:

```ruby
    dependencies: [
        .package(url: "https://github.com/ace4seven/Networker", from: "0.0.1")
    ],
```

# Usage

By default console logger is set in the **INFO**. To change the log level, just write the following code.

```swift
NetworkerConfiguration.logLevel = .info
```

## Log Levels: 

1. **Info** - Prints request url with response status and error when occurs.
2. **Error** -  Prints only when error occurs.
3. **Verbose** - Prints everything including request body and response object

## Endpoint Type

It is recommended to group all endpoints into a single enum file, which implements EndpointType protocol and define required attributes.

```swift
protocol EndpointType {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Encodable? { get }
    var parameters: Encodable? { get }
    var headers: HTTPHeaders? { get }

    func baseUrl() throws -> URL
}
```
- **Path** represent the second part of baseURL string 
- **Method** - GET, POST, UPDATE, DELETE, PATCH ... [https://www.rfc-editor.org/rfc/rfc7231#section-4.3]
- **Query parameters**, encoded into URL
- **Parameters** cover body parameters
- **Headers** for HTTP headers

## Endpoint implementation

```swift
enum Endpoint: EndpointType {

    case swapiPlanets

    var path: String {
        switch self {
        case .swapiPlanets: return "planets"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .swapiPlanets: return .get
        }
    }

    func baseUrl() throws -> URL {
        switch self {
        case .swapiPlanets: return try "https://swapi.dev/api/".asURL()
        }
    }
}
```

---

## Networker

The class is a wrapper for the Alamofire session object with a powerful call method, which transforms endpoint type into AnyPublisher containing Output as a Decodable object and Error object. Async await is also supported.

### Combine publisher usage

```swift
private let networker = Networker<Endpoint>()

func getPlantets() -> AnyPublisher<PlanetsDto, Error> {
    networker
        .call(endpoint: .swapiPlanets)
}
```

### Async await usage

```swift
private let networker = Networker<Endpoint>()

func getPlantets() async -> Result<PlanetsDto, Error> {
    await networker
        .call(endpoint: .swapiPlanets)
}
```
> **Info**
> Error is Alamofire error - AFError

---

## API Result

API Resul is a enum which control lifecycle of the request progress.

**ApiResult.created** - idle state

**ApiResult.loading** - loading state, called immediately after a request is called

**ApiResult.loaded** - loaded state containing response object (200..<400 response codes)

**ApiResult.error** - error state containing AFError object (400+ response codes)

### Example

```swift
func getPlantets() -> AnyPublisher<ApiResult<PlanetsDto, Error>, Never> {
    networker
        .call(endpoint: .swapiPlanets)
        .mapToApiResult()
}
```