desc "Bundle all required sources"
task :build do
  exec 'bundle', 'install'
end
