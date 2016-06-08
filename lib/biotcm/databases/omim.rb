require 'yaml'

# Module for retrieving OMIM entries
module BioTCM::Databases::OMIM
  # Current version of OMIM
  VERSION = '0.3.0'.freeze

  # Public API key (change to your private key if in need)
  API_KEY = BioTCM.meta['OMIM']['API_KEY']

  # Get the URL for retrieving given entry
  def self.entry_url(omim_id, api_key: API_KEY)
    "http://api.omim.org/api/entry?mimNumber=#{omim_id}&apiKey=#{api_key}&include=all&format=ruby"
  end

  # Retrieve a OMIM entry
  # @return [Hash]
  # @raise ArgumentError if omim_id not exists
  def self.get(omim_id)
    BioTCM::Databases::HGNC.ensure

    filepath = BioTCM.path_to "omim/#{omim_id}.yaml"
    if File.exist?(filepath)
      content = YAML.load_file(filepath)
    else
      begin
        content = eval(BioTCM.curl(entry_url(omim_id)).delete("\n")) # rubocop:disable Lint/Eval
        content = content['omim']['entryList'].fetch(0)['entry']
        File.open(filepath, 'w').puts content.to_yaml
      rescue
        raise ArgumentError, 'OMIM number not exists'
      end
    end

    content
  end

  # Detect gene symbols in OMIM text content
  # @return [Array]
  def self.detect_genes(content)
    @gene_detector ||= BioTCM::Apps::GeneDetector.new
    genes = []

    if content['phenotypeMapExists']
      genes |= content['phenotypeMapList']
        .collect { |hash| hash['phenotypeMap']['geneSymbols'].split(', ') }
        .flatten.to_formal_symbols
    end

    if content['textSectionList']
      text = content['textSectionList'].map { |hash| hash['textSection']['textSectionContent'] }.join(' ')
      genes |= @gene_detector.detect(text)
    end

    genes.uniq - ['']
  end
end
