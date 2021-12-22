# AEMO Gem
Makes working with AEMO data more pleasant.

[![Gem Version](https://badge.fury.io/rb/aemo.svg)](http://badge.fury.io/rb/aemo)
[![Build Status](https://app.travis-ci.com/jufemaiz/aemo.svg?branch=main)](https://app.travis-ci.com/jufemaiz/aemo)
[![Maintainability](https://api.codeclimate.com/v1/badges/f16f9df6762d9870cd2c/maintainability)](https://codeclimate.com/github/jufemaiz/aemo/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/f16f9df6762d9870cd2c/test_coverage)](https://codeclimate.com/github/jufemaiz/aemo/test_coverage)
[![Coverage Status](https://coveralls.io/repos/github/jufemaiz/aemo/badge.svg?branch=master)](https://coveralls.io/github/jufemaiz/aemo?branch=master)
[![Known Vulnerabilities](https://snyk.io/test/github/jufemaiz/aemo/badge.svg)](https://snyk.io/test/github/jufemaiz/aemo)
[![Help Contribute to Open Source](https://www.codetriage.com/jufemaiz/aemo/badges/users.svg)](https://www.codetriage.com/jufemaiz/aemo)
[![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=jufemaiz_aemo)](https://sonarcloud.io/summary/new_code?id=jufemaiz_aemo)


# Documentation

<http://www.rubydoc.info/gems/aemo>

# Installation

## Ruby Versions Supported

*   ruby-head (failures allowed)
*   3.1.0-preview1 (failures allowed)
*   3.0 (.0, .1, .2, .3)
*   2.7 (.0, .1, .2, .3, .4, .5)
*   2.6 (.0, .1, .2, .3, .4, .5, .6, .7, .8, .9)

### Deprecated

*   2.5
*   2.4
*   2.3
*   2.2

## Manually from RubyGems.org

```sh
% gem install aemo
```

## Or if you are using Bundler

```ruby
# frozen_string_literal: true

# Gemfile
source 'https://rubygems.org' do
  gem 'aemo'
end
```

# Maintenance

## Updating loss factors

1.  Connect to AEMO via VPN (tip: be a market participant in order to unlock
    this step)
1.  Log in to [MSATS](https://msats.prod.nemnet.net.au/)
1.  Navigate to Reports and Alerts » CATS » C1 - Data Replication
    Resynchronisation Report - Data Replication Resynchronisation Report (C1)
1.  Export both the CATS_DLF_CODES and CATS_TNI_CODES tables (from 1-Jan-1970 to
    the current date, both with 30,000 max rows)
1.  Wait...
1.  Wait some more...
1.  Navigate to Participant Outbox (you have new messages link)
1.  Get the file!
1.  Run the following:
    ```ruby
    cd lib/data && ruby xml_to_json.rb
    ```
1.  Add tests for your new FY to spec/lib/aemo/nmi_spec.rb
1.  `rspec` - note that AEMO can retroactively change factors so if there is an
    old failing test double check the json to make sure it's not AEMO's fault.
1.  Commit, push & [create a pull request](http://github.com/jufemaiz/aemo/pull/new)
