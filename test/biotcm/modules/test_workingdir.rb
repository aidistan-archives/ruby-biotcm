require_relative '../../test_helper'

include BioTCM::Modules::WorkingDir

describe BioTCM::Modules::WorkingDir do
  it 'must change @wd if :wd= called' do
    assert_raises(RuntimeError, '@wd already initialized at first.') { wd }
    self.wd = File.dirname(__FILE__)
    assert_equal(File.dirname(__FILE__), wd, '@wd not changed.')
  end

  it 'must create working directory if @wd not exist' do
    test_path = File.expand_path('../_test', __FILE__)
    Dir.delete(test_path) if Dir.exist?(test_path)

    wd = test_path
    refute(Dir.exist?(wd), "Oops, \"#{wd}\" created too early.")
    self.wd = wd
    assert(Dir.exist?(wd), 'Working directory not created.')
    Dir.delete(wd)
  end
end
