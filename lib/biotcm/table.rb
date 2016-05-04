module BioTCM
  # One of the basic data models used in BioTCM to process
  # {https://github.com/biotcm/biotcm/wiki/Formats#tab .tab files},
  # developed under <b>"strict entry and tolerant exit"</b> philosophy.
  #
  # For more details, please refer to the test.
  class Table
    # Version
    VERSION = '0.5.0'

    # Primary key
    attr_accessor :primary_key
    # Keys of rows
    attr_accessor :row_keys
    # Keys of columns
    attr_accessor :col_keys
    # Comments
    attr_accessor :comments

    # @private
    # Factory method
    # @return [Table]
    def self.build(primary_key: nil, row_keys: {}, col_keys: {}, content: [], comments: [])
      @tab = new
      @tab.instance_variable_set(:@primary_key, primary_key)
      @tab.instance_variable_set(:@row_keys, row_keys)
      @tab.instance_variable_set(:@col_keys, col_keys)
      @tab.instance_variable_set(:@content, content)
      @tab.instance_variable_set(:@comments, comments)
      @tab
    end

    # Load a table from a file
    # @param filepath [String]
    # @param encoding [String]
    # @param seperator [String]
    # @return [Table]
    def self.load(filepath, encoding: Encoding.default_external, seperator: "\t")
      raise ArgumentError, 'Illegal argument type for Table.load' unless filepath.is_a?(String)
      File.open(filepath, "r:#{encoding}").read.to_table(seperator: seperator)
    end

    # Create an empty table with keys
    # @param primary_key [String]
    # @param row_keys [Array]
    # @param col_keys [Array]
    def initialize(primary_key: nil, row_keys: [], col_keys: [], comments: [])
      @primary_key = primary_key
      @row_keys = row_keys.map.with_index { |r, ri| [r, ri] }.to_h
      @col_keys = col_keys.map.with_index { |c, ci| [c, ci] }.to_h
      @content = row_keys.collect { col_keys.collect { '' } }
      @comments = comments
    end

    # Clone this table
    # @return [Table]
    def clone
      self.class.build(
        primary_key: @primary_key,
        row_keys: @row_keys.clone,
        col_keys: @col_keys.clone,
        content: @content.collect(&:clone),
        comments: @comments.clone
      )
    end

    # Set the primary key
    # @param val [String]
    def primary_key=(val)
      if val.nil?
        @primary_key = nil
      else
        @primary_key = val.to_s
      end
    end

    # Get row keys
    # @return [Array]
    def row_keys
      @row_keys.keys
    end

    # Set row keys
    # @param val [Array]
    def row_keys=(val)
      raise ArgumentError, 'Illegal agrument type' unless val.is_a?(Array)
      raise ArgumentError, 'Unmatched size' if val.size < @row_keys.size
      @row_keys = val.map.with_index { |v, i| [v, i] }.to_h
    end

    # Get col keys
    # @return [Array]
    def col_keys
      @col_keys.keys
    end

    # Set col keys
    # @param val [Array]
    def col_keys=(val)
      raise ArgumentError, 'Illegal agrument type' unless val.is_a?(Array)
      raise ArgumentError, 'Unmatched size' if val.size < @col_keys.size
      @col_keys = val.map.with_index { |v, i| [v, i] }.to_h
    end

    # Set comments
    # @param val [Array/String]
    def comments=(val)
      if val.respond_to?(:collect)
        @comments = val.map(&:to_s)
      elsif val.respond_to?(:to_s)
        @comments = [val.to_s]
      end
    end

    # Access an element
    # @overload ele(row, col)
    #   Get an element
    #   @param row [String]
    #   @param col [String]
    #   @return [String]
    # @overload ele(row, col, val)
    #   Set an element
    #   @param row [String]
    #   @param col [String]
    #   @param val [String]
    #   @return [Table]
    def ele(row, col, val = nil)
      if val.nil?
        row = @row_keys[row]
        col = @col_keys[col]
        return row && col ? @content[row][col] : nil
      end

      unless row.is_a?(String) && col.is_a?(String) && val.respond_to?(:to_s)
        raise ArgumentError, 'Illegal argument type'
      end

      unless @row_keys[row]
        @row_keys[row] = @row_keys.size
        @content << ([''] * @col_keys.size)
      end

      unless @col_keys[col]
        @col_keys[col] = @col_keys.size
        @content.each { |arr| arr << '' }
      end

      row = @row_keys[row]
      col = @col_keys[col]
      @content[row][col] = val.to_s

      self
    end

    # Access a row
    # @overload row(row)
    #   Get a row
    #   @param row [String]
    #   @return [Hash]
    # @overload row(row, val)
    #   Set a row
    #   @param row [String]
    #   @param val [Hash, Array]
    #   @return [Table]
    def row(row, val = nil)
      # Getter
      if val.nil?
        row = @row_keys[row] or return nil
        return @col_keys.map { |c, ci| [c, @content[row][ci]] }.to_h
      end

      # Setter
      if !row.is_a?(String) || (!val.is_a?(Hash) && !val.is_a?(Array))
        raise ArgumentError, 'Illegal argument type'
      elsif val.is_a?(Array) && val.size != col_keys.size
        raise ArgumentError, 'Column size not match'
      end

      case val
      when Array
        if @row_keys[row]
          row = @row_keys[row]
          @content[row] = val
        else
          @row_keys[row] = @row_keys.size
          @content << val
        end
      when Hash
        unless @row_keys[row]
          @row_keys[row] = @row_keys.size
          @content << ([''] * @col_keys.size)
        end

        row = @row_keys[row]
        val.each do |k, v|
          col = @col_keys[k] or next
          @content[row][col] = v
        end
      end

      self
    end

    # Access a column
    # @overload col(col)
    #   Get a column
    #   @param col [String]
    #   @return [Hash]
    # @overload col(col, val)
    #   Set a column
    #   @param col [String]
    #   @param val [Hash, Array]
    #   @return [Table]
    def col(col, val = nil)
      # Getter
      if val.nil?
        col = @col_keys[col] or return nil
        return @row_keys.map { |r, ri| [r, @content[ri][col]] }.to_h
      end

      # Setter
      if !col.is_a?(String) || (!val.is_a?(Hash) && !val.is_a?(Array))
        raise ArgumentError, 'Illegal argument type'
      elsif val.is_a?(Array) && val.size != row_keys.size
        raise ArgumentError, 'Row size not match'
      end

      case val
      when Array
        if @col_keys[col]
          col = @col_keys[col]
          val.each_with_index { |v, row| @content[row][col] = v }
        else
          col = @col_keys[col] = @col_keys.size
          val.each_with_index { |v, row| @content[row] << v }
        end
      when Hash
        unless @col_keys[col]
          @col_keys[col] = @col_keys.size
          @content.each { |arr| arr << '' }
        end

        col = @col_keys[col]
        val.each do |k, v|
          row = @row_keys[k] or next
          @content[row][col] = v
        end
      end

      self
    end

    # Iterate by row
    def each_row
      if block_given?
        @row_keys.each_key { |r| yield(r, row(r)) }
        self
      else
        Enumerator.new do |y|
          @row_keys.each_key { |r| y << [r, row(r)] }
        end
      end
    end

    # Iterate by col
    def each_col
      if block_given?
        @col_keys.each_key { |c| yield(c, col(c)) }
        self
      else
        Enumerator.new do |y|
          @col_keys.each_key { |c| y << [c, col(c)] }
        end
      end
    end

    # Select row(s) to build a new table
    # @param rows [Array]
    # @return [Table]
    def select_row(rows)
      select(rows, :all)
    end

    # Select column(s) to build a new table
    # @param cols [Array]
    # @return [Table]
    def select_col(cols)
      select(:all, cols)
    end

    # Select row(s) and column(s) to build a new table
    # @param rows [Array]
    # @param cols [Array]
    # @return [Table]
    def select(rows, cols)
      # Prune rows
      if rows == :all
        row_keys = @row_keys.clone
        content = @content.collect(&:clone)
      else
        raise ArgumentError, 'Illegal argument type' unless rows.is_a?(Array)
        row_keys = {}
        (rows & @row_keys.keys).each { |row| row_keys[row] = row_keys.size }
        content = []
        row_keys.each_key { |row| content << @content[@row_keys[row]] }
      end

      # Prune columns
      if cols == :all
        col_keys = @col_keys.clone
      else
        raise ArgumentError, 'Illegal argument type' unless cols.is_a?(Array)
        col_keys = {}
        (cols & @col_keys.keys).each { |col| col_keys[col] = col_keys.size }
        eval 'content.collect! { |arr| [' + col_keys.keys.collect { |col| "arr[#{@col_keys[col]}]" }.join(',') + '] }'
      end

      # Create a new table
      self.class.build(
        primary_key: primary_key,
        row_keys: row_keys,
        col_keys: col_keys,
        content: content,
        comments: comments
      )
    end

    # Merge with another table
    # @param tab [Table]
    def merge(tab)
      raise ArgumentError, 'Only tables could be merged' unless tab.is_a?(self.class)
      raise ArgumentError, 'Primary keys not the same' unless tab.primary_key == primary_key

      # Empty content
      content = []
      row_keys = {}
      (@row_keys.keys | tab.row_keys).each { |row| row_keys[row] = row_keys.size }
      col_keys = {}
      (@col_keys.keys | tab.col_keys).each { |col| col_keys[col] = col_keys.size }
      row_keys.size.times { content << Array.new(col_keys.size, '') }

      # rubocop:disable Style/SpaceInsideStringInterpolation

      # Fill content with self
      eval <<-END_OF_DOC
        @row_keys.each do |row, o_ri| # old row index
          n_ri = row_keys[row] # new row index
          #{
            str = []
            @col_keys.map do |col, o_ci| # old column index
              n_ci = col_keys[col] # new column index
              str << "content[n_ri][#{n_ci}] = @content[o_ri][#{o_ci}]"
            end
            str.join("\n" + ' ' * 8)
          }
        end
      END_OF_DOC

      # rubocop:disable Lint/UselessAssignment

      # Fill content with tab
      tab_content = tab.instance_variable_get(:@content)
      eval <<-END_OF_DOC
        tab.row_keys.each_with_index do |row, o_ri| # old row index
          n_ri = row_keys[row] # new row index
          #{
            str = []
            tab.col_keys.each_with_index do |col, o_ci| # old column index
              n_ci = col_keys[col] # new column index
              str << "content[n_ri][#{n_ci}] = tab_content[o_ri][#{o_ci}]"
            end
            str.join("\n" + ' ' * 8)
          }
        end
      END_OF_DOC

      # rubocop:enable Lint/UselessAssignment
      # rubocop:enable Style/SpaceInsideStringInterpolation

      # Create a new table
      self.class.build(
        primary_key: primary_key,
        row_keys: row_keys,
        col_keys: col_keys,
        content: content,
        comments: comments + tab.comments
      )
    end

    # @private
    # For inspection
    def inspect
      '#<Table primary_key=' + @primary_key.inspect +
        ' col_keys=' + @col_keys.keys.sort_by { |k| @col_keys[k] }.inspect +
        ' row_keys=' + @row_keys.keys.sort_by { |k| @row_keys[k] }.inspect +
        ' content=' + @content.inspect +
        ' comments=' + @comments.join.inspect +
        '>'
    end

    # @private
    # Convert to {String}
    def to_s
      [
        @comments.collect { |line| '# ' + line },
        @primary_key.nil? ?
          @col_keys.keys.join("\t") :
          [@primary_key, @col_keys.keys].join("\t"),
        @row_keys.keys.zip(@content).collect { |a| a.join("\t") }
      ].join("\n")
    end

    # Print in a file
    # @param filepath [String]
    # @return [self]
    def save(filepath)
      File.open(filepath, 'w').puts self
      self
    end
  end
