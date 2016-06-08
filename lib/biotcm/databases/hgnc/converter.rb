module BioTCM::Databases::HGNC
  # Converter module
  module Converter
    # Get a list of existing converters
    # @return [Hash]
    def converter_list
      { direct: @direct_converters, indirect: @indirect_converters }
    end

    # @private
    def create_direct_converter(sym)
      instance_eval %{
        def #{sym}(obj = nil)
          return @#{sym} unless obj
          return @#{sym}[obj.to_s].to_s rescue raise ArgumentError, "The parameter \\"\#{obj}\\"(\#{obj.class}) can't be converted into String"
        end
      }

      @string_mixin += %{
        def #{sym}
          BioTCM::Databases::HGNC.#{sym}[self].to_s
        end
        def #{sym}!
          replace(BioTCM::Databases::HGNC.#{sym}[self].to_s)
        end
      }

      @array_mixin += %{
        def #{sym}
          self.collect do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect { |item| item.#{sym} }
        end
        def #{sym}!
          self.collect! do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect! { |item| item.#{sym} }
        end
      }

      @direct_converters << sym
    end

    # @private
    def create_indirect_converter(sym)
      /^(?<src>[^2]+)2(?<dst>.+)$/ =~ sym.to_s

      instance_eval %{
        def #{sym}(obj)
          return hgncid2#{dst}(#{src}2hgncid(obj)) rescue raise ArgumentError, "The parameter \\"\#{obj}\\"(\#{obj.class}) can't be converted into String"
        end
      }

      @string_mixin += %{
        def #{sym}
          self.#{src}2hgncid.hgncid2#{dst}
        end
        def #{sym}!
          replace(self.#{src}2hgncid.hgncid2#{dst})
        end
      }

      @array_mixin += %{
        def #{sym}
          self.collect do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect { |item| item.#{src}2hgncid.hgncid2#{dst} }
        end
        def #{sym}!
          self.collect! do |item|
            item.to_s rescue raise ArgumentError, "The element \\"\#{item}\\"(\#{item.class}) in the Array can't be converted into String"
          end.collect! { |item| item.#{src}2hgncid.hgncid2#{dst} }
        end
      }

      @indirect_converters << sym
    end

    def self.extended(mod)
      mod.instance_eval do
        # Initialize instance variables
        @direct_converters = []
        @indirect_converters = []
        @string_mixin = ''
        @array_mixin = ''

        # Create converters
        IDENTIFIERS.each_key do |src|
          IDENTIFIERS.each_key do |dst|
            next if src == dst
            sym = (src.to_s + '2' + dst.to_s).to_sym
            [src, dst].include?(:hgncid) ? create_direct_converter(sym) : create_indirect_converter(sym)
          end
        end

        # Initialize converter hashes
        @direct_converters.each { |sym| instance_variable_set('@' + sym.to_s, {}) }
      end
    end
  end
end
