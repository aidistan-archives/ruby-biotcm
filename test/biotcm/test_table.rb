require_relative '../test_helper'
require 'tempfile'

describe BioTCM::Table do
  it 'has three ways to get instances' do
    # Table.build (used internally)
    assert_instance_of(BioTCM::Table, BioTCM::Table.build)

    # Table.load
    file = Tempfile.new('test')
    file.write "ID\tA\tB\n1\tC++\tgood\n2\tRuby\tbetter\n"
    file.flush
    assert_instance_of(BioTCM::Table, BioTCM::Table.load(file.path))
    file.close!

    # Table#new
    @tab = BioTCM::Table.new(primary_key: 'id', row_keys: %w(1 2), col_keys: %w(A B))
    assert_equal('id', @tab.primary_key)
  end

  # Strict entry

  describe 'when initialized improperly' do
    it 'must raise ArgumentError' do
      # Duplicated columns
      file = Tempfile.new('test')
      file.write "ID\tA\tA\n1\tC++\tgood\n2\tRuby\tbetter\n"
      file.flush
      assert_raises(ArgumentError) { BioTCM::Table.load(file.path) }
      file.close!

      # Duplicated primary keys
      file = Tempfile.new('test')
      file.write "ID\tA\tB\n1\tC++\tgood\n1\tRuby\tbetter\n"
      file.flush
      assert_raises(ArgumentError) { BioTCM::Table.load(file.path) }
      file.close!

      # Inconsistent-size row
      file = Tempfile.new('test')
      file.write "ID\tA\tA\n1\tC++\tgood\n2\tRuby\n"
      file.flush
      assert_raises(ArgumentError) { BioTCM::Table.load(file.path) }
      file.close!
    end
  end

  # Tolerant exit

  describe 'when method called' do
    before do
      @tab = "ID\tA\tB\tC\n1\tab\t1\t0.8\n2\tde\t3\t0.2\n3\tfk\t6\t1.9".to_table
    end

    it 'must return primary key' do
      assert_equal('ID', @tab.primary_key)
      # It's OK to make primary key the same as one column
      @tab.primary_key = 'A'
      assert_equal('A', @tab.primary_key)
    end

    it 'must return column keys' do
      assert_equal(%w(A B C), @tab.col_keys)
      # Make sure that we just get a copy of column keys
      @tab.col_keys.push nil
      assert_equal(%w(A B C), @tab.col_keys)
      # But we can modify them this way
      keys = @tab.col_keys
      keys[1] = 'D'
      @tab.col_keys = keys
      assert_equal(%w(A D C), @tab.col_keys)
    end

    it 'must return row keys' do
      assert_equal(%w(1 2 3), @tab.row_keys)
      # Make sure that we just get a copy of row keys
      @tab.row_keys.push nil
      assert_equal(%w(1 2 3), @tab.row_keys)
      # But we can modify them this way
      keys = @tab.row_keys
      keys[2] = '4'
      @tab.row_keys = keys
      assert_equal(%w(1 2 4), @tab.row_keys)
    end

    it 'must print itself' do
      tab_string = "ID\tA\tB\tC\n1\tab\t1\t0.8\n2\tde\t3\t0.2\n3\tfk\t6\t1.9"
      tab = tab_string.gsub("\t", ',').to_table(seperator: ',')
      assert_equal(tab_string, tab.to_s)
    end

    it 'must return elements' do
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

      @tab['5', 'F'] = '='
      assert_equal('=', @tab['5', 'F'])
    end

    it 'must return rows' do
      assert_equal('6', @tab.row('3')['B'])
      assert_equal(nil, @tab.row('3')['D'])
      assert_equal(nil, @tab.row('4'))

      @tab.row('3', 'B' => '-')
      assert_equal('-', @tab.row('3')['B'])
      @tab.row('4', 'B' => '-', 'D' => '-')
      assert_equal('',  @tab.row('4')['A'])
      assert_equal('-', @tab.row('4')['B'])
      assert_equal(nil, @tab.row('4')['D'])

      @tab.row('4', ['-', '', '-'])
      assert_equal('-', @tab.row('4')['A'])
      assert_equal('',  @tab.row('4')['B'])

      @tab['4', nil] = ['', '=', '']
      assert_equal('',  @tab['4', nil]['A'])
      assert_equal('=', @tab['4', nil]['B'])
    end

    it 'must return columns' do
      assert_equal('6', @tab.col('B')['3'])
      assert_equal(nil, @tab.col('C')['4'])
      assert_equal(nil, @tab.col('D'))

      @tab.col('B', '3' => '-')
      assert_equal('-', @tab.col('B')['3'])
      @tab.col('D', '2' => '-', '4' => '-')
      assert_equal('',  @tab.col('D')['1'])
      assert_equal('-', @tab.col('D')['2'])
      assert_equal(nil, @tab.col('D')['4'])

      @tab.col('D', ['-', '', '-'])
      assert_equal('-', @tab.col('D')['1'])
      assert_equal('',  @tab.col('D')['2'])

      @tab[nil, 'D'] = ['', '=', '']
      assert_equal('',  @tab[nil, 'D']['1'])
      assert_equal('=', @tab[nil, 'D']['2'])
    end

    it 'must return selected rows and columns as a Table' do
      tab = @tab.select(%w(4 3 1), %w(D C B))
      refute_same(@tab, tab)
      assert_equal(@tab.primary_key, tab.primary_key)
      assert_equal(%w(3 1), tab.row_keys)
      assert_equal(%w(C B), tab.col_keys)
      assert_equal(nil, tab.ele('2', 'A'))
      assert_equal(nil, tab.ele('2', 'C'))
      assert_equal(nil, tab.ele('1', 'A'))
      assert_equal('6', tab.ele('3', 'B'))
    end

    it 'must return selected rows as a Table' do
      tab = @tab.select_row(%w(4 3 1))
      refute_same(@tab, tab)
      assert_equal(%w(3 1), tab.row_keys)
      assert_equal('1', tab.ele('1', 'B'))
      assert_equal(nil, tab.ele('2', 'B'))
      assert_equal('6', tab.ele('3', 'B'))
    end

    it 'must return selected columns as a Table' do
      tab = @tab.select_col(%w(D C B))
      refute_same(@tab, tab)
      assert_equal(%w(C B), tab.col_keys)
      assert_equal(nil, tab.ele('3', 'A'))
      assert_equal('6', tab.ele('3', 'B'))
      assert_equal('1.9', tab.ele('3', 'C'))
    end

    it 'must be merged with another table' do
      assert_equal(nil, @tab.ele('4', 'A'))
      assert_equal(nil, @tab.ele('2', 'D'))
      assert_equal('6', @tab.ele('3', 'B'))
      assert_equal(nil, @tab.ele('4', 'B'))
      assert_equal('1', @tab.ele('1', 'B'))

      tab = @tab.merge("ID\tB\tD\n1\tab\t1\n4\tuc\t4".to_table)
      refute_same(@tab, tab)
      assert_instance_of(BioTCM::Table, tab)
      assert_equal('', tab.ele('4', 'A'))
      assert_equal('', tab.ele('2', 'D'))
      assert_equal('6', tab.ele('3', 'B'))
      assert_equal('uc', tab.ele('4', 'B'))
      assert_equal('ab', tab.ele('1', 'B'))
    end
  end
end
