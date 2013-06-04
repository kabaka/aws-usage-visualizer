require 'fileutils'
require 'csv'

# gems
require 'zipruby'
require 'aws'

include AWS

load 'lib/templates.rb'
load 'lib/config.rb'

def create_html name, body
  title = File.basename(name, '.html').split('-').map {|w| w.capitalize}.join ' '

  content = Templates.result 'html', binding

  create_file name, content
end

def create_file name, content
  @renamed.each do |original, new|
    content.gsub! original, new
  end

  File.open("output/#{name}", 'w') { |f| f.puts content }
end


output_dir = File.join(__dir__, '../output')

FileUtils.mkdir_p output_dir


s3 = S3.new $conf[:AWS]


print 'Getting bucket info...'

bucket = s3.buckets[$conf[:bucket]]

unless bucket.exists?
  puts ' Failed'
  abort "bucket #{$conf[:bucket]} does not exist"
end

puts ' Done'


puts 'Processing files...'

bucket.objects.each do |object|
  match = object.key.match(
    /^(?<id>\d+)-aws-billing-detailed-line-items-(?<date>\d{4}-\d{2}).csv.zip$/
  )

  next unless match

  puts  "  - #{match[:date]}"
  print "    - Downloading..."

  zip = object.read

  puts " Done"
  print "    - Extracting..."

  buf = ''

  Zip::Archive.open_buffer zip do |archive|
    archive.each do |entry|
      buf << entry.read
    end
  end
  
  puts " Done"
  print "    - Parsing..."

  data = {}
  
  CSV.parse buf do |a|
    # lol
    # {
    #  "ProductName" => {
    #    "UsageType" => {
    #      "Operation" => {
    #        "ItemDescription" => {
    #          "UsageStartDate" => ["UsageQuantity", "Rate", "Cost"]
    #         }
    #       }
    #     }
    #   }
    # }
    data[a[4]]                    ||= {}
    data[a[4]][a[8]]              ||= {}
    data[a[4]][a[8]][a[9]]        ||= {}
    data[a[4]][a[8]][a[9]][a[12]] ||= {}

    data[a[4]][a[8]][a[9]][a[12]][a[13]] = a[15..-1]
  end

  puts " Done"
  puts "    - Generating output..."

  data.each do |product_name, product_data|
    my_output_dir = File.join(output_dir, match[:date])
    FileUtils.mkdir_p my_output_dir

    output = Templates.result 'product', binding

    File.open File.join(my_output_dir, "#{product_name}.html") , 'w'do |f|
      f.puts output
    end
  end
end

puts 'Done'

