# frozen_string_literal: true

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port        ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RAILS_ENV") { "development" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

worker_count = if ENV["WEB_CONCURRENCY"]
                 ENV["WEB_CONCURRENCY"].to_i
               elsif ENV["RAILS_ENV"] == "production"
                 2
               else
                 0
               end

workers worker_count

if worker_count > 0
  preload_app!

  on_worker_boot do
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
    end
  end
end

plugin :tmp_restart
