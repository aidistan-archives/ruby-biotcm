module BioTCM::Databases::HGNC
  # {HGNC}'s extention to core classes
  module Extentions
    # {HGNC}'s extention to String
    module String
      # Formalize the gene symbol
      # @return '' if fails to formalize
      # @deprecated Use {#to_formal_symbol} instead
      def formalize_symbol
        to_formal_symbol
      end

      # Convert to a formal symbol
      # @return '' if fails to formalize
      def to_formal_symbol
        symbol2hgncid.hgncid2symbol
      end

      # Check the gene symbol whether formal
      def formal_symbol?
        empty? ? false : self == to_formal_symbol
      end
    end

    # {HGNC}'s extention to Array
    module Array
      # Convert to a list of formal symbols
      def to_formal_symbols
        map(&:to_formal_symbol)
      end
    end
  end
end
