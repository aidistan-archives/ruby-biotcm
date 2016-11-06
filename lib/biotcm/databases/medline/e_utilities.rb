class BioTCM::Databases::Medline
  # Module wrapper for E-utilities operations
  #
  # = About E-utilities
  # {https://www.ncbi.nlm.nih.gov/books/NBK25500/ The Entrez Programming Utilities (E-utilities)}
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
  # {https://www.ncbi.nlm.nih.gov/About/disclaimer.html}
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
      BioTCM.curl('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi', params: params)
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
      BioTCM.curl('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi', params: params)
    end
    # # EInfo (database statistics)
    # # Provides the number of records indexed in each field of a given database, the date of the last update of the database, and the available links from the database to other Entrez databases.
    # def einfo
    #   # https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
    # end
    # # EPost (UID uploads)
    # # Accepts a list of UIDs from a given database, stores the set on the History Server, and responds with a query key and web environment for the uploaded dataset.
    # def epost
    #   # request({
    #   # :url => 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/epost.fcgi',
    #   # :method => 'get',
    #   # # :query => 'a string',
    #   # # :timeout => 60
    #   # })
    # end
    # # ESummary (document summary downloads)
    # # Responds to a list of UIDs from a given database with the corresponding document summaries.
    # def esummary
    #   # https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi
    # end
    # # ELink (Entrez links)
    # # Responds to a list of UIDs in a given database with either a list of related UIDs (and relevancy scores) in the same database or a list of linked UIDs in another Entrez database; checks for the existence of a specified link from a list of one or more UIDs; creates a hyperlink to the primary LinkOut provider for a specific UID and database, or lists LinkOut URLs and attributes for multiple UIDs.
    # def elink
    #   # https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi
    # end
    # # EGQuery (global query)
    # # Responds to a text query with the number of records matching the query in each Entrez database.
    # def egquery
    #   # https://eutils.ncbi.nlm.nih.gov/entrez/eutils/egquery.fcgi
    # end
    # # ESpell (spelling suggestions)
    # # Retrieves spelling suggestions for a text query in a given database.
    # def espell
    #    # https://eutils.ncbi.nlm.nih.gov/entrez/eutils/espell.fcgi
    # end
  end
end
