#!/usr/local/bin/ruby -w
require File.expand_path(File.join(File.dirname(__FILE__), 'X86.rb'))

def processArgs()
	case ARGV.length
	when 1 then
		output_format = ARGV[0]
	else
		puts "USAGE: text_X86.rb <output output_format>"
		exit 0
	end	
	if output_format != "a" and output_format != "b"
		raise "output_format option must be either 'a' for assembly or 'b' for binary."
	end
	return output_format
end #processArgs()


def test_X86(output_format)
	p = X86::Enumerator.new("instructions.csv", output_format)
	p.each do |v|
		puts v
	end
end


if __FILE__ == $0
	test_X86(*processArgs)
end