program Serverstats;

uses
  Forms,
  Serverstatsmain in 'Serverstatsmain.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.ShowMainForm:=false;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
