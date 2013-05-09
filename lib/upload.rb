require 'aws/s3'
include AWS::S3

load 'lib/config.rb'

print 'Connecting to S3...'

Base.establish_connection! $conf[:AWS]

puts ' Done'

print 'Getting bucket info...'

bucket = Bucket.find $conf[:bucket]

puts ' Done'

puts 'Processing files...'

Dir['output/**/*'].each do |local|
  next if File.directory? local

  name = local.match(/^output(\/.+)$/)[1]
  print "  - #{name}"

  S3Object.store name, open(local),
    $conf[:bucket], :access => :public_read

  puts ' Done'
end

__END__

bucket.objects.each do |obj|
  remote = obj.key

  if File.exists? "output/#{remote}"
    puts "Existing file found: #{remote}"
  end
end
