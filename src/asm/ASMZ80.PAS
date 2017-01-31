unit ASMZ80;

interface

uses
  SysUtils, MessageIntf;

{R-}
{  $M 16384,0,655360   }

CONST
   maxSymLen    = 16;
   maxOpcdLen   = 4;

   alphaNumeric = '1234567890$ABCDEFGHIJKLMNOPQRSTUVWXYZ_';
   numeric      = '1234567890';
   hex          = '0123456789ABCDEF';
   white        = #9' ';  { A tab plus a space }

   o_Illegal  =   0;  { Opcode not found in FindOpcode }
   o_None     =   1;  { No operands }
   o_LD       =   2;  { Generic LD opcode }
   o_EX       =   3;  { Generic EX opcode }
   o_ADD      =   4;  { Generic ADD opcode }
   o_ADC_SBC  =   5;  { Generic ADC and SBC opcodes }
   o_INC_DEC  =   6;  { Generic INC and DEC opcodes }
   o_JP_CALL  =   7;  { Generic JP and CALL opcodes }
   o_JR       =   8;  { Generic JR opcode }
   o_RET      =   9;  { Generic RET opcode }
   o_IN       =  10;  { Generic IN opcode }
   o_OUT      =  11;  { Generic OUT opcode }

   o_PushPop  =  12;  { PUSH and POP instructions }
   o_Arith    =  13;  { Arithmetic instructions }
   o_Rotate   =  14;  { Z-80 rotate instructions }
   o_Bit      =  15;  { BIT, RES, and SET instructions }
   o_IM       =  16;  { IM instruction }
   o_DJNZ     =  17;  { DJNZ instruction }
   o_RST      =  18;  { RST instruction }

   o_DB       =  19;  { DB pseudo-op }
   o_DW       =  20;  { DW pseudo-op }
   o_DS       =  21;  { DS pseudo-op }
   o_EQU      = -22;  { EQU and SET pseudo-ops }
   o_ORG      = -23;  { ORG pseudo-op }
   o_END      =  24;  { END pseudo-op }
   o_LIST     = -25;  { LIST pseudo-op }
   o_OPT      = -26;  { OPT pseudo-op }

   regs       = ' B C D E H L A I R BC DE HL SP IX IY AF (  ';
   regVals    = ' 0 1 2 3 4 5 7 8 9 10 11 12 13 14 15 16 17 ';

   reg_None   = -1;
   reg_B      = 0;
   reg_C      = 1;
   reg_D      = 2;
   reg_E      = 3;
   reg_H      = 4;
   reg_L      = 5;
   reg_M      = 6;
   reg_A      = 7;
{  reg_Byte   = [reg_B..reg_A];  }
   reg_I      = 8;
   reg_R      = 9;
   reg_BC     = 10;
   reg_DE     = 11;
   reg_HL     = 12;
   reg_SP     = 13;
{  reg_Word   = [reg_BC..reg_SP];  }
   reg_IX     = 14;
   reg_IY     = 15;
   reg_AF     = 16;
   reg_Paren  = 17;

   conds      = ' NZ Z NC C PO PE P M ';
   condVals   = ' 0  1 2  3 4  5  6 7 ';

TYPE
   SymStr  = String[maxSymLen];

   SymPtr  = ^SymRec;
   SymRec  = RECORD
                name:     SymStr;   { Symbol name }
                value:    Integer;  { Symbol value }
                next:     SymPtr;   { Pointer to next symtab entry }
                defined:  Boolean;  { TRUE if defined }
                multiDef: Boolean;  { TRUE if multiply defined }
                isSet:    Boolean;  { TRUE if defined with SET pseudo }
                equ:      Boolean;  { TRUE if defined with EQU pseudo }
             END;

   OpcdStr = String[maxOpcdLen];

   OpcdPtr = ^OpcdRec;
   OpcdRec = RECORD
                name:   OpcdStr;    { Opcode name }
                typ:    Integer;    { Opcode type }
                parm:   Integer;    { Opcode parameter }
                next:   OpcdPtr;    { Pointer to next opcode entry }
             END;
   { TP 3.0 does not know any length-less string variable }
   string_tp = String[128];
   { TP 3.0 does not know any machine dependant variable like 'word' }
   word = integer;

VAR
   symTab:       SymPtr;      { Pointer to first entry in symtab }
   opcdTab:      OpcdPtr;     { Opcode table }

   locPtr:       Integer;     { Current program address }
   newLoc:       Integer;     { New program address }
   updLoc:       Boolean;     { TRUE if newLoc needs to be written to file }
   pass:         Integer;     { Current assembler pass }
   errFlag:      Boolean;     { TRUE if error occurred this line }
   errCount:     Integer;     { Total number of errors }
   lineCount:    integer;     { Number of lines processed in sourcefile }
   byteCount:    integer;     { Number of bytes processed in sourcefile }

   line:         string_tp;      { Current line from input file }
   listLine:     string_tp;      { Current listing line }
   listFlag:     Boolean;     { FALSE to suppress listing source }
   listThisLine: Boolean;     { TRUE to force listing this line }
   sourceEnd:    Boolean;     { TRUE when END pseudo encountered }

   instr:        ARRAY[1..5] OF Integer; { Current instruction word }
   instrLen:     Integer;                { Current instruction length }

   bytStr:       string_tp;      { Buffer for long DB statements }
   showAddr:     Boolean;     { TRUE to show LocPtr on listing }
   xferAddr:     Integer;     { Transfer address from END pseudo }
   xferFound:    Boolean;     { TRUE if xfer addr defined w/ END }

   { Command line parameters }
   cl_SrcName:   string_tp;      { Source file name }
   cl_ListName:  string_tp;      { Listing file name }
   cl_ObjName:   string_tp;      { Object file name }
   cl_Err:       Boolean;        { TRUE for errors to screen }

   source:       Text;
   object_:       Text;
   listing:      Text;

procedure ASMZ80_execute(SrcName, ListName, ObjName: String_tp; Err: Boolean);

implementation

FUNCTION Deblank(s: string_tp): string_tp;
VAR
   i: Integer;
