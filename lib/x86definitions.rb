require File.expand_path(File.join(File.dirname(__FILE__), 'cartprod.rb'))

################ NOT RECOGNIZED BY MASM ########################################
UNSUPPORTED = ["MOVBE"]

################ MISC CONSTANTS ################################################
#MASM-integer-constant:[0-9][0-9a-fA-F]*
# DISPLACEMENT = "12345678h"
DISPLACEMENT = "0" + (rand(0xFFFF).to_s(16)).upcase + "h"
# MULTIPLIER = 4
MULTIPLIERS = [1, 2, 4, 8]
MULTIPLIER = MULTIPLIERS[ rand(MULTIPLIERS.size) ]

################ IMMEDIATE #####################################################
# IMM8 = ["12h"]
IMM8 = ["0" + (rand(0xFF).to_s(16)).upcase + "h"]
# IMM16 = ["1234h"]
IMM16 = ["0" + (rand(0xFFFF).to_s(16)).upcase + "h"]
#must limit the range of IMM32 beause though IMUL does not accept large 
#immediate doublewords; limit unknown
# IMM32 = ["123456h"]
IMM32 = ["0" + (rand(0x0FFFFFFF).to_s(16)).upcase + "h"]

################ REGISTERS #####################################################
# General Registers
#eax
EAX, AX, AL = ["eax"], ["ax"], ["al"]
#edx
DX = ["dx"]
#ecx
CL = ["cl"] 
#By size
R8 = AL + ["bl", "cl", "dl", "ah", "bh", "ch", "dh"]
R16 = AX + ["bx", "cx", "dx", "si", "di", "sp", "bp"]
R32 = EAX + ["ebx", "ecx", "edx", "esi", "edi", "esp", "ebp"]
# Segment Registers
# writable
ES, SS, FS, GS = ["es"], ["ss"], ["fs"], ["gs"]
SEGMENTS_WRITABLE = ES + SS + FS + GS
#not writable?
CS, DS = ["cs"], ["ds"]
SEGREG = CS + DS + SEGMENTS_WRITABLE
#control registers
# CR = ["CR0", "CR2", "CR3", "CR4"]
CR = ["CR0", "CR2", "CR3"]
#CR4 can only be used in protected mode
#debug registers
DR = ["DR0", "DR1", "DR2", "DR3", "DR6", "DR7"]
#test registers
# TR = ["TR4", "TR5", "TR6", "TR7"]
#each x87 register, known as ST(0) through ST(7), is 80 bits wide and stores numbers in the IEEE floating-point standard double extended precision format.
# ST = ["ST(0)", "ST(1)", "ST(2)", "ST(3)", "ST(4)", "ST(5)", "ST(6)", "ST(7)"] 
#MMX
# MM = ["mm0", "mm1", "mm2", "mm3", "mm4", "mm5", "mm6", "mm7"]
#SSE
# XMM = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7"]

################ MEMORY ########################################################
# Create operands of the form "byte/word/dword ptr [value]"
simple_ptr = lambda { |size| R32.map { |r| "#{size}  ptr [#{r}]"} }
# Create operands of the form "byte/word/dword ptr [register + 123456h]"
ptr_offset = lambda { |size | R32.map { |r| "#{size} ptr [#{r} + #{DISPLACEMENT}]" } }
# Create operands of the form "byte/word/dword ptr [4 * register + 123456h]"
mult_reg = lambda { |size | R32.reject { |r| r == "esp" }.map { |r| "#{size} ptr [#{MULTIPLIER} * #{r} + #{DISPLACEMENT}]" } }
# Create operands of the form "byte/word/dword ptr [register + register]"
two_regs = lambda { |size| R32.cartprod(R32).find_all{ |arr| arr != ["esp", "esp"] }.map { |arr|  "#{size}  ptr [#{arr[0]} + #{arr[1]}]"} }
# Create operands of the form "byte/word/dword ptr [4 * register + register]"
mult_two_regs = lambda { |size| R32.reject { |r| r == "esp" }.cartprod(R32).map { |arr|  "#{size}  ptr [ #{MULTIPLIER} * #{arr[0]} + #{arr[1]}]"} }

