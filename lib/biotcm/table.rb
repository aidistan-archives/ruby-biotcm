# encoding: UTF-8

module BioTCM
  # One of the basic data models used in BioTCM, 
  # developed under <b>"strict entry and tolerant exit"</b> philosophy
  # (please refer to the test for details). 
  class BioTCM::Table
    # Utility function to create an object
    # @private
    def self._build(primary_key, row_keys, col_keys, content, modifiable_tab=nil)
      tab = modifiable_tab ? modifiable_tab : self.new
      tab.instance_variable_set(:@primary_key, primary_key)
      tab.instance_variable_set(:@row_keys, row_keys)
      tab.instance_variable_set(:@col_keys, col_keys)
      tab.instance_variable_set(:@content, content)
      tab
    end
    private_class_method :_build

    # Create a(n) (empty) table
    # @param arg [nil, String] initialize with nothing or a file
    # @note The primary key in an empty table is "_id"
    def initialize(arg=nil)
      case arg
      when nil # Empty table
        @primary_key = "_id"
        @row_keys = []
        @col_keys = []
        @content = []
      when String
        File.open(arg).read.to_table(self)
      else
        raise ArgumentError, 'Illegal argument type for Table#new'
      end
    end

    # Keys of rows
    attr_reader :row_keys
    def row_keys; @row_keys.clone; end
    # Keys of columns
    attr_reader :col_keys
    def col_keys; @col_keys.clone; end
    # Primary key used in this table
    attr_accessor :primary_key
    def primary_key; @primary_key; end
    def primary_key=(val)
      if @col_keys.include?(val)
        raise ArgumentError, "Key \"#{val}\" exists in column keys"
      else
        @primary_key = val
      end
    end

    # Clone this table
    # @return [Table]
    def clone
      self.class.send(:_build, @primary_key,  @row_keys.clone,  @col_keys.clone, 
          @content.collect { |arr| arr.clone })
    end
    # Access an element
    # @param row [String]
    # @param col [String]
    # @param val [String]
    def ele(row, col, val=nil)
      if val.nil?
        row = @row_keys.index(row) or return nil
        col = @col_keys.index(col) or return nil
        @content[row][col]
      else
        unless row.is_a?(String) && col.is_a?(String) && val.is_a?(String)
          raise ArgumentError, 'Illegal argument type'
        end

        unless @row_keys.include?(row)
          @row_keys<<row
          @content<<([""]*@col_keys.size)
        end

        unless @col_keys.include?(col)
          @col_keys<<col
          @content.each { |row| row<<"" }
        end

        row = @row_keys.index(row)
        col = @col_keys.index(col)
        @content[row][col] = val
      end
    end
    # Access a row
    # @param row [String]
    # @param val [Hash]
    def row(row, val=nil)
      if val.nil?
        row = @row_keys.index(row) or return nil
        rtn = {}
        @col_keys.each_with_index { |key, index| rtn[key] = @content[row][index] }
        rtn
      else
        unless row.is_a?(String) && val.is_a?(Hash)
          raise ArgumentError, 'Illegal argument type'
        end

        unless @row_keys.include?(row)
          @row_keys<<row
          @content<<([""]*@col_keys.size)
        end

        row = @row_keys.index(row)
        val.each do |k, v|
          col = @col_keys.index(k) or next
          @content[row][col] = v
        end
      end
    end
    # Access a column
    # @param col [String]
    # @param val [Hash]
    def col(col, val=nil)
      if val.nil?
        col = @col_keys.index(col) or return nil
        rtn = {}
        @row_keys.each_with_index { |key, index| rtn[key] = @content[index][col] }
        rtn
      else
        unless col.is_a?(String) && val.is_a?(Hash)
          raise ArgumentError, 'Illegal argument type'
        end

        unless @col_keys.include?(col)
          @col_keys<<col
          @content.each { |row| row<<"" }
        end

        col = @col_keys.index(col)
        val.each do |k, v|
          row = @row_keys.index(k) or next
          @content[row][col] = v
        end
      end
    end
    # Select row(s) to build a new table
    def select_row(row)
      select(row, :all)
    end
    # Select column(s) to build a new table
    def select_col(col)
      select(:all, col)
    end
    # Select row(s) and column(s) to build a new table
    def select(rows, cols)
      # Prune rows
      if rows == :all
        row_keys = @row_keys
        content = @content.collect { |arr| arr.clone }
      else
        raise ArgumentError, 'Illegal argument type' unless rows.is_a?(Array)
        row_keys = rows & @row_keys
        content = []
        row_keys.each { |row| content<<@content[@row_keys.index(row)] }
      end

      # Prune columns
      if cols == :all
        col_keys = @col_keys
      else
        raise ArgumentError, 'Illegal argument type' unless cols.is_a?(Array)
        col_keys = cols & @col_keys
        eval 'content.collect! { |arr| [' + col_keys.collect { |col| "arr[#{@col_keys.index(col)}]" }.join(',') + '] }'
      end

      # Create a new table
      self.class.send(:_build, @primary_key, row_keys, col_keys, content)
    end
    # Merge with another table
    # @param tab [Table]
    def merge(tab)
      raise ArgumentError unless tab.is_a?(self.class)

      # Empty content
      content = []
      row_keys = @row_keys | tab.row_keys
      col_keys = @col_keys | tab.col_keys
      row_keys.size.times { content<<Array.new(col_keys.size, "") }

      # Fill content with self
      eval <<-END_OF_DOC
        @row_keys.each_with_index do |row, _row|
          row = row_keys.index(row)
          #{
            str = []
            @col_keys.each_with_index do |col, _col|
              col = col_keys.index(col)
              str<<"content[row][#{col}] = @content[_row][#{_col}]"
            end
            str.join("\n"+" "*8)
          }
        end
      END_OF_DOC

      # Fill content with tab
      tab_content = tab.instance_variable_get(:@content)
      eval <<-END_OF_DOC
        tab.row_keys.each_with_index do |row, _row|
          row = row_keys.index(row)
          #{
            str = []
            tab.col_keys.each_with_index do |col, _col|
              col = col_keys.index(col)
              str<<"content[row][#{col}] = tab_content[_row][#{_col}]"
            end
            str.join("\n"+" "*8)
          }
        end
      END_OF_DOC

      # Create a new table
      self.class.send(:_build, @primary_key, row_keys, col_keys, content)
    end
    # @private
    # For inspection
    def inspect
      super.split(' ').shift + " col_keys.size=#{col_keys.size} row_keys.size=#{row_keys.size}>"
    end
    # @private
    # Convert to {String}
    def to_s
      @row_keys.zip(@content).unshift([@primary_key, @col_keys]).collect { |a| a.join("\t") }.join("\n")
    end
    # Print in a file
    def export(filepath)
      File.open(filepath, 'w').puts self
    end
  end
end

class String
  # Create a {BioTCM::Table} based on a String
  # @param modifiable_tab [BioTCM::Table] optional table object to fill
  def to_table(modifiable_tab=nil)
    stuff = self.split(/\r\n|\n/)
    
    # Headline
    col_keys = stuff.shift.split("\t")
    raise ArgumentError, "Duplicated column names" unless col_keys.uniq!.nil?
    primary_key = col_keys.shift
    
    # Table content
    row_keys = []
    content = []
    stuff.each_with_index do |line, line_index|
      col = (line+"\tTAIL").split("\t"); col.pop
      raise ArgumentError, "Row size inconsistent in line #{line_index+2}" unless col.size == col_keys.size+1
      raise ArgumentError, "Duplicated primary key: #{col[0]}" if row_keys.include? col[0]
      row_keys<<col.shift
      content<<col
    end

    BioTCM::Table.send(:_build, primary_key, row_keys, col_keys, content, modifiable_tab)
  end
end
