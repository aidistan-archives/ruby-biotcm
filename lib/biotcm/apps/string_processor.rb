# To extract ppi network from STRING
class BioTCM::Apps::StringProcessor
  # Version of StringProcessor
  VERSION = '0.1.0'

  # Open STRING data files
  # @param protein_links_filepath [String]
  # @param species_filepath [String]
  def initialize(protein_links_filepath, species_filepath)
    @f_protein_links = File.open(protein_links_filepath)
    @f_species = File.open(species_filepath)
  end

  # Check given STRING network file
  def check
    species = []
    counter = 0

    @f_protein_links.pos = 0
    @f_protein_links.each do |line|
      col = line.chomp!.split("\t")
      /^(?<id>\d+)\./ =~ col[0]
      if id != species.last
        puts "Processing Species No.#{id}..."
        species << id
      end
      counter += 1
    end

    puts "Total #{species.size} kinds of species"
    puts "Total #{counter} lines"
  end

  # Extract ppi network by species
  # @param output [String] output file path
  # @param species [String/Integer] species name or ID
  def extract_by_species(filepath, species = 'Homo sapiens')
    fout = File.new(filepath, 'w')
    raise ArgumentError, 'Illegal filepath given' unless fout

    species = find_species_id(species).to_i
    raise ArgumentError, 'Illegal species given' unless species > 0

    # Start from head of the file
    counter = 0
    @f_protein_links.pos = 0

    # Jump to target lines
    until @f_protein_links.gets =~ /^#{species}\./
      @f_protein_links.pos += 500_000
      @f_protein_links.gets # finish reading current line
    end
    @f_protein_links.pos -= 501_000
    @f_protein_links.gets

    # Start to extract
    @f_protein_links.each do |line|
      col = line.chomp.split(' ')
      col[0] =~ /(\d+)\.(.*)$/
      next if $1.to_i < species
      break if $1.to_i > species

      # Handle proteins' names
      col[0] = $2
      col[1] =~ /\d+\.(.*)$/
      col[1] = $1

      fout.puts col.join("\t")
      counter += 1
    end

    puts "Total #{counter} PPIs extracted"
    fout.close
  end

  private

  # Find species id by taxon_id, STRING_name_compact or official_name_NCBI
  def find_species_id(species)
    pattern = Regexp.new(species)

    @f_species.pos = 0
    @f_species.gets # Title line
    @f_species.each do |line|
      col = line.chomp.split("\t")
      [col[0], col[2], col[3]].each do |str|
        return col[0] if pattern =~ str
      end
    end
    nil
  end
end