# Definitions of all possible memory access operand trees\
M8 = ["byte ptr [someDword]"] + simple_ptr.call("byte") + ptr_offset.call("byte") + mult_reg.call("byte") + two_regs.call("byte") + mult_two_regs.call("byte")
M16 = ["word ptr [someDword]"] + simple_ptr.call("word") + ptr_offset.call("word") + mult_reg.call("word") + two_regs.call("word") + mult_two_regs.call("word")
M32 = ["dword ptr [someDword]"] + simple_ptr.call("dword") + ptr_offset.call("dword") + mult_reg.call("dword") + two_regs.call("dword") + mult_two_regs.call("dword")
M48 = ["fword ptr [someDword]"] + simple_ptr.call("fword") + ptr_offset.call("fword") + mult_reg.call("fword") + two_regs.call("fword") + mult_two_regs.call("fword")
M64 = ["qword ptr [someDword]"] + simple_ptr.call("qword") + ptr_offset.call("qword") + mult_reg.call("qword") + two_regs.call("qword") + mult_two_regs.call("qword")

################ POSSIBLE OPERANDS #############################################
#simple operand types
R8M8 = R8 + M8
R16M16 = R16 + M16
R32M32 = R32 + M32

# Simple operand pairs
R8_R8 = R8.cartprod(R8)
R8_M8 = R8.cartprod(M8)
R8_IMM8 = R8.cartprod(IMM8)

M8_IMM8 = M8.cartprod(IMM8)
M8_R8 = M8.cartprod(R8)

R16_R16 = R16.cartprod(R16)
R16_M16 = R16.cartprod(M16)
R16_IMM16 = R16.cartprod(IMM16)
R16_IMM8 = R16.cartprod(IMM8)
R16_M32 = R16.cartprod(M32)
R16_R8 = R16.cartprod(R8)
R16_M8 = R16.cartprod(M8)

M16_R16 = M16.cartprod(R16)
M16_IMM8 = M16.cartprod(IMM8)
M16_IMM16 = M16.cartprod(IMM16)

IMM16_IMM8 = IMM16.cartprod(IMM8)

R32_R32 = R32.cartprod(R32)
R32_M32 = R32.cartprod(M32)
R32_R16 = R32.cartprod(R16)
R32_M16 = R32.cartprod(M16)
R32_IMM32 = R32.cartprod(IMM32)
R32_R8 = R32.cartprod(R8)
R32_M8 = R32.cartprod(M8)
R32_IMM8 = R32.cartprod(IMM8)
R32_M48 = R32.cartprod(M48)

M32_IMM32 = M32.cartprod(IMM32)
M32_IMM8 = M32.cartprod(IMM8)
M32_R32 = M32.cartprod(R32)

#mixed operand pairs
R8_R8M8 = R8_R8+R8_M8
R16_R16M16 = R16_R16+R16_M16
R32_R32M32 = R32_R32+R32_M32
R8M8_IMM8 = R8_IMM8+M8_IMM8
R16M16_IMM16 = R16_IMM16+M16_IMM16
R32M32_IMM32 = R32_IMM32+M32_IMM32
R16M16_IMM8 = R16_IMM8+M16_IMM8
R32M32_IMM8 = R32_IMM8+M32_IMM8
R8M8_R8 = R8_R8+M8_R8
R16M16_R16 = R16_R16+M16_R16
R32M32_R32 = R32_R32+M32_R32

