# Trekko Backend

## Introduction

`Trekko` is a comprehensive interface designed for managing user profiles, trips, and tracking
information in Flutter applications. This interface offers a variety of methods to perform
operations like initializing the service, managing user profiles and trips, handling real-time
tracking, and more.

## Main Interface: Trekko

### Methods:
- `Future<void> init()`: Initializes the Trekko service. 
- `Stream<Profile> getProfile()`: Retrieves the user's profile as a stream. 
- `Future<void> saveProfile(Profile profile)`: Saves the user's profile. 
- `Future<String> loadText(OnboardingTextType type)`: Loads onboarding text based on the specified type. 
- `Future<void> saveTrip(Trip trip)`: Saves a trip. 
- `Future<bool> deleteTrip(int tripId)`: Deletes a trip by its ID. 
- `Future<Trip> mergeTrips(Query<Trip> trips)`: Merges multiple trips into one. 
- `QueryBuilder<Trip, Trip, QWhere> getTripQuery()`: Provides a query builder for trips. 
- `Stream<TripsAnalysis> analyze(Query<Trip> query)`: Analyzes trips based on a given query. 
- `Future<void> donate(Query<Trip> query)`: Handles donation-related actions. 
- `Future<Stream<Position>> getPosition()`: Retrieves the current position as a stream. 
- `Stream<TrackingState> getTrackingState()`: Retrieves the tracking state as a stream. 
- `Future<bool> setTrackingState(TrackingState state)`: Sets the tracking state.

## Getting an instance of Trekko

To get an instance of `Trekko`, use one of the following builders with the required data:

- `RegistrationBuilder`: Register a new profile
- `LoginBuilder`: Login a profile
- `LastLoginBuilder`: Use the last logged in profile

These builders return a `ProfiledTrekko` instance, which is the concrete implementation of the `Trekko` interface.

Each of these builders may throw a `BuildException` if the required data is invalid or missing.
The exception will include a reason, which will either be a `LoginResult` or a `RegistrationResult`.

## Handling Streams in Flutter
Streams in Flutter are used to handle asynchronous data sequences. The `StreamBuilder` widget is particularly useful for this purpose.

The following example shows how to use the `StreamBuilder` widget to handle a stream of `Profile` objects:

```dart
StreamBuilder<Profile>(
  stream: trekko.getProfile(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.active) {
      if (snapshot.hasData) {
        final profile = snapshot.data;
        // Use profile here
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
    }
    return CircularProgressIndicator(); // Loading state
  },
);
```
