program CsicsaCrypt;
{$APPTYPE CONSOLE}
uses
  SysUtils,windows;

const
 decoder:array [0..37] of byte =(
 $FD, $33, $C0, $BF, $78, $56, $34, $12, $B9, $78, $56, $34, $12, $03, $07, $AB,
 $49, $75, $FA, $FC, $33, $C0, $BF, $78, $56, $34, $12, $B9, $78, $56, $34, $12,
 $03, $07, $AB, $49, $75, $FA);

OFFS1=4;
OFFS2=9;
OFFS3=23;
OFFS4=28;

var
 fil:file;
 i:integer;
 pe:integer;
 base:integer;
 oep:integer;
 soc,soc4:integer;
 csec:integer;
 adat:integer;
 caddr:integer;
 cpoi:integer;
 code:array of dword;
 poffs:Pdword;
begin
 if paramstr(1)='' then
 begin
  writeln('Usage: csicsa.exe to_be_coded.exe');
  writeln('Magyarul elkúrtad bazmeg :P');
  exit;
 end;
 copyfile(Pchar(paramstr(1)),Pchar(paramstr(1)+'.bak'),false);
 assignfile(fil,paramstr(1));
 reset(fil,1);
 seek(fil,$3c);
 blockread(fil,pe,4);

 seek(fil,pe+$34);
 blockread(fil,base,4);
 writeln('Image base:',inttohex(base,8));

 seek(fil,pe+$28);
 blockread(fil,oep,4);
 writeln('Original OEP:',inttohex(oep,8));

 seek(fil,pe+$1c);
 blockread(fil,soc,4);
 writeln('Size Of Code:',inttohex(soc,8));

 csec:=pe+$f8;
 repeat
  seek(fil,csec+$8);
  blockread(fil,soc,4);
  blockread(fil,caddr,4);
  if (caddr<=oep) and (oep<=caddr+soc) then
   break;

  csec:=csec+$28;
 until false;

 seek(fil,csec+$14);
 blockread(fil,cpoi,4);

 seek(fil,csec+$24);
 blockread(fil,adat,4);
 adat:=adat or $80000000;
 seek(fil,csec+$24);
 blockwrite(fil,adat,4);

 writeln('File Pointer of Code:',inttohex(cpoi,8));
 writeln('Actual Size Of Code:',inttohex(soc,8));

 //OEP patch
 seek(fil,pe+$28);
 adat:=0;
 blockwrite(fil,adat,4);


 //STUB

 soc4:=soc div 4;

 poffs:=@(decoder[OFFS1]);
 poffs^:=base+caddr+soc4*4-4;
 poffs:=@(decoder[OFFS2]);
 poffs^:=soc4;
 poffs:=@(decoder[OFFS3]);
 poffs^:=base+caddr;
 poffs:=@(decoder[OFFS4]);
 poffs^:=soc4;
 seek(fil,2);
 blockwrite(fil,decoder,sizeof(decoder));
 adat:=$E9;
 blockwrite(fil,adat,1);
 adat:=oep-45;
 blockwrite(fil,adat,4);


 //Encode
 seek(fil,cpoi);
 setlength(code,soc4);
 blockread(fil,code[0],soc4*4);

 //odafelé:
 for i:=soc4-1 downto 1 do
  code[i]:=code[i]-code[i-1];

 //visszafelé:
 for i:=0 to soc4-2 do
  code[i]:=code[i]-code[i+1];

 seek(fil,cpoi);
 blockwrite(fil,code[0],soc4*4);
 writeln('Encryption succesful...') ;
 
end.