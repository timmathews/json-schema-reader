require 'json'
require 'jsonpath'
require 'pathname'

# A little hack to let us reference hash members with dot notation
class Hash
  def method_missing sym
    self[sym.to_s]
  end
end

class Schema
  attr_accessor :data, :uri

  def initialize data, uri
    @data = JSON.parse data
    @uri = uri
    @data = expand @data
  end

  def self.load_from_file path
    Schema.new File.read(path), Pathname.new(path).realdirpath
  end

  def path
    @uri.dirname
  end

  def title
    @data.title
  end

  def pretty_generate
    puts @data.title
    print_line @data
  end

  private

  def print_line line, indent = ''
    if line.properties && line.patternProperties
      pp = line.properties.merge line.patternProperties
    else
      pp = line.properties || line.patternProperties
    end

    pp.each_with_index do |(prop_k, prop_v), idx|
      i = indent

      if idx + 1 == pp.count
        c = "\u2514"
        s = "  "
      else
        c = "\u251C"
        s = "\u2502 "
      end

      print i + c

      if (prop_v.required == true) || (line.required && line.required.is_a?(Array) && line.required.include?(prop_k))
        print '!'
      end

      print prop_k

      if prop_v.type
        print ':' + prop_v.type
      end

      if prop_v.units
        print ':' + prop_v.units
      end

      print "\n"

      print_line prop_v, indent + s
    end unless pp.nil?
  end

  def expand data
    if data.definitions
      data.definitions.each do |k, v|
        if v['$ref']
          v.merge! expand_ref v['$ref']
          v.delete '$ref'
        end
        v = expand v
        data.definitions[k] = v
      end
    end
    if data.properties
      data.properties.each do |k, v|
        if v['$ref']
          v.merge! expand_ref v['$ref']
          v.delete '$ref'
        end
        v = expand v
        data.properties[k] = v
      end
    end
    if data.patternProperties
      data.patternProperties.each do |k, v|
        if v['$ref']
          v.merge! expand_ref v['$ref']
          v.delete '$ref'
        end
        v = expand v
        data.patternProperties[k] = v
      end
    end

    data
  end

  def expand_ref ref
    if ref[0] == '#' # refers to current schema
      path = ref.gsub(/[\/#]/, '.')
      data = JsonPath.new(path).first @data
    else
      uri = (self.path + Pathname.new(ref)).to_s
      tok = uri.split '#'
      t_schema = Schema.load_from_file tok[0]

      if tok[1]
        path = tok[1].gsub(/\//, '.')
        data = JsonPath.new(path).first t_schema.data
      else
        data = t_schema.data
      end
    end

    data || {}
  end
end
