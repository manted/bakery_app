task :default => [:run]

desc "run the bakery app"
task "run" do
  $LOAD_PATH.unshift(File.dirname(__FILE__), "lib")  
  require 'bakery_app'
  
  BakeryApp.run
end
