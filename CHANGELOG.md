# AEMO Gem Changelog

## v.0.2


### v0.2.0

* AEMO::Market::Interval objects are now created via the #parse_csv method (NEM12 format) or the #parse_json method. Direct creation has been rubified.
* AEMO::NEM12 has been overhauled for data parsing

## v0.1

### v0.1.36

* Minor change to AEMO::NMI::NMI_ALLOCATIONS for a 'State' to be an instance of AEMO::Region

### v0.1.34

* Added AEMO::Market::Node to deal with Region v Node differences

### v0.1.33

* Rubocop lint bugfix (AEMO::NEM12.parse_nem12 not breaking up rows correctly)
* Timecop added to deal with RSpec failures for unpublished TNI Data
* FY17 Marginal Loss Factors added from http://www.aemo.com.au/Electricity/Market-Operations/Loss-Factors-and-Regional-Boundaries/Distribution-Loss-Factors-for-the-2016_17-Financial-Year

### v0.1.32

* Nokogiri security flaw patched (Ref: https://github.com/sparklemotion/nokogiri/issues/1374 )

### v0.1.31

* AEMO::Market#historic_trading
* AEMO::Market#historic_trading_by_range

### v0.1.30

* AEMO::NMI#current_annual_load
>>>>>>> master
