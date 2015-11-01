# Superclass of all app class
class BioTCM::Apps::App
  # GLI parser
  def self.gli(_c)
    fail NotImplementedError
  end
end
