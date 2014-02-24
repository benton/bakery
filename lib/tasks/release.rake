desc "Write config files from ENV"
task :release do
  Rake::Task["config:deploy"].invoke
end
