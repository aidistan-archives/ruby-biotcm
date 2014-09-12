require_relative '../test_helper'

describe BioTCM::Scripts::Script do
  it "must raise NotImplementedError" do
    assert_raises(NotImplementedError) do
      BioTCM::Scripts::Script.new(File.dirname(__FILE__)).run
    end
  end
end
