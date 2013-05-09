require 'fileutils'
require 'ostruct'
require 'kramdown'
require 'digest/md5'

load 'lib/templates.rb'

items   = []

@renamed = {}

puts 'Preparing static assets...'

FileUtils.mkdir_p 'output/static-assets'

Dir['source-files/static-assets/*'].each do |relative_path|
  match = relative_path.match(/source-files\/static-assets\/(?<full_name>(?<name>[^\.]+)\.(?<extension>.+))$/)
  
  print "  - #{match[:full_name]}..."

  # For assets behind CDN
  # TODO: Something better than MD5.hexdigest?
#  hash = Digest::MD5.hexdigest(File.read(relative_path))
#  new_name = "#{match[:name]}-#{hash}.#{match[:extension]}"
#  @renamed["static-assets/#{match[:full_name]}"] = "static-assets/#{new_name}"
#  FileUtils.cp relative_path, "output/static-assets/#{new_name}"

  FileUtils.cp_r relative_path, "output/static-assets/"
  
  puts ' Done'
end

def create_html name, body
  content = Templates.result 'html', binding

  create_file name, content
end

def create_file name, content
  @renamed.each do |original, new|
    content.gsub! original, new
  end

  File.open("output/#{name}", 'w') { |f| f.puts content }
end

puts 'Generating HTML...'

Dir['source-files/pages/*.*'].each do |file|
  match = file.match(/^source-files\/pages\/(?<name>[^\.]+)\.(?<type>.+)$/)

  output_file_name = "#{match[:name]}.html"

  print "  - #{output_file_name}..."

  case match[:type].to_sym
  when :md, :markdown
    body = Kramdown::Document.new(IO.read(file)).to_html
  else
    body = IO.read(file)
  end

  create_html output_file_name, body

  puts ' Done'
end


