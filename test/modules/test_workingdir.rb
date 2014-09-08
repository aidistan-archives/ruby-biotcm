require_relative '../test-helper'

class BioTCM_Modules_WorkingDir_Test < Test::Unit::TestCase
  include BioTCM::Modules::WorkingDir
  
  context "WorkingDir module" do
    should "change @wd if :wd= called" do
      assert_raise(RuntimeError, "@wd initialized at first.") { self.wd }
      self.wd = File.dirname(__FILE__)
      assert_nothing_raised ("@wd not changed.") { self.wd }
    end

    should "create working directory if @wd not exist" do
      test_path = File.expand_path("../_test" ,__FILE__)
      Dir.delete(test_path) if Dir.exists?(test_path)

      wd = test_path
      assert(!Dir.exist?(wd), "Oops, \"#{wd}\" created too early.")
      self.wd = wd
      assert(Dir.exist?(wd), "Working directory not created.")
      Dir.delete(wd)
    end
  end
end
