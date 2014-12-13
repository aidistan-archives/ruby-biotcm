# A built-in app for running BioTCM in irb
class BioTCM::Apps::Console < BioTCM::Apps::App
  # Version of Console
  VERSION = '1.0.0'
  # Run BioTCM in console
  def run
    BioTCM.console
  end
end
