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
Major resource components supported by the Sashimi API are:

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
| `/reports/{report_uid}`           | returns metadata for the specified Report. The report UID is a combination of the year, month the report was created and publisher that created the report. For example, for a created_by `CDL` for 2018-03-01 the uid of the report is `2018-03-CDL` |
| `/publishers/{publisher_id}`      | returns metadata for specified publisher  |




## Depositing Reports

To add a report, you need to send JSON content and your POST call should include `Content-Type: application/json` and `Accept: application/json` in the headers. Additionally you will need to include to JSON Web Token (JWT) for authenthication. For example:

```shell
curl --header "Content-Type: application/json; Accept: application/json" -H "X-Authorization: Bearer {YOUR_JWT}" -X POST https://metrics.test.datacite.org/reports
```

```json
{
  "report-header": {
    "report-name": "Dataset Report",
    "report-id": "DSR",
    "release": "RD1",
    "created": "2016-09-08T22:47:31Z",
    "created-by": "DataONE",
    "report-filters": [
      {
        "Name": "Begin-Date",
        "Value": "2015-01"
      }
    ],
    "report-attributes": [
      {
        "Name": "Exclude-Monthly-Details",
        "Value": "True"
      }
    ],
    "exceptions": [
      {
        "Code": 3040,
        "Severity": "Warning",
        "Message": "Partial Data Returned.",
        "Help-URL": "string",
        "Data": "Usage data has not been processed for all requested months."
      }
    ]
  },
  "report-datasets": [
    {
      "Dataset-Title": "Lake Erie Fish Community Data",
      "Dataset-ID": [
        {
          "Type": "DOI",
          "Value": "0931-865"
        }
      ],
      "Dataset-Contributors": [
        {
          "Type": "Name",
          "Value": "John Smith"
        }
      ],
      "Dataset-Dates": [
        {
          "Type": "Pub-Date",
          "Value": "2002-01-15"
        }
      ],
      "Dataset-Attributes": [
        {
          "Type": "Dataset-Version",
          "Value": "VoR"
        }
      ],
      "Platform": "DataONE",
      "Publisher": "DataONE",
      "Publisher-ID": [
        {
          "Type": "ORCID",
          "Value": "1234-1234-1234-1234"
        }
      ],
      "Data-Type": "Dataset",
      "YOP": "2010",
      "Access-Method": "Regular",
      "Performance": [
        {
          "Period": {
            "Begin-Date": "2015-01-01",
            "End-Date": "2015-01-31"
          },
          "Instance": [
            {
              "Metric-Type": "Total-Dataset-Requests",
              "Count": 21
            }
          ]
        }
      ]
    }
  ]
}
```


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
