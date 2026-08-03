unit Unit1;

{$mode objfpc}{$H+}

interface

uses
   Classes , SysUtils , Types , Forms , Controls , Graphics , Dialogs ,
	 StdCtrls , StrUtils
   ;

type

	 { TForm1 }

   TForm1 = class(TForm)
			Button1: TButton;
			Memo1: TMemo;
			procedure Button1Click(Sender: TObject);
   private

   public

   end;

var
   Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
	 SL: TStringList;
	 i: Integer;
	 Aline: String;
	 arr: TStringDynArray;
begin
   SL := TStringList.create;
   SL.LoadFromFile('C:\Users\Owner\hp42scommands.txt');
   Memo1.lines.BeginUpdate;
   For i := 0 to SL.Count - 1 do begin
     Aline := SL[i];
     arr := SplitString(ALine, ',');
     memo1.Lines.Add(arr[0]);



	 end;

	 Memo1.Lines.EndUpdate ;
   Memo1.Lines.SaveToFile('hp42Scommands2.txt');
end;

end.

