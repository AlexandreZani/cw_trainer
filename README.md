# cw_trainer

## Get all the dependent libraries

```
flutter pub get
```

## To do development in vscode

Install the `mkhl.direnv` extension as well as the Flutter extension.

## To run the app

```
flutter run
```

## To update launcher icon

```
./update_icon.sh
```

## To release a new version

First bump up the version in `pubspec.yaml`.

Then, create a tag for that new version and push it:

```
VERSION_TAG=$(grep '^version:' pubspec.yaml | awk '{print $2}')

git tag $VERSION_TAG
git push origin $VERSION_TAG
```

Build the Android App Bundle

```
build-aab
```

Upload to the Google Play Developer Console.
