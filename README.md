# AEMO Gem
Makes working with AEMO data more pleasant.

[![Gem Version](https://badge.fury.io/rb/aemo.svg)](http://badge.fury.io/rb/aemo)
[![Build Status](https://travis-ci.org/jufemaiz/aemo.svg?branch=master)](https://travis-ci.org/jufemaiz/aemo)
[![Dependency Status](https://gemnasium.com/jufemaiz/aemo.svg)](https://gemnasium.com/jufemaiz/aemo)
[![Code Climate](https://codeclimate.com/github/jufemaiz/aemo/badges/gpa.svg)](https://codeclimate.com/github/jufemaiz/aemo)
[![Coverage Status](https://coveralls.io/repos/github/jufemaiz/aemo/badge.svg?branch=master)](https://coveralls.io/github/jufemaiz/aemo?branch=master)

# Installation

## Manually from RubyGems.org ###

```sh
% gem install aemo
```

## Or if you are using Bundler ###

```ruby
# Gemfile
gem 'aemo'
```

# Using AEMO Gem

## Market Information

Access to AEMO Market Information from www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_5#NSW1.csv or www.nemweb.com.au/mms.GRAPHS/GRAPHS/GRAPH_30#NSW1.csv

### Regions

```RUBY
AEMO::Market::REGIONS
```

### Current Dispatch

```RUBY
AEMO::Market.current_dispatch('NSW')
```

### Current Trading

```RUBY
AEMO::Market.current_trading('NSW')
```

## Market::Interval

### Initialize

```RUBY
AEMO::Market::Interval.new(datetime, { region: 'NSW', total_demand: 123.456, rrp: 78.96, periodtype: 'TRADING'})
```

### parse_csv

```RUBY
AEMO::Market::Interval.parse_csv(CSV::Row)
```

### parse_json

```RUBY
AEMO::Market::Interval.parse_json(String)
```

### datetime

```RUBY
interval.datetime
```

### Interval Length

```RUBY
interval.interval_length
```

### Interval Type

```RUBY
interval.interval_type
```

### Is Dispatch?

```RUBY
interval.is_dispatch?
```

### Is Trading?

```RUBY
interval.is_trading?
```

### Value

The value of the interval in Australian Dollars

```RUBY
interval.value
```

## Region

AEMO Regions.

### REGIONS

Hash of abbreviations to fullnames of AEMO regions.

```RUBY
AEMO::Region::REGIONS
```

### initialize

```RUBY
AEMO::Region.new('NSW')
```

### abbr

```RUBY
region.abbr
```

### to_s

```RUBY
region.to_s
```

### fullname

```RUBY
region.fullname
```

### current_dispatch

```RUBY
region.current_dispatch
```

### current_trading

```RUBY
region.current_trading
```

### All

```RUBY
AEMO::Region.all
```

## NEM12 Files

TODO: Update this to provide more information on these class constants.

RECORD_INDICATORS
TRANSACTION_CODE_FLAGS
UOM
UOM_NON_SPEC_MAPPING
QUALITY_FLAGS
METHOD_FLAGS
REASON_CODES
DATA_STREAM_SUFFIX

### Initialize

```RUBY
AEMO::NEM12.new(nmi)
```

### Flag to String

```RUBY
nem12.flag_to_s
```

### To Array

```RUBY
nem12.to_a
```

### To CSV

```RUBY
nem12.to_csv
```

### Parse NEM12 File

```RUBY
AEMO::NEM12.parse_nem12_file(path_to_file)
```

### Parse NEM12 String

```RUBY
AEMO::NEM12.parse_nem12(string)
```


## NEM13 Files

## NMI

General support for a National Meter Identifier.

### Regions

```RUBY
AEMO::NMI::REGIONS
```

### NMI Allocations

NMIs have been allocated to DNSPs by AEMO. Provides an easy lookup of the network for a given NMI.

```RUBY
AEMO::NMI::NMI_ALLOCATIONS
```

### Distribution Loss Factors

Distribution Loss Factor Codes as a hash of the code to the various sets of data from AEMO.

```RUBY
AEMO::NMI::DLF_CODES
```

### Transmission Node Identifiers & Marginal Loss Factors

Transmission Node Identifiers as a hash of the TNI to the various sets of data from AEMO including relevant Marginal Loss Factors.

```RUBY
AEMO::NMI::TNI_CODES
```

### Create

```RUBY
nmi = AEMO::NMI.new("4001234567")
```

### Valid NMI?

```RUBY
nmi.valid_nmi?
```

### Valid Checksum?

```RUBY
nmi.valid_checksum?(checksum_value)
```

### Network

Returns the network information based on NMI allocation.

```RUBY
nmi.network
```

### Checksum

Returns the checksum for a NMI

```RUBY
nmi.checksum
```

### Raw MSATS NMI Detail Data

Returns MSATS NMI Detail data as opposed to mapping it into

```RUBY
nmi.raw_msats_nmi_detail(options)
```

### Update from MSATS

Requires MSATS authorization to work. Sets attributes from MSATS NMI Detail request data.

```RUBY
nmi = AEMO::NMI.new("4001234567")
nmi.update_from_msats!
```

### Friendly Address

Helper method for friendly address for a NMI from AEMO's structured address.

```RUBY
nmi.friendly_address
```

### Meters by Status

Returns the meters for a provided status ("C(urrent)" or "R(etired)").

```RUBY
nmi.meters_by_status(status)
```

### Data Streams by Status

Returns the data streams for a provided status ("A(ctive)" or "I(nactive)").

```RUBY
nmi.data_streams_by_status(status)
```

### Current Daily Load

Provides current daily load for the NMI instead of at a data stream level.

```RUBY
nmi.current_daily_load
```

### Transmission Node Identifier Margin Loss Factor Value

Returns the TNI MLF value for a given datetime.

```RUBY
nmi.tni_value(datetime)
```

### Distribution Loss Factor Code Value

Returns the DLF value for a given datetime.

```RUBY
nmi.dlfc_value(datetime)
```

## MSATS

MSATS is the [Market Settlements And Trading System](http://www.aemo.com.au/Electricity/Policies-and-Procedures/Market-Settlement-and-Transfer-Solutions). This gem currently only provides support for AEMO's MSATS Web Services and does not provide capabilities around the B2B Inbox or other services not exposed via the AEMO Web Service.

Further information available at [AEMO's website](http://www.aemo.com.au/About-the-Industry/Information-Systems/Using-Energy-Market-Information-Systems)

### Authentication

Authentication requires an MSATS username and password configured for your participant id.

```RUBY
AEMO::MSATS(PARTICIPANT_ID, USERNAME, PASSWORD)
```

### C4 Query

```RUBY
AEMO::MSATS.c4(nmi, from_date,to_date,as_at_date, options = {})
```

### MSATS Limits Query

```RUBY
AEMO::MSATS.msats_limits
```

### NMI Discovery By Delivery Point Identifier Query

```RUBY
AEMO::MSATS.nmi_discovery_by_delivery_point_identifier(jurisdiction_code,delivery_point_identifier)
```

### NMI Discovery By Meter Serial Number Identifier Query

```RUBY
AEMO::MSATS.nmi_discovery_by_meter_serial_number(jurisdiction_code,meter_serial_number)
```

### NMI Discovery By Address Query

```RUBY
AEMO::MSATS.nmi_discovery_by_address(jurisdiction_code,options = {})
```

#### Options

* :building_or_property_name
* :location_descriptor
* :lot_number
* :flat_or_unit_number
* :flat_or_unit_type
* :floor_or_level_number
* :floor_or_level_type
* :house_number
* :house_number_suffix
* :street_name
* :street_suffix
* :street_type
* :suburb_or_place_or_locality
* :postcode
* :state_or_territory

### MSATS System Status Query

```RUBY
AEMO::MSATS.system_status
```

### NMI Detail Query

```RUBY
AEMO::MSATS.nmi_detail(nmi, options = {})
```

#### Options

* :type
* :reason
