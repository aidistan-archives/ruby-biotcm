require 'optparse'

# A built-in app for gene detection
class BioTCM::Apps::GeneDetector < BioTCM::Apps::App
  # Version of GeneDetector
  VERSION = '0.1.0'
  # Default patterns of genes to exclude
  DEFAULT_GENE_BLACKLIST = [
    '^\w$',
    '^\d'
  ]
  # Default patterns of text to exclude
  DEFAULT_TEXT_BLACKLIST = [
  ]

  # Initialize a gene detector
  def initialize(
    gene_blacklist:DEFAULT_GENE_BLACKLIST,
    text_blacklist:DEFAULT_TEXT_BLACKLIST,
    if_formalize:true
  )
    @gene_regexp = gene_blacklist.empty? ? nil : Regexp.new('(' + gene_blacklist.join(')|(') + ')')
    @text_regexp = text_blacklist.empty? ? nil : Regexp.new('(' + text_blacklist.join(')|(') + ')')
    @if_formalize = if_formalize
  end
  # Detect genes appearing in text
  # @param text [String]
  # @return [Array] list of symbols
  def detect(text)
    # Check dependency
    BioTCM::Databases::HGNC.ensure
    # Prepare symbol list
    unless @symbols
      @symbols = String.hgnc.symbol2hgncid.keys
      # Exclude symbol patterns
      @symbols.reject! { |sym| sym =~ @gene_regexp } if @gene_regexp
    end
    # Exclude text patterns
    text.gsub!(@text_regexp, ' ') if @text_regexp
    # Split sentences into words and eliminate redundancies
    rtn = text.split(/\.\s|\s?[,:!?#()\[\]{}]\s?|\s/).uniq & @symbols
    # Return approved symbols
    @if_formalize ? rtn.formalize_symbol.uniq : rtn
  end
  # Run
  def run
    # Get options
    options = {
      output: 'gene-detector.out.txt'
    }
    optparser = OptionParser.new do |opts|
      opts.banner = 'Usage: biotcm gene-detector input_file [OPTIONS]'

      opts.on('-o', '--output [FILE]', String, 'Output to FILE') do |v|
        options[:output] = v
      end
    end
    optparser.parse!
    # Run the app
    if ARGV[0]
      File.open(options[:output], 'w').puts detect(File.open(ARGV.shift).read)
    else
      puts optparser.to_s
    end
  end
end
