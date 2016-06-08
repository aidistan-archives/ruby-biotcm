module BioTCM::Databases::HGNC
  # Parser module
  module Parser
    # Symbol who may refer to more than one gene is removed from the dictionary
    # but listed here paired with the corresponding official symbol, unless it's
    # an official one.
    # @return [Hash]
    # @example
    #   HGNC.ambiguous_symbol.keys & HGNC.symbol2hgncid.keys # are all official symbols
    def ambiguous_symbol
      @ambiguous_symbol
    end

    # Load an HGNC table from IO
    # @param fin [#gets, #each] Typically a File or IO
    # @private
    def parse(fin)
      # Headline
      names = fin.gets.chomp.split("\t")
      index2identifier = {}
      index_hgncid = nil
      BioTCM::Databases::HGNC::IDENTIFIERS.each do |identifer, name|
        if identifer == :hgncid
          index_hgncid = names.index(name)
        elsif name.is_a?(String)
          index2identifier[names.index(name)] = identifer if names.index(name)
        else
          name.each_with_index do |n, i|
            next unless names.index(n)
            index2identifier[names.index(n)] = (i == 0 ? identifer : identifer.to_s)
          end
        end
      end

      # Dynamically bulid a line processor
      process_one_line = index2identifier.collect do |index, identifer|
        # Symbol will be mapped to single item
        if identifer.is_a?(Symbol)
          %(
            unless column[#{index}] == nil || column[#{index}] == "" || column[#{index}] == "-"
              @#{identifer}2hgncid[column[#{index}]] = column[#{index_hgncid}]
              @hgncid2#{identifer}[column[#{index_hgncid}]] = column[#{index}]
            end
          )
        # Others will be mapped to list item
        else
          %{
            unless column[#{index}] == nil
              column[#{index}].split(", ").each do |id|
          } +
            if identifer == 'symbol'
              %(
                if @ambiguous_symbol[id]
                  @ambiguous_symbol[id] << @hgncid2symbol[column[#{index_hgncid}]]
                elsif @symbol2hgncid[id].nil?
                  @symbol2hgncid[id] = column[#{index_hgncid}]
                else
                  @ambiguous_symbol[id] = [@hgncid2symbol[column[#{index_hgncid}]]]
                  unless @hgncid2symbol[@symbol2hgncid[id]] == id
                    @ambiguous_symbol[id] << @hgncid2symbol[@symbol2hgncid[id]]
                    @symbol2hgncid.delete(id)
                  end
                end
              )
            else
              %(
                @#{identifer}2hgncid[id] = column[#{index_hgncid}] if @#{identifer}2hgncid[id].nil?
              )
            end +
            %(
              end
            end
            )
        end
      end.join

      # Process the content
      eval %{fin.each do |line|\n column = line.chomp.split("\\t", -1)} + process_one_line + 'end' # rubocop:disable Lint/Eval
    end

    def self.extended(mod)
      # Initialize the instance variable
      mod.instance_variable_set(:@ambiguous_symbol, {})
    end
  end
end
