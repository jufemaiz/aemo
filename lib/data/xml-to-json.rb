require 'nokogiri'
require 'json'

@path  = Dir.pwd
@files = Dir.entries(@path).reject{|f| %w(. ..).include?(f)}

# Let's do TNI First
@files.select{|x| ['aemo-tni.xml','aemo-dlf.xml'].include?(x) }.each do |file|
  output_file = file.gsub('.xml','.json')
  output_data = {}
  open_file = File.open(File.join(@path,file))
  xml = Nokogiri::XML(open_file) {|c| c.options = Nokogiri::XML::ParseOptions::NOBLANKS }
  open_file.close
  
  xml.xpath("//Row").each do |row|
    row_children = row.children
    code = row_children.find{ |x| x.name == 'Code' }.children.first.text
    output_data[code] ||= []
    output_data_instance = {}
    row_children.each do |row_child|
      output_data_instance[row_child.name] = row_child.children.first.text
    end
    output_data[code] << output_data_instance
  end
  
  File.open(File.join(@path,output_file),'w') do |write_file|
    write_file.write(output_data.to_json)
  end
end

