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


## Resource components

Full API Reference can be found in the [DataCite Support Website](https://support.datacite.org/v1.1/reference#metrics-api). This reference is also a Live API. Major resource components supported by the Sashimi API are:

- reports
- publishers
- status


These can be used alone like this

| resource      | description                       |
|:--------------|:----------------------------------|
| `/reports`      | returns a list of all reports in the Hub
| `/publishers`    | returns a list of all Publishers
| `/status` | returns the service status |


### Resource components and identifiers
Resource components can be used in conjunction with identifiers to retrieve the metadata for that report.

| resource                    | description                       |
|:----------------------------|:----------------------------------|
| `/reports/{report-uid}`           | returns metadata for the specified Report. The report UID is a combination of the year, month the report was created and publisher that created the report. For example, for a created_by `CDL` for 2018-03-01 the uid of the report is `2018-03-CDL` |
| `/publishers/{publisher-id}`      | returns metadata for specified publisher  |




## Depositing Reports

To add a report, you need to send JSON content and your POST call should include `Content-Type: application/json` and `Accept: application/json` in the headers. Additionally you will need to include to JSON Web Token (JWT) for authenthication. For example:

```shell
curl --header "Content-Type: application/json; Accept: application/json" -H "X-Authorization: Bearer {YOUR_JWT}" -X POST https://metrics.test.datacite.org/reports
```

```json
{
  "report-header": {
    "report-name": "dataset report",
    "report-id": "dsr",
    "release": "rd1",
    "created": "2016-09-08t22:47:31z",
    "created-by": "dataone",
    "report-filters": [
      {
        "name": "begin-date",
        "value": "2015-01"
      }
    ],
    "report-attributes": [
      {
        "name": "exclude-monthly-details",
        "value": "true"
      }
    ],
    "exceptions": [
      {
        "code": 3040,
        "severity": "warning",
        "message": "partial data returned.",
        "help-url": "string",
        "data": "usage data has not been processed for all requested months."
      }
    ]
  },
  "report-datasets": [
    {
      "dataset-title": "lake erie fish community data",
      "dataset-id": [
        {
          "type": "doi",
          "value": "0931-865"
        }
      ],
      "dataset-contributors": [
        {
          "type": "name",
          "value": "john smith"
        }
      ],
      "dataset-dates": [
        {
          "type": "pub-date",
          "value": "2002-01-15"
        }
      ],
      "dataset-attributes": [
        {
          "type": "dataset-version",
          "value": "vor"
        }
      ],
      "platform": "dataone",
      "publisher": "dataone",
      "publisher-id": [
        {
          "type": "orcid",
          "value": "1234-1234-1234-1234"
        }
      ],
      "data-type": "dataset",
      "yop": "2010",
      "access-method": "regular",
      "performance": [
        {
          "period": {
            "begin-date": "2015-01-01",
            "end-date": "2015-01-31"
          },
          "instance": [
            {
              "metric-type": "total-dataset-requests",
              "count": 21
            }
          ]
        }
      ]
    }
  ]
}

```
## Key and Values

The allowed and recommended characters for an URL safe naming of parameters are defined in the format spec. To also standardize parameters names, the following (more restrictive) rules are recommended:

- Parameters names SHOULD start and end with the characters “a-z” (U+0061 to U+007A)
- Parameters names SHOULD contain only the characters “a-z” (U+0061 to U+007A), “0-9” (U+0030 to U+0039), and the hyphen minus (U+002D HYPHEN-MINUS, “-“) as separator between multiple words.

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
