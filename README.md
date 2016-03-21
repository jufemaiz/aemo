# AEMO Gem
Makes working with AEMO data more pleasant.

## Market Information

## NEM12 Files

## NEM13 Files

## NMI

## MSATS

MSATS is the [Market Settlements And Trading System](http://www.aemo.com.au/Electricity/Policies-and-Procedures/Market-Settlement-and-Transfer-Solutions). This gem currently only provides support for AEMO's MSATS Web Services and does not provide capabilities around the B2B Inbox or other services not exposed via the AEMO Web Service.

Further information available at [AEMO's website](http://www.aemo.com.au/About-the-Industry/Information-Systems/Using-Energy-Market-Information-Systems)

### Authentication

Authentication requires an MSATS username and password configured for your participant id.

```RUBY
AEMO::MSATS(PARTICIPANT_ID, USERNAME, PASSWORD)
```

### C4 Query

```
AEMO::MSATS.c4(nmi, from_date,to_date,as_at_date, options = {})
```

### MSATS Limits Query

```
AEMO::MSATS.msats_limits
```

### NMI Discovery By Delivery Point Identifier Query

```
AEMO::MSATS.nmi_discovery_by_delivery_point_identifier(jurisdiction_code,delivery_point_identifier)
```

### NMI Discovery By Meter Serial Number Identifier Query

```
AEMO::MSATS.nmi_discovery_by_meter_serial_number(jurisdiction_code,meter_serial_number)
```

### NMI Discovery By Address Query

```
AEMO::MSATS.nmi_discovery_by_address(jurisdiction_code,options = {})
```

#### Options

:building_or_property_name
:location_descriptor
:lot_number
:flat_or_unit_number
:flat_or_unit_type
:floor_or_level_number
:floor_or_level_type
:house_number
:house_number_suffix
:street_name
:street_suffix
:street_type
:suburb_or_place_or_locality
:postcode
:state_or_territory

### MSATS System Status Query

```
AEMO::MSATS.system_status
```

### NMI Detail Query

```
AEMO::MSATS.nmi_detail(nmi, options = {})
```

#### Options

:type
:reason

# Build Status

[![Build Status](https://travis-ci.org/jufemaiz/aemo.svg?branch=master)](https://travis-ci.org/jufemaiz/aemo)

# Coverage Status

[![Coverage Status](https://coveralls.io/repos/github/jufemaiz/aemo/badge.svg?branch=master)](https://coveralls.io/github/jufemaiz/aemo?branch=master)
