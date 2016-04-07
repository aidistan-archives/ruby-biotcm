require 'net/http'

module BioTCM
  # Provide utility functions
  module Utility
    module_function

    # Get an url
    # @param url [String]
    # @return [String] if success, the content
    # @return [nil] if cannot recognize the scheme
    # @raise RuntimeError if return status is not 200
    def curl(url)
      uri = URI(url)
      case uri.scheme
      when 'http'
        res = Net::HTTP.get_response(uri)
        raise "HTTP status #{res.code} returned when #{uri} sent" unless res.is_a?(Net::HTTPOK)
        return res.body
      end
      nil
    end

    # Get a stamp string containing time and thread_id
    # @return [String]
    # @example
    #   BioTCM::Utility.stamp # => "20140314_011353_1bbfd18"
    def stamp
      Time.now.to_s.split(' ')[0..1]
        .push((Thread.current.object_id << 1).to_s(16))
        .join('_').gsub(/-|:/, '')
    end
  end
end
