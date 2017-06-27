program PetyaVaccine;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}
{$R manifest.REC}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.ShowMainForm := False;
  Application.Title := 'Petya Vaccine by Safelly';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
