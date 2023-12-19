# frozen_string_literal: true

require 'active_support/all'
require 'httparty'
require 'csv'

require 'aemo/struct'
require 'aemo/time'
require 'aemo/region'
require 'aemo/market'
require 'aemo/market/interval'
require 'aemo/market/node'
require 'aemo/meter'
require 'aemo/nem12'
require 'aemo/nmi'
require 'aemo/msats'
require 'aemo/register'
require 'aemo/version'
require 'aemo/exceptions/invalid_nmi_allocation_type'

# AEMO Module to encapsulate all AEMO classes
module AEMO
end