BEGIN
   i := Length(s);
   WHILE (i>0) AND (s[i] IN [#9,' ']) DO
      i:=i-1;

   s[0] := CHR(i);

   i := 1;
   WHILE (i<=Length(s)) AND (s[i] IN [#9,' ']) DO
      i:=i+1;
   Delete(s,1,i-1);

   Deblank := s;
END;

FUNCTION UprCase(s: string_tp): string_tp;
VAR
   i: Integer;
BEGIN
   FOR i := 1 TO Length(s) DO
      IF s[i] IN ['a'..'z'] THEN
         s[i] := UpCase(s[i]);

   UprCase := s;
END;

FUNCTION Hex2(i: Integer): string_tp;
BEGIN
   i := i AND 255;
   Hex2 := Copy(hex,(i SHR  4)+1,1) + Copy(hex,(i AND 15)+1,1);
END;

FUNCTION Hex4(i: Integer): string_tp;
BEGIN
   Hex4 := Hex2(i SHR 8) + Hex2(i AND 255);
END;

PROCEDURE Error(message: string_tp);
BEGIN
   errFlag := TRUE;
   errCount:=errCount+1;

   IF pass<>1 THEN BEGIN
      listThisLine := TRUE;
      WriteLn(listing,'*** Error:  ',Message,' ***');
      IF cl_Err THEN Messages.LogFmt('*** Error:  %s ***', [Message]);
   END;
END;

PROCEDURE IllegalOperand;
BEGIN
   Error('Illegal operand');
   line := '';
END;

PROCEDURE AddOpcode(name: OpcdStr; typ: Integer; parm: Word);
VAR
   p: OpcdPtr;
BEGIN
   New(p);

   p^.name := name;
   p^.typ  := typ;
   p^.parm := parm;
   p^.next := opcdTab;

   opcdTab := p;
END;

PROCEDURE FindOpcode(name: OpcdStr; VAR typ,parm: Integer);
VAR
   p:     OpcdPtr;
   found: Boolean;
BEGIN
   found := FALSE;
   p := opcdTab;

   WHILE (p<>NIL) AND NOT found DO BEGIN
      found := (p^.name = name);
      IF NOT found THEN
         p := p^.next;
   END;

   IF NOT found THEN BEGIN
      typ  := o_Illegal;
      parm := 0;
   END
   ELSE BEGIN
      typ  := p^.typ;
      parm := p^.parm;
   END;
END;

PROCEDURE InitOpcodes;
BEGIN
   opcdTab := NIL;

   AddOpcode('EXX' ,o_None,$D9);
   AddOpcode('LDI' ,o_None,$EDA0);
   AddOpcode('LDIR',o_None,$EDB0);
   AddOpcode('LDD' ,o_None,$EDA8);
   AddOpcode('LDDR',o_None,$EDB8);
   AddOpcode('CPI' ,o_None,$EDA1);
   AddOpcode('CPIR',o_None,$EDB1);
   AddOpcode('CPD' ,o_None,$EDA9);
   AddOpcode('CPDR',o_None,$EDB9);
   AddOpcode('DAA' ,o_None,$27);
   AddOpcode('CPL' ,o_None,$2F);
   AddOpcode('NEG' ,o_None,$ED44);
   AddOpcode('CCF' ,o_None,$3F);
   AddOpcode('SCF' ,o_None,$37);
   AddOpcode('NOP' ,o_None,$00);
   AddOpcode('HALT',o_None,$76);
   AddOpcode('DI'  ,o_None,$F3);
   AddOpcode('EI'  ,o_None,$FB);
   AddOpcode('RLCA',o_None,$07);
   AddOpcode('RLA' ,o_None,$17);
   AddOpcode('RRCA',o_None,$0F);
   AddOpcode('RRA' ,o_None,$1F);
   AddOpcode('RLD' ,o_None,$ED6F);
   AddOpcode('RRD' ,o_None,$ED67);
   AddOpcode('RET' ,o_None,$C9);
   AddOpcode('RETI',o_None,$ED4D);
   AddOpcode('RETN',o_None,$ED45);
   AddOpcode('INI' ,o_None,$EDA2);
   AddOpcode('INIR',o_None,$EDB2);
   AddOpcode('IND' ,o_None,$EDAA);
   AddOpcode('INDR',o_None,$EDBA);
   AddOpcode('OUTI',o_None,$EDA3);
   AddOpcode('OTIR',o_None,$EDB3);
   AddOpcode('OUTD',o_None,$EDAB);
   AddOpcode('OTDR',o_None,$EDBB);

   AddOpcode('LD'  ,o_LD,0);
   AddOpcode('EX'  ,o_EX,0);
   AddOpcode('ADD' ,o_ADD,0);
   AddOpcode('ADC' ,o_ADC_SBC,0);
   AddOpcode('SBC' ,o_ADC_SBC,1);
   AddOpcode('INC' ,o_INC_DEC,0);
   AddOpcode('DEC' ,o_INC_DEC,1);
   AddOpcode('JP'  ,o_JP_CALL,$C3C2);
   AddOpcode('CALL',o_JP_CALL,$CDC4);
   AddOpcode('JR'  ,o_JR,0);
   AddOpcode('RET' ,o_RET,0);

   AddOpcode('PUSH',o_PushPop,$C5);
   AddOpcode('POP' ,o_PushPop,$C1);

   AddOpcode('SUB' ,o_Arith,$D690);
   AddOpcode('AND' ,o_Arith,$E6A0);
   AddOpcode('XOR' ,o_Arith,$EEA8);
   AddOpcode('OR'  ,o_Arith,$F6B0);
   AddOpcode('CP'  ,o_Arith,$FEB8);

   AddOpcode('RLC' ,o_Rotate,$00);
   AddOpcode('RRC' ,o_Rotate,$08);
   AddOpcode('RL'  ,o_Rotate,$10);
   AddOpcode('RR'  ,o_Rotate,$18);
   AddOpcode('SLA' ,o_Rotate,$20);
   AddOpcode('SRA' ,o_Rotate,$28);
   AddOpcode('SRL' ,o_Rotate,$38);

   AddOpcode('BIT' ,o_Bit,$40);
   AddOpcode('RES' ,o_Bit,$80);
   AddOpcode('SET' ,o_Bit,$C0);

   AddOpcode('IM'  ,o_IM,0);

   AddOpcode('DJNZ',o_DJNZ,0);

   AddOpcode('IN'  ,o_IN,0);

   AddOpcode('OUT' ,o_OUT,0);

   AddOpcode('RST' ,o_RST,0);

   AddOpcode('DB'  ,o_DB,0);
   AddOpcode('DW'  ,o_DW,0);
   AddOpcode('DS'  ,o_DS,0);

   AddOpcode('='   ,o_EQU,0);
   AddOpcode('EQU' ,o_EQU,0);
  {AddOpcode('SET' ,o_EQU,1);}
   AddOpcode('DEFL',o_EQU,1);

   AddOpcode('ORG' ,o_ORG,0);
   AddOpcode('END' ,o_END,0);
   AddOpcode('LIST',o_LIST,0);
   AddOpcode('OPT' ,o_OPT,0);
END;

FUNCTION FindSym(symName: SymStr): SymPtr;
VAR
   p:     SymPtr;
   found: Boolean;
BEGIN
   found := FALSE;
   p     := SymTab;
   WHILE (p<>NIL) AND NOT Found DO BEGIN
      found := (p^.name = symName);
      IF NOT found THEN
         p := p^.next;
   END;

   FindSym := p;
END;

FUNCTION AddSym(symName: SymStr): SymPtr;
VAR
   p: SymPtr;
BEGIN
   New(p);

   WITH p^ DO BEGIN
      name     := SymName;
      value    := 0;
      next     := SymTab;
      defined  := FALSE;
      multiDef := FALSE;
      isSet    := FALSE;
      equ      := FALSE;
   END;

   symTab := p;

   AddSym := p;
END;

FUNCTION RefSym(symName: SymStr): Integer;
VAR
   p: SymPtr;
BEGIN
   p := FindSym(symName);
   IF p=NIL THEN p := AddSym(symName);

   IF NOT p^.defined THEN
      Error('Symbol "' + symName + '" undefined');

   RefSym := p^.value;
END;

PROCEDURE DefSym(symName: SymStr; val: Integer; setSym,equSym: Boolean);
VAR
   p: SymPtr;
BEGIN
   IF Length(symName)<>0 THEN BEGIN

      p := FindSym(symName);
      IF p=NIL THEN p := AddSym(symName);

      IF (NOT p^.defined) OR (p^.isSet AND setSym) THEN BEGIN
         p^.value   := val;
         p^.defined := TRUE;
         p^.isSet   := setSym;
         p^.equ     := equSym;
      END
      ELSE IF p^.value <> val THEN BEGIN
         p^.multiDef := TRUE;
         Error('Symbol "' + symName + '" multiply defined');
      END;
   END;
END;

FUNCTION GetWord: string_tp;
VAR
   word: string_tp;
   done: Boolean;
BEGIN
   line := Deblank(line);
   word := '';

   IF Length(line)>0 THEN
      IF (line[1]=#12) OR (line[1]=';') THEN
         line := '';

   IF Length(line)>0 THEN BEGIN
      IF Pos(Upcase(line[1]),alphaNumeric)=0 THEN BEGIN
         word := Copy(Line,1,1);
         Delete(line,1,1);
      END
      ELSE BEGIN
         done := FALSE;
         WHILE (Length(line)>0) AND NOT done DO BEGIN
	    word := word + Upcase(line[1]);
            Delete(line,1,1);
	    IF Length(line)>0 THEN
               done := Pos(Upcase(line[1]),AlphaNumeric)=0;
         END;
      END;
   END;

   GetWord := word;
END;

PROCEDURE Expect(expected: string_tp);
BEGIN
   IF GetWord<>expected THEN
      Error('"' + expected + '" expected');
END;

PROCEDURE Comma;
BEGIN
   Expect(',');
END;

PROCEDURE RParen;
BEGIN
   Expect(')');
END;

FUNCTION EvalOct(octStr: string_tp): Integer;
VAR
   octVal:  Integer;
   evalErr: Boolean;
   i,n:     Integer;
BEGIN
   evalErr := FALSE;
   octVal  := 0;

   FOR i := 1 TO Length(octStr) DO BEGIN
      n := Pos(octStr[i],'01234567');
      IF n=0 THEN evalErr := TRUE
             ELSE octVal  := octVal*8 + n-1;
   END;

   IF evalErr THEN BEGIN
      octVal := 0;
      Error('Invalid octal number');
   END;

   EvalOct := octVal;
END;

FUNCTION EvalDec(decStr: string_tp): Integer;
VAR
   decVal:  Integer;
   evalErr: Boolean;
   i,n:     Integer;
BEGIN
   evalErr := FALSE;
   decVal  := 0;

   FOR i := 1 TO Length(decStr) DO BEGIN
      n := Pos(decStr[i],'0123456789');
      IF n=0 THEN evalErr := TRUE
             ELSE decVal  := decVal*10 + n-1;
   END;

   IF evalErr THEN BEGIN
      decVal := 0;
      Error('Invalid decimal number');
   END;

   EvalDec := decVal;
END;

FUNCTION EvalHex(hexStr: string_tp): Integer;
VAR
   hexVal:  Integer;
   evalErr: Boolean;
   i,n:     Integer;
BEGIN
   evalErr := FALSE;
   hexVal  := 0;

   FOR i := 1 TO Length(hexStr) DO BEGIN
      n := Pos(Upcase(hexStr[i]),'0123456789ABCDEF');
      IF n=0 THEN evalErr := TRUE
             ELSE hexVal  := hexVal*16 + n-1;
   END;

   IF evalErr THEN BEGIN
      hexVal := 0;
      Error('Invalid hexadecimal number');
   END;

   EvalHex := hexVal;
END;

FUNCTION Factor: Integer; FORWARD;

FUNCTION Term: Integer;
VAR
   word:    string_tp;
   val:     Integer;
   oldLine: string_tp;
BEGIN
   val := Factor;

{   oldLine := line;
   word := GetWord;
   WHILE ( word = '*' ) OR ( word = '/' ) OR ( word = '%' ) DO
   BEGIN
      CASE word[1] OF
         '*': val := val  *  Factor;
         '/': val := val DIV Factor;
         '%': val := val MOD Factor;
      END;
      oldLine := line;
      word := GetWord;
   END;
   line := oldLine;
}
   Term := val;
END;

FUNCTION Eval: Integer;
VAR
   word:    string_tp;
   val:     Integer;
   oldLine: string_tp;
BEGIN
   val := Term;

   oldLine := line;
   word := GetWord;
   WHILE (word='+') OR (word='-') {OR (word='*') OR (word='/')} DO BEGIN
      CASE word[1] OF
         '+': val := val + Term;
         '-': val := val - Term;
      END;
      oldLine := line;
      word := GetWord;
   END;
   line := oldLine;

   Eval := val;
END;

FUNCTION Factor: integer;
VAR
   word: string_tp;
   val:  Integer;
BEGIN
   word := GetWord;
   val  := 0;
        IF Length(word)=0           THEN Error('Missing operand')
   ELSE IF (word='.') OR (word='*') THEN val := locPtr
   ELSE IF  word='$'                THEN val := locPtr
   ELSE IF  word='-'                THEN val := -Factor
   ELSE IF  word='+'                THEN val := Factor
   ELSE IF  word='~'                THEN val := -Factor-1
   ELSE IF  word='('                THEN BEGIN
                                            val := Eval;
                                            RParen;
                                         END
   ELSE IF  word=''''               THEN BEGIN
                                            IF Length(line)=0 THEN
                                               Error('Missing operand')
                                            ELSE BEGIN
                                               val := Ord(line[1]);
                                               Delete(line,1,1);
                                               Expect('''');
                                            END;
                                         END
   ELSE IF Pos(word[1],numeric)>0   THEN BEGIN
                  CASE word[Length(word)] OF
                     'O': val := EvalOct(Copy(word,1,Length(word)-1));
                     'D': val := EvalDec(Copy(word,1,Length(word)-1));
                     'H': val := EvalHex(Copy(word,1,Length(word)-1));
                     ELSE val := EvalDec(word);
                  END;
                                         END
   ELSE                                  val := RefSym(word);

   Factor := val;
END;

FUNCTION EvalByte: Integer;
VAR
   val: Integer;
BEGIN
   val := Eval;

   IF (val<-128) OR (val>255) THEN
      Error('Byte out of range');

   EvalByte := val AND 255;
END;

FUNCTION FindReg(regName,regList,valList: string_tp): Integer;
VAR
   p:    Integer;
   reg:  Integer;
   code: Integer;
BEGIN
   p := Pos(' ' + Deblank(regName) + ' ',regList);

   IF p=0 THEN reg := -1
   ELSE IF valList[p+2]=' ' THEN Val(Copy(valList,p+1,1),reg,code)
                            ELSE Val(Copy(valList,p+1,2),reg,code);

   FindReg := reg;
END;

PROCEDURE CodeOut(byte: Integer);
BEGIN
   IF (pass=2) AND updLoc THEN BEGIN
      WriteLn(object_,':',Hex4(newLoc));
      updLoc := FALSE;
   END;

   IF pass=2 THEN
      WriteLn(object_,Hex2(byte));
END;

PROCEDURE CodeOrg(addr: Integer);
BEGIN
   locPtr := addr;
   newLoc := locPtr;
   updLoc := TRUE;
END;

PROCEDURE CodeFlush;
BEGIN
    { Object file format does not use buffering; no flush needed }
END;

PROCEDURE CodeEnd;
BEGIN
   CodeFlush;

   IF (pass=2) AND xferFound THEN BEGIN
      WriteLn(object_,'$',Hex4(xferAddr));
   END;
END;

PROCEDURE CodeXfer(addr: Integer);
BEGIN
   xferAddr  := addr;
   xferFound := TRUE;
END;

PROCEDURE Instr1(b: Byte);
BEGIN
   instr[1] := b;
   instrLen := 1;
END;

PROCEDURE Instr2(b1,b2: Byte);
BEGIN
   instr[1] := b1;
   instr[2] := b2;
   instrLen := 2;
END;

PROCEDURE Instr3(b1,b2,b3: Byte);
BEGIN
   instr[1] := b1;
   instr[2] := b2;
   instr[3] := b3;
   instrLen := 3;
END;

PROCEDURE Instr3W(b: Byte; w: Word);
BEGIN
   Instr3(b,w AND 255,w SHR 8);
END;

PROCEDURE Instr4(b1,b2,b3,b4: Byte);
BEGIN
   instr[1] := b1;
   instr[2] := b2;
   instr[3] := b3;
   instr[4] := b4;
   instrLen := 4;
END;

PROCEDURE Instr4W(b1,b2: Byte; w: Word);
BEGIN
   Instr4(b1,b2,w AND 255,w SHR 8);
END;

PROCEDURE DoOpcode(typ: Integer; parm: Word);
VAR
   val:     Integer;
   reg1:    Integer;
   reg2:    Integer;
   word:    string_tp;
   oldLine: string_tp;

   PROCEDURE IXOffset;
   BEGIN
      word := GetWord;
      IF word=')' THEN val := 0
      ELSE IF (word='+') OR (word='-') THEN BEGIN
         val := Eval;
         IF word='-' THEN val := -val;
         RParen;
      END;
   END;

   PROCEDURE DoArith(imm,reg: Integer);
   BEGIN
      oldLine := line;
      reg2 := FindReg(GetWord,regs,regVals);
      CASE reg2 OF
         reg_None: { ADD A,nn }
            BEGIN
               line := oldLine;
               val := Eval;
               Instr2(imm,val);
            END;

         reg_B,
         reg_C,
         reg_D,
         reg_E,
         reg_H,
         reg_L,
         reg_A: { ADD A,r }
            Instr1(reg + reg2);

         reg_Paren:
            BEGIN
               reg2 := FindReg(GetWord,regs,regVals);
               CASE reg2 OF
                  reg_HL:
                     BEGIN
                        RParen;
                        Instr1(reg+reg_M);
                     END;

                  reg_IX,
                  reg_IY:
                     BEGIN
                        IXOffset;
                        IF reg2=reg_IX
                           THEN Instr3($DD,reg+reg_M,val)
                           ELSE Instr3($FD,reg+reg_M,val);
                     END;

                  ELSE IllegalOperand;
               END;
            END;

         ELSE IllegalOperand;
      END;
   END;

BEGIN
   CASE typ OF
      o_None:
         IF parm>255 THEN Instr2(parm SHR 8,parm AND 255)
                     ELSE Instr1(parm);

      o_LD:
         BEGIN
            word := GetWord;
            reg1 := FindReg(word,regs,regVals);

            CASE reg1 OF
               reg_None: { LD nnnn,? }
                  IllegalOperand;

               reg_B,
               reg_C,
               reg_D,
               reg_E,
               reg_H,
               reg_L,
               reg_A: { LD r,? }
                  BEGIN
                     Comma;
                     oldLine := line;
                     reg2 := FindReg(GetWord,regs,regVals);

                     CASE reg2 OF
                        reg_B,
                        reg_C,
                        reg_D,
                        reg_E,
                        reg_H,
                        reg_L,
                        reg_A:    { LD r,r }
                           Instr1($40 + reg1*8 + reg2);

                        reg_I:       { LD A,I }
                           Instr2($ED,$57);

                        reg_R:       { LD A,R }
                           Instr2($ED,$5F);

                        reg_Paren:   { LD r,(?) }
                           BEGIN
                              oldLine := line;
                              reg2 := FindReg(GetWord,regs,regVals);

                              CASE reg2 OF
                                 reg_BC, { LD A,(BC) }
                                 reg_DE: { LD A,(DE) }
                                    IF reg1<>reg_A THEN IllegalOperand
                                    ELSE BEGIN
                                       RParen;
                                       Instr1($0A + (reg2-reg_BC)*16);
                                    END;

                                 reg_HL: { LD r,(HL) }
                                    BEGIN
                                       RParen;
                                       Instr1($40 + reg1*8 + reg_M);
                                    END;

                                 reg_IX, { LD r,(IX+d) }
                                 reg_IY: { LD r,(IY+d) }
                                    BEGIN
                                       IXOffset;
                                       IF reg2=reg_IX
                                          THEN Instr3($DD,$46 + reg1*8,val)
                                          ELSE Instr3($FD,$46 + reg1*8,val);
                                    END;

                                 reg_None: { LD A,(nnnn) }
                                    IF reg1<>reg_A THEN IllegalOperand
                                    ELSE BEGIN
                                       line := oldLine;
                                       val := Eval;
                                       RParen;
                                       Instr3W($3A,val);
                                    END;

                                 ELSE IllegalOperand;
                              END;
                           END;

                        reg_None: { LD r,nn }
                           BEGIN
                              line := oldLine;
                              Instr2($06 + reg1*8,Eval);
                           END;

                        ELSE IllegalOperand;
                     END; { CASE reg2 }
                  END; { reg_Byte }

               reg_I:
                  BEGIN { LD I,A }
                     Comma;
                     Expect('A');
                     Instr2($ED,$47);
                  END;

               reg_R:
                  BEGIN { LD R,A }
                     Comma;
                     Expect('A');
                     Instr2($ED,$4F);
                  END;

               reg_BC,
               reg_DE,
               reg_HL,
               reg_SP:
                  BEGIN { LD rr,? }
                     Comma;
                     oldLine := line;
                     reg2 := FindReg(GetWord,regs,regVals);

                     IF (reg1=reg_SP) AND { LD SP,HL }
                        (reg2 IN [reg_HL,reg_IX,reg_IY]) THEN BEGIN
                        CASE reg2 OF
                           reg_HL: Instr1($F9);
                           reg_IX: Instr2($DD,$F9);
                           reg_IY: Instr2($FD,$F9);
                        END;
                     END

                     ELSE IF (reg1=reg_HL) AND (reg2=reg_Paren) THEN BEGIN
                        val := Eval; { LD HL,(nnnn) }
                        RParen;
                        Instr3W($2A,val);
                     END

                     ELSE IF reg2=reg_Paren THEN BEGIN
                        val := Eval; { LD BC,(nnnn) }
                        RParen;
                        Instr4W($ED,$4B + (reg1-reg_BC)*16,val);
                     END

                     ELSE IF reg2=reg_None THEN BEGIN { LD rr,nnnn }
                        line := oldLine;
                        val := Eval;
                        Instr3W($01 + (reg1-reg_BC)*16,val);
                     END

                     ELSE IllegalOperand;
                  END;

               reg_IX, { LD IX,? }
               reg_IY: { LD IY,? }
                  BEGIN
                     Comma;
                     oldLine := line;
                     reg2 := FindReg(GetWord,regs,regVals);

                     CASE reg2 OF
                        reg_None: { LD IX,nnnn }
                           BEGIN
                              line := oldLine;
                              val := Eval;
                              IF reg1=reg_IX THEN Instr4W($DD,$21,val)
                                             ELSE Instr4W($FD,$21,val);
                           END;

                        reg_Paren: { LD IX,(nnnn) }
                           BEGIN
                              val := Eval;
                              RParen;
                              IF reg1=reg_IX THEN Instr4W($DD,$2A,val)
                                             ELSE Instr4W($FD,$2A,val);
                           END;

                        ELSE IllegalOperand;
                     END;
                  END;

               reg_Paren: { LD (?),? }
                  BEGIN
                     oldLine := line;
                     reg1 := FindReg(GetWord,regs,regVals);

                     CASE reg1 OF
                        reg_None: { LD (nnnn),? }
                           BEGIN
                              line := oldLine;
                              val := Eval;
                              RParen;
                              Comma;
                              reg2 := FindReg(GetWord,regs,regVals);

                              CASE reg2 OF
                                 reg_A:  Instr3W($32,val);
                                 reg_HL: Instr3W($22,val);
                                 reg_BC,
                                 reg_DE,
                                 reg_SP: Instr4W($ED,$43+(reg2-reg_BC)*16,val);
                                 reg_IX: Instr4W($DD,$22,val);
                                 reg_IY: Instr4W($FD,$22,val);
                                 ELSE IllegalOperand;
                              END; { CASE reg2 }
                           END;

                        reg_BC,
                        reg_DE:
                           BEGIN
                              RParen;
                              Comma;
                              Expect('A');
                              Instr1($02+(reg1-reg_BC)*16);
                           END;

                        reg_HL: { LD (HL),? }
                           BEGIN
                              RParen;
                              Comma;
                              oldLine := line;
                              reg2 := FindReg(GetWord,regs,regVals);
                              IF reg2=reg_None THEN BEGIN
                                 line := oldLine;
                                 val := Eval;
                                 Instr2($36,val);
                              END
                              ELSE IF reg2 IN [ 0..7 ] THEN
                                 Instr1($70 + reg2)
                              ELSE IllegalOperand;
                           END;

                        reg_IX,
                        reg_IY: { LD (IX),? }
                           BEGIN
                              IXOffset;
                              Comma;
                              oldLine := line;
                              reg2 := FindReg(GetWord,regs,regVals);
                              IF reg2=reg_None THEN BEGIN
                                 line := oldLine;
                                 reg2 := Eval;
                                 IF reg1=reg_IX
                                    THEN Instr4($DD,$36,val,reg2)
                                    ELSE Instr4($FD,$36,val,reg2);
                              END
                              ELSE IF reg2 IN [ 0..7 ] THEN
                                 IF reg1=reg_IX
                                    THEN Instr3($DD,$70 + reg2,val)
                                    ELSE Instr3($FD,$70 + reg2,val)
                              ELSE IllegalOperand;
                           END;
                     END; { CASE reg1 }
                  END; { reg_Paren }

               ELSE IllegalOperand;

            END; { CASE reg1 }
         END; { o_LD }

      o_EX:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            CASE reg1 OF
               reg_DE: { EX DE,HL }
                  BEGIN
                     Comma;
                     Expect('HL');
                     Instr1($EB);
                  END;

               reg_AF: { EX AF,AF' }
                  BEGIN
                     Comma;
                     Expect('AF');
                     Expect('''');
                     Instr1($08);
                  END;

               reg_Paren: { EX (SP),? }
                  BEGIN
                     Expect('SP');
                     RParen;
                     Comma;
                     reg2 := FindReg(GetWord,regs,regVals);
                     CASE reg2 OF
                        reg_HL: Instr1($E3);
                        reg_IX: Instr2($DD,$E3);
                        reg_IY: Instr2($FD,$E3);
                        ELSE IllegalOperand;
                     END;
                  END;

               ELSE IllegalOperand;
            END; { CASE reg1 }
         END; { o_EX }

      o_ADD:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            CASE reg1 OF
               reg_A:
                  BEGIN
                     Comma;
                     DoArith($C6,$80);
                  END;

               reg_HL,
               reg_IX,
               reg_IY:
                  BEGIN
                     Comma;
                     reg2 := FindReg(GetWord,regs,regVals);
                     IF reg2=reg1 THEN reg2 := reg_HL;
                     IF reg2 IN [ 10..13 ] THEN BEGIN
                        CASE reg1 OF
                           reg_HL: Instr1($09 + (reg2-reg_BC)*16);
                           reg_IX: Instr2($DD,$09 + (reg2-reg_BC)*16);
                           reg_IY: Instr2($FD,$09 + (reg2-reg_BC)*16);
                        END;
                     END
                     ELSE IllegalOperand;
                  END;
               ELSE IllegalOperand;
            END; { CASE reg1 }
         END; { o_ADD }

      o_ADC_SBC:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            CASE reg1 OF
               reg_A:
                  BEGIN
                     Comma;
                     DoArith($CE+parm*16,$88+parm*16);
                  END;

               reg_HL:
                  BEGIN
                     Comma;
                     reg2 := FindReg(GetWord,regs,regVals);
                     IF reg2 IN [ 10..13 ]
                        THEN Instr2($ED,$4A + (reg2-reg_BC)*16 - parm*8)
                        ELSE IllegalOperand;
                  END;

               ELSE IllegalOperand;
            END; { CASE reg1 }
         END; { o_ADC_SBC }

      o_INC_DEC:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            CASE reg1 OF
               reg_B,
               reg_C,
               reg_D,
               reg_E,
               reg_H,
               reg_L,
               reg_A: { INC r }
                  Instr1($04 + reg1*8 + parm);

               reg_BC,
               reg_DE,
               reg_HL,
               reg_SP: { INC rr }
                  Instr1($03 + (reg1-reg_BC)*16 + parm*8);

               reg_IX: Instr2($DD,$23 + parm*8);
               reg_IY: Instr2($FD,$23 + parm*8);

               reg_Paren: { INC (HL) }
                  BEGIN
                     reg1 := FindReg(GetWord,regs,regVals);
                     CASE reg1 OF
                        reg_HL:
                           BEGIN
                              RParen;
                              Instr1($34 + parm);
                           END;

                        reg_IX,
                        reg_IY:
                           BEGIN
                              IXOffset;
                              IF reg1=reg_IX
                                 THEN Instr3($DD,$34 + parm,val)
                                 ELSE Instr3($FD,$34 + parm,val);
                           END;

                        ELSE IllegalOperand;
                     END;
                  END;
            END;
         END; { o_INC_DEC }

      o_JP_CALL:
         BEGIN
            oldLine := line;
            word := GetWord;
            IF word='(' THEN BEGIN
               reg1 := FindReg(GetWord,regs,regVals);
               RParen;
               CASE reg1 OF
                  reg_HL: Instr1($E9);
                  reg_IX: Instr2($DD,$E9);
                  reg_IY: Instr2($FD,$E9);
                  ELSE IllegalOperand;
               END;
            END
            ELSE BEGIN
               reg1 := FindReg(word,conds,condVals);
               IF reg1=reg_None THEN BEGIN
                  line := oldLine;
                  val := Eval;
                  Instr3W(parm SHR 8,val);
               END
               ELSE BEGIN
                  Comma;
                  val := Eval;
                  Instr3W((parm AND 255) + reg1*8,val);
               END;
            END;
         END; { o_JP_CALL }

      o_JR:
         BEGIN
            oldLine := line;
            reg1 := FindReg(GetWord,conds,condVals);
            IF reg1=reg_None THEN BEGIN
               line := oldLine;
               val := Eval;
               val := val - locPtr - 2;
               IF (val<-128) OR (val>127) THEN
                  Error('Branch out of range');
               Instr2($18,val);
            END
            ELSE IF reg1>=4 THEN
               IllegalOperand
            ELSE BEGIN
               Comma;
               val := Eval;
               val := val - locPtr - 2;
               IF (val<-128) OR (val>127) THEN
                  Error('Branch out of range');
               Instr2($20 + reg1*8,val);
            END;
         END; { o_JR }

      o_RET:
         BEGIN
            reg1 := FindReg(GetWord,conds,condVals);
            IF reg1=reg_None THEN Instr1($C9)
                             ELSE Instr1($C0 + reg1*8);
         END; { o_RET }

      o_IN:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            IF NOT (reg1 IN [reg_B..reg_A]) THEN
               IllegalOperand
            ELSE BEGIN
               Comma;
               Expect('(');
               oldLine := line;
               reg2 := FindReg(GetWord,regs,regVals);

               IF (reg1=reg_A) AND (reg2=reg_none) THEN BEGIN
                  line := oldLine;
                  val := Eval;
                  RParen;
                  Instr2($DB,val);
               END
               ELSE IF reg2=reg_C THEN BEGIN
                  RParen;
                  Instr2($ED,$40 + reg1*8)
               END
               ELSE IllegalOperand;
            END;
         END; { o_IN }

      o_OUT:
         BEGIN
            Expect('(');
            oldLine := line;
            reg1 := FindReg(GetWord,regs,regVals);

            IF reg1=reg_None THEN BEGIN
               line := oldLine;
               val := Eval;
               RParen;
               Comma;
               Expect('A');
               Instr2($D3,val);
            END
            ELSE IF reg1=reg_C THEN BEGIN
               RParen;
               Comma;
               reg2 := FindReg(GetWord,regs,regVals);
               IF reg2 IN [reg_B..reg_A] THEN BEGIN
                  Instr2($ED,$41 + reg2*8);
               END
               ELSE IllegalOperand;
            END
            ELSE IllegalOperand;
         END; { o_OUT }

      o_PushPop:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            CASE reg1 OF
               reg_BC,
               reg_DE,
               reg_HL: Instr1(parm + (reg1-reg_BC)*16);
               reg_AF: Instr1(parm + $30);
               reg_IX: Instr2($DD,parm + $20);
               reg_IY: Instr2($FD,parm + $20);
               ELSE IllegalOperand;
            END;
         END;

      o_Arith:
         DoArith(parm SHR 8,parm AND 255);

      o_Rotate:
         BEGIN
            reg1 := FindReg(GetWord,regs,regVals);
            CASE reg1 OF
               reg_B,
               reg_C,
               reg_D,
               reg_E,
               reg_H,
               reg_L,
               reg_A: { RLC r }
                  Instr2($CB,parm+reg1);

               reg_Paren:
                  BEGIN
                     reg1 := FindReg(GetWord,regs,regVals);
                     CASE reg1 OF
                        reg_HL:
                           BEGIN
                              RParen;
                              Instr2($CB,parm+reg_M);
                           END;

                        reg_IX,
                        reg_IY:
                           BEGIN
                              IXOffset;
                              IF reg1=reg_IX
                                 THEN Instr4($DD,$CB,val,parm+reg_M)
                                 ELSE Instr4($FD,$CB,val,parm+reg_M);
                           END;

                        ELSE IllegalOperand;
                     END;
                  END;

               ELSE IllegalOperand;
            END; { CASE reg1 }
         END; { o_Rotate }

      o_Bit:
         BEGIN
            reg1 := Eval;
            Comma;
            reg2 := FindReg(GetWord,regs,regVals);
            CASE reg2 OF
               reg_B,
               reg_C,
               reg_D,
               reg_E,
               reg_H,
               reg_L,
               reg_A: { BIT n,r }
                  Instr2($CB,parm + reg1*8 + reg2);

               reg_Paren: { BIT n,(HL) }
                  BEGIN
                     reg2 := FindReg(GetWord,regs,regVals);
                     CASE reg2 OF
                        reg_HL:
                           BEGIN
                              RParen;
                              Instr2($CB,parm + reg1*8 + reg_M);
                           END;

                        reg_IX,
                        reg_IY:
                           BEGIN
                              IXOffset;
                              IF reg1=reg_IX
                                 THEN Instr4($DD,$CB,val,parm + reg1*8 + reg_M)
                                 ELSE Instr4($FD,$CB,val,parm + reg1*8 + reg_M);
                           END;

                        ELSE IllegalOperand;
                     END;
                  END;
            END; { CASE reg2 }
         END; { o_Bit }

      o_IM:
         BEGIN
            word := GetWord;
                 IF word='0' THEN Instr2($ED,$46)
            ELSE IF word='1' THEN Instr2($ED,$56)
            ELSE IF word='2' THEN Instr2($ED,$5E)
            ELSE IllegalOperand;
         END;

      o_DJNZ:
         BEGIN
            val := Eval;
            val := val - locPtr - 2;
            IF (val<-128) OR (val>127) THEN
               Error('Branch out of range');
            Instr2($10,val);
         END;

      o_RST:
         BEGIN
            val := Eval;
            IF val IN [0..7] THEN
               Instr1($C7 + val*8)
            ELSE IF val IN [$08,$10,$18,$20,$28,$30,$38] THEN
               Instr1($C7 + val)
            ELSE IllegalOperand;
         END;

      o_DB:
         BEGIN
            bytStr := '';

            oldLine := line;
            word := GetWord;

            IF (word='') OR (word=';') THEN
               Error('Missing operand');

            WHILE (word<>'') AND (word<>';') DO BEGIN
               IF word='''' THEN
                  WHILE word='''' DO BEGIN
                     val := Pos('''',line);
                     IF val=0 THEN BEGIN
                        bytStr := bytStr + line;
                        line := '';
                        word := '';
                     END
                     ELSE BEGIN
                        bytStr := bytStr + Copy(line,1,val-1);
                        Delete(line,1,val);
                        word := GetWord;
                        IF word='''' THEN bytStr := bytStr + '''';
                     END;
                  END

               ELSE BEGIN
                  line := oldLine;
                  bytStr := bytStr + CHR(EvalByte);
               END;

               word := GetWord;
               oldLine := line;

               IF word=',' THEN BEGIN
                  word := GetWord;
                  IF (word='') OR (word=';') THEN
                     Error('Missing operand');
               END;
            END;
            instrLen := -Length(bytStr);
         END;

      o_DW:
         BEGIN
            bytStr := '';

            oldLine := line;
            word := GetWord;

            IF (word='') OR (word=';') THEN
               Error('Missing operand');

            WHILE (word<>'') AND (word<>';') DO BEGIN
               line := oldLine;
               val := Eval;
               bytStr := bytStr + CHR(val AND 255) + CHR(val SHR 8);

               word := GetWord;
               oldLine := line;

               IF word=',' THEN BEGIN
                  word := GetWord;
                     IF (word='') OR (word=';') THEN
                        Error('Missing operand');
               END;
            END;
            instrLen := -Length(bytStr);
         END;

      o_DS:       BEGIN
                     val := Eval;

                     IF pass=2 THEN BEGIN
                        showAddr := FALSE;
                        Delete(listLine,1,12);
                        listLine := Hex4(locPtr) + '  (' + Hex4(val) + ')'
                                                 + listLine;
                     END;

                     val := val + locPtr;
                     CodeOrg(val);
                  END;

      o_END:     BEGIN
                    oldLine := line;

                    IF Length(GetWord)<>0 THEN BEGIN
                       line := oldLine;
                       val  := Eval;
                       CodeXfer(val);
                       line := Copy(line,1,6) + '(' + Hex4(val) + ')' +
                               Copy(line,13,255);
                    END;

                    sourceEnd := TRUE;
                 END;

      ELSE Error('Unknown opcode');
   END;
END;

PROCEDURE DoLabelOp(typ,parm: Integer; labl: SymStr);
VAR
   val:  Integer;
   word: string_tp;
BEGIN
   CASE typ OF
      o_EQU:   BEGIN
                  IF Length(labl)=0 THEN
                     Error('Missing label')
                  ELSE BEGIN
                     val := Eval;

                     listLine := Copy(listLine,1,5) + '= ' + Hex4(val) +
                                 Copy(listLine,12,255);

                     DefSym(labl,val,parm=1,parm=0);
                  END;
               END;


      o_ORG:   BEGIN
                  CodeOrg(Eval);
                  DefSym(labl,locPtr,FALSE,FALSE);
                  showAddr := TRUE;
               END;

      o_LIST:  BEGIN
                  listThisLine := TRUE;

                  IF Length(labl)<>0 THEN
                     Error('Label not allowed');

                  word := GetWord;
                       IF word='ON'  THEN listFlag := TRUE
                  ELSE IF word='OFF' THEN listFlag := FALSE
                  ELSE                    IllegalOperand;
               END;

      o_OPT:   BEGIN
                  listThisLine := TRUE;

                  IF Length(labl)<>0 THEN
                     Error('Label not allowed');

                  word := GetWord;
                       IF word='LIST'   THEN listFlag := TRUE
                  ELSE IF word='NOLIST' THEN listFlag := FALSE
                  ELSE                       Error('Illegal option');
               END;

      ELSE Error('Unknown opcode');
   END;
END;

PROCEDURE ListOut;
VAR
   i: Integer;
BEGIN
   IF Deblank(listLine) = #12 THEN
      WriteLn(listing,#12)

   ELSE IF Deblank(listLine)='' THEN
      WriteLn(listing)

   ELSE BEGIN
      i := Length(listLine);
      WHILE (i>0) AND (listLine[i]=' ') DO
         i:=i-1;
      listLine[0] := CHR(i);

      WriteLn(listing,listLine);
      IF errFlag AND cl_Err THEN
         Messages.Log(listLine);
   END;
END;

PROCEDURE DoPass;
VAR
   labl:    SymStr;
   opcode:  OpcdStr;
   typ:     Integer;
   parm:    Integer;
   i:       Integer;
   word:    string_tp;
BEGIN
   Assign(source,cl_SrcName);
   Reset(source);
   sourceEnd := FALSE;

   //Messages.LogFmt('Pass %d',[pass]);

   CodeOrg(0);
   errCount := 0;
   listFlag := TRUE;

   WHILE (NOT Eof(source)) AND (NOT SourceEnd) DO BEGIN
      ReadLn(source,line);

      if Pass = 1 then
      begin
         inc(lineCount);
         inc(byteCount, length(line));
      end;

      errFlag      := FALSE;
      instrLen     := 0;
      showAddr     := FALSE;
      listThisLine := ListFlag;
      listLine     := '                '; { 16 blanks }

      IF Pass=2 THEN listLine := Copy(listLine,1,16) + line;

      labl := '';

      IF Length(line)>0 THEN
         IF Pos(line[1],white)=0 THEN BEGIN
            labl := GetWord;
            showAddr := (Length(labl)<>0);

            IF Length(line)>0 THEN
               IF line[1]=':' THEN
                  Delete(line,1,1);

         END;

      opcode := GetWord;
      IF Length(opcode)=0 THEN BEGIN
         typ := 0;
         DefSym(labl,locPtr,FALSE,FALSE);
      END
      ELSE BEGIN
         FindOpcode(opcode,typ,parm);

              IF typ=o_Illegal THEN Error('Illegal opcode "' + Deblank(opcode) + '"')
         ELSE IF typ<0         THEN BEGIN
                                       showAddr := FALSE;
                                       DoLabelOp(typ,parm,labl);
                                    END
         ELSE                       BEGIN
                                       showAddr := TRUE;
                                       DefSym(labl,locPtr,FALSE,FALSE);
                                       DoOpcode(typ,parm);
                                    END;

         IF typ<>o_Illegal THEN
            IF Length(GetWord)>0 THEN
               Error('Too many operands');
      END;

      IF Pass=2 THEN BEGIN
         IF ShowAddr THEN
            listLine := Hex4(locPtr) + Copy(listLine,5,255);

         IF instrLen>0 THEN
            FOR i := 1 TO instrLen DO BEGIN
               word := Hex2(instr[i]);
               listLine[i*2+4] := word[1];
               listLine[i*2+5] := word[2];
               CodeOut(instr[I]);
            END
         ELSE FOR i := 1 TO -instrLen DO BEGIN
            IF I<=5 THEN BEGIN
               word := Hex2(ORD(bytStr[i]));
               listLine[i*2+4] := word[1];
               listLine[i*2+5] := word[2];
            END;
            CodeOut(ORD(bytStr[i]));
         END;

         IF listThisLine THEN ListOut;
      END;

      locPtr := locPtr + ABS(instrLen);
   END;

   IF Pass=2 THEN CodeEnd;

   { Put the lines after the END statement into the listing file   }
   { while still checking for listing control statements.  Ignore  }
   { any lines which have invalid syntax, etc., because whatever   }
   { is found after an END statement should esentially be ignored. }

   IF Pass=2 THEN
      WHILE NOT Eof(source) DO BEGIN
         listThisLine := listFlag;
         listLine := '                ' + line; { 16 blanks }

         IF Length(line)>0 THEN
            IF Pos(line[1],white)<>0 THEN BEGIN
               word := GetWord;
               IF Length(word)<>0 THEN BEGIN
                   IF word='LIST' THEN
                      BEGIN
                         listThisLine := TRUE;
                         word := GetWord;

                              IF word='ON'  THEN listFlag := TRUE
                         ELSE IF word='OFF' THEN listFlag := FALSE
                         ELSE                    listThisLine := listFlag;
                      END

                   ELSE IF word='OPT' THEN
                      BEGIN
                         listThisLine := TRUE;
                         word := GetWord;

                              IF word='LIST'   THEN listFlag := TRUE
                         ELSE IF word='NOLIST' THEN listFlag := FALSE
                         ELSE                       listThisLine := listFlag;
                      END;
               END;
            END;

         IF listThisLine THEN ListOut;
      END;

   Close(source);
END;

PROCEDURE SortSymTab;
VAR
   i,j,t:  SymPtr;
   sorted: Boolean;
   temp:   SymRec;
BEGIN
   IF symTab<>NIL THEN BEGIN

      i := symTab;
      j := i^.next;
      WHILE (j<>NIL) DO BEGIN
         sorted := TRUE;

         WHILE (j<>NIL) DO BEGIN
            IF j^.name < i^.name THEN BEGIN
               temp := i^;
               i^   := j^;
               j^   := temp;

               t       := i^.next;
               i^.next := j^.next;
               j^.next := t;

               sorted := FALSE;
            END;
            j := j^.next;
         END;
         i := i^.next;
         j := i^.next;
      END;
   END;
END;

PROCEDURE DumpSym(p: SymPtr);
BEGIN
   Write(listing,p^.name:maxSymLen,' ',Hex4(p^.value));

   IF NOT p^.defined  THEN Write(listing,' U');
   IF     p^.multiDef THEN Write(listing,' M');
   IF     p^.isSet    THEN Write(listing,' S');
   IF     p^.equ      THEN Write(listing,' E');

   WriteLn(listing);
END;

PROCEDURE DumpSymTab;
VAR
   p: SymPtr;
BEGIN
   SortSymTab;

   p := symTab;
   WHILE (p<>NIL) DO BEGIN
      DumpSym(p);
      p := p^.next;
   END;
END;

FUNCTION GetOption(VAR optStr: String_tp): String_tp;
VAR
   option: String[80];
   p:      Integer;
BEGIN
   optStr := Deblank(optStr);

   p := Pos(' ',optStr);

   IF p=0 THEN BEGIN
      option := optStr;
      optStr := '';
   END
   ELSE BEGIN
      option := Copy(optStr,1,p-1);
      optStr := Copy(optStr,p+1,255);
   END;

   optStr := UprCase(Deblank(optStr));

   GetOption := option;
END;

procedure ASMZ80_execute(SrcName, ListName, ObjName: String_tp; Err: Boolean);
var
   time: double;
begin
   Messages.Log('ASMZ80 - easy80 assembler');

   time := Now;

   lineCount := 0;
   byteCount := 0;

   cl_SrcName := SrcName;
   cl_ListName := ListName;
   cl_ObjName := ObjName;
   cl_Err := Err;

  Assign(listing,cl_ListName);
   Rewrite(listing);
   Assign(object_,cl_ObjName);
   Rewrite(object_);

   symTab    := NIL;
   xferAddr  := 0;
   xferFound := FALSE;
   InitOpcodes;

   pass := 1;
   DoPass;

   pass := 2;
   DoPass;

   WriteLn(listing);
   WriteLn(listing,errCount:5,' Total Error(s)');
   WriteLn(listing);

   IF cl_Err THEN BEGIN
      Messages.Log('');
      Messages.LogFmt('%d lines assembled, %.1f sec, %d bytes code', [lineCount, (Now - time) * 24 * 3600, byteCount]);
      //Messages.LogFmt('%d warning(s) issued', [warnCount]);
      //Messages.LogFmt('%d note(s) issued', [noteCount]);
      Messages.LogFmt('%d error(s) issued', [errCount]);
      Messages.Log('');
   END;

   DumpSymTab;

   Close(listing);
   Close(object_);
end;

end.
