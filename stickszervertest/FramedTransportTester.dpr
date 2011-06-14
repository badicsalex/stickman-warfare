program FramedTransportTester;

uses
  Forms,
  main in 'main.pas' {Form1},
  tcp_socket_stuff in 'tcp_socket_stuff.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
