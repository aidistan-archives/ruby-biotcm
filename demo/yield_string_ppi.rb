#!/usr/bin/env ruby
#
# This demo shows how to extract STRING PPIs and translate proteins
# into genes automatically by using Ensembl's API.
#
require 'biotcm'
BioTCM::Databases::HGNC.ensure

#
# Extract proteins and their links
#

unless File.exist?('protein.links.detailed.v10.homo.sapiens.txt')
  BioTCM::Apps::StringProcessor.new(
    'protein.links.detailed.v10.txt',
    'species.v10.txt'
  ).extract_by_species(
    'protein.links.detailed.v10.homo.sapiens.txt'
  )
end

protein2symbol = {}
if File.exist?('proteins.v10.homo.sapiens.txt')
  File.open('proteins.v10.homo.sapiens.txt').each do |line|
    protein2symbol[line.chomp] = ''
  end
else
  File.open('protein.links.detailed.v10.homo.sapiens.txt').each do |line|
    col = line.chomp.split("\t")
    protein2symbol[col[0]] = ''
    protein2symbol[col[1]] = ''
  end
  File.open('proteins.v10.homo.sapiens.txt', 'w').puts protein2symbol.keys
end

#
# Prepare protein2symbol dictionary
#

if File.exist?('protein2symbol.v10.homo.sapiens.txt')
  File.open('protein2symbol.v10.homo.sapiens.txt').each do |line|
    col = line.chomp.split("\t")
    protein2symbol[col[0]] = col[1]
  end
else
  url = URI.parse('http://rest.ensembl.org')
  http = Net::HTTP.new(url.host, url.port)

  protein2symbol.each_key do |protein|
    json = JSON.parse(http.request(
      Net::HTTP::Get.new("/xrefs/id/#{protein}?external_db=Uniprot/SWISSPROT", {
        'Content-Type' => 'application/json'
      })
    ).body)
    next if json.is_a?(Hash) || json.empty?
    p protein2symbol[protein] = json.first['primary_id'].uniprot2symbol
  end

  File.open('protein2symbol.v10.homo.sapiens.txt', 'w') do |fout|
    protein2symbol.each { |k, v| fout.puts k + "\t" + v }
  end
end

#
# Translate proteins into gene symbols
#

File.open('ppi.detailed.v10.homo.sapiens.all.txt', 'w') do |fout|
  File.open('protein.links.detailed.v10.homo.sapiens.txt').each do |line|
    col = line.chomp.split("\t")
    next unless (col[0] = protein2symbol[col[0]]) && (col[1] = protein2symbol[col[1]])
    fout.puts col.join("\t")
  end
end

File.open('ppi.v10.homo.sapiens.700.txt', 'w') do |fout|
  File.open('protein.links.detailed.v10.homo.sapiens.txt').each do |line|
    col = line.chomp.split("\t")
    next unless (col[0] = protein2symbol[col[0]]) && (col[1] = protein2symbol[col[1]])
    next unless col.last.to_i >= 700
    fout.puts col.take(2).join("\t")
  end
end

File.open('ppi.v10.homo.sapiens.900.txt', 'w') do |fout|
  File.open('protein.links.detailed.v10.homo.sapiens.txt').each do |line|
    col = line.chomp.split("\t")
    next unless (col[0] = protein2symbol[col[0]]) && (col[1] = protein2symbol[col[1]])
    next unless col.last.to_i >= 900
    fout.puts col.take(2).join("\t")
  end
end
