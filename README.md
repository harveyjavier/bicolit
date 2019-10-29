# Bicol IT App

An entry for Flutter Hackathon 2019, Philippines.

# Screenshots

```
Not yet available...
```

## Setup

### Missing Key.Properties file

Running the project straight away will get you an error regarding a `key.properties` file that is missing. To fix it,

1.  Open android/app/build.gradle file and comment the following lines-

```
//keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

signingConfigs {
// release {
// keyAlias keystoreProperties['keyAlias']
// keyPassword keystoreProperties['keyPassword']
// storeFile file(keystoreProperties['storeFile'])
// storePassword keystoreProperties['storePassword']
// }
}
buildTypes {
// release {
// signingConfig signingConfigs.release
// }
}
```

2.  Open the project on your cmd or terminal, type flutter run, then you're good to go!

```
flutter run
```

## Developer

### Harvz

Hi! I'm Harvz, the developer of this project. Let's get connected!

<a href="https://play.google.com/store/apps/dev?id=4935714394750436171"><img src="raw/play-store-icon.png" width="60"></a>
<a href="https://www.linkedin.com/in/harvz/"><img src="raw/linkedin-icon.png" width="60"></a>
<a href="https://www.facebook.com/harvzjavier"><img src="raw/facebook-icon.png" width="60"></a>
<a href="https://www.instagram.com/harvzjavier/"><img src="raw/instagram-icon.png" width="60"></a>

## License

```
MIT License

Copyright (c) 2019 Harvey Javier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
