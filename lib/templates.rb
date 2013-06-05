module Templates
  require 'erb'
  require 'kramdown'

  Template = Struct.new(:type, :template)

  @@templates = {}

  Dir["templates/*.erb*"].each do |f|
    match = f.match(/^templates\/(?<name>.+)\.erb(\.(?<type>.+))?$/)

    type = match[:type] ? match[:type].to_sym : nil

    @@templates[match[:name]] = Template.new(type, ERB.new(IO.read(f)))
  end

  def self.each
    @@templates.each { |key, val| yield key, val }
  end

  def self.result name, b = TOPLEVEL_BINDING
    header = @@templates['header'].template.result b
    result = @@templates[name].template.result     b
    footer = @@templates['footer'].template.result b

    case @@templates[name].type
    when :md, :markdown
      body = Kramdown::Document.new(result).to_html

      result = @@templates['html'].template.result binding
    end

    "#{header}#{result}#{footer}"
  end
end
