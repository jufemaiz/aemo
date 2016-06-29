require 'active_support/all'
require 'httparty'
require 'csv'

require 'aemo/region.rb'
require 'aemo/market.rb'
require 'aemo/market/interval.rb'
require 'aemo/nem12.rb'
require 'aemo/nem12/header.rb'
require 'aemo/nem12/nmi_data_details.rb'
require 'aemo/nmi.rb'
require 'aemo/msats.rb'
require 'aemo/version.rb'

# Namespace for classes and modules that handle AEMO interactions
# @since 0.0.0
module AEMO
end
