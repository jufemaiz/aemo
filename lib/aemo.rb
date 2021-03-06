# frozen_string_literal: true

require 'active_support/all'
require 'httparty'
require 'csv'

require 'aemo/region.rb'
require 'aemo/market.rb'
require 'aemo/market/interval.rb'
require 'aemo/market/node.rb'
require 'aemo/meter.rb'
require 'aemo/nem12.rb'
require 'aemo/nmi.rb'
require 'aemo/nmi/allocation.rb'
require 'aemo/msats.rb'
require 'aemo/register.rb'
require 'aemo/version.rb'
require 'aemo/exceptions/invalid_nmi_allocation_type.rb'

# AEMO Module to encapsulate all AEMO classes
module AEMO
end
