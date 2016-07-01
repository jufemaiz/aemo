# AEMO Gem Changelog

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
