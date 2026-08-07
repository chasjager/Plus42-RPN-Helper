unit Hash;
{$mode ObjFPC}{$H+}


interface

uses
  DCPsha256, Classes, SysUtils;


function VerifySelf(const HashFilePath: string): boolean;
function VerifySelf: boolean;


implementation

function VerifySelf(const HashFilePath: string): boolean;
var
  Hash: TDCP_sha256;
  Stream: TFileStream;
  Digest: array[0..31] of byte;
  i: Integer;
  CurrentHash, StoredHash: string;
  SL: TStringList;
begin
  Result := False;

  // 1. Calculate current EXE hash
  Hash := TDCP_sha256.Create(nil);
  try
    Hash.Init;
    Stream := TFileStream.Create(ParamStr(0), fmOpenRead);
    try
      Hash.UpdateStream(Stream, Stream.Size);
    finally
      Stream.Free;
    end;
    Hash.Final(Digest);

    CurrentHash := '';
    for i := 0 to 31 do
      CurrentHash := CurrentHash + IntToHex(Digest[i], 2);
    CurrentHash := UpperCase(CurrentHash);
  finally
    Hash.Free;
  end;

  // 2. Read stored hash from file
  SL := TStringList.Create;
  try
    SL.LoadFromFile(HashFilePath);
    StoredHash := UpperCase(Trim(SL[0]));
  finally
    SL.Free;
  end;

  // 3. Compare
  Result := (CurrentHash = StoredHash);
end;
function VerifySelf: boolean;
begin
  Result := VerifySelf('C:\Hashes\' + ExtractFileName(ParamStr(0)) + '.hash');
end;
end.




