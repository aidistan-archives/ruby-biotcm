# encoding: UTF-8

# Namespace of all classes who interactive with databases
# directly or indirectly
module BioTCM::Databases
  autoload(:HGNC, "biotcm/databases/hgnc")
  autoload(:Cipher, "biotcm/databases/cipher")
end
