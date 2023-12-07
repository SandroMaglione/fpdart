# now_in_dart_flutter

This app serves the purpose of staying up-to-date with the latest changes across Dart and Flutter ecosystem. The way this app works is by fetching markdowns from Dart and Flutter's official Github repo via REST API and rendering the information in a `WebView` widget.

## Features

- Display Dart CHANGELOG
- Display Flutter What's New
- Display Flutter Release Notes
- Offline Support

## Application Demo

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <video width="200" controls>
                    <source src="https://user-images.githubusercontent.com/63902683/192081298-78bb3e31-10ed-4150-b726-e9181b240346.mp4" type="video/mp4">
                </video>
           </td>
           <td style="text-align: center">
               <video width="200" controls>
                    <source src="https://user-images.githubusercontent.com/63902683/192081334-09f4be61-e836-4661-9aa9-cacce7c50739.mp4" type="video/mp4">
               </video>
           </td>
        </tr>
    </table>
</div>

## Architecture

The app follows a simple but effective architecture. It relies on a feature-driven architecture with some sub-features.

Inside [lib/features/](./lib/features/) directory, you can find two sub-features: `detail` and `home`.

The [home](./lib/features/home/) sub-feature is responsible for showing a scaffold with a bottom navigation bar. It also contains logic for maintaining bottom navigation bar's state.

The [detail](./lib/features/detail/) feature is divided into two sub-features: [dart_detail](./lib/features/detail/dart_detail/) and [flutter_detail](./lib/features/detail/flutter_detail/). Each of these sub-features has similar structure and is divided into three layers.

- **Application Layer**: Contains state management logic and acts as a mediator between the presentation and the data layer.
- **Data Layer**: Responsible for making all the necessary API calls and local cache operations.
- **Presentation Layer**: Associated with the UI

To check the `fpdart` implementation, consider taking a look at the `data` layer of each of the sub-features.

## State Management
The project uses [flutter_bloc](https://pub.dev/packages/flutter_bloc) for managing the app's state.

## Storage
The app stores fetched data locally on user's device for offline support. The project uses the latest [isar](https://pub.dev/packages/isar) plugin for local storage.

## Test
The unit test has been written based on the `fpdart` refactoring and can be found in the [test](./test/) directory.
- [detail_local_service_test.dart](./test/features/detail/core/data/detail_local_service_test.dart)
- [detail_remote_service_test.dart](./test/features/detail/core/data/detail_remote_service_test.dart)

Dependencies
The project makes use of few third-party packages for rapid development. Some of them are listed below:
- [dio](https://pub.dev/packages/dio) (To perform network calls)
- [equatable](https://pub.dev/packages/equatable) (To achieve value equality)
- [flash](https://pub.dev/packages/flash) (To display customizable toast)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) (State Management)
- [fpdart](https://pub.dev/packages/fpdart) (Functional Programming)
- [isar](https://pub.dev/packages/isar) (Local Storage)
- [url_launcher](https://pub.dev/packages/url_launcher) (To display information from hyperlinks in a browser interface within the app)
- [webview_flutter](https://pub.dev/packages/webview_flutter) (To display markdowns)
- [mocktail](https://pub.dev/packages/mocktail) (As a mocking library)

## Types used from `fpdart`
- `TaskEither`: Used instead of `Future` to make async request that may fail
- `IOEither`: Used to represent a synchronous computation that may fail
- `Do` Notation: Used to write functional code that looks like normal imperative code and to avoid methods chaining