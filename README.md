# DataCite REST API

[![Build Status](https://travis-ci.org/datacite/sashimi.svg?branch=master)](https://travis-ci.org/datacite/sashimi) [![Docker Build Status](https://img.shields.io/docker/build/datacite/sashimi.svg)](https://hub.docker.com/r/datacite/sashimi/) [![Maintainability](https://api.codeclimate.com/v1/badges/dddd95f9f6f354b7af93/maintainability)](https://codeclimate.com/github/datacite/sashimi/maintainability) (https://codeclimate.com/github/datacite/sashimi/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/dddd95f9f6f354b7af93/test_coverage)](https://codeclimate.com/github/datacite/sashimi/test_coverage)

Sashimi API is an api-only application that wraps a storage hub of SUSHI reports for data level metrics. Shashimi expects SUSHI formated reports in ingestion and produces collections of SUSHI reports for consumption.


![]("https://fthmb.tqn.com/C6mkh3RMG43enijMEMaM2UeBMZY=/960x0/filters:no_upscale()/Fresh-sashimi-GettyImages-86057409-58a0f05e3df78c475826b7de.jpg")



## Installation

Using Docker.

```
docker run -p 8075:80 datacite/sashimi
```

You can now point your browser to `http://localhost:8075` and use the application.

## Development

We use Rspec for unit and acceptance testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/sashimi/issues).

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
**Sashimi** is released under the [MIT License](https://github.com/datacite/sashimi/blob/master/LICENSE).