end

class String
  # Create a {BioTCM::Table} based on a String or fill the given table
  # @param seperator [String]
  def to_table(seperator:"\t")
    stuff = split(/\r\n|\n/)

    # Comments
    comments = []
    while stuff[0] =~ /\# /
      # Some tables' head lines start with a '#', such as *mim2gene.txt* in OMIM
      break if stuff[0] =~ /\# [\w ]+\t/
      comments << stuff.shift.gsub(/^\# /, '')
    end

    # Headline
    col_keys = stuff.shift.split(seperator)
    raise ArgumentError, 'Duplicated column names' unless col_keys.uniq!.nil?
    if stuff.first && stuff.first.split(seperator).size == col_keys.size + 1
      primary_key = nil
    else
      primary_key = col_keys.shift
    end
    col_keys = col_keys.map.with_index { |n, i| [n, i] }.to_h

    # Table content
    row_keys = {}
    content = []
    stuff.each_with_index do |line, line_index|
      col = line.split(seperator, -1)

      if col.size != col_keys.size + 1
        raise ArgumentError, "Row size inconsistent in line #{line_index + 2}"
      elsif row_keys[col[0]]
        raise ArgumentError, "Duplicated primary key: #{col[0]}"
      end

      row_keys[col.shift] = row_keys.size
      content << col
    end

    # Build a table to return
    BioTCM::Table.build(
      primary_key: primary_key,
      row_keys: row_keys,
      col_keys: col_keys,
      content: content,
      comments: comments
    )
  end
end
