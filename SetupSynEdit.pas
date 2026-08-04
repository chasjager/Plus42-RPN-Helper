unit SetupSynEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, SynEdit, SynHighlighterAny;

// Declare the procedure so your main form can call it
procedure ConfigureRPNHighlighter(SynEdit: TSynEdit; SynAnySyn: TSynAnySyn);

implementation

procedure ConfigureRPNHighlighter(SynEdit: TSynEdit; SynAnySyn: TSynAnySyn);
begin
  if not Assigned(SynEdit) or not Assigned(SynAnySyn) then Exit;

  // Link highlighter to SynEdit
  SynEdit.Highlighter := SynAnySyn;

  // 1. First Group: Standard Keywords (e.g., White text on Blue background)
  SynAnySyn.KeyWords.AddCommaText('LBL, END');
  SynAnySyn.KeyAttri.Foreground := clWhite;
  SynAnySyn.KeyAttri.Background := clBlue;
  SynAnySyn.KeyAttri.Style := [fsBold];

  // 2. Second Group: Objects/Commands (e.g., Yellow text on Green background)
  SynAnySyn.Objects.AddCommaText('RCL, RCL+, RCL-, RCL*, RCL/');
  SynAnySyn.Objects.Add('read');
  SynAnySyn.ObjectAttri.Foreground := clYellow;
  SynAnySyn.ObjectAttri.Background := clGreen;
  SynAnySyn.ObjectAttri.Style := [];

  // 3. Third Group: Constants (e.g., Black text on Red background)
  SynAnySyn.Constants.Add('true');
  SynAnySyn.Constants.Add('false');
  SynAnySyn.ConstantAttri.Foreground := clBlack;
  SynAnySyn.ConstantAttri.Background := clRed;
  SynAnySyn.ConstantAttri.Style := [fsItalic];
end;

end.
