require "faker"
FactoryBot.define do
  factory :report do
    sequence(:report_id) { |n| "dsr-12hd-zt#{n}" }
    client_id "datacite.datacite"
    provider_id "datacite"
    sequence(:created_by) { |n| "datacite#{n}" }
    created "2020-03-02"
    reporting_period  "begin_date": "2018-03-01", "end_date": "2018-03-31" 
    report_filters []
    report_attributes []
    exceptions []
    report_datasets [{
      "yop": "2010",
      "platform": "DataONE",
      "data-type": "dataset",
      "dataset-title": "Plasma Electron adjustment",
      "publisher": "DataONE",
      "publisher-id": [{
        "type": "orcid",
        "value": "0931-865"
       }],
      "dataset-id": [{
          "type": "doi",
          "value": "0931-865"
      }],
      "performance": [
        {
          "period": {
            "begin-date": "2018-03-01",
            "end-date": "2018-03-31"
          },
          "instance": [
            {
              "access-method": "regular",
              "metric-type": "total-dataset-investigations",
              "count": 3
            },
            {
              "access-method": "regular",
              "metric-type": "unique-dataset-investigations",
              "count": 3
            }
          ]
        }
      ]
    }]
  end
end
