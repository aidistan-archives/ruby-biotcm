require_relative 'bm-helper'

MyBenchmark.group "Table initialization" do |b|
  
  # Current method used by Table#new
  b.report("String#to_table") do
    tab = File.open("bm_table/table_1.txt").read.to_table
  end

  b.report("Table#row:Hash") do
    tab = Table.new
    fin = File.open("bm_table/table_1.txt")
    # Fill column names
    col_names = fin.gets.chomp.split("\t")
    tab.primary_key = col_names.shift
    col_names.each { |c| tab.col(c, {}) }
    # Insert rows
    fin.each do |line|
      col = (line.chomp + "\tTILE").split("\t"); col.pop
      val = {col_names[0]=>col[1], col_names[1]=>col[2]}
      tab.row(col[0], val)
    end
  end

  b.report("Table#row:Array") do
    tab = Table.new
    fin = File.open("bm_table/table_1.txt")
    # Fill column names
    col_names = fin.gets.chomp.split("\t")
    tab.primary_key = col_names.shift
    col_names.each { |c| tab.col(c, {}) }
    # Insert rows
    fin.each do |line|
      col = (line.chomp + "\tTILE").split("\t"); col.pop
      tab.row(col.shift, col)
    end
  end
end

@tab1 = Table.new("bm_table/table_1.txt")
@tab2 = Table.new("bm_table/table_2.txt")

MyBenchmark.group "Table operation" do |b|
  b.report("merge") do
    @tab = @tab1.merge(@tab2)
  end

  b.report("select") do
    @tab.select_col(['Name', 'Fullname'])
  end
end
