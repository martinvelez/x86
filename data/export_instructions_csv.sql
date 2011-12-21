SELECT ALL * 
INTO OUTFILE 'C:\\Documents and Settings\\mvelez\\My Documents\\obama\\dev\\tool\\bin\\x86\\instructions.csv' 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
FROM instructions_view;