unit NewRPNEditorU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils , Types, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, SynEdit, SynEditTypes , SynHighlighterAny, LCLType, StrUtils

  ;

type

	{ TForm1 }

  TForm1 = class(TForm)
		 Button1: TButton;
		 Button2: TButton;
		 CheckBox1: TCheckBox;
		 Label1: TLabel;
		 Label2: TLabel;
		 Label3: TLabel;
		 ListBox1: TListBox;
		 ListBox2: TListBox;
		 Memo1: TMemo;
		Panel1: TPanel;
		SynAnySyn1: TSynAnySyn;
    SynEdit1: TSynEdit;
    Timer1: TTimer;

		procedure Button1Click(Sender: TObject);
		procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure ListBox1Click(Sender: TObject);
		procedure ListBox2Click(Sender: TObject);
    procedure SynEdit1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure SynEdit1KeyPress(Sender: TObject; var Key: char);
    procedure CheckBox1Click(Sender: TObject);

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


    // Private methods

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
  //ShowMessage(arr[0] + LineEnding + arr[1]);
  LA := Length(arr);
  for i := 0 to Length(arr) - 1 do begin
    Trim(Arr[i]);
	end;

  case LA of
    1:  begin

        end;
    2:  if (arr[0] in Alphacommands) and (arr[1] in LocalLabels) then
          Exit
        else if (arr[0] in Alphacommands) then begin
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
          if (arr[0] in Alphacommands) and (arr[2] in LocalLabels) then
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
  // Save cursor position
  CaretX := SynEdit1.CaretX;
  CaretY := SynEdit1.CaretY;

  LineIndex := CaretY - 1;

  if (LineIndex >= 0) and (LineIndex < SynEdit1.Lines.Count) then
  begin
    SynEdit1.Lines[LineIndex] := NewText;

    // Restore cursor position (keep it on the same line)
    SynEdit1.CaretY := CaretY;
    // Make sure X doesn't exceed new line length
    if CaretX > Length(NewText) + 1 then
      SynEdit1.CaretX := Length(NewText) + 1
    else
      SynEdit1.CaretX := CaretX;
  end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  LocalLabels := splitstring('A B C D E F G H I J a b c d e', ' ');
  Arithmeticals := SplitString('+ - / *', ' ');
  Alphacommands:= SplitString('CLV CLP XEQ GTO AVIEW VIEW STO STO+ STO- STO* ' +
                  'STO/ RCL RCL+ RCL- RCL* MVAR RCL/ LBL STO INPUT', ' ');
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
  SynEdit1.Lines.Add('LBL CATS');
  SynEdit1.Lines.Add('LBL A');
  CaretToPoint(Length('lbl cats') + 1, 1);
  VarsList := TStringList.Create;
  ss := '';
  ssCount := 0;
    SynAnySyn1 := TSynAnySyn.Create(Self);
  SynEdit1.Highlighter := SynAnySyn1;

  // Add keywords programmatically
  SynAnySyn1.KeyWords.Clear;
  SynAnySyn1.KeyWords.Add('LBL');
  SynAnySyn1.KeyWords.Add('world');
  SynAnySyn1.KeyWords.Add('test');

  SynAnySyn1.Enabled := True;
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
begin
  ss := ss + ListBox2.Items[ListBox2.ItemIndex];
  SynEdit1.lines.add(ss);
end;



procedure TForm1.Button1Click(Sender: TObject);
var
	 alist: TStringDynArray;
	 s: String;
	 I , j: Integer;
begin
 alist := SplitString('48, 49, 50, 51, 52, 53, 54, 55, 56, 57', ',');
 for I := 0 to ListBox1.Items.Count - 1 do begin
   s := ListBox1.Items[i];
   for j := 0 to Length(s) - 1 do begin
     if IntToStr(Ord(s[j])) in alist then
      ShowMessage(s);

		 end;
	 end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   Memo1.Lines.Add(ss);
   ss := '';

end;

{ Updates all labels with current caret info }
procedure TForm1.UpdateLabels;
begin
  Label1.Caption := IntToStr(FCarX);
  Label2.Caption := IntToStr(FCarY);
  Label3.Caption :=  FThisString;
end;



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
  ;
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
  Label1.Caption := IntToStr(SynEdit1.CaretX);
  Label2.Caption := IntToStr(SynEdit1.CaretY);
  Label3.Caption := LineText;
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
  if CheckBox1.Checked then
    SynEdit1.Hint := 'UPPERCASE mode ON'
  else
    SynEdit1.Hint := 'UPPERCASE mode OFF';
end;
procedure TForm1.SynEdit1KeyPress(Sender: TObject; var Key: char);
var
	 S: String;
begin
   // Key := UpCase(Key);
   // { Key is '+' for testing }
   // S := FThisString;
   // s := s + key  ;
   // if (key in Arithmeticals) and (not Trim(s).Contains(' ')) and
   //     (length(Trim(s)) > 1) Then begin
   //   //showMessage(FThisString);
   //   With synedit1 do begin
   //      CaretX := Length(s) + 1;
	  //     Lines[FCarY - 1]  := s;
   //      if CaretY <Lines.Count then
   //         CaretY := CaretY + 1;
	  //     CaretX := 1;
   //      CaretY := CaretY + 1;
			//end;
   //   Key := #0;
   // end;

end;





end.
