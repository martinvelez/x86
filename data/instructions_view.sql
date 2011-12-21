CREATE OR REPLACE VIEW instructions_view AS
SELECT mnemonic, operands FROM gen_control
UNION 
SELECT mnemonic, operands FROM gen_bin_arithmetic
UNION 
SELECT mnemonic, operands FROM gen_bit_byte
UNION 
SELECT mnemonic, operands FROM gen_data
UNION 
SELECT mnemonic, operands FROM gen_dec_arithmetic
UNION 
SELECT mnemonic, operands FROM gen_flag
UNION 
SELECT mnemonic, operands FROM gen_io
UNION 
SELECT mnemonic, operands FROM gen_logical
UNION 
SELECT mnemonic, operands FROM gen_misc
UNION
SELECT mnemonic, operands FROM gen_segment
UNION
SELECT mnemonic, operands FROM gen_shift_rotate
UNION
SELECT mnemonic, operands FROM gen_strings;