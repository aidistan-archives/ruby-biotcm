require 'fileutils'

module BioTCM
  module Modules
    # Designed for handling with working directory, {WorkingDir} is included
    # in almost all classes and modules in BioTCM. It provides
    # {WorkingDir#wd= setter} and {WorkingDir#wd getter} for working directory
    # variable @wd and a useful method {WorkingDir#path_to} to reference files.
    # Note that WorkingDir doesn't initialize @wd itself.
    #   class BioWhat
    #     include BioTCM::Modules::WorkingDir
    #   end
    #
    #   BioWhat.new.wd # raise RuntimeError
    #
    module WorkingDir
      # Get current working directory
      # @return [String]
      # @raise RuntimeError Raised if @wd undefined
      def wd
        @wd || fail("The working directory of #{self} is undefined.")
      end

      # Set current working directory
      #
      # If not exists, the method will try to mkdir one
      # @param val [String] target working directory
      def wd=(val)
        FileUtils.mkdir_p(val)
        @wd = val
      end

      # Expand a relative path to absolute one based on @wd
      # @param relative_path [String]
      # @param secure [Boolean] If true, make sure that parent directories exist
      # @return [String] absolute path
      def path_to(relative_path, secure:false)
        path = File.expand_path(relative_path, @wd)
        FileUtils.mkdir_p(File.dirname(path)) if secure
        path
      end
    end
  end
end
