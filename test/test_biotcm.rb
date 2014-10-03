require_relative 'test_helper'

describe BioTCM do
  it "must be able to get meta data" do
    assert_equal('meta.json', BioTCM.get_meta('_filename'))
  end

  it "must be able to get apps data" do
    assert_equal('apps.json', JSON.parse(BioTCM.get(BioTCM::DEFAULT_APPS_FILE)).fetch('_filename'))
  end
end
