require 'fileutils'

module BioTCM
  module Modules
    # Provide setter and getter for working directory variable @wd
    module WorkingDir
      # Get current working directory
      # @return [String]
      # @raise RuntimeError Raised if @wd undefined
      def wd
        @wd or raise "The working directory of #{self} is undefined."
      end
      # Set current working directory
      #
      # If not exists, the method will try to mkdir one.
      # @param val [String] target working directory
      def wd=(val)
        FileUtils.mkdir_p(val)
        @wd = val
      end
      # Expand a relative path to absolute one based on _wd_
      # @param relative_path [String]
      # @param secure [Boolean] If true, make parent directories exist
      # @return [String] absolute path
      def path_to(relative_path, secure = false)
        path = File.expand_path(relative_path, @wd)
        FileUtils.mkdir_p(File.dirname(path)) if secure
        path
      end
    end
  end
end
