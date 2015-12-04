#!/usr/bin/env ruby

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
  attr_accessor :data, :uri, :path

  def initialize path
    @data = JSON.parse File.read path
    @uri = Pathname.new(path).realdirpath
    @path = @uri.dirname
  end

  def title
    @data.title
  end
end

@base_schema = Schema.new ARGV[0]

puts @base_schema.title

def print_line schema, line, indent = ''
  if line['$ref']
    ref = expand_ref schema, line['$ref']
    line.merge! ref
  end

  line.properties.each_with_index do |(prop_k, prop_v), idx|

    i = indent

    if idx + 1 == line.properties.count
      c = "\u2514"
      s = "  "
    else
      c = "\u251C"
      s = "\u2502 "
    end

    print i + c

    if (prop_v.required == true) || (line.required && (line.required.include? prop_k))
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

    print_line schema, prop_v, indent + s
  end unless line.properties.nil?
end

def expand_ref schema, ref
  if ref[0] == '#'
    path = ref.gsub(/[\/#]/, '.')
    data = JsonPath.new(path).first schema.data
  else
    uri = (schema.path + Pathname.new(ref)).to_s
    tok = uri.split '#'
    schema = Schema.new tok[0]
    if tok[1]
      path = tok[1].gsub(/\//, '.')
      data = JsonPath.new(path).first schema.data
    else
      data = schema.data
    end
  end

  if data && data.properties
    data.properties.each do |k,v|
      if v['$ref']
        r = expand_ref schema, v['$ref']
        k = v.merge! r
      end
    end
  end

  data || {}
end

print_line @base_schema, @base_schema.data
