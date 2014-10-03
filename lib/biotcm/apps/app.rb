# Superclass of all app class
class BioTCM::Apps::App
  # Main entry for apps.
  # Run the app from a command prompt with arguments set in ARGV.
  # @abstract
  def run
    raise NotImplementedError, "Please overload"
  end
end
