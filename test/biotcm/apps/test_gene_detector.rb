require_relative '../../test_helper'

describe BioTCM::Apps::GeneDetector do
  it 'must detect genes' do
    assert_equal(%w(TP53), BioTCM::Apps::GeneDetector.new.detect('p53 is a critical gene during oncogenesis.'))
  end
end
