# AEMO Gem Changelog

## 0.2.0

* AEMO::Market::Interval objects are now created via the #parse_csv method (NEM12 format) or the #parse_json method. Direct creation has been rubified.
* AEMO::NEM12 is now parsing things better too.

## 0.1.31

AEMO::Market#historic_trading
AEMO::Market#historic_trading_by_range

## 0.1.30

AEMO::NMI#current_annual_load
