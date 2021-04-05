# MSTS Activity to ZIP Converter

This is a converter for the Microsoft Train Simulator (MSTS) APK activity files.
It can convert the APK files to the more commonly used ZIP format.

You can use it with [OpenRails](http://openrails.org/)
or when your original MSTS unpacking utility does not work properly.

## The On-line Version

If you cannot run Ruby scripts in your system or the installation procedure is
too complicated for you then you can try the [on-line version](
https://msts2zip.herokuapp.com/).
It is basically a web wrapper around this script.

## Usage

### Installation

First you need to install the required Ruby gems, the easiest way is to install
them into a `vendor` subdirectory:

```shell
bundle install --path vendor
```

### Conversion

Simly run `bundler exec ./apk2zip <apk_file>` where `<apk_file>` is the APK file to convert.

##### Example

```console
# bundler exec ./apk2zip rt_82120.apk
Reading APK file rt_82120.apk...
The activity is for route 'Breclav - Praha'
Found 51 files inside
Creating ZIP file...
Saved to rt_82120.zip
```

### Running the Server Locally

To test the web application locally run

```shell
bundle exec rackup config.ru
```

ans connect to this URL: [http://localhost:9292](http://localhost:9292)

### Unpacking the ZIP File

Then unpack the ZIP file into your MSTS base directory or if you use OpenRails into the selected profile.
