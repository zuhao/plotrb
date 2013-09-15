require 'yajl'
require 'json'
require 'uri'

require_relative 'plotrb/base'

require_relative 'plotrb/data'
require_relative 'plotrb/transforms'
require_relative 'plotrb/scales'
require_relative 'plotrb/marks'
require_relative 'plotrb/axes'
require_relative 'plotrb/kernel'
require_relative 'plotrb/visualization'

module Plotrb

end

class Object

  include ::Plotrb::Kernel

end
