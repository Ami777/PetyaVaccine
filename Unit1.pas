unit Unit1;

//Sorry, I have not used Delphi for over 5 years now :D So code my not be the best :)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, ShellAPI, Registry, Menus, IdHTTP;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    OprogramieAboutapp1: TMenuItem;
    N1: TMenuItem;
    Odinstalujuninstall1: TMenuItem;
    SafellyFacebook1: TMenuItem;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure OprogramieAboutapp1Click(Sender: TObject);
    procedure Odinstalujuninstall1Click(Sender: TObject);
    procedure SafellyFacebook1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  fileLockStreams : array of TFileStream;

implementation

{$R *.dfm}

procedure createFileIfPossible( fn : string );
var
  tmpFile : TextFile;
begin
  try
    if FileExists(fn) then exit;
    ForceDirectories( ExtractFileDir( fn ) );
    AssignFile(tmpFile, fn);
    try
      ReWrite(tmpFile);
      WriteLn(tmpFile, 'PetyaVaccine by Safelly.');
    finally
      CloseFile(tmpFile);
    end;
  except
    //Just skip errors
  end;
end;

procedure lockFileIfPossible( fn : string );
begin
  try
    if not FileExists(fn) then exit;
    SetLength(fileLockStreams, Length(fileLockStreams) + 1);
    fileLockStreams[High(fileLockStreams)] := TFileStream.Create( fn, fmOpenReadWrite or fmShareExclusive );
  except
    //Just skip errors
  end;
end;

function GetWinDir: string;
var
  dir: array [0..MAX_PATH] of Char;
begin
  GetWindowsDirectory(dir, MAX_PATH);
  Result := StrPas(dir);
end;

procedure runVaccine();
begin
  // Based on sources I put link on the form

  createFileIfPossible( 'C:\Windows\perfc' );
  createFileIfPossible( 'C:\Windows\perfc.dat' );
  createFileIfPossible( 'C:\Windows\perfc.dll' );
  createFileIfPossible( GetWinDir + '\perfc' );
  createFileIfPossible( GetWinDir + '\perfc.dat' );
  createFileIfPossible( GetWinDir + '\perfc.dll' );
  lockFileIfPossible( 'C:\Windows\perfc' );
  lockFileIfPossible( 'C:\Windows\perfc.dat' );
  lockFileIfPossible( 'C:\Windows\perfc.dll' );
  lockFileIfPossible( GetWinDir + '\perfc' );
  lockFileIfPossible( GetWinDir + '\perfc.dat' );
  lockFileIfPossible( GetWinDir + '\perfc.dll' );
end;

procedure runUrl( url : PWideChar );
begin
  ShellExecute(Application.Handle, 'open', url, nil, nil, sw_shownormal);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Form1.Hide;
end;

procedure SetAutoStart(AppName, AppTitle: string; bRegister: Boolean);
const
  RegKey = '\Software\Microsoft\Windows\CurrentVersion\Run';
  // or: RegKey = '\Software\Microsoft\Windows\CurrentVersion\RunOnce';
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, False) then
    begin
      if bRegister = False then
        Registry.DeleteValue(AppTitle)
      else
        Registry.WriteString(AppTitle, AppName);
    end;
  finally
    Registry.Free;
  end;
end;

procedure downloadUpdatesAndShowIfAny();
var
  S: string;
  IdHTTP: TIdHTTP;
begin
  IdHTTP := TIdHTTP.Create(nil);
  try
    S := IdHTTP.Get('http://www.safelly.com/petya/petya-updates.txt');
    if Copy(S, 1, Length('!DOUPDATE!')) = '!DOUPDATE!' then begin
      ShowMessage(Copy(S, Length('!DOUPDATE!')+1, Length(S)));
    end;
  finally
    IdHTTP.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  runVaccine();
  SetAutoStart(Application.ExeName, 'PetyaVaccine by Safelly', true);
  downloadUpdatesAndShowIfAny();
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  runUrl('https://twitter.com/0xAmit/status/879764284020064256');
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  runUrl('https://twitter.com/HackingDave/status/879779361364357121');
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  runUrl('http://safelly.com');
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  runUrl('https://www.facebook.com/SafellyOfficial');
end;

procedure TForm1.Odinstalujuninstall1Click(Sender: TObject);
begin
  if MessageDlg('Czy na pewno chcesz odinstalowaæ PetyaVaccine? Nie bêdzie ju¿ wiêcej chroni³. // Are you sure you want to uninstall PetyaVaccine? It will not protect anymore!', mtWarning, mbYesNo, 0) <> mrYes then exit;

  SetAutoStart(Application.ExeName, 'PetyaVaccine by Safelly', false);
  Application.Terminate;
end;

procedure TForm1.OprogramieAboutapp1Click(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.SafellyFacebook1Click(Sender: TObject);
begin
  runUrl('https://www.facebook.com/SafellyOfficial');
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  downloadUpdatesAndShowIfAny();
end;

end.
