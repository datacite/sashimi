# Changelog

## [Unreleased](https://github.com/datacite/sashimi/tree/HEAD)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.6...HEAD)

**Closed issues:**

- Sashimi is not signalling events to levriero for compressed report submission. [\#140](https://github.com/datacite/sashimi/issues/140)

**Merged pull requests:**

- Issue-140 - modify rake tasks to allow push of report files to levriero. [\#142](https://github.com/datacite/sashimi/pull/142) ([svogt0511](https://github.com/svogt0511))

## [0.10.6](https://github.com/datacite/sashimi/tree/0.10.6) (2021-05-21)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.5...0.10.6)

**Implemented enhancements:**

- Store uploaded files in Amazon S3 instead of the database. [\#133](https://github.com/datacite/sashimi/issues/133)

**Closed issues:**

- .env.example file needs minor edit [\#134](https://github.com/datacite/sashimi/issues/134)

**Merged pull requests:**

- Issue-140 - Sashimi is not signalling events to levriero for compress… [\#141](https://github.com/datacite/sashimi/pull/141) ([svogt0511](https://github.com/svogt0511))

## [0.10.5](https://github.com/datacite/sashimi/tree/0.10.5) (2021-03-26)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.4...0.10.5)

**Merged pull requests:**

- Mime-magic issue mods. [\#139](https://github.com/datacite/sashimi/pull/139) ([svogt0511](https://github.com/svogt0511))

## [0.10.4](https://github.com/datacite/sashimi/tree/0.10.4) (2021-03-10)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.3...0.10.4)

**Implemented enhancements:**

- WIP - svogt issue \#133 store reports as files [\#137](https://github.com/datacite/sashimi/pull/137) ([svogt0511](https://github.com/svogt0511))

**Closed issues:**

- Large compressed reports cannot be updated with PUT requests as documented [\#135](https://github.com/datacite/sashimi/issues/135)

## [0.10.3](https://github.com/datacite/sashimi/tree/0.10.3) (2020-12-21)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.2...0.10.3)

**Implemented enhancements:**

- \[Proposal\] New response for validated compressed reports [\#112](https://github.com/datacite/sashimi/issues/112)

**Fixed bugs:**

- Handle older generated JWTs [\#131](https://github.com/datacite/sashimi/issues/131)
- Undefined method `aasm\_state` error [\#130](https://github.com/datacite/sashimi/issues/130)

**Closed issues:**

- Access process for new providers of usage stats [\#39](https://github.com/datacite/sashimi/issues/39)

**Merged pull requests:**

- Revert PR\#129 then fix issue \#135 [\#138](https://github.com/datacite/sashimi/pull/138) ([svogt0511](https://github.com/svogt0511))
- Change the API to send different status codes depending of the status of the validation [\#129](https://github.com/datacite/sashimi/pull/129) ([kjgarza](https://github.com/kjgarza))

## [0.10.2](https://github.com/datacite/sashimi/tree/0.10.2) (2020-07-14)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.1...0.10.2)

**Closed issues:**

- Change reliance on client\_id to identify the Provider and Client [\#123](https://github.com/datacite/sashimi/issues/123)

**Merged pull requests:**

- Feature remove provider\_id references  [\#128](https://github.com/datacite/sashimi/pull/128) ([kjgarza](https://github.com/kjgarza))

## [0.10.1](https://github.com/datacite/sashimi/tree/0.10.1) (2020-07-10)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.10.0...0.10.1)

**Merged pull requests:**

- Bump rack from 2.0.8 to 2.2.3 [\#127](https://github.com/datacite/sashimi/pull/127) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump websocket-extensions from 0.1.4 to 0.1.5 [\#126](https://github.com/datacite/sashimi/pull/126) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump kaminari from 1.1.1 to 1.2.1 [\#125](https://github.com/datacite/sashimi/pull/125) ([dependabot[bot]](https://github.com/apps/dependabot))

## [0.10.0](https://github.com/datacite/sashimi/tree/0.10.0) (2020-04-30)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.25...0.10.0)

**Closed issues:**

- Push CDL reports that failed validation [\#116](https://github.com/datacite/sashimi/issues/116)

**Merged pull requests:**

- quick summary for client\_id [\#121](https://github.com/datacite/sashimi/pull/121) ([kjgarza](https://github.com/kjgarza))
- Bump nokogiri from 1.10.7 to 1.10.8 [\#120](https://github.com/datacite/sashimi/pull/120) ([dependabot[bot]](https://github.com/apps/dependabot))
- fix codeclimate analysis error [\#119](https://github.com/datacite/sashimi/pull/119) ([kjgarza](https://github.com/kjgarza))
- auto assign reviewers in PRs [\#118](https://github.com/datacite/sashimi/pull/118) ([kjgarza](https://github.com/kjgarza))

## [0.9.25](https://github.com/datacite/sashimi/tree/0.9.25) (2020-02-14)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.24...0.9.25)

## [0.9.24](https://github.com/datacite/sashimi/tree/0.9.24) (2020-02-10)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.23...0.9.24)

**Fixed bugs:**

- ERROR: No worker found for queue [\#114](https://github.com/datacite/sashimi/issues/114)

**Merged pull requests:**

- Avoid multiple report indexing [\#117](https://github.com/datacite/sashimi/pull/117) ([kjgarza](https://github.com/kjgarza))

## [0.9.23](https://github.com/datacite/sashimi/tree/0.9.23) (2019-12-20)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.22...0.9.23)

## [0.9.22](https://github.com/datacite/sashimi/tree/0.9.22) (2019-12-20)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.21...0.9.22)

## [0.9.21](https://github.com/datacite/sashimi/tree/0.9.21) (2019-12-20)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.20...0.9.21)

## [0.9.20](https://github.com/datacite/sashimi/tree/0.9.20) (2019-12-20)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.19...0.9.20)

## [0.9.19](https://github.com/datacite/sashimi/tree/0.9.19) (2019-12-19)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.18...0.9.19)

## [0.9.18](https://github.com/datacite/sashimi/tree/0.9.18) (2019-12-19)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.17...0.9.18)

**Closed issues:**

- Rake task to convert keys in reports JSON [\#108](https://github.com/datacite/sashimi/issues/108)
- Don't transform keys in usage reports [\#107](https://github.com/datacite/sashimi/issues/107)
- Standardize logging [\#87](https://github.com/datacite/sashimi/issues/87)
- to document  usage report generation \(implementation agnostic\) [\#60](https://github.com/datacite/sashimi/issues/60)
- improve performance on report consumption [\#59](https://github.com/datacite/sashimi/issues/59)

**Merged pull requests:**

- Bump rack-cors from 1.0.3 to 1.0.5 [\#111](https://github.com/datacite/sashimi/pull/111) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump loofah from 2.2.3 to 2.3.1 [\#110](https://github.com/datacite/sashimi/pull/110) ([dependabot[bot]](https://github.com/apps/dependabot))

## [0.9.17](https://github.com/datacite/sashimi/tree/0.9.17) (2019-09-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.16...0.9.17)

## [0.9.16](https://github.com/datacite/sashimi/tree/0.9.16) (2019-09-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.15...0.9.16)

## [0.9.15](https://github.com/datacite/sashimi/tree/0.9.15) (2019-09-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.14...0.9.15)

## [0.9.14](https://github.com/datacite/sashimi/tree/0.9.14) (2019-09-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.13...0.9.14)

## [0.9.13](https://github.com/datacite/sashimi/tree/0.9.13) (2019-09-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.12...0.9.13)

## [0.9.12](https://github.com/datacite/sashimi/tree/0.9.12) (2019-09-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.11...0.9.12)

## [0.9.11](https://github.com/datacite/sashimi/tree/0.9.11) (2019-09-23)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.10...0.9.11)

## [0.9.10](https://github.com/datacite/sashimi/tree/0.9.10) (2019-09-23)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.9...0.9.10)

## [0.9.9](https://github.com/datacite/sashimi/tree/0.9.9) (2019-09-23)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.8...0.9.9)

## [0.9.8](https://github.com/datacite/sashimi/tree/0.9.8) (2019-09-23)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.7...0.9.8)

**Closed issues:**

- Show client\_id, year, month in API response [\#61](https://github.com/datacite/sashimi/issues/61)

**Merged pull requests:**

- Bump jwt from 2.1.0 to 2.2.1 [\#106](https://github.com/datacite/sashimi/pull/106) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump cancancan from 2.3.0 to 3.0.1 [\#105](https://github.com/datacite/sashimi/pull/105) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump faker from 1.9.1 to 2.4.0 [\#104](https://github.com/datacite/sashimi/pull/104) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump capybara from 3.10.1 to 3.29.0 [\#103](https://github.com/datacite/sashimi/pull/103) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump webmock from 3.4.2 to 3.7.5 [\#102](https://github.com/datacite/sashimi/pull/102) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump vcr from 3.0.3 to 5.0.0 [\#101](https://github.com/datacite/sashimi/pull/101) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump rspec-rails from 3.8.1 to 3.8.2 [\#100](https://github.com/datacite/sashimi/pull/100) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump oj from 2.18.5 to 3.9.1 [\#99](https://github.com/datacite/sashimi/pull/99) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump rack-cors from 1.0.2 to 1.0.3 [\#98](https://github.com/datacite/sashimi/pull/98) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump dotenv from 2.5.0 to 2.7.5 [\#97](https://github.com/datacite/sashimi/pull/97) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump shoryuken from 3.3.1 to 5.0.1 [\#96](https://github.com/datacite/sashimi/pull/96) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump active\_model\_serializers from 0.10.8 to 0.10.10 [\#95](https://github.com/datacite/sashimi/pull/95) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump simple\_command from 0.0.9 to 0.1.0 [\#94](https://github.com/datacite/sashimi/pull/94) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump json from 1.8.6 to 2.2.0 [\#93](https://github.com/datacite/sashimi/pull/93) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump spring from 2.0.2 to 2.1.0 [\#92](https://github.com/datacite/sashimi/pull/92) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump shoulda-matchers from 3.1.2 to 4.1.2 [\#91](https://github.com/datacite/sashimi/pull/91) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump bcrypt from 3.1.12 to 3.1.13 [\#90](https://github.com/datacite/sashimi/pull/90) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump api-pagination from 4.8.1 to 4.8.2 [\#89](https://github.com/datacite/sashimi/pull/89) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump aws-sdk-sqs from 1.9.0 to 1.22.0 [\#88](https://github.com/datacite/sashimi/pull/88) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump capybara from 3.10.1 to 3.28.0 [\#86](https://github.com/datacite/sashimi/pull/86) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump aws-sdk-s3 from 1.23.1 to 1.48.0 [\#85](https://github.com/datacite/sashimi/pull/85) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump bootsnap from 1.3.2 to 1.4.5 [\#84](https://github.com/datacite/sashimi/pull/84) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- \[Security\] Bump rails from 5.2.1 to 5.2.2.1 [\#83](https://github.com/datacite/sashimi/pull/83) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump httplog from 1.1.1 to 1.3.2 [\#82](https://github.com/datacite/sashimi/pull/82) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump lograge from 0.10.0 to 0.11.2 [\#76](https://github.com/datacite/sashimi/pull/76) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump iso8601 from 0.9.1 to 0.12.1 [\#70](https://github.com/datacite/sashimi/pull/70) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump byebug from 10.0.2 to 11.0.1 [\#64](https://github.com/datacite/sashimi/pull/64) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump better\_errors from 2.5.0 to 2.5.1 [\#63](https://github.com/datacite/sashimi/pull/63) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Bump factory\_bot\_rails from 4.11.1 to 5.0.2 [\#62](https://github.com/datacite/sashimi/pull/62) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))
- Basic filtering [\#16](https://github.com/datacite/sashimi/pull/16) ([kjgarza](https://github.com/kjgarza))

## [0.9.7](https://github.com/datacite/sashimi/tree/0.9.7) (2019-05-17)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.6...0.9.7)

## [0.9.6](https://github.com/datacite/sashimi/tree/0.9.6) (2019-05-17)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.5...0.9.6)

## [0.9.5](https://github.com/datacite/sashimi/tree/0.9.5) (2019-05-17)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.4...0.9.5)

## [0.9.4](https://github.com/datacite/sashimi/tree/0.9.4) (2019-05-17)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.3...0.9.4)

**Closed issues:**

- Switch to Sentry [\#58](https://github.com/datacite/sashimi/issues/58)

## [0.9.3](https://github.com/datacite/sashimi/tree/0.9.3) (2019-04-24)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.2...0.9.3)

**Fixed bugs:**

- Test instace has no space [\#57](https://github.com/datacite/sashimi/issues/57)
- There are multiple reports for the same month in the Hub [\#35](https://github.com/datacite/sashimi/issues/35)

**Closed issues:**

- move to Fargate and add SSH [\#56](https://github.com/datacite/sashimi/issues/56)
- Documentation to send compressed report [\#52](https://github.com/datacite/sashimi/issues/52)
- Setup S3 [\#46](https://github.com/datacite/sashimi/issues/46)
- Enable Large File Upload to Sashimi [\#44](https://github.com/datacite/sashimi/issues/44)
- Feature: delete reports and its events [\#43](https://github.com/datacite/sashimi/issues/43)

## [0.9.2](https://github.com/datacite/sashimi/tree/0.9.2) (2018-12-04)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.1...0.9.2)

**Closed issues:**

- Store report with a limit of 50K datasets [\#53](https://github.com/datacite/sashimi/issues/53)
- Enable compression on display [\#47](https://github.com/datacite/sashimi/issues/47)

**Merged pull requests:**

- Feature subsetted reports [\#54](https://github.com/datacite/sashimi/pull/54) ([kjgarza](https://github.com/kjgarza))

## [0.9.1](https://github.com/datacite/sashimi/tree/0.9.1) (2018-11-22)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.9.0...0.9.1)

## [0.9.0](https://github.com/datacite/sashimi/tree/0.9.0) (2018-11-20)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.8.5...0.9.0)

**Closed issues:**

- store comprrseed gzip in mysql to store comprresed reports [\#49](https://github.com/datacite/sashimi/issues/49)
- Enable compression acceptance [\#48](https://github.com/datacite/sashimi/issues/48)

**Merged pull requests:**

- Feature parametrise compressed reports [\#51](https://github.com/datacite/sashimi/pull/51) ([kjgarza](https://github.com/kjgarza))
- Feature accept compressed reports [\#50](https://github.com/datacite/sashimi/pull/50) ([kjgarza](https://github.com/kjgarza))

## [0.8.5](https://github.com/datacite/sashimi/tree/0.8.5) (2018-10-29)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.8.4...0.8.5)

## [0.8.4](https://github.com/datacite/sashimi/tree/0.8.4) (2018-10-25)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.8.3...0.8.4)

**Fixed bugs:**

- The GET request does not show all the fields [\#36](https://github.com/datacite/sashimi/issues/36)

**Closed issues:**

- remove max\_allowed\_packet changes [\#41](https://github.com/datacite/sashimi/issues/41)

## [0.8.3](https://github.com/datacite/sashimi/tree/0.8.3) (2018-10-17)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.8.2...0.8.3)

**Closed issues:**

- Sashimi API-Endpoint Consolidation [\#30](https://github.com/datacite/sashimi/issues/30)
- JSONAPI for Sashimi [\#29](https://github.com/datacite/sashimi/issues/29)

## [0.8.2](https://github.com/datacite/sashimi/tree/0.8.2) (2018-10-12)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.8.1...0.8.2)

## [0.8.1](https://github.com/datacite/sashimi/tree/0.8.1) (2018-10-06)

[Full Changelog](https://github.com/datacite/sashimi/compare/0.8...0.8.1)

## [0.8](https://github.com/datacite/sashimi/tree/0.8) (2018-10-06)

[Full Changelog](https://github.com/datacite/sashimi/compare/v0.0.5...0.8)

**Closed issues:**

- Rake task to reindex all documents [\#38](https://github.com/datacite/sashimi/issues/38)
- To evaluate sushi reports from IRUS-UK using Hub API [\#34](https://github.com/datacite/sashimi/issues/34)
- move-and-transform the basic documentation into a guide in support.dataci [\#33](https://github.com/datacite/sashimi/issues/33)

## [v0.0.5](https://github.com/datacite/sashimi/tree/v0.0.5) (2018-09-05)

[Full Changelog](https://github.com/datacite/sashimi/compare/v0.0.4...v0.0.5)

## [v0.0.4](https://github.com/datacite/sashimi/tree/v0.0.4) (2018-08-21)

[Full Changelog](https://github.com/datacite/sashimi/compare/v0.0.3...v0.0.4)

**Fixed bugs:**

- Message when events are processes does show correct count. [\#24](https://github.com/datacite/sashimi/issues/24)

**Closed issues:**

- Change Sashimi API documentation to reflect new endpoint [\#31](https://github.com/datacite/sashimi/issues/31)
- Change inputing data to sashimi for UPSERT [\#20](https://github.com/datacite/sashimi/issues/20)
- Create a truly UUID for usage reports [\#19](https://github.com/datacite/sashimi/issues/19)
- SQS trigger for sending usage reports [\#14](https://github.com/datacite/sashimi/issues/14)
- Basic filtering [\#11](https://github.com/datacite/sashimi/issues/11)
- Robust swagger documentation [\#10](https://github.com/datacite/sashimi/issues/10)

**Merged pull requests:**

- remove metrics mentiones [\#32](https://github.com/datacite/sashimi/pull/32) ([kjgarza](https://github.com/kjgarza))

## [v0.0.3](https://github.com/datacite/sashimi/tree/v0.0.3) (2018-05-28)

[Full Changelog](https://github.com/datacite/sashimi/compare/v0.0.2...v0.0.3)

**Closed issues:**

- serialization is missing some attributos [\#25](https://github.com/datacite/sashimi/issues/25)

## [v0.0.2](https://github.com/datacite/sashimi/tree/v0.0.2) (2018-05-28)

[Full Changelog](https://github.com/datacite/sashimi/compare/v0.0.1...v0.0.2)

**Closed issues:**

- Reports submission not accurately tracking temporal coverage [\#22](https://github.com/datacite/sashimi/issues/22)
- Accepting country-counts as part of instance submissions? [\#21](https://github.com/datacite/sashimi/issues/21)

**Merged pull requests:**

- Bug variousfixes [\#28](https://github.com/datacite/sashimi/pull/28) ([kjgarza](https://github.com/kjgarza))

## [v0.0.1](https://github.com/datacite/sashimi/tree/v0.0.1) (2018-05-15)

[Full Changelog](https://github.com/datacite/sashimi/compare/75489c63dc5e74d16ce12cc5383c414cc6517c01...v0.0.1)

**Closed issues:**

- HTTP Response 413: Request entity too large POSTing to /reports [\#17](https://github.com/datacite/sashimi/issues/17)
- set strong parameters [\#15](https://github.com/datacite/sashimi/issues/15)
- MVP for architecture- to write up a document on how we will be using the architecture in the future \(future development, syntax, sample call, etc…\) [\#9](https://github.com/datacite/sashimi/issues/9)
- Add specs for models and requests [\#7](https://github.com/datacite/sashimi/issues/7)
- Use ids for models [\#6](https://github.com/datacite/sashimi/issues/6)
- Refactor to use AWS SQS instead if sidekiq when background jobs are needed [\#5](https://github.com/datacite/sashimi/issues/5)
- Hub App definition [\#3](https://github.com/datacite/sashimi/issues/3)
- Spec fo Technical Hub v0 [\#2](https://github.com/datacite/sashimi/issues/2)
- Study about Sushi Specification [\#1](https://github.com/datacite/sashimi/issues/1)

**Merged pull requests:**

- Feature UPSERT for Sashimi report [\#27](https://github.com/datacite/sashimi/pull/27) ([kjgarza](https://github.com/kjgarza))
- Feature send reports sqs [\#18](https://github.com/datacite/sashimi/pull/18) ([kjgarza](https://github.com/kjgarza))
- Feature kebab case normalisation [\#13](https://github.com/datacite/sashimi/pull/13) ([kjgarza](https://github.com/kjgarza))
- Feature sushi validation [\#12](https://github.com/datacite/sashimi/pull/12) ([kjgarza](https://github.com/kjgarza))
- Authentication [\#8](https://github.com/datacite/sashimi/pull/8) ([mfenner](https://github.com/mfenner))
- Chore apispec [\#4](https://github.com/datacite/sashimi/pull/4) ([kjgarza](https://github.com/kjgarza))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
