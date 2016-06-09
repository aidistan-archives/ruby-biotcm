# Namespace of all classes who interacts with databases directly or indirectly
module BioTCM::Databases
  autoload(:HGNC, 'biotcm/databases/hgnc')
  autoload(:Cipher, 'biotcm/databases/cipher')
  autoload(:Medline, 'biotcm/databases/medline')
  # autoload(:KEGG, 'biotcm/databases/kegg')
  autoload(:OMIM, 'biotcm/databases/omim')
end
