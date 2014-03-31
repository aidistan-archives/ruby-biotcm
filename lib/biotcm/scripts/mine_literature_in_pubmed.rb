#!/usr/bin/env ruby
# encoding: UTF-8

# LM was first developed by Jun Yuan in Perl in 2010, which was used to identify
# genes/proteins in abstracts of articles from PubMed[http://www.ncbi.nlm.nih.gov/pubmed/]
# through E-utilities[http://www.ncbi.nlm.nih.gov/books/NBK25500/] (Disclaimer&Copyright)[www.ncbi.nlm.nih.gov/About/disclaimer.html]. 
# Now LM has been introduced into BioTCM to respond to diverse user-defined queries.
# See interfaces for param/return details
#
# @example Inheritance example
#   class MyLM < BioTCM::Scripts::MineLiteratureInPubMed
#
#     def search_medline
#       BioDB::LiteratureMining::Medline.new("IL-2 IBD")
#     end
#
#     def match_sentence(sentence)
#       return "IL-2\tIBD" if (sentence =~ /IL-2/i) and (sentence =~ /IBD/i)
#       return nil
#     end
#
#   end
#
#   MyLM.new.run
#
# @example Implementation example I
#   myLM = BioTCM::Scripts::MineLiteratureInPubMed.new
#
#   def myLM.search_medline
#     BioDB::LiteratureMining::Medline.new("IL-2 IBD")
#   end
#
#   def match_sentence(sentence)
#     return "IL-2\tIBD" if (sentence =~ /IL-2/i) and (sentence =~ /IBD/i)
#     return nil
#   end
#
#   myLM.new.run
#
# @example Implementation example II
#   BioTCM::Scripts::MineLiteratureInPubMed.new do
#     public
#
#     def search_medline
#       BioDB::LiteratureMining::Medline.new("IL-2 IBD")
#     end
#
#     def match_sentence(sentence)
#       return "IL-2\tIBD" if (sentence =~ /IL-2/i) and (sentence =~ /IBD/i)
#       return nil
#     end
#   end.run
#
class BioTCM::Scripts::MineLiteratureInPubMed < BioTCM::Scripts::Script
  # @!group Interface
  # Interface for medline searching
  # @abstract
  # @return [Medline]
  def search_medline
    raise NotImplementedError
  end

  # Interface for sentence matching
  # @abstract
  # @param sentence [String]
  # @return [String] a String for matched term, if matched
  # @return [nil] if unmatched
  def match_sentence(sentence)
    raise NotImplementedError
  end
  # @!endgroup

  # Main entry
  def run
    # Initialize
    @run_id = BioTCM.get_stamp
    @filenames = {
      medlines:"output_medlines.txt",
      sentences:"output_sentences.txt",
      matches:"output_matches.txt",
      results:"output_results.txt",
    }

    # Search & Downlaod medlines
    raise ArgumentError, "Illegal implementation of \"searc_medline\" for wrong type return" if (@medline = search_medline).is_a? Medline
    @medline.download(path_of :medlines) # call interface to search

    # Splite into sentences
    split2sentences

    # Scan all sentences for sentence-match
    scan_sentences

    # Count matches & output
    count_matches
  end

  # Require a path
  # @param obj [Symbol or String]
  # @return [String]
  def path_of(obj="")
    case obj
    when Symbol
      "#{@wd}/#{@run_id}_#{@filenames[obj]}"
    else String
      "#{@wd}/#{@run_id}_#{obj}"
    end
  end

  private

  # Split abstracts in medlines
  def split2sentences
    BioDB.message "[LM] Spliting the sentences"
    @num_abstract = @medline.count
    abstract_index = 0
    sentence_index = 0
    pmid = ""
    abstract = ""

    bar = ProgressBar.new("Spliting", @num_abstract) if BioDB.show_progressbar?
    fout = File.new(path_of(:sentences),"w")
    fin  = File.new(path_of :medlines)
    fin.each do |line|
      case ""+line.chomp!
      when /^PMID/
        pmid = line.match(/PMID-\s(\d+)/)[1]
        abstract_index += 1
        bar.inc if BioDB.show_progressbar?
      when /^TI/
        abstract = line.split(/\-\s/)[1]
      when /^AB/
        abstract += line.split(/\-\s/)[1]
        while (line = fin.gets.chomp) =~ /^\s{6}/
          abstract += " " + line.split(/^\s{6}/)[1]
        end
      when /^SO/
        abstract.gsub(/\s+/," ").split(/(?<=[a-z0-9]{2})[.?!]\s(?=\S)/).each do |s|
          if s =~ /\w\s\w/ # Check
            sentence_index += 1
            fout.puts "#{pmid}\t #{s}"
          end
        end
      end
    end
    @num_sentence = sentence_index

    fout.close
    fin.close
    bar.finish if BioDB.show_progressbar?
    BioDB.message "[LM] Total #{@num_sentence} sentences"
  end

  def scan_sentences
    BioDB.message "[LM] Scanning sentences"
    match_index = 0

    bar = ProgressBar.new("Spliting", @num_sentence) if BioDB.show_progressbar?
    fout = File.new(path_of(:matches),"w")
    File.open(path_of :sentences).each do |line|
      col = line.chomp.split /\t/
      col[1] = match_sentence(col[1]) # call interface to match
      unless col[1].nil?
        fout.print col[1],"\t\t",col[0],"\n" 
        match_index += 1
      end
      bar.inc if BioDB.show_progressbar?
    end

    fout.close
    @num_match = match_index
    bar.finish if BioDB.show_progressbar?
  end

  def count_matches
    BioDB.message "[LM] Counting sentences"
    hash = {}

    bar = ProgressBar.new("Counting", 100) if BioDB.show_progressbar?
    File.open(path_of :matches).each_with_index do |match, match_index|
      col = match.chomp.split /\t\t/
      hash[col[0]] = [] if hash[col[0]].nil?
      hash[col[0]].push col[1]
      bar.set(match_index.to_f/@num_match) if match_index%1000==0 and BioDB.show_progressbar?
    end
    bar.finish if BioDB.show_progressbar?
    
    File.open(path_of(:results), "w") do |fout|
      hash.each { |key, value| fout.puts "#{key}\t#{value.size}\t\t#{value.join("\t")}" }
    end
  end

  # Class to realize medline operations
  class Medline
    attr_reader :xml, :time, :count, :query_key, :webenv
    @@last_webenv = nil

    # Create a medline search
    def initialize(query, webenv = @@last_webenv)
      BioDB.message "[LM] Searching medlines for \"#{query}\""
      @webenv = webenv if webenv

      query = File.open(query).readlines if query =~ /.txt$/
      case query
      when Array
        query.collect!{ |line| line.chomp.gsub(/\s+/, "+") }
        query.delete("")

        bar = ProgressBar.new("Searching", query.size) if BioDB.show_progressbar?
        search(query.shift)
        query.each do |q|
          bar.inc if BioDB.show_progressbar?
          self | q
        end
        bar.finish if BioDB.show_progressbar?
      else # Single query
        search(query.chomp.gsub(/\s+/, "+"))
      end

      # Save current webenv
      @@last_webenv = @webenv
    end

    # OR operation search
    def | (query)
      search("%23#{@query_key}+OR+" + 
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

    # AND operation search
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

    # Use efetch to download
    # @return [String] path to the downloaded file
    def download(savepath)
      retstart = 0
      retmax = 500
      total_count = @count

      BioDB.message "[LM] Downloading #{total_count} medlines"
      bar = ProgressBar.new("Downloading", total_count) if BioDB.show_progressbar?
      File.open(savepath, "w") do |fout|
        while retstart<total_count
          fout.puts NCBI::EUtilities.efetch({
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
          bar.set(retstart) if BioDB.show_progressbar?
          BioDB.message("Medline\tdownloading\t#{retstart}/#{total_count}", :debug)
        end
      end
      bar.finish if BioDB.show_progressbar?
      return self
    end

    private
      # Append an esearch
      def search(term)
        @xml = NCBI::EUtilities.esearch({
          db:"pubmed",
          term:term,
          webenv:@webenv,
          usehistory:"y",
        })
        @xml =~ /<Count>(\d+)<\/Count>.*<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(\S+)<\/WebEnv>/
        @time = Time.now
        @count = $1.to_i
        @query_key = $2
        @webenv = $3

        Dir.mkdir(BioDB.data_dir + "/temp") unless Dir.exists?(BioDB.data_dir + "/temp")
        File.open(BioDB.data_dir + "/temp/LiteratureMining-Medline #{webenv} ##{query_key}.txt", "w").puts @xml
        BioDB.message("Medline\tsearch\tterm:\"#{term}\"\tcount:#{@count}\tquery_key:#{@query_key}\twebenv:#{@webenv}", :debug)
      end
  end

  # E-utilities[http://www.ncbi.nlm.nih.gov/books/NBK25500/] (Disclaimer&Copyright)[www.ncbi.nlm.nih.gov/About/disclaimer.html]
  module EUtilities
    class << self
      # EInfo (database statistics)
      # Provides the number of records indexed in each field of a given database, the date of the last update of the database, and the available links from the database to other Entrez databases.
      def einfo
        # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi
      end

      # ESearch (text searches)
      # Responds to a text query with the list of matching UIDs in a given database (for later use in ESummary, EFetch or ELink), along with the term translations of the query.
      #
      # @param params [Hash] parameters to be passed to the server
      # @option params [String] :db database
      # @option params [String] :term term
      # @option params [String] :webenv web environment used
      # @option params ["y" or "n"] :usehistory ('y') whether to use history server
      def esearch(params)
        BioDB.request({
          :url => ["http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=#{params[:db]}",
            "term=#{params[:term]}",
            params[:webenv] ? "WebEnv=#{params[:webenv]}" : "",
            params[:usehistory]=="n" ? "" : "usehistory=y",
            ].join("&").gsub(/&+/,"&"),
          :method => 'get',
        })
      end

      # EPost (UID uploads)
      # Accepts a list of UIDs from a given database, stores the set on the History Server, and responds with a query key and web environment for the uploaded dataset.
      def epost
        # request({
        # :url => 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/epost.fcgi',
        # :method => 'get',
        # # :query => 'a string',
        # # :timeout => 60
        # })
      end
      
      # ESummary (document summary downloads)
      # Responds to a list of UIDs from a given database with the corresponding document summaries.
      def esummary
        # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi
      end

      # EFetch (data record downloads)
      # Responds to a list of UIDs in a given database with the corresponding data records in a specified format.
      #
      # @param params [Hash] parameters to be passed to the server
      # @option params [String] :db database
      # @option params [String] :rettype return type
      # @option params [String] :retmode return mode
      # @option params [String] :retstart return start
      # @option params [String] :retmax return max
      # @option params [String] :query_key query key used
      # @option params [String] :webenv web environment used
      def efetch(params)
        BioDB.request({
          :url => ["http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=#{params[:db]}",
            params[:rettype] ? "rettype=#{params[:rettype]}" : "",
            params[:retmode] ? "retmode=#{params[:retmode]}" : "",
            params[:retstart] ? "retstart=#{params[:retstart]}" : "",
            params[:retmax] ? "retmax=#{params[:retmax]}" : "",
            "query_key=#{params[:query_key]}",
            "WebEnv=#{params[:webenv]}",
            ].join("&").gsub(/&+/,"&"),
          :method => 'get',
        })
      end

      # ELink (Entrez links)
      # Responds to a list of UIDs in a given database with either a list of related UIDs (and relevancy scores) in the same database or a list of linked UIDs in another Entrez database; checks for the existence of a specified link from a list of one or more UIDs; creates a hyperlink to the primary LinkOut provider for a specific UID and database, or lists LinkOut URLs and attributes for multiple UIDs.
      def elink
        # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi
      end

      # EGQuery (global query)
      # Responds to a text query with the number of records matching the query in each Entrez database.
      def egquery
        # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/egquery.fcgi
      end

      # ESpell (spelling suggestions)
      # Retrieves spelling suggestions for a text query in a given database.
      def espell
         # http://eutils.ncbi.nlm.nih.gov/entrez/eutils/espell.fcgi
      end
    end
  end

end