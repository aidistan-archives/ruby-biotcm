# encoding: UTF-8
require 'fileutils'

# Class for retrieving medlines in PubMed
class BioTCM::Databases::Medline
  # Module wrapper for E-utilities operations
  #
  # = About E-utilities
  # {http://www.ncbi.nlm.nih.gov/books/NBK25500/ The Entrez Programming Utilities (E-utilities)}
  # are a set of nine server-side programs that provide a stable interface 
  # into the Entrez query and database system at the National Center for 
  # Biotechnology Information (NCBI). The E-utilities use a fixed URL 
  # syntax that translates a standard set of input parameters into the 
  # values necessary for various NCBI software components to search for 
  # and retrieve the requested data. The E-utilities are therefore the 
  # structured interface to the Entrez system, which currently includes 
  # 38 databases covering a variety of biomedical data, including nucleotide 
  # and protein sequences, gene records, three-dimensional molecular 
  # structures, and the biomedical literature. 
  #
  # = Copyright & Disclaimer
  # {http://www.ncbi.nlm.nih.gov/About/disclaimer.html}
  #
  module EUtilities
    module_function
    # ESearch (text searches)
    #
    # Responds to a text query with the list of matching UIDs in a given database (for later use in ESummary, EFetch or ELink), along with the term translations of the query.
    #
    # @param params [Hash] parameters to be passed to the server
    # @return [String] returned XML from PubMed
    # @option params :db [String] database
    # @option params :term [String] term
    # @option params :webenv [String]  web environment used
    # @option params :usehistory ["y" or "n"] ('y') whether to use history server
    def esearch(params)
      BioTCM.get(
        [
          "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=#{params[:db]}",
          params[:term] ? "term=#{params[:term]}" : "",
          params[:webenv] ? "WebEnv=#{params[:webenv]}" : "",
          params[:usehistory]=="n" ? "" : "usehistory=y",

          params[:retstart] ? "retstart=#{params[:retstart]}" : "",
          params[:retmax] ? "retmax=#{params[:retmax]}" : "",
          params[:query_key] ? "query_key=#{params[:query_key]}" : "",
        ].join("&").gsub(/&+/,"&")
      )
    end
    # EFetch (data record downloads)
    #
    # Responds to a list of UIDs in a given database with the corresponding data records in a specified format.
    #
    # @param params [Hash] parameters to be passed to the server
    # @return [String] returned XML from PubMed
    # @option params :db [String] database
    # @option params :rettype [String] return type
    # @option params :retmode [String] return mode
    # @option params :retstart [String] return start
    # @option params :retmax [String] return max
    # @option params :query_key [String] query key used
    # @option params :webenv [String] web environment used
    def efetch(params)
      BioTCM.get(
        [
          "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=#{params[:db]}",
          params[:rettype] ? "rettype=#{params[:rettype]}" : "",
          params[:retmode] ? "retmode=#{params[:retmode]}" : "",
          params[:retstart] ? "retstart=#{params[:retstart]}" : "",
          params[:retmax] ? "retmax=#{params[:retmax]}" : "",
          "query_key=#{params[:query_key]}",
          "WebEnv=#{params[:webenv]}",
        ].join("&").gsub(/&+/,"&")
      )
    end
    # # EInfo (database statistics)
    # # Provides the number of records indexed in each field of a given database, the date of the last update of the database, and the available links from the database to other Entrez databases.
    # def einfo
    #   # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
    # end
    # # EPost (UID uploads)
    # # Accepts a list of UIDs from a given database, stores the set on the History Server, and responds with a query key and web environment for the uploaded dataset.
    # def epost
    #   # request({
    #   # :url => 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/epost.fcgi',
    #   # :method => 'get',
    #   # # :query => 'a string',
    #   # # :timeout => 60
    #   # })
    # end
    # # ESummary (document summary downloads)
    # # Responds to a list of UIDs from a given database with the corresponding document summaries.
    # def esummary
    #   # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi
    # end
    # # ELink (Entrez links)
    # # Responds to a list of UIDs in a given database with either a list of related UIDs (and relevancy scores) in the same database or a list of linked UIDs in another Entrez database; checks for the existence of a specified link from a list of one or more UIDs; creates a hyperlink to the primary LinkOut provider for a specific UID and database, or lists LinkOut URLs and attributes for multiple UIDs.
    # def elink
    #   # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi
    # end
    # # EGQuery (global query)
    # # Responds to a text query with the number of records matching the query in each Entrez database.
    # def egquery
    #   # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/egquery.fcgi
    # end
    # # ESpell (spelling suggestions)
    # # Retrieves spelling suggestions for a text query in a given database.
    # def espell
    #    # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/espell.fcgi
    # end
  end

  attr_reader :term, :count

  # @private
  # WebEnv used last time
  @@last_webenv = nil

  # Perform a search of medlines
  # @param query [String] query terms
  # @param webenv [String]
  def initialize(query, webenv = @@last_webenv)
    @webenv = webenv if webenv
    search(query)
    @@last_webenv = @webenv # Save current webenv
  end

  # OR operation search
  # @return [self]
  def | (query)
    search("%23#{@query_key}+OR+" + 
      case query
      when String
        query
      when self.class
        '%23'+query.query_key
      else
        raise ArgumentError, "illegal query"
      end
    )
    return self
  end

  # AND operation search
  # @return [self]
  def & (query)
    search("%23#{@query_key}+AND+" + 
      case query
      when String
        query
      when self.class
        "%23"+query.query_key
      else
        raise ArgumentError, "illegal query"
      end
    )
    return self
  end

  # Fetch all pubmed ids
  # @return [Array]
  def fetch_pubmed_ids
    rtn = []
    retstart = 0
    retmax = 500
    total_count = @count

    while retstart<total_count
      rtn += EUtilities.esearch({
        db:"pubmed",
        retstart:retstart,
        retmax:retmax,
        query_key:@query_key,
        webenv:@webenv,
      }).scan(/<Id>(\d+)<\/Id>/).flatten

      retstart += retmax
      retstart = total_count unless retstart < total_count
    end
    return rtn
  end

  # Download all abstracts
  # @param filename [String] path to expected file
  # @return [self]
  def download_abstracts(filename)
    retstart = 0
    retmax = 500
    total_count = @count

    BioTCM.log.info("Medline") { "Downloading #{total_count} medlines ..." }
    File.open(filename, "w") do |fout|
      while retstart<total_count
        fout.puts EUtilities.efetch({
          db:"pubmed",
          rettype:"medline",
          retmode:"text",
          retstart:retstart,
          retmax:retmax,
          query_key:@query_key,
          webenv:@webenv,
        })

        retstart += retmax
        retstart = total_count unless retstart < total_count

        BioTCM.log.info("Medline") { "#{retstart}/#{total_count}" }
      end
    end
    return self
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
    @term = term.chomp.gsub(/\s+/, "+")

    @xml = EUtilities.esearch({
      db:"pubmed",
      term:@term,
      webenv:@webenv,
      usehistory:"y",
    })
    @xml =~ /<Count>(\d+)<\/Count>.*<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(\S+)<\/WebEnv>/
    @count = $1.to_i
    @query_key = $2
    @webenv = $3

    File.open(BioTCM.path_to("tmp/MineLiteratureInPubMed #{@webenv} ##{@query_key}.txt", true), 'w').puts @xml
    BioTCM.log.debug("Medline") { "Object updated by searching => #{self}" }
  end
end
