# frozen_string_literal: true

module AEMO
  class Region
    DISPATCH_TYPE   = ['Generator', 'Load Norm Off', 'Network Service Provider'].freeze
    CATEGORY        = ['Market', 'Non-Market'].freeze
    CLASSIFICATION  = ['Scheduled', 'Semi-Scheduled', 'Non-Scheduled'].freeze
  end
end
