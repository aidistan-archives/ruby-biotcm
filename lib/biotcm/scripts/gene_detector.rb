# encoding: UTF-8

# For gene detection
class BioTCM::Scripts::GeneDetector < BioTCM::Scripts::Script
  # Version of GeneDetector
  VERSION = '0.1.0'
  # Default patterns of genes to exclude
  DEFAULT_GENE_BLACKLIST = [
    '^\w$',
    '^\d',
  ]
  # Default patterns of text to exclude
  DEFAULT_TEXT_BLACKLIST = [
  ]

  # Initialize a gene detector
  def initialize(
    gene_blacklist:DEFAULT_GENE_BLACKLIST, 
    text_blacklist:DEFAULT_TEXT_BLACKLIST, 
    if_regularize:true
  )
    @gene_regexp = gene_blacklist.empty? ? nil : Regexp.new('(' + gene_blacklist.join(')|(') + ')')
    @text_regexp = text_blacklist.empty? ? nil : Regexp.new('(' + text_blacklist.join(')|(') + ')')
    @if_regularize = if_regularize
  end
  # Detect genes appearing in text
  # @param text [String]
  # @return [Array]
  def run(text)
    # Check dependency
    "".symbol2hgncid rescue BioTCM::Databases::HGNC.new.as_dictionary
    # Prepare symbol list
    unless @symbols
      @symbols = String.hgnc.symbol2hgncid.keys
      # Exclude symbol patterns
      @symbols.reject! { |sym| sym =~ @gene_regexp } if @gene_regexp
    end
    # Exclude text patterns
    text.gsub!(@text_regexp, " ") if @text_regexp
    # Split sentences into words and eliminate redundancies
    rtn = text.split(/\.\s|\s?[,:!?#()\[\]{}]\s?|\s/).uniq & @symbols
    # Return approved symbols
    return @if_regularize ? rtn.symbol2hgncid.hgncid2symbol.uniq : rtn
  end
  alias_method :detect, :run
end
