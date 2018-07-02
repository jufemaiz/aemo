# AEMO Gem Changelog

## 0.2.2

* Return an empty array on empty NEM12 file or string.

## 0.2.1

* Loss factors for FY18

## 0.2.0

* Default NEM12 parsing to use strict validation
* Only enforce validation of NMIConfiguration in strict mode

## 0.1.45

* [Nokogiri vulnerability](https://rubysec.com/advisories/nokogiri-CVE-2017-15412) update

## 0.1.44

* [YARD vulnerability](https://rubysec.com/advisories/yard-CVE-2017-17042) update

## 0.1.42

* Dependency updates to support Rails 5.1

## 0.1.41

* Dependency updates
* Drop support for old versions of Ruby. Currently supported versions are:
  * ruby-head
  * 2.4 (.0, .1, .2)
  * 2.3 (.0, .1, .2, .3, .4, .5)
  * 2.2 (.5, .6, .7, .8)

## 0.1.40

* Remove ZIP
* Update loss factor data including finalised values according to FY18 data
  available at:
  http://www.aemo.org.au/Electricity/National-Electricity-Market-NEM/Security-and-reliability/Loss-factor-and-regional-boundaries

### (TNI/MLF errata 2017-10-18)

* NCAR FY17 listed as 1.0035 in the FY18 publication (we had 1.0016)
* NCB1 has disappeared in FY18
* NFNY FY17 listed as 1.0825 in the FY18 publication (we had 1.0157)
* NLTS FY17 listed as 0.9897 in the FY18 publication (we had 1.0142)
* NPH1 has disappeared in FY18
* NSHN FY17 listed as 0.9904 in the FY18 publication (we had 1.0001)
* SNPS has gone offline in FY18
* SPPS has gone offline in FY18
* A whole bunch of new generation added

## 0.1.39

* AEMO went and changed their data schema. Need to point historical requests
at something like:
http://aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_201601_QLD1.csv

## 0.1.38

* AEMO::NMI::DLF_CODES updates for FY17.

## 0.1.37

* Gem updates.

## 0.1.36

* Minor change to AEMO::NMI::NMI_ALLOCATIONS for a 'State' to be an instance of AEMO::Region

## 0.1.34

* Added AEMO::Market::Node to deal with Region v Node differences

## 0.1.33

* Rubocop lint bugfix (AEMO::NEM12.parse_nem12 not breaking up rows correctly)
* Timecop added to deal with RSpec failures for unpublished TNI Data
* FY17 Marginal Loss Factors added from http://www.aemo.com.au/Electricity/Market-Operations/Loss-Factors-and-Regional-Boundaries/Distribution-Loss-Factors-for-the-2016_17-Financial-Year

## 0.1.32

* Nokogiri security flaw patched (Ref: https://github.com/sparklemotion/nokogiri/issues/1374 )

## 0.1.31

* AEMO::Market#historic_trading
* AEMO::Market#historic_trading_by_range

## 0.1.30

* AEMO::NMI#current_annual_load
