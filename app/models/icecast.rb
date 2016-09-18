require 'sys/proctable'

class Icecast

  class Status
    def initialize(is_running)
      @is_running = is_running
    end

    def is_running
      @is_running
    end
  end

  def self.get_status
    icecast_procs = Sys::ProcTable.ps.select{|process| process.name == 'icecast'}
    Status.new(icecast_procs.count > 0)
  end

end