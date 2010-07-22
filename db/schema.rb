# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100721053436) do

  create_table "counters", :force => true do |t|
    t.string   "values_string"
    t.string   "counter_type",       :default => "standard"
    t.integer  "n"
    t.integer  "d",                  :default => 2
    t.integer  "leaper_a",           :default => 0
    t.integer  "leaper_b",           :default => 0
    t.integer  "parallel_level",     :default => 0
    t.integer  "slices",             :default => 1
    t.boolean  "active",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finished_tasks_num"
    t.integer  "total_tasks_num"
    t.integer  "task_max",           :default => 0
  end

  create_table "counting_tasks", :force => true do |t|
    t.string   "cmd"
    t.string   "result"
    t.boolean  "finished",   :default => false
    t.integer  "priority",   :default => 0
    t.integer  "counter_id"
    t.float    "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permutation_classes", :force => true do |t|
    t.string   "patterns"
    t.integer  "sequence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sequences", :force => true do |t|
    t.string   "values_string"
    t.string   "description"
    t.boolean  "checked",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
