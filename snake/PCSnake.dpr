program PCSnake;

uses
  Forms,
  Snake in 'Snake.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'PC Snake';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
