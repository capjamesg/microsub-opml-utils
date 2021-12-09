# Microsub OPML Import and Export Utilities

This repository contains scripts to import an OPML file into a Microsub server and export a list of Microsub subscriptions to an OPML file.

Subscription logic is defined in the Microsub draft specification. This means that the code in this repository should work with all Microsub servers that implement the Microsub GET and POST "follow" actions.

## Why

You may want to use the code in this repository if you want to:

1. Move feeds from another feed reader into a Microsub server.
2. Move your subscriptions between Microsub servers or to another feed reader.

## Getting Started

To start using this project, first install the required dependencies:

    bundle install

Next, create a .env file and populate it with the following values:

    MICROSUB_URL = "https://microsub.example.com/endpoint"
    MICROSUB_API_KEY = "example_key"
    CHANNEL = "channel_id"

You must specify values for all three of these variables to run the script.

The CHANNEL variable must be equal to the channel in which you want to import your OPML files or from which you want to export your subscriptions to OPML.

At the moment, CHANNEL is a static variable. Support for determining channel by "Option" in an OPML file will follow in a future release.

## Importing from OPML

To import files into Microsub, first create a file called feeds.xml which contains your OPML file. Next, run the following command:

    ruby utils/opml_export.rb

You will see output in your terminal that indicates whether the request to import a feed was successful or not. This output will look like this:

## Exporting to OPML

To export feed subscriptions from Microsub to OPML, run this command:

    ruby utils/opml_export.rb

A file called opml.xml will be created with the output.

This module extends the Microsub draft to support an additional "name" attribute if one is set. A fallback is in place so as to ensure this function can be used on any server that complies with the draft Microsub specification.

If a Microsub "name" attribute is set, that value will be translated into the "title" attribute in the OPML file. If no "name" attribute is set, the "title" attribute will be equal to the feed URL stored on the Microsub server.

## License

This project is licensed under the [MIT license](LICENSE).

## Dependencies

This project uses the following Ruby dependencies:

- nokogiri for XML parsing
- httparty for HTTP requests
- dotenv for reading values in a .env file

## Contributors

- capjamesg