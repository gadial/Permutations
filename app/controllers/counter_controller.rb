class CounterController < ApplicationController
  def index
  end

  def status
  end

  def admin
  end

  def create
    @counter = Counter.new
  end

  def add_counter
    @counter = Counter.new(params[:counter])
    @counter.active = true if Counter.find_by_active(true) == nil
		 if @counter.save
       @counter.create_tasks
        flash[:notice] = "counter added"
        redirect_to :action => :index
      else
        render :action => :create
      end
  end
  def show_counters
    @counters = Counter.find(:all)
  end
  def show_counting_tasks
    @counting_tasks = CountingTask.find(:all)
  end
  def get_task
    @counter = Counter.find_by_active(true)
    @task = @counter.get_counting_task if @counter
  end
  def submit_task
    @id = params[:id]
    @result = params[:result]
    @time = params[:time]
    if @id and @result
      task = CountingTask.find_by_id(@id)
      task.set_result(@result, @time)
    end

    counter = Counter.find_by_active(true)
    if counter.percent_done == 100
      counter.active = false
      counter.save
    end
  end
  def activate_counter
    counter = Counter.find_by_id(params[:id])
    if counter
      old_counter = Counter.find_by_active(true)
      if old_counter
        old_counter.active = false
        old_counter.save
      end
      counter.active = true
      counter.save
    end
    redirect_to :action => :show_counters
  end
  def fix_counter
    counter = Counter.find_by_id(params[:id])
    if counter
      counter.fix_results
    end
    redirect_to :action => :show_counters
  end
end
