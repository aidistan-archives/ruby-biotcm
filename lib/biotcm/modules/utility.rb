# encoding: UTF-8
require 'net/http'

# Provide some utility functions
module BioTCM::Modules::Utility
  module_function
  public
  # Get an url
  # @return [String]
  def get(url)
    uri = URI(url)
    case uri.scheme
    when 'http'
      Net::HTTP.get(uri)
    else
      nil
    end
  end
  # Get a stamp string containing time and thread_id
  # @return [String]
  # @example
  #   Bioinfo::Utility.get_timestamp # => "20140314_011353_1bbfd18"
  def get_stamp
    Time.now.to_s.split(" ")[0..1]
        .push((Thread.current.object_id<<1).to_s(16))
        .join("_").gsub(/-|:/,"")
  end
end
