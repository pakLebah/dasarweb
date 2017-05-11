program webTest;

uses 
  SysUtils, StrUtils, webUtils;

// menerjemahkan teks normal ke teks html (berkode &)
function htmlEncode(const aText: string): string;
begin
  result := aText;
  // penggantian tanda & harus dilakukan paling awal
  result := stringReplace(result,'&','&amp;' ,[rfReplaceAll]);
  result := stringReplace(result,'"','&quot;',[rfReplaceAll]);
  result := stringReplace(result,'<','&lt;'  ,[rfReplaceAll]);
  result := stringReplace(result,'>','&gt;'  ,[rfReplaceAll]);
  log.debug('#'+{$I %LINE%}+': @htmlEncode '+aText+' ⇒ '+result);
end;

// menerjemahkan teks http (berkode %) ke teks normal
function httpDecode(const encodedText: string): string;
var
  b: byte;
  c: word;
  l,p: integer;
  s,r,res: string;
begin
  // ganti seluruh tanda + menjadi spasi
  res := stringReplace(encodedText,'+',' ',[rfReplaceAll]);
  l := length(res);
  p := 1;
  // cari tanda % satu per satu
  repeat
    p := posEx('%', res, p);
    if p > 0 then 
    begin
      s := copy(res, p+1, 2);
      val('$'+s,b,c);  // % dlm hexa
      // ganti tanda % menjadi huruf yg sesuai
      if c = 0 then 
      begin
        r := chr(b);  // hexa ke huruf
        res := stringReplace(res,'%'+s,r,[rfIgnoreCase]);
      end;
      p += 1;
    end;
  until (p = 0) or (p > l);
  result := res;
  log.debug('#'+{$I %LINE%}+': @httpDecode '+encodedText+' ⇒ '+res);
end;

// mengambil nilai dari pasangan key=value dalam data masukan web
function getValue(const aKey, ofString: string; const delimiter: string = '&'): string;
var
  pStart, pStop: integer;
  s: string;
begin
  s := lowerCase(ofString);
  pStart := pos(lowerCase(aKey)+'=', s);
  if pStart > 0 then
  begin
    pStop := posEx(delimiter, s, pStart);
    pStart := pStart + length(aKey) + 1;
    if pStop = 0 then pStop := length(s) + 1;
    result := copy(ofString, pStart, pStop-pStart);
  end
  else result := '';
  log.debug('#'+{$I %LINE%}+': @getValue '+aKey+' = '+result);
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [string]
procedure webRead(var str: string; const newLine: boolean = false);
var
  s: string;
begin
  // baca data masukan
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then str := s;
  // tampilan antarmuka masukan
  write(inputText(htmlEncode(httpDecode(str))));
  if newLine then writeln(BR) else writeln;
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [integer]
procedure webRead(var int: integer; const newLine: boolean = false);
var
  s: string;
begin
  // baca data masukan
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then int := strToInt(s);
  // tampilan antarmuka masukan
  write(inputNumber(int));
  if newLine then writeln(BR) else writeln;
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [boolean]
procedure webRead(var bool: boolean; const aCaption: string; const newLine: boolean = false);
var
  s: string;
begin
  // baca data masukan
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if webHasInput then bool := (s = 'true');
  // tampilan antarmuka masukan
  write(inputBool(aCaption,bool));
  if newLine then writeln(BR) else writeln;
end;

// akhiran ln untuk membuat baris baru setelah antarmuka masukan
procedure webReadLn(var str: string);
begin
  webRead(str,true);
end;

procedure webReadLn(var int: integer);
begin
  webRead(int,true);
end;

procedure webReadLn(var bool: boolean; const aCaption: string);
begin
  webRead(bool,aCaption,true);
end;
// gabungkan antarmuka masukan dan pembacaan data masukan [memo]
procedure webReadMemo(var str: string; const newLine: boolean = true);
var
  s: string;
begin
  // baca data masukan
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then str := s;
  // tampilan antarmuka masukan
  write(inputMemo(htmlEncode(httpDecode(str))));
  if newLine then writeln(BR) else writeln;
end;

// menulis isi laman
procedure writeContent;
var
  m: string  = '';
  s: string  = '';
  i: integer = -1;
  b: boolean = true;
begin
  // tampilkan antarmuka masukan
  writeln(Po,formOpen(ExtractFilename(ParamStr(0)),true));
  write(putLabel('String: '));      webReadln(s);
  write(putLabel('Number: '));      webReadln(i);
  write(putLabel('Boolean: ',''));  webReadln(b,'Yes, I agree');
  write(putLabel('Memo: '));        webReadMemo(m);
  writeln(separator);
  writeln(putSpace,inputButton(' SUBMIT '),BR);
  writeln(FORMc,Pc,HR);

  // tampilkan masukan, jika ada
  if webHasInput then
  begin
    writeln(Po,span('Accepted input:','bold'),BR);
    writeln('Input: ' ,switch(webInputs ='','[empty]',webInputs),BR);
    writeln('Query: ' ,switch(webQueries='','[empty]',webQueries),BR);
    writeln(Pc,HR);
  end;
  log.debug('#'+{$I %LINE%}+': [main.writeContent] done.');
end;

(*** program utama ***)
begin
  writeHeader('Read Input','test.css');
  writeTitle('READ INPUT',3);
  allWebInput := readAllWebInput;
  writeContent;
  writeFooter;
end.