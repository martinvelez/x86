#!/usr/local/bin/ruby -w

#This file defines the X86 module
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'tools', 'masm.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'tools', 'asm_to_binary.rb'))

# This class defines the X86 module.
# This module defines the constants needed to produce all of the
# possible variants of the x86 instructions.  This module also
# defines an X86Enumertor class which accesses a MySQL
# database to obtain the list of all of the x86 instructions.
# This list contains a mnemonic and an operand_type.
# The operand_type is used to determine what operand list follows.

module X86
	require 'csv'
	require File.expand_path(File.join(File.dirname(__FILE__), '.', 'x86definitions.rb'))
	
	class Enumerator
		include Enumerable
		#Instantiating a x86enumerator requires a MySQL database handle
		def initialize(instructions_csv="instructions.csv", format)
			#check for errors in parameters
			raise "instructions_csv must not be null" unless !instructions_csv.nil?
			raise "#{instructiosn_csv} is not a readable file" unless File.exist?(instructions_csv) and File.readable?(instructions_csv)
			#assign parameters to object variables
			@instructions_csv = instructions_csv
			#format can be 'a' for assembly or 'b' for binary
			@format = format
		end
		
		# Get the next instruciton in the instructions table
		def each
			instructions = CSV.readlines( @instructions_csv )
			instructions.each do |instruction|
				mnemonic, operands = instruction[0], instruction[1]
				variant = ""
				ops_list = OPERANDS[operands]
				raise "#{instruction}: ops_list is null" unless not ops_list.nil?
				ops_list.each do |ops|
					#skip if unsupported by 
					if UNSUPPORTED.include?( mnemonic )
						next
					else
						if ops.instance_of?(Array)
							variant = mnemonic + " " + "#{ops.join(", ")}"
						elsif
							variant = mnemonic + " " + "#{ops}"
						end
						if @format == "source"
							yield variant
						else
							yield asm_to_binary(variant)
						end
					end #each loop
				end
			end
		end
	end #class, X86Enumerator
end #module, X86