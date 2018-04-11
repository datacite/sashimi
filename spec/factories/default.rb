require "faker"
FactoryBot.define do
  factory :report do
    sequence(:report_id) { |n| "dsr-12hd-zt#{n}" }
    client_id "datacite.datacite"
    provider_id "datacite"
    sequence(:created_by) { |n| "datacite#{n}" }
    created "2020-03-02"
    report_filters []
    report_attributes []
    report_datasets [{
      "yop": "2010",
      "platform": "DataONE",
      "data_type": "dataset",
      "dataset_title": "Plasma Electron adjustment",
      "publisher": "DataONE",
      "publisher_id": [{
        "type": "orcid",
        "value": "0931-865"
       }],
      "dataset_id": [{
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
              "country": "gb",
              "access-method": "regular",
              "metric-type": "total_dataset_investigations",
              "count": 3
            },
            {
              "country": "gb",
              "access-method": "regular",
              "metric-type": "unique_dataset_investigations",
              "count": 3
            }
          ]
        }
      ]
    }]
  end
end
