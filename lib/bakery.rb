require 'aws-sdk'

module Bakery

  CANONICAL_AWS_ID      = '099720109477'  # AWS ID for Ubuntu's publisher
  DATE_MATCHER          = /(\d\d\d\d)(\d\d)(\d\d)(\.\d+)?\Z/
  RUBY_VERSION_MATCHER  = /\A(\d\.\d)/
  DEFAULT_RUBIES        = %w{ 1.9.2-p290 1.9.3-p125 1.9.3-p327 2.0.0-p353 }
  DEFAULT_UBUNTUS       = [ "12.04", "13.10" ]
  DEFAULT_REGIONS       = %w{ us-east-1 }
  PROJECT_DIR           = File.expand_path("#{File.dirname(__FILE__)}/..")
  PACKER_OUTPATH        = "#{PROJECT_DIR}/build/packer.json"

  # Returns the latest Canonical Ubuntu AMI for a given
  # Ubuntu version, AWS region, architecture, and root device type.
  def self.canonical_ami(ubuntu_version, region = 'us-east-1',
    arch = :x86_64, root_type = :ebs)
    ec2 = AWS::EC2.new(:region => region)
    candidates = ec2.images.with_owner(CANONICAL_AWS_ID).select do |image|
      (image.type                 == :machine)      &&
      (image.root_device_type     == root_type)     &&
      (image.architecture         == arch)          &&
      (image.virtualization_type  == :paravirtual)  &&
      ((image.name || '')         =~ DATE_MATCHER)  &&
      ((image.name || '')         =~ /#{ubuntu_version}/)
    end
    candidates.sort{|a,b| a.name <=> b.name}.last.id
  end

  # returns a url (String) for downloading the given version of Ruby
  def self.ruby_url(version, base_url = nil)
    unless matches = version.match(RUBY_VERSION_MATCHER)
      raise "version must match #{RUBY_VERSION_MATCHER}"
    end
    major_v, filename = matches[1], "ruby-#{version}.tar.gz"
    if base_url
      return "#{base_url}/#{filename}"
    else
      return "ftp://ftp.ruby-lang.org/pub/ruby/#{major_v}/#{filename}"
    end
  end
end
