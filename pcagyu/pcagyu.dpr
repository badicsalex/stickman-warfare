program pcagyu;

uses
  Forms,
  main in 'main.pas' {Form1},
  setting in 'setting.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'PC �gy�! (Ki akarod l�ni task managerben?!)';
  Application.HelpFile := 'C:\Program Files\Borland\Delphi5\Projects\PC �gyu\Pc �gy� s�g�.hlp';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
