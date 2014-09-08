require 'net/http'

module BioTCM
  module Modules
    # Provide utility functions
    module Utility
      # A useful method for diverse purposes
      # @overload get(url)
      #   Get an url
      #   @param url [String]
      #   @return [String] if success, the content
      #   @return [nil] if cannot recognize the scheme
      # @overload get(:stamp)
      #   Get a stamp string containing time and thread_id
      #   @return [String]
      #   @example
      #     BioTCM::Modules::Utility.get(:stamp) # => "20140314_011353_1bbfd18"
      def get(obj)
        case obj
        when String
          uri = URI(obj)
          case uri.scheme
          when 'http'
            Net::HTTP.get(uri)
          else
            nil
          end
        when :stamp
          Time.now.to_s.split(" ")[0..1]
              .push((Thread.current.object_id<<1).to_s(16))
              .join("_").gsub(/-|:/,"")
        end
      end
    end
  end
end
