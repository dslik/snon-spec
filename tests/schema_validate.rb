require "time"
require "json"
require "optparse"
require "json-schema"

# ------------------------------------------------------------------------------
# Process Arguments
# ------------------------------------------------------------------------------
options = {}
optparse = OptionParser.new do|opts|
	opts.banner = "Usage: schema_validate.rb schema input"

	options[:schema] = "snon-schema.json"
	opts.on( '-s', '--schema file', 'Path to schema file to use for validation' ) do |schema|
		options[:schema] = schema
	end

	options[:input] = "input.json"
	opts.on( '-i', '--input file', 'Path to input file to validate' ) do |input|
		options[:input] = input
	end

	opts.on( '-h', '--help', 'Display command line help information screen' ) do
		puts opts
		exit
	end
end

optparse.parse!

# ------------------------------------------------------------------------------
# Load inputs
# ------------------------------------------------------------------------------
schema_file = File.read(options[:schema])
input_file = File.read(options[:input])

schema_json = JSON::parse(schema_file)
input_json = JSON::parse(input_file)

# ------------------------------------------------------------------------------
# Validate the schema
# ------------------------------------------------------------------------------
validation_result = JSON::Validator.fully_validate(schema_json, input_json)  

validation_result.each do |line|
	print line
end
print "\n"