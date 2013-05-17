require 'aws'
require 'digest/md5'

include AWS

load 'lib/config.rb'

print 'Connecting to S3...'

s3 = S3.new $conf[:AWS]

puts ' Done'

print 'Getting bucket info...'

bucket = s3.buckets[$conf[:bucket]]

unless bucket.exists?
  puts ' Failed'
  abort "bucket #{$conf[:bucket]} does not exist"
end

puts ' Done'

puts 'Processing files...'

Dir['output/**/*'].each do |local|
  next if File.directory? local

  name = local.match(/^output\/(.+)$/)[1]
  print "  - #{name}..."

  digest = Digest::MD5.hexdigest File.read local
 
  remote = bucket.objects[name]

  if remote.exists? and remote.etag.delete('"') == digest
    puts ' Skipped Existing File'
    next
  end

  remote.write Pathname.new(local),
    acl: :public_read

  puts ' Done'
end

