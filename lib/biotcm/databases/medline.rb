# Class for retrieving medlines in PubMed
class BioTCM::Databases::Medline
  autoload(:EUtilities, 'biotcm/databases/medline/e_utilities')

  # Query term
  # @return [String]
  attr_reader :term
  # Number of entries for current query
  # @return [Fixnum]
  attr_reader :count
  # Web environment
  # @return [String]
  attr_reader :webenv

  class << self
    # WebEnv used last time
    attr_accessor :last_webenv
  end
  self.last_webenv = nil

  # Current version of Medline
  VERSION = '0.2.2'.freeze

  # Perform a search of medlines
  # @param query [String] query terms
  # @param webenv [String]
  def initialize(query, webenv = self.class.last_webenv)
    @webenv = webenv
    search(query)
  end

  # OR operation search
  # @param other [String/Medline]
  # @return [self]
  def or(other)
    other = '%23' + other.query_key if other.is_a?(self.class)
    search("%23#{@query_key}+OR+#{other}")
  end
  alias_method :|, :or

  # AND operation search
  # @param other [String/Medline]
  # @return [self]
  def and(other)
    other = '%23' + other.query_key if other.is_a?(self.class)
    search("%23#{@query_key}+AND+#{other}")
  end
  alias_method :&, :and

  # Fetch all pubmed ids
  # @return [Array]
  def fetch_pubmed_ids
    rtn = []
    retstart = 0
    retmax = 500
    total_count = @count

    while retstart < total_count
      rtn += EUtilities.esearch(
        db: 'pubmed',
        retstart: retstart,
        retmax: retmax,
        query_key: @query_key,
        webenv: @webenv
      ).scan(%r{<Id>(\d+)</Id>}).flatten

      retstart += retmax
      retstart = total_count unless retstart < total_count
    end
    rtn
  end

  # Download all abstracts
  # @param filename [String] path to expected file
  # @return [self]
  def download_abstracts(filename)
    retstart = 0
    retmax = 500
    total_count = @count

    BioTCM.logger.info('Medline') { "Downloading #{total_count} medlines ..." }
    File.open(filename, 'w') do |fout|
      while retstart < total_count
        fout.puts EUtilities.efetch(
          db: 'pubmed',
          rettype: 'medline',
          retmode: 'text',
          retstart: retstart,
          retmax: retmax,
          query_key: @query_key,
          webenv: @webenv
        )

        retstart += retmax
        retstart = total_count unless retstart < total_count

        BioTCM.logger.info('Medline') { "#{retstart}/#{total_count}" }
      end
    end

    self
  end

  # @private
  def inspect
    "<BioTCM::Databases::Medline last_term=#{@term.inspect} count=#{@count.inspect} query_key=#{@query_key.inspect} webenv=#{@webenv.inspect}>"
  end

  # @private
  def to_s
    inspect
  end

  private

  # Append an esearch
  def search(term)
    # Make sure term is valid
    @term = term.chomp.gsub(/\s+/, '+')

    @xml = EUtilities.esearch(
      db: 'pubmed',
      term: @term,
      webenv: @webenv,
      usehistory: 'y'
    )
    @xml =~ %r{<Count>(\d+)</Count>.*<QueryKey>(\d+)</QueryKey>.*<WebEnv>(\S+)</WebEnv>}
    @count = Regexp.last_match[1].to_i
    @query_key = Regexp.last_match[2]
    self.class.last_webenv = @webenv = Regexp.last_match[3]

    File.open(BioTCM.path_to("tmp/Medline_#{@webenv}_##{@query_key}.txt"), 'w').puts @xml
    BioTCM.logger.debug('Medline') { "Object updated to => #{self}" }

    self
  end
end
