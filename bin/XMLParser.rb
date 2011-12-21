#!/usr/local/bin/ruby

#This file defines the NgramProducer class

require 'rexml/document'
require 'rexml/namespace'

include REXML

def get_description(entry)
		str = ""
		if not entry.elements['note'].nil? and not entry.elements['note'].elements['brief'].nil?
			str = entry.elements['note'].elements['brief'].text
		end
		return str
end

def get_src2(entry)
	str = ""
	if not entry.elements['syntax'].elements['src'].nil?
		src = entry.elements['syntax'].elements['src']
		if not src.next_element.nil? and src.next_element.has_name?("src")
			src = src.next_element
			if not src.elements['a'].nil? and not src.elements['t'].nil?
				str += src.elements['a'].text + src.elements['t'].text
			elsif not src.has_elements?
				if not (src.has_attributes? and src.attributes['displayed'] == "no")
					str += src.text
				end
			end
		end
	end
	return str
end

def get_src(entry)
	str = ""
	if not entry.elements['syntax'].elements['src'].nil?
		src = entry.elements['syntax'].elements['src']
		if not src.elements['a'].nil? and not src.elements['t'].nil?
			str += src.elements['a'].text + src.elements['t'].text
		elsif not src.has_elements?
			if not(src.has_attributes? and src.attributes['displayed'] == "no")
				str += src.text
			end
		end
	end
	return str
end

def get_dst2(entry)
	str = ""
	if not entry.elements['syntax'].elements['dst'].nil?
		dst = entry.elements['syntax'].elements['dst']
		if not dst.next_element.nil? and dst.next_element.has_name?("dst")
			dst = dst.next_element
			if not dst.elements['a'].nil? and not dst.elements['t'].nil?
				str += dst.elements['a'].text + dst.elements['t'].text
			elsif not dst.has_elements?
				if not(dst.has_attributes? and dst.attributes['displayed'] == "no")
					str += dst.text
				end
			end
		end
	end
	return str
end

def get_dst(entry)
	str = ""
	if not entry.elements['syntax'].elements['dst'].nil?
		dst = entry.elements['syntax'].elements['dst']
		if not dst.elements['a'].nil? and not dst.elements['t'].nil?
			str += dst.elements['a'].text + dst.elements['t'].text
		elsif not dst.has_elements?
			if not(dst.has_attributes? and dst.attributes['displayed'] == "no")
				str += dst.text
			end
		end
	end
	return str
end

def get_operands(entry)
	return double_quote(get_dst(entry)) + "," + double_quote(get_dst2(entry)) + "," + double_quote(get_src(entry)) + "," + double_quote(get_src2(entry))
end

def get_pf_opcode(entry)
	str = ""
	if not entry.elements['pref'].nil?
		str += entry.elements['pref'].text
	end
	return str
end

def get_OF_opcodes(entry)
	str = ""
	if entry.parent.parent.has_name?("two-byte")
		str += "OF"
	end
	return str
end

def get_so_opcodes(entry)
	str = ""
	if not entry.elements['sec_opcd'].nil?
		str += entry.elements['sec_opcd'].text
	end
	return str
end

def get_opcodes(entry)
	opcodes = double_quote(get_pf_opcode(entry)) #prefix
	opcodes += ","
	opcodes += double_quote(get_OF_opcodes(entry)) #two-byte instructions
	opcodes += ","
	opcodes += double_quote(entry.parent.attributes['value']) #opcode
	opcodes += ","
	opcodes += double_quote(get_so_opcodes(entry)) #secondary opcode
	return opcodes
end

def has_mnemonic(entry)
	if not entry.elements['syntax'].nil?
		if not entry.elements['syntax'].elements['mnem'].nil?
			return true
		end
	end
	return false
end

def good_attributes(entry)
	bad_attributes = ["invd", "undef", "null"]
	if entry.has_attributes? 
		if bad_attributes.include?(entry.attributes['attr']) 
			return false
		elsif entry.attributes['ref'] == "two-byte"
			return false
		elsif entry.attributes['doc1632_ref'] == "gen_note_branch_prefixes"
			return false
		elsif entry.attributes['mode'] == "e"
			return false
		end
	end
	return true
end

def is_prefix(entry)
	if not entry.elements['grp1'].nil?
		if entry.elements['grp1'].text == "prefix"
			return true
		end
	end
	return false
end

def good_entry(entry)		
	if entry.node_type.to_s == 'element'				
		if not good_attributes(entry) or is_prefix(entry)
			return false
		else
			return has_mnemonic(entry)
		end
	end
	return false
end

def double_quote(str)
	return "\"" + str + "\""
end

def csv_record(entry)
	record = "\"\","
	record += get_opcodes(entry)
	record += ","
	record += double_quote(entry.elements['syntax'].elements['mnem'].text) #mnemonic
	record += ","
	record += get_operands(entry) # 2 dst operands, 2 src operands
	record += ","
	record += double_quote(get_description(entry))
	return record
end

# Main 
f = File.new("x86reference.xml")
xml_doc = Document.new(f)
root = xml_doc.root
root.each do |byte|
	if byte.node_type.to_s == 'element'
		byte.each do |pri_opcd|
			if pri_opcd.node_type.to_s == 'element'
				pri_opcd.elements.each do |pri_opcd_child|
					if pri_opcd_child.has_name?("entry")
						if good_entry(pri_opcd_child)
							puts csv_record(pri_opcd_child)
						end
					end			
				end
			end
		end
	end
end

f.close()