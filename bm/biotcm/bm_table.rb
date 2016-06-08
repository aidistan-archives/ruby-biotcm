require_relative '../bm_helper'

RUN_TIMES = 10

MyBenchmark.group 'Table initialization' do |b|
  # Current method used by Table#new
  b.report('String#to_table') do
    RUN_TIMES.times do
      File.open('bm/fixtures/table_1.txt').read.to_table
    end
  end

  b.report('Table#row:Hash') do
    RUN_TIMES.times do
      fin = File.open('bm/fixtures/table_1.txt')
      # Fill column names
      col_names = fin.gets.chomp.split("\t")
      tab = BioTCM::Table.new(primary_key: col_names.shift, col_keys: col_names)
      # Insert rows
      fin.each do |line|
        col = line.chomp.split("\t", -1)
        val = { col_names[0] => col[1], col_names[1] => col[2] }
        tab.row(col[0], val)
      end
    end
  end

  b.report('Table#row:Array') do
    RUN_TIMES.times do
      fin = File.open('bm/fixtures/table_1.txt')
      # Fill column names
      col_names = fin.gets.chomp.split("\t")
      tab = BioTCM::Table.new(primary_key: col_names.shift, col_keys: col_names)
      # Insert rows
      fin.each do |line|
        col = line.chomp.split("\t", -1)
        tab.row(col.shift, col)
      end
    end
  end
end

@tab1 = BioTCM::Table.load('bm/fixtures/table_1.txt')
@tab2 = BioTCM::Table.load('bm/fixtures/table_2.txt')

MyBenchmark.group 'Table operation' do |b|
  b.report('merge') do
    RUN_TIMES.times do
      @tab = @tab1.merge(@tab2)
    end
  end

  b.report('select') do
    RUN_TIMES.times do
      @tab.select_col(%w(Name Fullname))
    end
  end
end
