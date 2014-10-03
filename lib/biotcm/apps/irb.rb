# An built-in app for running BioTCM in irb
class BioTCM::Apps::IRB < BioTCM::Apps::App
  # Version of IRB
  VERSION = '1.0.0'
  # Run BioTCM in irb
  def run
    BioTCM.console
  end
end
