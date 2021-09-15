# DataCite Usage Reports API

[![Build Status](https://travis-ci.org/datacite/sashimi.svg?branch=master)](https://travis-ci.org/datacite/sashimi) [![Docker Build Status](https://img.shields.io/docker/build/datacite/sashimi.svg)](https://hub.docker.com/r/datacite/sashimi/) [![Maintainability](https://api.codeclimate.com/v1/badges/a0d15834af2cdc24e22f/maintainability)](https://codeclimate.com/github/datacite/sashimi/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/a0d15834af2cdc24e22f/test_coverage)](https://codeclimate.com/github/datacite/sashimi/test_coverage)

Sashimi is an api-only application for Usage Reports in [SUSHI](https://www.niso.org/schemas/sushi) format. Sashimi expects SUSHI-formatted reports in ingestion and returns collections of SUSHI reports for consumption.

The application closely follows the [RESEARCH_DATA_SUSHI specification](https://app.swaggerhub.com/apis/COUNTER/researchdata-sushi_1_0_api/1.0.0#/).

![](https://c1.staticflickr.com/1/21/31470457_3680ff198e_b.jpg)

## Service Documentation

DataCites provides an API for usage reports as a service. For a description about the API Rerefence and how-to guides, please visit:

* [API Reference](https://support.datacite.org/v1.1/reference#usage-reports)
* [How To Guide for Usage Reports API](https://support.datacite.org/docs/usage-reports-api-guide)


The rest of the README deals with techincal description and usage of the software in this repository.

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

## Technical Description

### Resource components

Major resource components supported by the Data Usage API are:

- reports
- hearthbeat

These can be used alone like this

| resource      | description                       |
|:--------------|:----------------------------------|
| `/reports`      | returns a list of all reports in the Hub
| `/hearthbeat` | returns the service status |

### Resource components and identifiers

Resource components can be used in conjunction with identifiers to retrieve the metadata for that report.

| resource                    | description                       |
|:----------------------------|:----------------------------------|
| `/reports/{report-uid}`           |   returns metadata for the specified Report. The report UID is a UUID according to RFC 4122. |

## Depositing Reports

To add a report, you need to send JSON content and your POST call should include `Content-Type: application/json` and `Accept: application/json` in the headers. Additionally you will need to include to JSON Web Token (JWT) for authenthication. For example:

```shell
curl --header "Content-Type: application/json; Accept: application/json" -H "X-Authorization: Bearer {YOUR_JWT}" -X POST https://api.datacite.org/reports
```

```json
{
  "report-header": {
    "report-name": "dataset report",
    "report-id": "dsr",
    "release": "rd1",
    "created": "2016-09-08t22:47:31z",
    "created-by": "dataone",
		"reporting-period":
    {
        "begin-date": "2018-05-01",
        "end-date": "2018-05-30"
    },
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

Additionally, you can use a PUT call whith a new report and providing your own 'report_id'. this will create a report provided the report follows the Sushi schema and the 'report_id' is a UUID.

## Key and Values

The allowed and recommended characters for an URL safe naming of parameters are defined in the format spec. To also standardize parameters names, the following (more restrictive) rules are recommended:

- Parameters names SHOULD start and end with the characters “a-z” (U+0061 to U+007A)
- Parameters names SHOULD contain only the characters “a-z” (U+0061 to U+007A), “0-9” (U+0030 to U+0039), and the hyphen minus (U+002D HYPHEN-MINUS, “-“) as separator between multiple words.

## Report Storage

Reports are stored in a S3 bucket using ActiveStorage. We are storing them rather than in MySQL because report can get rather big as mentioned in the [COUNTER documentation](https://groups.niso.org/workrooms/sushi/start/clients).

## Register a large Usage Report

Usage report can get very large and we use two approaches handle them. The first approach is compression and the second is subsetting. Large reports need to be divided and compressed. We have set up a top limit of 50,000 datasets per report.

In both cases, you need to add this exception in the report header:

```json
"exceptions": [{
  "code": 69,
  "severity": "warning",
  "message": "Report is compressed using gzip",
  "help-url": "https://github.com/datacite/sashimi",
  "data": "usage data needs to be uncompressed"
}]
```

### Sending compressed reports

 We suggest compressing any report that is larger than 10MB. Here it is a ruby example of report compression:

```ruby
def compress file
  report = File.read(file)
  gzip = Zlib::GzipWriter.new(StringIO.new)
  string = JSON.parse(report).to_json
  gzip << string
  body = gzip.close.string
  body
end
```

When sending the compressed reports you need to send them using application/gzip as Content Type and gzip as Content Encoding. For example

```ruby
URI = 'https://api.datacite.org/reports'

def post_file file

  headers = {
    content_type: "application/gzip",
    content_encoding: 'gzip',
    accept: 'gzip'
  }

  body = compress(file)

  request = Maremma.post(URI, data: body,
    bearer: ENV['TOKEN'],
    headers: headers,
    timeout: 100)
end
```

The equivalent Curl call would be:

```shell
$ curl --header "Content-Type: application/gzip; Content-Encoding: gzip" -H "X-Authorization: Bearer {YOUR-JSON-WEB-TOKEN}" -X POST https://api.datacite.org/reports/ -d @usage-report-compressed
```

### Send Usage Report in subsets

In order to create a report with more of 50,000 records, just keep making POST requests with the same report-header. This will create subsets of the report. For example:

```shell
POST /reports
POST /reports
POST /reports
```

To update an existing compressed report make a PUT request followed with as many POST requests with the same report-header as you need. For example:

```shell
PUT /reports/{report-id}
POST /reports
POST /reports
```

### Metadata Validation

The validation of the metadata in the reports its a two-step process. The controller takes care of checking presence of fields. Then the Schema validation is performed before saving the report. We use json-schema validation for this.

## Queries

Very basic querying is supported and just for fields in the header of the reports. For more complex quering we suggest to use the DataCite Event Data Service.

## Pagination

Pagination follows the JSOANPI specification.

Follow along via [Github Issues](https://github.com/datacite/sashimi/issues).

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License

**Sashimi** is released under the [MIT License](https://github.com/datacite/sashimi/blob/master/LICENSE).
