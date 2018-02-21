# Sashimi API for Data Level Metrics

[![Build Status](https://travis-ci.org/datacite/sashimi.svg?branch=master)](https://travis-ci.org/datacite/sashimi) [![Docker Build Status](https://img.shields.io/docker/build/datacite/sashimi.svg)](https://hub.docker.com/r/datacite/sashimi/) [![Maintainability](https://api.codeclimate.com/v1/badges/a0d15834af2cdc24e22f/maintainability)](https://codeclimate.com/github/datacite/sashimi/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/a0d15834af2cdc24e22f/test_coverage)](https://codeclimate.com/github/datacite/sashimi/test_coverage)

Sashimi API is an api-only application that wraps a storage hub of SUSHI reports for data level metrics. Sashimi expects SUSHI formated reports in ingestion and produces collections of SUSHI reports for consumption.

It closely follows the [RESEARCH_DATA_SUSHI specification](https://app.swaggerhub.com/apis/COUNTER/researchdata-sushi_1_0_api/1.0.0#/).


![](https://c1.staticflickr.com/1/21/31470457_3680ff198e_b.jpg)



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
