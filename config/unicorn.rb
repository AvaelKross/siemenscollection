app_path = "/home/apps/siemenscollection/production/current"

worker_processes   1
preload_app        true
timeout            30
listen             '127.0.0.1:8080'
user               'apps', 'apps'
working_directory  app_path
pid                "#{app_path}/tmp/pids/unicorn.pid"
stderr_path        "/home/apps/siemenscollection/log/unicorn.err.log"
stdout_path        "/home/apps/siemenscollection/log/unicorn.out.log"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
