desc "Build and release all AMIs"
task :run => [:render] do
  puts "Building #{Bakery::PACKER_OUTPATH} with Packer..."
  exec 'packer', 'build', Bakery::PACKER_OUTPATH
end
