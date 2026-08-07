unit NewRPNEditorU;

{$mode objfpc}{$H+}

interface

uses
  Classes , SysUtils , Types , Forms , Controls , Graphics , Dialogs , StdCtrls ,
	ExtCtrls , SynEdit , SynEditTypes , SynHighlighterAny , LCLType , StrUtils ,
	SynFacilHighlighter , SynEditHighlighter , SpinEx , Plus42Comms , Clipbrd ,
	Menus , DCPsha256 , SetupSynEdit
  ;

type

	{ TForm1 }

  TForm1 = class(TForm)
		 btnExportToPlus42: TButton;
		 btnImportFromPlus42: TButton;
		 btnLoad: TButton;
		 btnProgrammingMode: TButton;
		 btnSave: TButton;
		 ColorDialog1: TColorDialog;
		 ListBox1: TListBox;
		 ListBox2: TListBox;
		 MainMenu1: TMainMenu;
		 MenuItem1: TMenuItem;
		 mnuSelectColours: TMenuItem;
		 mnuSelectSaveDirectory: TMenuItem;
		 mnuSetup: TMenuItem;
		 OpenDialog1: TOpenDialog;
		 Panel1: TPanel;
		 SaveDialog1: TSaveDialog;
		 SelectDirectoryDialog1: TSelectDirectoryDialog;
		 SynAnySyn1: TSynAnySyn;
		 SynEdit1: TSynEdit;
		 SynEdit2: TSynEdit;
		 Timer1: TTimer;

		procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    //procedure Button1Click(Sender: TObject);
		procedure FormActivate(Sender: TObject);
	  procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
		procedure ListBox1Click(Sender: TObject);
		procedure ListBox2Click(Sender: TObject);
		procedure mnuSelectColoursClick(Sender: TObject);
		procedure mnuSelectSaveDirectoryClick(Sender: TObject);

    procedure SynEdit1Click(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    //procedure SynEdit1KeyPress(Sender: TObject; var Key: char);
    procedure CheckBox1Click(Sender: TObject);
    procedure btnExportToPlus42Click(Sender: TObject);
  procedure btnImportFromPlus42Click(Sender: TObject);
	procedure btnProgrammingModeClick(Sender: TObject);

  private
    // Standardized private variables
    FCarX: Integer;              // Current column (1-based)
    FCarY: Integer;              // Current line number (1-based)
    FThisString: string;         // Text of current line
    FLastLine: Integer;          // Last processed line for comparison
    FLineCount: integer;
    //FlineText: String;
    Alphacommands,
    LocalLabels,
    Arithmeticals: TStringDynArray;
    VarsList: TStringList;
    ss: String;
    ssCount: word;
    FSaveDirectory: String;
    // Private methods
    ConfigList: TStringList;
    Fsavekey: String;


  procedure CaretToPoint(X , Y: Integer);
  procedure ProcessLine;
		procedure ReplaceCurrentLineWithCursorRestore(const NewText: string);

    procedure UpdateCaretInfo(Data: PtrInt);
    procedure UpdateLabels;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1. btnImportFromPlus42Click( Sender: TObject);
var
  e: string;
  UniqueFileName: String;
  Timestamp: String;
  NewText: string;
  ErrMsg: string;
begin
  Timestamp := FormatDateTime('yyyymmdd_hhnnss', Now);
  UniqueFileName := ExtractFilePath(ParamStr(0)) + 'SavedSession_'
                                            + Timestamp + '.okken';
  SynEdit1.Lines.SaveToFile(UniqueFileName);
  if CopyFromPlus42(NewText, ErrMsg) then
  begin
    SynEdit1.Text := NewText;
    ShowMessage('Previous code saved to' + LineEnding + UniqueFileName);
  end
  else
  begin
    ShowMessage(ErrMsg);
  end;
end;
procedure TForm1. btnExportToPlus42Click( Sender: TObject);
var
  e: string;
begin
  PasteToPlus42(SynEdit1.Lines, e);
end;

procedure TForm1. btnProgrammingModeClick( Sender: TObject);
var
  e: string;
begin
  ToggleProgrammingMode(e);
end;

procedure TForm1.ProcessLine;
var
	 arr: TStringDynArray;
	 LA: SizeInt;
	 s , Aline: String;
	 a , x , y , i: Integer;
	 endChar: Char;
begin
  Aline :=  Synedit1.Lines[SynEdit1.CaretY -1] ;
  arr := splitString(Aline, ' ');
  LA := Length(arr);
  for i := 0 to Length(arr) - 1 do begin
    Trim(Arr[i]);
	end;

  case LA of
    1:  begin

        end;
       {  ONLY REJECT STRINGIFY IF ARR[0] = 'LBL'  }
    2:  if (arr[0] = 'LBL') and (arr[1] in LocalLabels) then
          Exit
        else if (arr[0] in Alphacommands)  then begin
          s := arr[1];
          s := StringReplace(s, '"', '', [rfReplaceAll]);
          VarsList.Add(s);
          s := ' "' + s + '"';
          s := arr[0] + s;
          //ReplaceCurrentLineWithCursorRestore(s)
          SynEdit1.CaretX := Length(s) + 2;
          x := Synedit1.CaretX;
          y := synedit1.CaretY;
          SynEdit1.Lines[Synedit1.CaretY - 1]  := s;
        end;
    3:  begin
          if (arr[0] in Alphacommands) and (arr[2] in LocalLabels)  then
            Exit
          else if (arr[0] in Alphacommands) then begin
	           s := arr[2];
	           s := StringReplace(s, '"', '', [rfReplaceAll]);
	           VarsList.Add(s);
	           s := '"' + s + '"';
             s := format('%s %s %s',[arr[0], arr[1], s]);
	           //s := arr[0] + ' ' + arr[1] + ' ' +  s;
	             SynEdit1.CaretX := Length(s) + 2;
	           x := Synedit1.CaretX;
	           y := synedit1.CaretY;
	           SynEdit1.Lines[Synedit1.CaretY - 1]  := s;
          end
    end;
  end;
end;


procedure TForm1.CaretToPoint(X, Y: Integer);
begin
  SynEdit1.CaretXY := Point(X, Y);

end;

procedure TForm1.ReplaceCurrentLineWithCursorRestore(const NewText: string);
var
  LineIndex: Integer;
  CaretX, CaretY: Integer;
begin

  CaretX := SynEdit1.CaretX;
  CaretY := SynEdit1.CaretY;

  LineIndex := CaretY - 1;

  if (LineIndex >= 0) and (LineIndex < SynEdit1.Lines.Count) then
  begin
    SynEdit1.Lines[LineIndex] := NewText;
    SynEdit1.CaretY := CaretY;
    if CaretX > Length(NewText) + 1 then
      SynEdit1.CaretX := Length(NewText) + 1
    else
      SynEdit1.CaretX := CaretX;
  end;
end;
 


procedure TForm1.FormCreate(Sender: TObject);

begin
  ConfigList := TStringlist.Create;
  ConfigureRPNHighlighter(SynEdit1, SynAnySyn1);
  LocalLabels := splitstring('A B C D E F G H I J a b c d e', ' ');
  Arithmeticals := SplitString('+ - / *', ' ');
  Alphacommands:= SplitString('CLV CLP XEQ GTO AVIEW VIEW STO STO+ STO- STO* ' +
                  'STO/ RCL RCL+ RCL- RCL* MVAR RCL/ LBL STO INPUT', ' ');
  FLastLine := -1;
  FCarX := 0;
  FCarY := 0;
  FThisString := '';
  FSaveDirectory := '';
  SynEdit1.Lines.Add('LBL CATS');
  SynEdit1.Lines.Add('LBL A');
  CaretToPoint(Length('lbl cats') + 1, 1);
  VarsList := TStringList.Create;
  ss := '';
  ssCount := 0;
  btnProgrammingMode.Caption := 'Toggle' + LineEnding
                                  + 'Programming' + LineEnding + 'Mode';
  FSavekey := 'save_directory';
  if not FileExists('config.conf') then begin
    ConfigList.Add('save_directory=C:\');
    ConfigList.SaveToFile('config.conf');
	end;

end;


procedure TForm1.ListBox1Click(Sender: TObject);
var
	 AItem: String;
begin
   if ListBox1.ItemIndex <> -1 then begin
     AItem := ListBox1.Items[ListBox1.ItemIndex];
     with SynEdit1 do begin
       if FCarY <= FLineCount then
          Lines.Insert(CaretY - 1, AItem)
       else
         SynEdit1.Lines.Add(AItem);
     end;
	 end;
end;

procedure TForm1.ListBox2Click(Sender: TObject);
var
	 AItem: String;
begin
   if ListBox1.ItemIndex <> -1 then begin
     AItem := ListBox2.Items[ListBox2.ItemIndex];
     with SynEdit1 do begin
       if FCarY <= FLineCount then
          Lines.Insert(CaretY - 1, AItem)
       else
         SynEdit1.Lines.Add(AItem);
     end;
	 end;
end;

procedure TForm1.mnuSelectColoursClick(Sender: TObject);
begin
  if ColorDialog1.Execute then begin

	end;

end;

procedure TForm1.mnuSelectSaveDirectoryClick(Sender: TObject);

begin

  if SelectDirectoryDialog1.Execute then begin
    FSaveDirectory := SelectDirectoryDialog1.Filename;

  end;
  ConfigList.Values[Fsavekey] := FSaveDirectory;
end;



procedure TForm1.FormActivate(Sender: TObject);
begin
  if FileExists('config.conf') then
    ConfigList.LoadFromFile('config.conf')
  else
    //

    Showmessage(ConfigList[0]);
  SelectDirectoryDialog1.InitialDir := ConfigList.Values[Fsavekey];
end;



procedure TForm1.btnSaveClick(Sender: TObject);
begin
  SaveDialog1.InitialDir := FSaveDirectory;
  if SaveDialog1.Execute then  begin
    SynEdit1.Lines.SaveToFile(SaveDialog1.FileName);
	 end;
end;

procedure TForm1.btnLoadClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := FSaveDirectory;
  if OpenDialog1.Execute then begin
    SynEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
	end;
end;

{ Updates all labels with current caret info }
procedure TForm1.UpdateLabels;
begin

end;

{ Handles text changes (typing, pasting, deleting) }
procedure TForm1.SynEdit1Change(Sender: TObject);
begin
  // Update immediately - this works for text changes
  FCarX := SynEdit1.CaretX;
  FCarY := SynEdit1.CaretY;

  if (FCarY >= 1) and (FCarY <= SynEdit1.Lines.Count) then
    FThisString := SynEdit1.Lines[FCarY - 1]
  else
    FThisString := '';

  UpdateLabels;
  FLineCount := Synedit1.Lines.Count;
end;

{ Handles mouse clicks }
procedure TForm1.SynEdit1Click(Sender: TObject);
begin
  // Update immediately - this works for mouse clicks
  FCarX := SynEdit1.CaretX;
  FCarY := SynEdit1.CaretY;

  if (FCarY >= 1) and (FCarY <= SynEdit1.Lines.Count) then
    FThisString := SynEdit1.Lines[FCarY - 1]
  else
    FThisString := '';

  UpdateLabels;
end;

{ Handles key releases }
procedure TForm1.SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // For arrow keys and other navigation keys
  if Key in [VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_PRIOR, VK_NEXT] then
  begin
    // Use QueueAsyncCall for arrow keys to get correct position

    Application.QueueAsyncCall(@UpdateCaretInfo, 0);
  end;
end;

{ Handles key presses }
procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    processLine  ;
    Application.QueueAsyncCall(@UpdateCaretInfo, 0);
end;


//===============================================================================

procedure TForm1.UpdateCaretInfo(Data: PtrInt);
var
  LineText: String;
begin
  // Get the text at cursor
  if SynEdit1.CaretY <= SynEdit1.Lines.Count then
    LineText := SynEdit1.Lines[SynEdit1.CaretY - 1]
  else
    LineText := '';

  // Update labels
  //Label1.Caption := IntToStr(SynEdit1.CaretX);
  //Label2.Caption := IntToStr(SynEdit1.CaretY);
  //Label3.Caption := LineText;
  FThisString := LineText;
end;

procedure TForm1.SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  // This ONE event catches EVERYTHING (arrow keys, mouse clicks, typing, etc.)
  if (scCaretX in Changes) or (scCaretY in Changes) then
    Application.QueueAsyncCall(@UpdateCaretInfo, 0);
end;
procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  // Optional: Show status
  //if CheckBox1.Checked then
  //  SynEdit1.Hint := 'UPPERCASE mode ON'
  //else
  //  SynEdit1.Hint := 'UPPERCASE mode OFF';
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  UniqueFileName: String;
  Timestamp: String;

begin
  Timestamp := FormatDateTime('yyyymmdd_hhnnss', Now);
  UniqueFileName := ExtractFilePath(ParamStr(0))
                    + 'SavedSession_' + Timestamp + '.okken';
  SynEdit1.Lines.SaveToFile(UniqueFileName);
  ConfigList.SaveToFile('config.conf');
  //===================================================================




  ConfigList.Free;
  VarsList.Free;
end;





end.
