# encoding: UTF-8

# Namespace of all classes who interactive with databases
# directly or indirectly
module BioTCM::Databases
  autoload(:HGNC, "biotcm/databases/hgnc")
  autoload(:Cipher, "biotcm/databases/cipher")
  autoload(:Medline, "biotcm/databases/medline")
  autoload(:KEGG, "biotcm/databases/kegg")
end
