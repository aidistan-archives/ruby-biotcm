require 'optparse'

# A built-in app for gene detection
class BioTCM::Apps::GeneDetector < BioTCM::Apps::App
  # Version of GeneDetector
  VERSION = '0.1.1'
  # Default patterns of genes to exclude
  DEFAULT_GENE_BLACKLIST = [
    '^\w$',
    '^\d'
  ]
  # Default patterns of text to transform
  DEFAULT_TEXT_CHANGELIST = [
    [/ type I receptor/i, 'R1'],
    [/ type II receptor/i, 'R2'],
    [/ R I/i, 'R1'],
    [/ R II/i, 'R2'],
    [/(\s*|-*)alpha/i, 'A'],
    [/(\s*|-*)beta/i, 'B'],
    [/(\s*|-*)gamma/i, 'G'],
    [/(\s*|-*)kappa/i, 'K'],
  ]

  # Initialize a gene detector
  def initialize(
    gene_blacklist: [],
    text_changelist: [],
    if_formalize: true
  )
    @gene_regexp = Regexp.new('(' + (DEFAULT_GENE_BLACKLIST + gene_blacklist).join(')|(') + ')')
    @text_changelist = text_changelist
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
      @symbols.reject! { |sym| sym =~ @gene_regexp }
    end
    # Transform text
    (DEFAULT_TEXT_CHANGELIST + @text_changelist).each do |item|
      text.gsub!(item[0], item[1])
    end

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
