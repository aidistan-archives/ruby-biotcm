# HGNC module loads in a HGNC flat file and builds hashes storing the conversion
# pairs, using HGNC ID as the primary key.
#
# = Example Usage
#
# == Initialization
# Initialize HGNC using default downloaded table is the most common way. It may
# take minutes to download the table at the first time.
#
#   HGNC = BioTCM::Databases::HGNC.load
#
# == Convert in hash way
# Using HGNC module in hash way is the most effective way but without symbol
# rescue. (Direct converters only)
#
#   HGNC.entrez2hgncid["ASIC1"] # => "HGNC:100"
#   some_function(HGNC.entrez2hgncid["ASIC1"], other_params) unless HGNC.entrez2hgncid["ASIC1"].nil?
#
# Note that nil (not "") will be returned by hash if failed to index.
#
#   HGNC.symbol2hgncid["NOT_SYMBOL"] # => nil
#
# And the hash does not rescue symbols if fail to index.
#
#   HGNC.symbol2hgncid["ada"] # => nil
#
# == Convert in method way
# Using HGNC module to convert identifers in method way would rescue symbol
# while costs a little more.
#
#   HGNC.entrez2symbol("100") # => "ADA"
#   some_function(HGNC.entrez2symbol("100"), other_params) unless HGNC.entrez2symbol("100") == ""
#
# Note that empty String "" (not nil) will be returned if failed to convert.
#
#   HGNC.symbol2entrez["NOT_SYMBOL"] # => ""
#
# Method will rescue symbols if fail to query.
#
#   HGNC.symbol2entrez("ada") # => "100"
#
# == Convert String or Array
# Using extended String or Array is a more "Ruby" way (as far as I think).
# Just claim an HGNC object as the dictionary at first.
#
#   BioTCM::Databases::HGNC.load.as_dictionary
#
# Then miricle happens
#
#   "100".entrez2symbol # => "ADA"
#   some_function("100".entrez2symbol, other_params) unless "100".entrez2symbol == ""
#
# Note that empty String "" (not nil) will be returned if fail to convert
#
#   "NOT_SYMBOL".symbol2entrez # => ""
#   "NOT_SYMBOL".symbol2entrez.entrez2ensembl # => ""
#
# Have fun!
#
#   "APC".symbol2entrez.entrez2ensembl # => "ENSG00000134982"
#   ["APC", "IL1"].symbol2entrez # => ["324","3552"]
#   nil.entrez2ensembl # NoMethodError
#
# = About HGNC Database
# The HUGO Gene Nomenclature Committee (HGNC) is the only worldwide authority
# that assigns standardised nomenclature to human genes. For each known human
# gene their approve a gene name and symbol (short-form abbreviation).  All
# approved symbols are stored in the HGNC database. Each symbol is unique and
# HGNC ensures that each gene is only given one approved gene symbol.
#
# = Reference
# {http://www.genenames.org/ HUGO Gene Nomenclature Committee at the European Bioinformatics Institute}
#
module BioTCM::Databases::HGNC
  autoload(:Converter, 'biotcm/databases/hgnc/converter')
  autoload(:Parser, 'biotcm/databases/hgnc/parser')
  autoload(:Rescuer, 'biotcm/databases/hgnc/rescuer')

  # Current version of HGNC
  VERSION = '0.3.0'.freeze

  # Identifers available in BioTCM::Databases::HGNC by now mapped to headline in HGNC table.
  # @note Single-item column comes first (at position 0) before multiple-item columns.
  IDENTIFIERS = {
    hgncid: 'HGNC ID',
    symbol: ['Approved Symbol', 'Previous Symbols', 'Synonyms'],
    entrez: 'Entrez Gene ID(supplied by NCBI)',
    refseq: ['RefSeq(supplied by NCBI)', 'RefSeq IDs'],
    uniprot: 'UniProt ID(supplied by UniProt)',
    ensembl: 'Ensembl ID(supplied by Ensembl)'
  }.freeze

  extend Converter
  extend Parser
  extend Rescuer

  # Make sure methods in String are working
  # @param file_path [String] the path of your HGNC table if default not used
  def self.ensure(file_path = nil)
    load(file_path).as_dictionary unless @__core_extended__
  end

  # Load the given flat file or a downloaded one if file_path is nil.
  # @param file_path [String] the path of your HGNC table if default not used
  # @return [HGNC]
  def self.load(file_path = nil)
    @direct_converters.each { |sym| instance_variable_get('@' + sym.to_s).clear }

    if file_path
      # Load given HGNC table
      raise ArgumentError, "#{file_path} not exists" unless File.exist?(file_path)
    else
      # Load default HGNC table (may download it if in need)
      file_path = BioTCM.path_to('hgnc/hgnc_set.txt')
      unless File.exist?(file_path)
        BioTCM.logger.info('HGNC') { 'Since default HGNC table not exists, trying to download one... (This may take several minutes.)' }
        hgnc_content = BioTCM.curl(BioTCM.meta['HGNC']['DOWNLOAD_URL'])
        File.open(file_path, 'w:UTF-8').puts hgnc_content.force_encoding('UTF-8')
      end
    end
    parse(File.open(file_path))

    self
  end

  # Use as the dictionary to extend String & Array
  # @return [HGNC]
  def self.as_dictionary
    return self unless require 'biotcm/databases/hgnc/core_ext'

    Extentions::String.module_eval(@string_mixin)
    String.include(Extentions::String)

    Extentions::Array.module_eval(@array_mixin)
    Array.include(Extentions::Array)

    @__core_extended__ = true
    self
  end
end
