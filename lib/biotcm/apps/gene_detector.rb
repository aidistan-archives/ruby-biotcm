# To detect gene symbols in text
#
# = Exampe Usage
#   BioTCM::Apps::GeneDetector.new.detect(str)
#
class BioTCM::Apps::GeneDetector
  # Version of GeneDetector
  VERSION = '0.2.1'.freeze

  # Default patterns of genes to exclude
  DEFAULT_GENE_BLACKLIST = [
    '^\w$',
    '^\d'
  ].freeze

  # Default patterns of text to transform
  DEFAULT_TEXT_CHANGELIST = [
    [/ type I receptor/i, 'R1'],
    [/ type II receptor/i, 'R2'],
    [/ R I/i, 'R1'],
    [/ R II/i, 'R2'],
    [/(\s*|-*)alpha/i, 'A'],
    [/(\s*|-*)beta/i, 'B'],
    [/(\s*|-*)gamma/i, 'G'],
    [/(\s*|-*)kappa/i, 'K']
  ].freeze

  # Initialize a gene detector
  # @param gene_blacklist [Array]
  # @param text_changelist [Array]
  # @param if_formalize [Boolean]
  def initialize(
    gene_blacklist: [],
    text_changelist: [],
    if_formalize: true
  )
    @gene_blacklist = Regexp.new('(' + (DEFAULT_GENE_BLACKLIST + gene_blacklist).join(')|(') + ')')
    @text_changelist = DEFAULT_TEXT_CHANGELIST + text_changelist
    @if_formalize = if_formalize
  end

  # Detect genes appearing in text
  # @param text [String]
  # @return [Array] list of symbols
  def detect(text)
    # Check dependency
    BioTCM::Databases::HGNC.ensure

    # Prepare symbols
    unless instance_variable_defined?(:@symbols)
      @symbols = BioTCM::Databases::HGNC.symbol2hgncid.keys
      @symbols.reject! { |sym| sym =~ @gene_blacklist }
    end

    # Transform text
    @text_changelist.each do |item|
      text.gsub!(item[0], item[1])
    end

    # Split sentences into words and eliminate redundancies
    rtn = text.split(/\.\s|\s?[,:!?#()\[\]{}]\s?|\s/).uniq & @symbols

    # Return approved symbols
    @if_formalize ? rtn.map(&:to_formal_symbol).uniq : rtn
  end
end
