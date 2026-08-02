unit NewRPNEditorU;

{$mode objfpc}{$H+}

interface

uses
   Classes , SysUtils , Forms , Controls , Graphics , Dialogs , StdCtrls ,
	 ExtCtrls , SynEdit, SynEditTypes, LCLType
   ;

type

	 { TForm1 }

   TForm1 = class(TForm)
			Label1: TLabel;
			Label2: TLabel;
			Label3: TLabel;
			SynEdit1: TSynEdit;
			Timer1: TTimer;

	 procedure FormCreate(Sender: TObject);
	 procedure SynEdit1Click(Sender: TObject);

   procedure Timer1Timer(Sender: TObject);
   	procedure SynEdit1Change(Sender: TObject);

		procedure SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
   private
    FCarX , FCarY: Integer;
    FThisString: String;
    FLastLine: Integer;
    FCurrentLine: string;
    FCurrentLineNumber: Integer;
    procedure UpdateCurrentLineInfo(Data: PtrInt);
		procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
			 );
  //procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
		procedure UpdateCurrentLine;


   public

   end;

var
   Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);


begin
   FCarX := SynEdit1.CaretX;
   FcarY := SynEdit1.CaretY;
   Label1.Caption := IntToStr(FCarX);       //1 based
   Label2.Caption := IntToStr(FCarY);
   Label3.Caption := FThisString;


end;



procedure TForm1.FormCreate(Sender: TObject);
begin
   FLastLine := 0;
end;

procedure TForm1.UpdateCurrentLine;
begin
  FCarY := SynEdit1.CaretY;
  // Ensure the line index is valid before reading
  if (FCarY >= 1) and (FCarY <= SynEdit1.Lines.Count) then
    FThisString := SynEdit1.Lines[FCarY - 1]
  else
    FThisString := '';
end;

procedure TForm1.SynEdit1Change(Sender: TObject);
begin
  UpdateCurrentLine; // Updates immediately as you type text
end;

procedure TForm1.SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  UpdateCurrentLine; // Updates when using arrow keys
end;
procedure TForm1.UpdateCurrentLineInfo(Data: PtrInt);
begin
  FCurrentLineNumber := SynEdit1.CaretY;
  if FCurrentLineNumber > 0 then
    FCurrentLine := SynEdit1.Lines[FCurrentLineNumber - 1];

  // Do something with the line text
  // For example, show it in a label:
  Label1.Caption := Format('Line %d: %s', [FCurrentLineNumber, FCurrentLine]);
  end;



procedure TForm1.SynEdit1Click(Sender: TObject);
begin
  FCarY := SynEdit1.CaretY;

  if (FCarY >= 1) and (FCarY <= SynEdit1.Lines.Count) then
    FThisString := SynEdit1.Lines[FCarY - 1]
  else
    FThisString := '';
end;


procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Check if an arrow key was pressed
  if Key in [VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT] then
  begin
    // We need to use Application.QueueAsyncCall to get the updated caret position
    Application.QueueAsyncCall(@UpdateCurrentLineInfo, 0);
  end;
end;


end.

