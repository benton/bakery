desc "Render all JSON files for Packer into build"
task :render do
  TIME          = Time.now.getgm
  TIMESTAMP     = TIME.strftime("%Y%m%d-%H%M%S")
  HUMANTIME     = TIME.strftime("%Y/%m/%d at %H:%M:%S")
  DEFAULTS_FILE = "#{File.dirname(__FILE__)}/../../config/defaults.yml"
  AWS_CFG_FILE  = "#{File.dirname(__FILE__)}/../../config/aws_config.yml"
  DEFAULTS_TEXT = File.read(DEFAULTS_FILE)
  REGIONS       = YAML.load(DEFAULTS_TEXT)['aws_regions']
  UBUNTUS       = YAML.load(DEFAULTS_TEXT)['ubuntu_versions']
  RUBIES        = YAML.load(DEFAULTS_TEXT)['ruby_versions']

  # Load AWS config if it's present
  AWS.config(YAML.load(File.read AWS_CFG_FILE)) if File.exists?(AWS_CFG_FILE)

  # create a provisioner for each ruby version, and index it by ruby version
  provisioners  = Hash.new
  RUBIES.each do |ruby_version|
    provisioner = YAML.load(DEFAULTS_TEXT)['provisioners'].first
    provisioner['only'] ||= Array.new
    ruby_url = Bakery.ruby_url(ruby_version, ENV['RUBY_BASE_URL'])
    provisioner['environment_vars'] << "RUBY_SRC_URL=#{ruby_url}"
    provisioners[ruby_version] = provisioner  # index for later retrieval
  end

  # for each region * ubuntu * ruby, create a dedicated builder
  builders = Array.new
  REGIONS.each do |region|
    UBUNTUS.each do |ubuntu_version|
      puts "Searching for latest Ubuntu #{ubuntu_version} in #{region}..."
      ami = Bakery.canonical_ami(ubuntu_version, region)
      puts "Creating Ubuntu #{ubuntu_version} #{region} AMI(s) based on #{ami}"
      RUBIES.each do |ruby_version|
        ruby = ruby_version.gsub(/\W/,'')  # strip all punctuation
        # Create a new builder based on the defaults
        builder = YAML.load(DEFAULTS_TEXT)['builders'].first
        name = "mdsol-ubuntu-#{ubuntu_version}-#{ruby}"
        desc = "Ubuntu #{ubuntu_version} + Ruby v#{ruby_version} (#{TIMESTAMP})"
        builder['source_ami']           = ami
        builder['name']                 = "#{name}-#{region}"
        builder['region']               = region
        builder['ami_name']             = "#{name} #{TIMESTAMP}"
        builder['ami_description']      = desc
        builder['tags']['Description']  = desc
        builder['tags']['Name']         = name
        builder['tags']['Owner']        = ENV['USER'] || 'unknown'
        builder['tags']['CreatedAt']    = HUMANTIME
        builder['tags']['CreatedFrom']  = ami
        builders << builder
        # assign this builder to the appropriate provisioner
        provisioners[ruby_version]['only'] << builder['name']
      end
    end
  end

  # write Packer's JSON output into the build directory
  puts "Writing #{Bakery::PACKER_OUTPATH}..."
  File.open(Bakery::PACKER_OUTPATH, 'w') do |outfile|
    outfile.write(JSON.pretty_generate(
      {"builders" => builders, "provisioners" => provisioners.values}
    ))
  end
  puts "Validating #{Bakery::PACKER_OUTPATH}..."
  puts `packer validate #{Bakery::PACKER_OUTPATH}`
end
