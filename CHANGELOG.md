# AEMO Gem Changelog

## [v0.4.0] (2021-12-22)

### Added

*   Support for Ruby 3.
*   [SonarCloud](https://sonarcloud.io/project/issues?id=jufemaiz_aemo) support.

### Changed

*   Migrated to [travis-ci.com](https://travis-ci.com/github/jufemaiz/aemo).

## [v0.3.6] (2020-03-11)

### Changed

* Bump nokogiri from 1.10.4 to 1.10.8
* Bump rack from 2.0.7 to 2.0.8.
* Update .travis.yml.

### Fixed

* Include updated at and MSATS load date in NEM12 data structure.

## [v0.3.5] (2019-08-20)

*   Upgrade [nokogiri](https://rubygems.org/gems/nokogiri) to v1.10.4 to resolve
    vulnerability:
    *   [CVE-2019-5477](https://nvd.nist.gov/vuln/detail/CVE-2019-5477)

## [v0.3.4] (2019-07-04)

*   Bump [yard](https://github.com/lsegal/yard) from 0.9.16 to 0.9.20
*   Added support for ruby versions: 2.6.3, 2.6.2, 2.5.5, 2.5.4, 2.4.6
*   Using [bundler](https://rubygems.com/gems/bundler) 2.0.2


## [v0.3.3] (2018-11-17)

*   Upgrade [nokogiri](https://rubygems.org/gems/nokogiri) to v1.8.5 to resolve
    vulnerabilities:
    *   [CVE-2018-14404](https://nvd.nist.gov/vuln/detail/CVE-2018-14404)
    *   [CVE-2018-14567](https://nvd.nist.gov/vuln/detail/CVE-2018-14567)
*   Set [ffi](https://rubygems.org/gems/ffi) and
    [rack](https://rubygems.org/gems/rack) versions to resolve vulnerabilities.

## [v0.3.2]

*   Support JSON v2.x.y JSON (#46)

## [v0.3.1]

*   Catch invalid length  NEM12 records (300 and 400)

## [v0.3.0]

*   Refactor NMI allocations
*   Return an empty array on empty NEM12 file or string.

## [v0.2.1]

*   Loss factors for FY18

## [v0.2.0]

*   Default NEM12 parsing to use strict validation
*   Only enforce validation of NMIConfiguration in strict mode

## [v0.1.45]

*   [Nokogiri vulnerability](https://rubysec.com/advisories/nokogiri-CVE-2017-15412)
    update

## [v0.1.44]

*   [YARD vulnerability](https://rubysec.com/advisories/yard-CVE-2017-17042)
    update

## [v0.1.42]

*   Dependency updates to support Rails 5.1

## [v0.1.41]

*   Dependency updates
*   Drop support for old versions of Ruby. Currently supported versions are:
    *   ruby-head
    *   2.4 (.0, .1, .2)
    *   2.3 (.0, .1, .2, .3, .4, .5)
    *   2.2 (.5, .6, .7, .8)

## [v0.1.40]

*   Remove ZIP
*   Update loss factor data including finalised values according to FY18 data
    available at:
    <http://www.aemo.org.au/Electricity/National-Electricity-Market-NEM/Security-and-reliability/Loss-factor-and-regional-boundaries>

### (TNI/MLF errata 2017-10-18)

*   NCAR FY17 listed as 1.0035 in the FY18 publication (we had 1.0016)
*   NCB1 has disappeared in FY18
*   NFNY FY17 listed as 1.0825 in the FY18 publication (we had 1.0157)
*   NLTS FY17 listed as 0.9897 in the FY18 publication (we had 1.0142)
*   NPH1 has disappeared in FY18
*   NSHN FY17 listed as 0.9904 in the FY18 publication (we had 1.0001)
*   SNPS has gone offline in FY18
*   SPPS has gone offline in FY18
*   A whole bunch of new generation added

## [v0.1.39]

*   AEMO went and changed their data schema. Need to point historical requests
    at something like:
    <http://aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_201601_QLD1.csv>

## [v0.1.38]

*   `AEMO::NMI::DLF_CODES` updates for FY17.

## [v0.1.37]

*   General Gem dependency updates.

## [v0.1.36]

*   Minor change to `AEMO::NMI::NMI_ALLOCATIONS` for a 'State' to be an instance
    of `AEMO::Region`

## [v0.1.34]

*   Added `AEMO::Market::Node` to deal with Region v Node differences

## [v0.1.33]

*   [Rubocop](https://github.com/rubocop-hq/rubocop) lint bugfix
    (`AEMO::NEM12.parse_nem12` not breaking up rows correctly)
*   [Timecop](https://github.com/travisjeffery/timecop) added to deal with
    [RSpec](https://rspec.info/) failures for unpublished `TNI` Data
*   FY17 Marginal Loss Factors added from
    <http://www.aemo.com.au/Electricity/Market-Operations/Loss-Factors-and-Regional-Boundaries/Distribution-Loss-Factors-for-the-2016_17-Financial-Year>

## [v0.1.32]

*   [Nokogiri](https://github.com/sparklemotion/nokogiri) security flaw patched
    (Ref: [Issue #1374](https://github.com/sparklemotion/nokogiri/issues/1374))

## [v0.1.31]

*   `AEMO::Market#historic_trading`
*   `AEMO::Market#historic_trading_by_range`

## [v0.1.30]

*   `AEMO::NMI#current_annual_load`