#Differnt types of operand list per instruction or group of instructions
#No operands
NONE = [""]
#Typical Binary Arithmetic Operands
TYPICAL_BINARY = R8M8_IMM8+R16M16_IMM16+R32M32_IMM32+R16M16_IMM8+R32M32_IMM8+R8M8_R8+R16M16_R16+R32M32_R32+R8_R8M8+R16_R16M16+R32_R32M32
#IMUL
R16_R16M16_IMM8 = R16.cartprod(R16, IMM8) + R16.cartprod(M16, IMM8) #IMUL r16,r/m16,imm8
R32_R32M32_IMM8 = R32.cartprod(R32, IMM8) + R32.cartprod(M32, IMM8) #IMUL r32,r/m32,imm8
R16_R16M16_IMM16 = R16.cartprod(R16, IMM16) + R16.cartprod(M16, IMM16) #IMUL r16,r/m16,imm16
R32_R32M32_IMM32 = R32.cartprod(R32, IMM32) + R32.cartprod(M32, IMM32) #IMUL r32,r/m32,imm32
IMUL = R8M8 + R16M16 + R32M32 + R16_R16M16 + R32_R32M32 + R16_R16M16_IMM8 + R32_R32M32_IMM8 + R16_IMM8 + R32_IMM8 + R16_R16M16_IMM16 + R32_R32M32_IMM32 + R16_IMM16 + R32_IMM32
#Single-operand instructions that write back to the operand, for example, MUL
RVALUES = R8+M8+R16+M16+R32+M32
#Conditional jumps
JCC_TARGETS = LOOP_TARGETS = ["start"]
#CALL
CALL_TARGETS = R32 + M32 +  LOOP_TARGETS
#RET
RET = NONE + IMM16
#INT
INT = [3] + IMM8
# BOUND
R1632_M3264 = R16.cartprod(M32) + R32.cartprod(M64)
#Certain bit instructions, for example BT, BTS
BIT = M16_IMM8+M32_IMM8+R16_IMM8+R32_IMM8+M16_R16+M32_R32
#Certain bit instructions, for example BSF, BSR
BIT_SCAN = R16_R16M16 + R32_R32M32
#Certain setting byte instructions, for example SETE, SETNE
BYTE = R8 + M8
#IN
IN = AL.cartprod(IMM8) + AX.cartprod(IMM8) + EAX.cartprod(IMM8) + AL.cartprod(DX) + AX.cartprod(DX) + EAX.cartprod(DX)
#OUT
OUT = IMM8.cartprod(AL + AX + EAX) + DX.cartprod(AL + AX + EAX)
#LEA
LEA = R16_M16 + R32_M32
#MOVBE
MOVBE = R16_M16 + R32_M32 + M16_R16 + M32_R32
#Segment register instructions, for example, LDS and LES
SEGMENT = R16_M32 + R32_M48
#Shifts and rotates
ROTATE = R8M8_IMM8 + R16M16_IMM8 + R32M32_IMM8 + R8.cartprod(CL) + M8.cartprod(CL) + R16.cartprod(CL) + M16.cartprod(CL) + R32.cartprod(CL) + M32.cartprod(CL)
#Shifts which require double precision
SHIFT_DOUBLE = R16.cartprod(R16, CL+IMM8) + M16.cartprod(R16, CL+IMM8) + R32.cartprod(R32, CL+IMM8) + M32.cartprod(R32, CL+IMM8)
#Repeat string operation instruction prefix
REP = ["INSB", "INSW", "INSD", "MOVSB", "MOVSW", "MOVSD", "OUTSB", "OUTSW", "OUTSD", "LODSB", "LODSW", "LODSD", "STOSB", "STOSW", "STOSD"]
REP_OTHER = ["CMPSB", "CMPSW", "CMPSD", "SCASB", "SCASW", "SCASD"]
#MOV instructions
MOV = TYPICAL_BINARY + CR.cartprod(R32) + R32.cartprod(CR) + DR.cartprod(R32) + R32.cartprod(DR)
#Conditional mov instructions, for example CMOVE
COND_MOV = R16_R16M16 + R32_R32M32
#XADD
XCHGBASIC = R8M8_R8+R16M16_R16+R32M32_R32
#XCHG instructions
XCHG = XCHGBASIC  + R8M8_R8+R16_R16M16+R32_R32M32
#PUSH instructions
PUSH = R16 + R32 + M16 + M32 + IMM8 + IMM16 + IMM32 + SEGREG
#POP instructions
POP = R16 + R32 + M16 + M32 + SEGMENTS_WRITABLE
#MOVSX and MOVZX
EXTEND = R16_R8 + R16_M8 + R32_R8 + R32_M8 + R32_R16 + R32_M16


#Hash of possible operand list, 0 to 3 operand arguments possible
OPERANDS = Hash[ "typical_binary" => TYPICAL_BINARY,\
"imul" => IMUL,\
"rvalues" => RVALUES,\
"jcc_targets" => JCC_TARGETS, \
"loop_targets" => LOOP_TARGETS, \
"call_targets" => CALL_TARGETS,\
"ret" => RET, "none" => NONE,\
"int" => INT,\
"bound" => R1632_M3264,\
"enter" => IMM16_IMM8, \
"bit" => BIT, \
"bit_scan" => BIT_SCAN, \
"byte" => BYTE, \
"in" => IN, \
"out" => OUT, \
"lea" => LEA, \
"movbe" => MOVBE, \
"segment" => SEGMENT, \
"rotate" => ROTATE, \
"shift_double" => SHIFT_DOUBLE, \
"rep" => REP, \
"rep_other" => REP_OTHER, \
"mov" => MOV, \
"cond_mov" => COND_MOV, \
"xchg" => XCHG, \
"r32" => R32, \
"xchg_basic" => XCHGBASIC, \
"m64" => M64, \
"push" => PUSH, \
"pop" => POP,\
"extend" =>EXTEND]