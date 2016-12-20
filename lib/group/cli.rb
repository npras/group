require 'thor'

module Group
  class CLI < Thor

    desc "process", "do the work!"
    def process(*args)
      Main.new.process!(args)
    end

  end
end
