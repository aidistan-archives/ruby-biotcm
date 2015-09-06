# Namespace of all scripts
module BioTCM::Apps
  # Built-in apps
  autoload(:App, 'biotcm/apps/app')
  autoload(:GeneDetector, 'biotcm/apps/gene_detector')

  # Get the list of all available apps
  def self.apps
    return @apps if @apps

    apps_file = BioTCM.path_to('data/apps.json', secure: true)
    available_gems = `gem list biotcm- --no-versions`.split("\n")

    @apps = JSON.parse(
      begin
        # Try to use the latest
        BioTCM.get(BioTCM::DEFAULT_APPS_FILE).tap do |json|
          File.open(apps_file, 'w').write(json)
        end
      rescue
        # Or use the one downloaded previously
        raise 'Please connect to Internet to get the latest list of apps' unless File.exist?(apps_file)
        File.read(apps_file)
      end
    ).reject { |k| /^__/ =~ k }.select do |_k, v|
      if v['gem-name']
        available_gems.include?(v['gem-name'])
      else
        constants.include?(v['class-name'].to_sym)
      end
    end
  end
end
