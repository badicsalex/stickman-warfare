unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
me:integer;
novchar:Char;
novmsg:lparam;
hovwnd:Hwnd;
i,j:integer;
ali:string;
poi:Tpoint;
begin
 sleep(2000);
 repaint;
 getcursorpos(poi);
 hovwnd:= windowfrompoint(poi);
 for i:=1 to strtoint(edit2.text) do
 begin
  ali:=edit1.text;
  me:=length(ali);
  for j:=1 to me+1 do
  begin
   if j>me then
   begin
    novmsg:=0+mapvirtualkey(VK_RETURN,0) shl 16 ;
    //showwindow(hovwnd,SW_MAXIMIZE);
    sendmessage(hovwnd,WM_KEYDOWN,VK_RETURN,novmsg);
    sendmessage(hovwnd,WM_CHAR,VK_RETURN,novmsg);
   end           
   else
   begin
    novchar:=edit1.text[j];
    novmsg:=0+mapvirtualkey(VkKeyScan(novchar),0) shl 16 ;
    //showwindow(hovwnd,SW_MAXIMIZE);
    sendmessage(hovwnd,WM_CHAR,ord(novchar),novmsg);
   end;
  end;
 end;
end;

end.
