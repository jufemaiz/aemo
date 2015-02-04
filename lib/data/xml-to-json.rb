require 'nokogiri'
require 'json'
require 'csv'

@path  = Dir.pwd
@files = Dir.entries(@path).reject{|f| %w(. ..).include?(f)}

@mlf_data = {}

# Let's get the CSV Data first
CSV.open(File.join(@path,"TNI-MLF-Codes.csv"), headers: true, converters: :numeric).each do |row|
  @mlf_data[row["TNI"]] ||= { location: row['Location'], voltage: row['Voltage'], loss_factors: [] }
  @mlf_data[row["TNI"]][:loss_factors] << { start: Date.parse('2014-07-01'), finish: Date.parse('2015-06-30'), value: row['FY15']}
  @mlf_data[row["TNI"]][:loss_factors] << { start: Date.parse('2013-07-01'), finish: Date.parse('2014-06-30'), value: row['FY14']}
end

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
    if file.match(/tni/)
      output_data_instance[:mlf_data] = @mlf_data[code]
    end
    output_data[code] << output_data_instance
  end
  
  File.open(File.join(@path,output_file),'w') do |write_file|
    write_file.write(output_data.to_json)
  end
end

