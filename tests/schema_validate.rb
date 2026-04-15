require "optparse"
require "json"
require "json-schema"

# ------------------------------------------------------------------------------
# Process Arguments
# ------------------------------------------------------------------------------
options = {}
optparse = OptionParser.new do|opts|
	opts.banner = "Usage: schema_validate.rb schema input"

	options[:schema] = "../v4/snon-schema.json"
	opts.on( '-s', '--schema file', 'Path to schema file to use for validation' ) do |schema|
		options[:schema] = schema
	end

	opts.on( '-i', '--input file', 'Path to input file to validate' ) do |input|
		options[:input] = input
	end

	options[:spec] = "../index.html"
	opts.on( '-p', '--spec file', 'Path to specification to validate' ) do |spec|
		options[:spec] = spec
	end


	opts.on( '-h', '--help', 'Display command line help information screen' ) do
		puts opts
		exit
	end
end

optparse.parse!

# ------------------------------------------------------------------------------
# Load schema
# ------------------------------------------------------------------------------
schema_file = File.read(options[:schema])
schema_json = JSON::parse(schema_file)

# ------------------------------------------------------------------------------
# Validate specified input file or the full SNON spec
# ------------------------------------------------------------------------------
if(options[:input])
	input_file = File.read(options[:input])
	input_json = JSON::parse(input_file)
	validation_result = JSON::Validator.fully_validate(schema_json, input_json)

	validation_result.each do |line|
		print line
	end
	
	if(validation_result.count == 0)
		print "No validation errors found"
	end
else
	# Extract examples
	skip = false
	start = true
	count = 0
	snon_lines = Array.new
	example_num_string = ""

	File.foreach(options[:spec]) do |line|
		if(line.index("Example "))
			example_num_string = line.slice(line.index(" "), line.length)
		end

		if(line.index("    ") == 0)
			if(start == true)
				# Beginning of code cite
				start = false

				if(line == "    [\n")
					# Beginning of SNON fragment
					skip = false
					count = count + 1
				else
					skip = true
				end
			end
			
			if(skip == false)
				snon_lines << line
			end
		else
			if(snon_lines.count != 0)
				# Validate SNON fragment
				print "\n------------------------------------------------------------------------------------------------\n"
				print "Validating #{example_num_string}"
				input_json = JSON::parse(snon_lines.join)
				validation_result = JSON::Validator.fully_validate(schema_json, input_json)

				validation_result.each do |line|
					print line
				end

				if(validation_result.count == 0)
					print "No validation errors found"
				end
			end

			snon_lines.clear

			start = true
		end
	end
end

print "\n"