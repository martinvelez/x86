CREATE TABLE instructions_view 
SELECT a.id, mnemonic, dst1, dst2, src1, src2 FROM
((SELECT instructions.id, mnemonic, operand_type_coder as dst1 FROM instructions LEFT JOIN operands ON (operand_type_geek = dst1)) AS a)
LEFT JOIN
((SELECT instructions.id, operand_type_coder as dst2 FROM instructions LEFT JOIN operands ON (operand_type_geek = dst2)) AS b)
ON a.id = b.id
LEFT JOIN
((SELECT instructions.id, operand_type_coder as src1 FROM instructions LEFT JOIN operands ON (operand_type_geek = src1)) AS c)
ON a.id = c.id
LEFT JOIN
((SELECT instructions.id, operand_type_coder as src2 FROM instructions LEFT JOIN operands ON (operand_type_geek = src2)) AS d)
ON a.id = d.id
;