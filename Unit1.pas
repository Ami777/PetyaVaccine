unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, ShellAPI, Registry, Menus, IdHTTP,
  Buttons, IdBaseComponent, IdComponent;

type
  TForm1 = class(TForm)
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    OprogramieAboutapp1: TMenuItem;
    SafellyFacebook1: TMenuItem;
    Timer1: TTimer;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label7: TLabel;
    Panel2: TPanel;
    panelFirst: TPanel;
    SpeedButton1: TSpeedButton;
    Image3: TImage;
    Image2: TImage;
    Image4: TImage;
    Image5: TImage;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label2: TLabel;
    panelSources: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    panelAbout: TPanel;
    Label13: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    panelUninstall: TPanel;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblOpenSource: TLabel;
    Label8: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Label5Click(Sender: TObject);
    procedure lblOpenSourceClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure OprogramieAboutapp1Click(Sender: TObject);
    procedure SafellyFacebook1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
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
      WriteLn(tmpFile, 'Vaccine by Safelly.');
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

  //BadRabbit
  createFileIfPossible( 'C:\Windows\cscc.dat' );
  createFileIfPossible( 'C:\Windows\infpub.dat' );
  createFileIfPossible( GetWinDir + '\cscc.dat' );
  createFileIfPossible( GetWinDir + '\infpub.dat' );
  lockFileIfPossible( 'C:\Windows\cscc.dat' );
  lockFileIfPossible( 'C:\Windows\infpub.dat' );
  lockFileIfPossible( GetWinDir + '\cscc.dat' );
  lockFileIfPossible( GetWinDir + '\infpub.dat' );

  //Petya
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

function setAutoStart(AppName, AppTitle: string; bRegister: Boolean) : Boolean;
const
  RegKey = '\Software\Microsoft\Windows\CurrentVersion\Run';
var
  Registry: TRegistry;
begin
  Result := False;
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, False) then
    begin
      if bRegister = False then
        Registry.DeleteValue(AppTitle)
      else begin
        if not Registry.ValueExists(AppTitle) then Result := True;
        Registry.WriteString(AppTitle, AppName);
      end;
    end;
  finally
    Registry.Free;
  end;
end;

function setLastMsgAndGetIsNew(msg: string) : Boolean;
const
  RegKey = '\Software\Safelly\Vaccine';
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if Registry.OpenKey(RegKey, True) then
    begin
      Result := (not Registry.ValueExists('last_msg')) or (Registry.ReadString('last_msg') <> msg);

      if Result then
        Registry.WriteString('last_msg', msg);
    end else
      Result := false;
  finally
    Registry.Free;
  end;
end;

procedure downloadUpdatesAndShowIfAny();
var
  S, cmd, url, txt: string;
  IdHTTP: TIdHTTP;
begin
  IdHTTP := TIdHTTP.Create(nil);
  try
    S := IdHTTP.Get('http://www.safelly.com/petya/vaccine-updates.txt');
    if (Copy(S, 1, Length('!DOUPDATE!')) = '!DOUPDATE!') and setLastMsgAndGetIsNew(S) then begin
      cmd := Copy(S, Length('!DOUPDATE!')+1, Length(S));
      url := Copy(cmd, 1, Pos('!', cmd)-1);
      txt := Copy(cmd, Length(url) + 2, Length(cmd));
      if (MessageDlg('VACCINE BY SAFELLY IMPORTANT UPDATE'#13#10 + txt, mtWarning, mbYesNo, 0) = mrYes) and (url <> '') then
         runUrl(PWideChar(url));
    end;
  finally
    IdHTTP.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  runVaccine();
  if SetAutoStart(Application.ExeName, 'Vaccine by Safelly', true) then Form1.Show;
  downloadUpdatesAndShowIfAny();
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if MessageDlg('Czy na pewno chcesz odinstalowaæ Vaccine? Nie bêdzie ju¿ wiêcej chroni³. // Are you sure you want to uninstall Vaccine? It will not protect anymore!', mtWarning, mbYesNo, 0) <> mrYes then exit;

  SetAutoStart(Application.ExeName, 'Vaccine by Safelly', false);

  ShowMessage('Vaccine by Safelly odinstalowane! // Vaccine by Safelly uninstalled!');

  Application.Terminate;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  runUrl('https://www.safelly.com');
end;

procedure TForm1.Label17Click(Sender: TObject);
begin
  runUrl('https://www.facebook.com/SafellyOfficial');
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
  runUrl('http://zaproszenie.safelly.com/');
end;

procedure TForm1.lblOpenSourceClick(Sender: TObject);
begin
  runUrl('https://github.com/Ami777/VaccineBySafelly');
end;

procedure TForm1.Label8Click(Sender: TObject);
begin
  runUrl('https://www.spidersweb.pl/2017/10/ransomware-bad-rabbit-szczepionka.html');
end;

procedure TForm1.OprogramieAboutapp1Click(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.SafellyFacebook1Click(Sender: TObject);
begin
  runUrl('https://www.facebook.com/SafellyOfficial');
end;

procedure selectPanel(panel : TPanel);
begin
  Form1.panelFirst.Hide;
  Form1.panelSources.Hide;
  Form1.panelAbout.Hide;
  Form1.panelUninstall.Hide;
  panel.Show;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  selectPanel(panelFirst);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  selectPanel(panelSources);
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  selectPanel(panelAbout);
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  selectPanel(panelUninstall);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  selectPanel(panelFirst);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  downloadUpdatesAndShowIfAny();
end;

end.
