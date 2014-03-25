# encoding: UTF-8
require_relative 'test-helper'
require 'tempfile'

class BioTCM_Tabel_Test < Test::Unit::TestCase

  context "[Strict entry] When initialized with" do

    context "duplicated columns, Table" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "ID\tA\tA\n1\tC++\tgood\n2\tRuby\tbetter\n"
        file.rewind
        assert_raise ArgumentError do
          BioTCM::Table.new(file.path)
        end
        file.close!
      end
    end
  
    context "duplicated primary keys, Table" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "ID\tA\tB\n1\tC++\tgood\n1\tRuby\tbetter\n"
        file.rewind
        assert_raise ArgumentError do
          BioTCM::Table.new(file.path)
        end
        file.close!
      end
    end

    context "an inconsistent-size row, Table" do
      should "raise ArgumentError" do
        file = Tempfile.new('test')
        file.write "ID\tA\tA\n1\tC++\tgood\n2\tRuby\n"
        file.rewind
        assert_raise ArgumentError do
          BioTCM::Table.new(file.path)
        end
        file.close!
      end
    end
  end

  context "[Tolerant exit] As for " do
    setup do
      @tab = "ID\tA\tB\tC\n1\tab\t1\t0.8\n2\tde\t3\t0.2\n3\tfk\t6\t1.9".to_table
    end

    context "key operations, we" do

      should "be able to access the primary key" do
        assert_equal('ID', @tab.primary_key)
        # It's OK to make primary key the same as one column
        assert_nothing_raised ArgumentError do
          @tab.primary_key = 'A'
        end
        assert_equal('A', @tab.primary_key)
        assert_nothing_raised ArgumentError do
          @tab.primary_key = 'id'
        end
        assert_equal('id', @tab.primary_key)
      end

      should "be able to access column keys" do
        assert_equal(%w{A B C}, @tab.col_keys)
        # Make sure that we just get a copy
        @tab.col_keys.push nil
        assert_equal(%w{A B C}, @tab.col_keys)
        # But we can modify them this way
        keys = @tab.col_keys
        keys[1] = 'D'
        @tab.col_keys = keys
        assert_equal(%w{A D C}, @tab.col_keys)
      end

      should "be able to access row keys" do
        assert_equal(%w{1 2 3}, @tab.row_keys)
        # Make sure that we just get a copy
        @tab.row_keys.push nil
        assert_equal(%w{1 2 3}, @tab.row_keys)
        # But we can modify them this way
        keys = @tab.row_keys
        keys[2] = '4'
        @tab.row_keys = keys
        assert_equal(%w{1 2 4}, @tab.row_keys)
      end
    end

    context "outputs ,we" do
      should "be able to print out" do
        tab_string = "ID\tA\tB\tC\n1\tab\t1\t0.8\n2\tde\t3\t0.2\n3\tfk\t6\t1.9"
        tab = tab_string.to_table
        assert_equal(tab_string, tab.to_s)
      end
    end

    context "basic operations, we" do

      should "be able to access elements" do
        assert_equal(nil, @tab.ele(nil, nil))
        assert_equal(nil, @tab.ele(nil, 'A'))
        assert_equal(nil, @tab.ele('1', nil))
        assert_equal('ab', @tab.ele('1', 'A'))

        @tab.ele('1', 'A', '-')
        assert_equal('-', @tab.ele('1', 'A'))
        @tab.ele('4', 'A', '-')
        assert_equal('-', @tab.ele('4', 'A'))
        @tab.ele('4', 'E', '-')
        assert_equal('-', @tab.ele('4', 'E'))
        @tab.ele('5', 'F', '-')
        assert_equal('-', @tab.ele('5', 'F'))
      end

      should "be able to access rows" do
        assert_equal('6', @tab.row('3')['B'])
        assert_equal(nil, @tab.row('3')['D'])
        assert_equal(nil, @tab.row('4'))

        @tab.row('3', {'B'=>'-'})
        assert_equal('-', @tab.row('3')['B'])
        @tab.row('4', {'B'=>'-', 'D'=>'-'})
        assert_equal('',  @tab.row('4')['A'])
        assert_equal('-', @tab.row('4')['B'])
        assert_equal(nil, @tab.row('4')['D'])

        @tab.row('4', ['-', '', '-'])
        assert_equal('-', @tab.row('4')['A'])
        assert_equal('',  @tab.row('4')['B'])
      end

      should "be able to access columns" do
        assert_equal('6', @tab.col('B')['3'])
        assert_equal(nil, @tab.col('C')['4'])
        assert_equal(nil, @tab.col('D'))

        @tab.col('B', {'3'=>'-'})
        assert_equal('-', @tab.col('B')['3'])
        @tab.col('D', {'2'=>'-', '4'=>'-'})
        assert_equal('',  @tab.col('D')['1'])
        assert_equal('-', @tab.col('D')['2'])
        assert_equal(nil, @tab.col('D')['4'])

        @tab.col('D', ['-', '', '-'])
        assert_equal('-', @tab.col('D')['1'])
        assert_equal('',  @tab.col('D')['2'])
      end
    end
    
    context "advanced operations, a table" do

      should "return selected rows and columns as a Table" do
        tab = @tab.select(%w{4 3 1}, %w{D C B})
        assert_not_same(@tab, tab)
        assert_equal(@tab.primary_key, tab.primary_key)
        assert_equal(%w{3 1}, tab.row_keys)
        assert_equal(%w{C B}, tab.col_keys)
        assert_equal(nil, tab.ele('2', 'A'))
        assert_equal(nil, tab.ele('2', 'C'))
        assert_equal(nil, tab.ele('1', 'A'))
        assert_equal('6', tab.ele('3', 'B'))
      end

      should "return selected rows as a Table" do
        tab = @tab.select_row(%w{4 3 1})
        assert_not_same(@tab, tab)
        assert_equal(%w{3 1}, tab.row_keys)
        assert_equal('1', tab.ele('1', 'B'))
        assert_equal(nil, tab.ele('2', 'B'))
        assert_equal('6', tab.ele('3', 'B'))
      end

      should "return selected columns as a Table" do
        tab = @tab.select_col(%w{D C B})
        assert_not_same(@tab, tab)
        assert_equal(%w{C B}, tab.col_keys)
        assert_equal(nil, tab.ele('3', 'A'))
        assert_equal('6', tab.ele('3', 'B'))
        assert_equal('1.9', tab.ele('3', 'C'))
      end
      
      should "merge with another table" do
        assert_equal(nil, @tab.ele('4', 'A'))
        assert_equal(nil, @tab.ele('2', 'D'))
        assert_equal('6', @tab.ele('3', 'B'))
        assert_equal(nil, @tab.ele('4', 'B'))
        assert_equal('1', @tab.ele('1', 'B'))

        tab = @tab.merge("ID\tB\tD\n1\tab\t1\n4\tuc\t4".to_table)
        assert_not_same(@tab, tab)
        assert(tab.is_a?(BioTCM::Table))
        assert_equal('', tab.ele('4', 'A'))
        assert_equal('', tab.ele('2', 'D'))
        assert_equal('6', tab.ele('3', 'B'))
        assert_equal('uc', tab.ele('4', 'B'))
        assert_equal('ab', tab.ele('1', 'B'))
      end
    end
  end
end
