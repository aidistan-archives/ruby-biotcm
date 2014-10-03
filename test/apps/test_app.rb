require_relative '../test_helper'

describe BioTCM::Apps::App do
  it "must raise NotImplementedError" do
    assert_raises(NotImplementedError) do
      BioTCM::Apps::App.new.run
    end
  end
end
