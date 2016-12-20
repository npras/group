require_relative 'group/constants'

require 'byebug'
require 'logger'
require 'csv'

require 'sequel'

Process.setproctitle "group"

module Group
  extend self

  def logger
    FileUtils.mkdir_p('log')
    @logger ||= Logger.new(FILEPATH_LOG)
  end
end


require_relative 'group/main'
require_relative 'group/cli'
