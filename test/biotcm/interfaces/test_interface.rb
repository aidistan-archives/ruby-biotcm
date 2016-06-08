require_relative '../../test_helper'

describe BioTCM::Interfaces do
  before do
    @context = { name: 'world' }
  end

  describe BioTCM::Interfaces::Interface do
    include BioTCM::Interfaces::Interface

    it 'must render scripts' do
      assert(render_template(File.expand_path('../template.R.erb', __FILE__), @context))
    end
  end

  # describe BioTCM::Interfaces::R do
  #   include BioTCM::Interfaces::R
  #
  #   it 'must evaluate R scripts' do
  #     assert(evaluate_r_script(File.expand_path('../template.R.erb', __FILE__), @context))
  #   end
  # end

  # describe BioTCM::Interfaces::Matlab do
  #   include BioTCM::Interfaces::Matlab
  #
  #   it 'must evaluate MATLAB scripts' do
  #     assert(evaluate_matlab_script(File.expand_path('../template.m.erb', __FILE__), @context))
  #   end
  # end
end
