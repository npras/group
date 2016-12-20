require 'thor'

module Group
  class CLI < Thor

    desc "process", "do the work!"
    def process
      Main.new.process!
    end

  end
end
