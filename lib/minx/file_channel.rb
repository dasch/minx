
require 'minx/io_channel'

module Minx
  class FileChannel < IOChannel
    # Open a new file channel.
    #
    # The lines of the file will be returned upon calls to {#read}.
    #
    # @param [String] filename
    # @param [Hash] options
    # @option options [String] :mode ("r") the file access mode
    def initialize(filename, options = {})
      options[:mode] ||= 'r'

      super(::File.new(filename, options[:mode]))
    end
  end
end
