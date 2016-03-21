require 'nokogiri'
require 'json'
require 'csv'
require 'active_support/all'

@path  = Dir.pwd
@files = Dir.entries(@path).reject{|f| %w(. ..).include?(f)}

@mlf_data = {}
@dlf_data = {}

# Let's get the CSV Data first

# TNI to MLF
CSV.open(File.join(@path,"tni-mlf-codes.csv"), headers: true, converters: :numeric).each do |row|
  @mlf_data[row["TNI"]] ||= { location: row['Location'], voltage: row['Voltage'], loss_factors: [] }
  @mlf_data[row["TNI"]][:loss_factors] << { start: DateTime.parse('2015-07-01T00:00:00+1000'), finish: DateTime.parse('2016-07-01T00:00:00+1000'), value: row['FY16']}
  @mlf_data[row["TNI"]][:loss_factors] << { start: DateTime.parse('2014-07-01T00:00:00+1000'), finish: DateTime.parse('2015-07-01T00:00:00+1000'), value: row['FY15']}
  @mlf_data[row["TNI"]][:loss_factors] << { start: DateTime.parse('2013-07-01T00:00:00+1000'), finish: DateTime.parse('2014-07-01T00:00:00+1000'), value: row['FY14']}
end

# TNI to MLF
CSV.open(File.join(@path,"aemo-dlf-dnsp.csv"), headers: true, converters: :numeric).each do |row|
  @dlf_data[row["dlf_code"]] ||= row['nsp_code']
end


# Now to create the DLF and TNI output JSON files for use
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
      puts "output_data_instance: #{output_data_instance.inspect}"
      output_data_instance[:mlf_data] = {}
      unless @mlf_data[code].nil?
        output_data_instance[:mlf_data] = @mlf_data[code].deep_dup
        output_data_instance[:mlf_data][:loss_factors] = output_data_instance[:mlf_data][:loss_factors].reject{|x| DateTime.parse(output_data_instance['ToDate']) < x[:start] || DateTime.parse(output_data_instance['FromDate']) >= x[:finish] }
        puts "output_data_instance[:mlf_data][:loss_factors]: #{output_data_instance[:mlf_data][:loss_factors].inspect}"
      end
    elsif file.match(/dlf/)
      output_data_instance[:nsp_code] = @dlf_data[code]
    end
    output_data[code] << output_data_instance
  end

  File.open(File.join(@path,output_file),'w') do |write_file|
    write_file.write(output_data.to_json)
  end
end
