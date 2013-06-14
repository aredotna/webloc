require "plist"

class Webloc
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def self.load(filename)
    data = File.read(filename)
    data = data.force_encoding("binary") rescue data
    parse(data)
  end

  def self.parse(data)
    if data !~ /\<plist/
      url = bin(data)
    else
      url = plist(data)
    end

    raise ArgumentError unless url
    new(url)
  end

  def data
    @data = "\x62\x70\x6C\x69\x73\x74\x30\x30\xD1\x01\x02\x53\x55\x52\x4C\x5F\x10"
    @data += @url.length.chr.force_encoding("UTF-8")
    @data += @url
    @data += "\x08\x0B\x0F\x00\x00\x00\x00\x00\x00\x01\x01\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    @data += (@url.length + 18).chr.force_encoding("UTF-8")
  end

  def save(filename)
    File.open(filename, "w:binary") { |f| f.print data }
  end

private

  def self.bin(data)
    offset = (data =~ /SURL_/)
    length = data[offset + 6]
    length = length.ord rescue length

    data[offset + 7,length]
  end

  def self.plist(data)
    Plist::parse_xml(data)["URL"] rescue nil
  end
end # Webloc
