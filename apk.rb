#! /usr/bin/env ruby
require "zlib"
require "zip"
require "stringio"

class ApkReader
  def initialize(apk)

    io = Zlib::GzipReader.new(StringIO.new(apk))

    # read unknown header
    read_header(io)
    read_header(io)
    read_header(io)

    # read unknown data
    read_int(io)
    read_int(io)

    self.content = {}

    until io.eof?
      file, val = read_file(io)
      content[file] = val
    end
  end

  attr_reader :content

private

  attr_writer :content

  def read_int(io)
    data = io.read(4)
    data.unpack("V").first
  end

  def read_header(io)
    len = read_int(io)

    data = io.read((len - 1)*2).force_encoding("UTF-16LE")
    # NULL terminator
    io.read(2)

    data
  end

  def read_file(io)
    file_len = read_int(io)
    name_len = read_int(io)
    
    name = io.read((name_len - 1)*2).force_encoding("UTF-16LE").encode("UTF-8")
    # NULL terminator
    io.read(2)

    # change file separator if needed
    if File::SEPARATOR != "\\"
      name.gsub!("\\", File::SEPARATOR)
    end
    
    data = io.read(file_len).force_encoding("UTF-16LE")
    [name, data]
  end
end

class ZipMaker
  def initialize(content)
    self.files = content
  end

  def build
    stringio = Zip::OutputStream.write_buffer do |zio|
      files.each do |name, value|
        zio.put_next_entry(name)
        zio.write(value)
      end
    end
    stringio.string
  end
  
private
  
  attr_accessor :files
end
