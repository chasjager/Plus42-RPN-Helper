unit NewRPNEditorU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, SynEdit, SynEditTypes, LCLType;

type
  TForm1 = class(TForm)
    Label1: TLabel;  // For CaretX
    Label2: TLabel;  // For CaretY
    Label3: TLabel;  // For current line text
    SynEdit1: TSynEdit;
    Timer1: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure SynEdit1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);

  private
    // Standardized private variables
    FCarX: Integer;              // Current column (1-based)
    FCarY: Integer;              // Current line number (1-based)
    FThisString: string;         // Text of current line
    FLastLine: Integer;          // Last processed line for comparison

    // Private methods
    procedure UpdateCaretInfo(Data: PtrInt);
    procedure UpdateLabels;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FLastLine := -1;
  FCarX := 0;
  FCarY := 0;
  FThisString := '';

  Label1.Caption := 'Col: 0';
  Label2.Caption := 'Line: 0';
  Label3.Caption := '';

  // Timer is optional - disabled by default
  Timer1.Enabled := False;
  Timer1.Interval := 50;
end;

{ Updates all labels with current caret info }
procedure TForm1.UpdateLabels;
begin
  Label1.Caption := IntToStr(FCarX);
  Label2.Caption := IntToStr(FCarY);
  Label3.Caption := FThisString;
end;

{ Called via QueueAsyncCall to get accurate caret position }
//procedure TForm1.UpdateCaretInfo(Data: PtrInt);
//begin
//  // Get current caret position
//  FCarX := SynEdit1.CaretX;
//  FCarY := SynEdit1.CaretY;
//
//  // Get current line text if valid
//  if (FCarY >= 1) and (FCarY <= SynEdit1.Lines.Count) then
//    FThisString := SynEdit1.Lines[FCarY - 1]
//  else
//    FThisString := '';
//
//  // Update labels
//  UpdateLabels;
//end;

{ Timer fallback - optional }
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // Get current caret position directly
  FCarX := SynEdit1.CaretX;
  FCarY := SynEdit1.CaretY;

  if (FCarY >= 1) and (FCarY <= SynEdit1.Lines.Count) then
    FThisString := SynEdit1.Lines[FCarY - 1]
  else
    FThisString := '';

  UpdateLabels;
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
  // For Tab, Enter, etc.
  if Key in [VK_TAB, VK_RETURN] then
  begin
    Application.QueueAsyncCall(@UpdateCaretInfo, 0);
  end;
end;

{ Handles all status changes - most comprehensive }
//procedure TForm1.SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
//begin
//  // This catches everything - arrow keys, mouse clicks, text changes, etc.
//  if (scCaretX in Changes) or (scCaretY in Changes) or (scModified in Changes) then
//  begin
//    Application.QueueAsyncCall(@UpdateCaretInfo, 0);
//  end;
//end;
//===============================================================================

procedure TForm1.UpdateCaretInfo(Data: PtrInt);
var
  LineText: string;
begin
  // Get the text at cursor
  if SynEdit1.CaretY <= SynEdit1.Lines.Count then
    LineText := SynEdit1.Lines[SynEdit1.CaretY - 1]
  else
    LineText := '';

  // Update labels
  Label1.Caption := IntToStr(SynEdit1.CaretX);
  Label2.Caption := IntToStr(SynEdit1.CaretY);
  Label3.Caption := LineText;
end;

procedure TForm1.SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  // This ONE event catches EVERYTHING (arrow keys, mouse clicks, typing, etc.)
  if (scCaretX in Changes) or (scCaretY in Changes) then
    Application.QueueAsyncCall(@UpdateCaretInfo, 0);
end;






end.
