require 'fileutils'
require 'csv'

# gems
require 'zipruby'
require 'aws'

include AWS

load 'lib/templates.rb'
load 'lib/config.rb'

output_dir = File.join(__dir__, '../output')
FileUtils.mkdir_p output_dir


s3 = S3.new $conf[:AWS]


print 'Getting bucket info...'

bucket = s3.buckets[$conf[:source_bucket]]

unless bucket.exists?
  puts ' Failed'
  abort "bucket #{$conf[:source_bucket]} does not exist"
end

puts ' Done'


puts 'Processing files...'

main_index_links = {}

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

  index_links = {}

  index_links['..'] = [
    "..", ''
  ]

  my_output_dir = File.join(output_dir, match[:date])
  FileUtils.mkdir_p my_output_dir

  data.each do |product_name, product_data|
    # XXX: this is hax
    next unless product_name
    next if product_name == 'ProductName'

    product_data.reject! {|k, v| k.nil?}

    page_title = "#{product_name} - #{match[:date]}"

    template_output = Templates.result 'product_combined', binding

    file_name = product_name.tr_s '^a-zA-Z0-9', '-'

    path = File.join my_output_dir, "#{file_name}.html"

    File.open path, 'w' do |f|
      f.puts template_output
    end

    index_links[product_name] = [
      "#{file_name}.html",
      "#{product_data.length} Products"
    ]
  end

  page_title = "Index - #{match[:date]}"
  template_output = Templates.result 'index', binding
  
  File.open File.join(my_output_dir, 'index.html'), 'w' do |f|
    f.puts template_output
  end

  main_index_links[match[:date]] = [
    "#{match[:date]}/",
    "#{index_links.length} Products"
  ]
end

index_links = main_index_links
page_title = 'Index'

File.open File.join(output_dir, 'index.html'), 'w' do |f|
  f.puts Templates.result('index', binding)
end


puts 'Done'

