module BioTCM::Databases::HGNC
  # Rescuer module
  module Rescuer
    # Return true if rescue symbol
    # @return [Boolean]
    def rescue_symbol?
      @rescue_symbol
    end

    # When set to true, try to rescue unrecognized symbol (default is true)
    # @param boolean [Boolean]
    def rescue_symbol=(boolean)
      @rescue_symbol = (boolean ? true : false)
    end

    # Return current rescue method
    # @return [Symbol] :manual or :auto
    def rescue_method
      @rescue_method
    end

    # When set to :manual, user has to explain every new unrecognized symbol;
    # otherwise, HGNC will try to do this by itself.
    # @param symbol [Symbol] :manual or :auto
    def rescue_method=(symbol)
      @rescue_method = (symbol == :manual ? :manual : :auto)
    end

    # Try to rescue a gene symbol
    # @param symbol [String] Gene symbol
    # @param method [Symbol] :auto or :manual
    # @param rehearsal [Boolean] When set to true, neither outputing warnings nor modifying rescue history
    # @return [String] "" if rescue failed
    def rescue_symbol(symbol, method = @rescue_method, rehearsal = false)
      return @rescue_history[symbol] if @rescue_history[symbol]

      case method
      when :auto
        auto_rescue = ''

        if @symbol2hgncid[symbol.upcase]
          auto_rescue = symbol.upcase
        elsif @symbol2hgncid[symbol.downcase]
          auto_rescue = symbol.downcase
        elsif @symbol2hgncid[symbol.delete('-')]
          auto_rescue = symbol.delete('-')
        elsif @symbol2hgncid[symbol.upcase.delete('-')]
          auto_rescue = symbol.upcase.delete('-')
        elsif @symbol2hgncid[symbol.downcase.delete('-')]
          auto_rescue = symbol.downcase.delete('-')
          # Add more rules here
        end

        # Record
        unless rehearsal
          BioTCM.logger.warn('HGNC') { "Unrecognized symbol \"#{symbol}\", \"#{auto_rescue}\" used instead" }
          @rescue_history[symbol] = auto_rescue
        end

        return auto_rescue
      when :manual
        # Try automatic rescue first
        if (auto_rescue = rescue_symbol(symbol, :auto, true)) != ''
          print "\"#{symbol}\" unrecognized. Use \"#{auto_rescue}\" instead? [Yn] "
          unless gets.chomp == 'n'
            @rescue_history[symbol] = auto_rescue unless rehearsal # rubocop:disable Metrics/BlockNesting
            return auto_rescue
          end
        end

        # Manually rescue
        loop do
          print "Please correct \"#{symbol}\" or press enter directly to return empty String instead:\n"
          unless (manual_rescue = gets.chomp) == '' || @symbol2hgncid[manual_rescue]
            puts "Failed to recognize \"#{manual_rescue}\""
            next
          end
          unless rehearsal
            @rescue_history[symbol] = manual_rescue
            File.open(@rescue_history_filepath, 'a').print(symbol, "\t", manual_rescue, "\n")
          end
          return manual_rescue
        end
      end
    end

    def self.extended(mod)
      mod.instance_eval do
        # Initialize instance variables
        @rescue_symbol = true
        @rescue_method = :auto
        @rescue_history = {}
        @rescue_history_filepath = BioTCM.path_to('hgnc/rescue_history.txt')
        if File.exist?(@rescue_history_filepath)
          File.open(@rescue_history_filepath).each do |line|
            column = line.chomp.split("\t")
            @rescue_history[column[0]] = column[1]
          end
        end

        # Redefine the method to introduce in the rescue function
        class << self
          undef_method :symbol2hgncid

          define_method(:symbol2hgncid) do |*args|
            symbol = args.shift

            return @symbol2hgncid unless symbol
            begin
              @symbol2hgncid.fetch(symbol)
            rescue KeyError
              return '' if symbol == '' || !@rescue_symbol
              @symbol2hgncid[rescue_symbol(symbol)].to_s
            end
          end
        end

        # Use method way other than hash way to introduce in the rescue function
        @string_mixin += %(
          remove_method :symbol2hgncid, :symbol2hgncid!

          def symbol2hgncid
            BioTCM::Databases::HGNC.symbol2hgncid(self)
          end

          def symbol2hgncid!
            replace(BioTCM::Databases::HGNC.symbol2hgncid(self))
          end
        )
      end
    end
  end
end
