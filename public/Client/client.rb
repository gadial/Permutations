require 'uri'
require 'net/http'

DEBUG_MESSAGES = false

class Client
#   $server_address = "http://localhost:3000"
  $server_address = "http://www.perm.gadial.net"
  $idle_sleep_time = 300
  def initialize
    @status = :idle
  end
  def get_task
    puts "getting task" if DEBUG_MESSAGES
    res = Net::HTTP.get URI.parse($server_address + "/counter/get_task")
    if res =~ /No task avialable/
      puts "got no task" if DEBUG_MESSAGES
      @status = :wait
    else
      res =~ /<div id=\"task_id\">(.*?)<\/div>.*<div id=\"task_cmd_line\">(.*?)<\/div>/m
      @id, @cmd = $1, $2
      puts "got task no. #{@id}: #{@cmd}" if DEBUG_MESSAGES
      @status = :has_task
      @status = :wait if @id == nil
    end
  end
  def do_task
    puts "doing task #{@cmd}" if DEBUG_MESSAGES
    time = Time.now
    @result = `#{@cmd}`
    @time_taken = Time.now - time
    @status = :finished_task
    puts "finished task" if DEBUG_MESSAGES
  end
  def submit_task
    puts "submitting task" if DEBUG_MESSAGES
    res = Net::HTTP.post_form URI.parse($server_address + "/counter/submit_task"), {:id => @id, :result => @result, :time => @time_taken}
    @status = :idle
  end
  
  def wait
    puts "sleeping..." if DEBUG_MESSAGES
    sleep $idle_sleep_time
    @status = :idle
  end
  
  def run
    while true
      begin
	case @status
	when :idle then get_task
	when :has_task then do_task
	when :finished_task then submit_task
	when :wait then wait
	when :quit then exit
	end
      rescue Exception
	puts "connection failed, retrying soon..." if DEBUG_MESSAGES
	@status = :wait
	retry
      end
    end
  end
end

Client.new.run