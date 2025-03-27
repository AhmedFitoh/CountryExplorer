# Country Explorer

A SwiftUI application that allows users to search for countries, view their capital cities and currencies, and save up to 5 countries for quick access.

## Features

- Search for countries by name
- View country details (capital city and currency)
- Save up to 5 countries to the main view
- Automatically add the user's country based on GPS location
- Remove countries from the saved list
- Offline access to saved countries

## Technical Specifications

- Swift 5+
- SwiftUI for UI
- MVVM-C architecture
- Swift Concurrency for asynchronous operations
- CoreData for offline storage
- Unit tests with XCTest framework

## Architecture

The app follows the MVVM-C (Model-View-ViewModel with Coordinators) pattern:

## Dependencies

- REST Countries API: https://restcountries.com/v2/all
- CoreLocation for user's geolocation
- CoreData for local persistence
  
## Requirements
- iOS 18.0+
- Xcode 16.1+
- Swift 5.0+
  
## Setup Instructions

1. Clone the repository
2. Open CountryExplorer.xcodeproj in Xcode
3. Build and run on a device or simulator running iOS 15.0+

## Testing

Run the unit tests in Xcode by pressing ⌘+U or selecting Product > Test.

## License
This project is licensed under the MIT License - see the LICENSE file for details
