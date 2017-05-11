unit webUtils;

{$MODE OBJFPC} {$H+} {$J-}

interface

uses
  EventLog;

const
  // tanda elemen html
  LE       = LineEnding;  // baris baru asli
  Po       = '<p>';       // buka paragraf
  Pc       = '</p>';      // tutup paragraf
  BR       = '<br/>';     // baris baru
  HR       = '<hr/>';     // garis horisontal
  DIVc     = '</div>';    // tutup div
  FORMc    = '</form>';   // tutup form
  TABLEc   = '</table>';  // tutup tabel
  // nama berkas catatan
  LOG_FILE = '/home/cabox/cgi.log';
  // alias konstanta sbg pasangan fungsi
  paraClose  = '</p>';
  divClose   = '</div>';
  formClose  = '</form>';
  tableClose = '</table>';
  
var
  log        : TEventLog;        // pencatatan
  inputIndex : integer = 0;      // penghitung antarmuka masukan
  webInputs  : string  = '';     // data input http
  webQueries : string  = '';     // data query http
  webCookies : string  = '';     // data kue http
  allWebInput: string  = '';     // gabungan seluruh data masukan
  webHasInput: boolean = false;  // status ketersediaan masukan

type
  TArrayOfString = array of string;

// penyusun bagian utama html
procedure writeHeader(const aTitle: string; const loadCSS: string = ''; const loadJS: string = '');
procedure writeFooter(const loadCSS: string = ''; const loadJS: string = '');
procedure writeTitle(const aTitle: string; const aLevel: integer = 1; const aClass: string = '');
procedure writeScript(const aScript: string);

// penyusun elemen html
function spacer(const aClass: string = 'spacer'; const aID: string = ''): string;
function separator(const aClass: string = 'separator'; const aID: string = ''): string;
function block(const aText: string; const aClass: string = ''; const aID: string = ''): string;
function span(const aText: string; const aClass: string = ''; const aID: string = ''): string;
function paraOpen(const aClass: string = ''; const aID: string = ''): string;
function divOpen(const aClass: string = ''; const aID: string = ''): string;
function listOpen(const isOrdered: boolean; const aClass: string = ''; const aID: string = ''): string;
function listItem(const aText: string): string;
function listClose: string;
function tableOpen(const headers: TArrayOfString; const cols: integer = 0; const aClass: string = ''; const aID: string = ''): string;
function tableRow(const cells: TArrayOfString; const cols: integer = 0): string;

// mengubah isian masukan dgn kode javascript
function jsFillValue(const aID: string; const aValue: string): string;
function jsFillValue(const aID: string; const aValue: integer): string;
function jsFillValue(const aID: string; const aValue: double): string;
function jsFillValue(const aID: string; const aValue: boolean): string;
function jsFillMemo(const aID: string; const aValue: string): string;
//function jsFillVar(const aID: string; const aValue: string): string;
//function jsFillOption(const aID: string; const aValue: integer): string;
//function jsFillSelect(const aID: string; const aValue: integer): string;

// penyusun antarmuka masukan
function formOpen(const action: string; const isPost: boolean = false): string;
function putSpace(const aText: string = ''): string;
function putLabel(const aLabel: string; const forID: string = '_'): string;
function putVar(const aKey, aValue: string): string;
function inputVar(const aValue: string): string;
function inputText(const aValue: string = ''): string;
function inputNumber(const aValue: integer = -1): string;
function inputFloat(const aValue: double = -1): string;
function inputBool(const aCaption: string; const aValue: boolean = false): string;
function inputMemo(const aValue: string = ''): string;
function inputOption(const options: TArrayOfString; const checked: integer = -1; const newLine: boolean = false): string;
function inputSelect(const items: TArrayOfString; const selected: integer = -1; const isMultiple: boolean = false): string;
function inputButton(const aCaption: string; const action: string = ''; const isReset: boolean = false): string;

// fungsi untuk membaca data masukan web
function readWebInput: string;
function readWebQuery: string;
function readWebCookie: string;
function readAllWebInput(const includeCookies: boolean = false): string;

// membaca data masukan dan menyusun antarmuka masukan
procedure webRead(var str: string; const newLine: boolean = false);
procedure webRead(var int: integer; const newLine: boolean = false);
procedure webRead(var float: double; const newLine: boolean = false);
procedure webRead(var bool: boolean; const aCaption: string; const newLine: boolean = false);
procedure webReadLn(var str: string);
procedure webReadLn(var int: integer);
procedure webReadLn(var float: double);
procedure webReadLn(var bool: boolean; const aCaption: string);
procedure webReadVar(var aValue: string);
procedure webReadMemo(var str: string; const newLine: boolean = true);
procedure webReadOption(var checked: integer; const options: TArrayOfString; const newLine: boolean = true);
procedure webReadSelect(var selected: integer; const items: TArrayOfString; const newLine: boolean = true);
procedure webReadButton(var clicked: boolean; const aCaption: string; const newLine: boolean = false;
                        const action: string = ''; const isReset: boolean = false);

// fungsi bantuan untuk baca/tulis data http/html
function createCookie(const aName, aValue: string; const aDuration: integer = 0): string;
function htmlEncode(const aText: string): string;
function httpDecode(const encodedText: string): string;

// fungsi bantuan olah data
function generateGUID: string;
function strings(const arrayOfString: array of string): TArrayOfString;
function switch(const condition: boolean; const ifTrue, ifFalse: string): string;
function hasKey(const aKey, ofString: string; const delimiter: string = '='): boolean;
function getValue(const aKey, ofString: string; const delimiter: string = '&'; const equalizer: string = '='): string;

implementation

uses
  SysUtils, StrUtils, DateUtils;

var
  start: TDateTime;             // untuk awal pewaktuan
  isLogged: boolean = false;    // pengaturan pencatatan unit
  listOrdered: boolean = true;  // penanda jenis list html yg sedang dibuat

// membuat guid
function generateGUID: string;
var
  guid: TGUID;
begin
  repeat sleep(1) until createGUID(guid) = 0;
  result := guidToString(guid);
end;

// memudahkan membuat deret string
function strings(const arrayOfString: array of string): TArrayOfString;
var
  i: integer;
begin
  setLength(result,high(arrayOfString)+1);
  for i := 0 to high(arrayOfString) do result[i] := arrayOfString[i];
end;

// uji kondisi 2 teks
function switch(const condition: boolean; const ifTrue, ifFalse: string): string;
begin
  if condition then result := ifTrue else result := ifFalse;
end;

// mengambil kata kunci dari teks key=value
function hasKey(const aKey, ofString: string; const delimiter: string = '='): boolean;
begin
  result := pos(lowerCase(aKey)+delimiter, lowerCase(ofString)) > 0;
end;

// mengambil nilai dari teks key=value
function getValue(const aKey, ofString: string; const delimiter: string = '&'; const equalizer: string = '='): string;
var
  pStart, pStop: integer;
  s: string;
begin
  s := lowerCase(ofString);
  // cari tanda kesamaan
  pStart := pos(lowerCase(aKey)+equalizer, s);
  if pStart > 0 then
  begin
    // cari tanda pemisah
    pStop := posEx(delimiter, s, pStart);
    pStart := pStart + length(aKey) + 1;
    // jika tak ada pemisah, ambil sampai akhir
    if pStop = 0 then pStop := length(s) + 1;
    result := copy(ofString, pStart, pStop-pStart);
  end
  else result := '';
end;

// menyusun kue http; harus dipanggil sebelum writeHeader()
function createCookie(const aName, aValue: string; const aDuration: integer = 0): string;
var
  utc: TDateTime;
begin
  result := 'set-cookie: '+aName+'='+aValue+'; SameSite=Strict; HTTPOnly';
  if aDuration > 0 then
  begin
    utc := incMinute(now,GetLocalTimeOffset + aDuration);
    result += formatDateTime('; "Expires="ddd, dd mmm yyyy hh:nn:ss "GMT"',utc);
  end;
end;

// menerjemahkan teks normal ke teks html (berkode &)
function htmlEncode(const aText: string): string;
begin
  result := aText;
  // penggantian tanda & harus dilakukan paling awal
  result := stringReplace(result,'&','&amp;' ,[rfReplaceAll]);
  result := stringReplace(result,'"','&quot;',[rfReplaceAll]);
  result := stringReplace(result,'<','&lt;'  ,[rfReplaceAll]);
  result := stringReplace(result,'>','&gt;'  ,[rfReplaceAll]);
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
      // ganti angka % menjadi huruf yg sesuai
      if c = 0 then 
      begin
        r := chr(b);  // hexa ke huruf
        res := stringReplace(res,'%'+s,r,[rfIgnoreCase]);
      end;
      p += 1;
    end;
  until (p = 0) or (p > l);
  result := res;
end;

// menulis kepala html
procedure writeHeader(const aTitle: string; const loadCSS: string = ''; const loadJS: string = '');
begin
  start := now;  // awal pewaktuan
  writeln('content-type: text/html;');
  writeln;  // penting!
  writeln('<!DOCTYPE html>');
  writeln('<html><head>');
  writeln('<meta charset="utf-8">');
  writeln('<meta name="viewport" content="width=device-width,initial-scale=1">');
  if loadCSS <> '' then writeln('<link rel="stylesheet" href="',loadCSS,'">');
  if loadJS  <> '' then writeln('<script src="',loadJS,'"></script>');
  writeln('<title>',aTitle,'</title>');
  writeln('</head><body>');
  writeln('<!-- isi laman mulai dari sini -->');
  if isLogged then log.debug('#'+{$I %LINE%}+': [webUtils.writeHeader] done.');
end;

// menulis kaki html
procedure writeFooter(const loadCSS: string = ''; const loadJS: string = '');
var
  elapse: integer;
begin
  if loadCSS <> '' then writeln('<link rel="stylesheet" href="',loadCSS,'">');
  if loadJS  <> '' then writeln('<script src="',loadJS,'"></script>');
  elapse := trunc(milliSecondSpan(start,now));  // akhir pewaktuan
  writeln('<!-- isi laman berhenti di sini -->');
  writeln('<p align="right"><small>This page is served in ',elapse,' ms.</small></p>');
  writeln('</body></html>');
  if isLogged then log.debug('#'+{$I %LINE%}+': [webUtils.writeFooter] done.');
end;

// menulis judul laman
procedure writeTitle(const aTitle:string; const aLevel:integer=1; const aClass:string='');
begin
  if aClass <> '' then
    writeln('<h',aLevel,' class="',aClass,'">',aTitle,'</h',aLevel,'>')
  else
    writeln('<h',aLevel,'>',aTitle,'</h',aLevel,'>');
  if isLogged then log.debug('#'+{$I %LINE%}+': [webUtils.writeTitle] done.');
end;

// menyisipkan kode javascript ke dokumen html
procedure writeScript(const aScript: string);
begin
  writeln('<script>',LE,aScript,'</script>',LE);
end;

// baca data dari masukan baku (std-in)
function readWebInput: string;
var
  ch: char;
begin
  result := '';
  while not EOF(input) do
  begin
    read(ch);
    result += ch;
  end;
end;

// baca data query dari variabel sistem
function readWebQuery: string;
begin
  result := GetEnvironmentVariable('QUERY_STRING');
end;

// baca data kue dari variabel sistem
function readWebCookie: string;
begin
  result := GetEnvironmentVariable('HTTP_COOKIE');
end;

// baca dan gabungkan seluruh data masukan web
function readAllWebInput(const includeCookies: boolean = false): string;
begin
  webInputs   := readWebInput;
  webQueries  := readWebQuery;
  webHasInput := (webQueries <> '') or (webInputs <> '');
  result      := switch(webQueries='', switch(webInputs='','',webInputs),
                 switch(webInputs='', webQueries, webQueries+'&'+webInputs));
  if includeCookies then
  begin
    webCookies := readWebCookie;
    result     := switch(webCookies='', switch(result='','',result),
                  switch(result='', webCookies, webCookies+'&'+result));
  end;
  webHasInput := (result <> '');
end;

// membuat garis pemisah vertical
function spacer(const aClass: string = 'spacer'; const aID: string = ''): string;
begin
  result := '<span'+switch(aClass='','',' class="'+aClass+'"')+
                    switch(aID='','',' id="'+aID+'"')+'> │ </span>';
end;

// membuat garis pemisah horisontal
function separator(const aClass: string = 'separator'; const aID: string = ''): string;
begin
  result := '<hr'+switch(aClass='','',' class="'+aClass+'"')+
                  switch(aID='','',' id="'+aID+'"')+'/>';
end;

// membuat tanda kutipan
function block(const aText: string; const aClass: string = ''; const aID: string = ''): string;
begin
  result := '<blockquote'+
              switch(aClass='','',' class="'+aClass+'"')+
              switch(aID='','',' id="'+aID+'"')+
            '>'+aText+'</blockquote>';
end;

// membuat tanda span
function span(const aText: string; const aClass: string = ''; const aID: string = ''): string;
begin
  result := '<span'+
              switch(aClass='','',' class="'+aClass+'"')+
              switch(aID='','',' id="'+aID+'"')+
            '>'+aText+'</span>';
end;

// membuat bukaan paragraf
function paraOpen(const aClass: string = ''; const aID: string = ''): string;
begin
  result := '<p'+switch(aClass='','',' class="'+aClass+'"')+
                 switch(aID='','',' id="'+aID+'"')+'>';
end;

// menulis bukaan tanda div
function divOpen(const aClass: string = ''; const aID: string = ''): string;
begin
  result := '<div'+switch(aClass='','',' class="'+aClass+'"')+
                   switch(aID='','',' id="'+aID+'"')+'>';  
end;

// membuat bukaan daftar
function listOpen(const isOrdered: boolean; const aClass: string = ''; const aID: string = ''): string;
begin
  listOrdered := isOrdered;
  result := switch(listOrdered,'<ol','<ul')+
            switch(aClass='','',' class="'+aClass+'"')+
            switch(aID='','',' id="'+aID+'"')+'>';
end;

// membuat item daftar
function listItem(const aText: string): string;
begin
  result := '<li>'+aText+'</li>';
end;

// membuat tutupan daftar
function listClose: string;
begin
  result := switch(listOrdered,'</ol>','</ul>');
end;

// membuat bukaan tabel
function tableOpen(const headers: TArrayOfString; const cols: integer = 0;
                   const aClass: string = ''; const aID: string = ''): string;
var
  i: integer;
begin
  result := '<table'+
              switch(aClass='','',' class="'+aClass+'"')+
              switch(aID='','',' id="'+aID+'"')+'>'+LE;
  if length(headers) > 0 then
  begin
    result += '<tr>';
    for i := 0 to high(headers) do
      if (cols > 0) and (i = high(headers)) then
        result += '<th colspan="'+intToStr(cols-high(headers))+'">'+headers[i]+'</th>'
      else
        result += '<th>'+headers[i]+'</th>';
    result += '</tr>';
  end;
end;

// membuat baris tabel
function tableRow(const cells: TArrayOfString; const cols: integer = 0): string;
var
  i: integer;
begin
  result := '';
  if length(cells) > 0 then
  begin
    result := '<tr>';
    for i := 0 to high(cells) do
      if (cols > 0) and (i = high(cells)) then
        result += '<td colspan="'+intToStr(cols-high(cells))+'">'+cells[i]+'</td>'
      else
        result += '<td>'+cells[i]+'</td>';
    result += '</tr>';
  end;
end;

// mengubah isian masukan dgn kode javascript [string]
function jsFillValue(const aID: string; const aValue: string): string;
begin
  result := 'document.getElementById("'+aID+'").value = "'+aValue+'";'+LE;
end;

// mengubah isian masukan dgn kode javascript [integer]
function jsFillValue(const aID: string; const aValue: integer): string;
begin
  result := 'document.getElementById("'+aID+'").value = '+intToStr(aValue)+';'+LE;
end;

// mengubah isian masukan dgn kode javascript [double]
function jsFillValue(const aID: string; const aValue: double): string;
begin
  result := 'document.getElementById("'+aID+'").value = '+floatToStr(aValue)+';'+LE;
end;

// mengubah isian masukan dgn kode javascript [boolean]
function jsFillValue(const aID: string; const aValue: boolean): string;
begin
  result := 'document.getElementById("'+aID+'").checked = '+lowerCase(boolToStr(aValue,true))+';'+LE;
end;

// mengubah isian masukan dgn kode javascript [memo]
function jsFillMemo(const aID: string; const aValue: string): string;
begin
  result := 'document.getElementById("'+aID+'").innerHTML = "'+aValue+'";'+LE;
end;

// membuat bukaan form
function formOpen(const action: string; const isPost: boolean = false): string;
begin
  result := '<form action="'+action+'"'+
            ' id="'+ExtractFilename(ParamStr(0))+'"'+
            ' method="'+switch(isPost,'post','get')+'">';
end;

// membuat ruang kosong sebelum masukan
function putSpace(const aText: string = ''): string;
begin
  result := '<span class="input">'+aText+'</span>';
end;

// membuat teks keterangan masukan
function putLabel(const aLabel: string; const forID: string = '_'): string;
begin
  result := '<label class="input"';
  if forID = '_' then
    result += ' for="input_'+intToStr(inputIndex+1)+'">'
  else if forID <> '' then
    result += ' for="'+forID+'">'
  else
    result += '>';
  result += aLabel+'</label>';
end;

// membuat masukan tersembunyi dgn nama berbeda
function putVar(const aKey, aValue: string): string;
begin
  result := '<input type="hidden" name="'+aKey+'" value="'+aValue+'"/>';
end;

// membuat masukan tersembunyi
function inputVar(const aValue: string): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="hidden" name="input_'+intToStr(inputIndex)+'" value="'+aValue+'"/>';
end;

// membuat masukan teks
function inputText(const aValue: string = ''): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="text"'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
              switch(aValue='','',' value="'+aValue+'"')+
            '/>';
end;

// membuat masukan bilangan bulat
function inputNumber(const aValue: integer = -1): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="number"'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
              switch(intToStr(aValue)='-1','',' value="'+intToStr(aValue)+'"')+
            '/>';
end;

// membuat masukan bilangan pecahan
function inputFloat(const aValue: double = -1): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="number"'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
              switch(floatToStr(aValue)='-1','',' value="'+floatToStr(aValue)+'"')+
            ' step="any"/>';
end;

// membuat masukan logika
function inputBool(const aCaption: string; const aValue: boolean = false): string;
begin
  inputIndex := inputIndex+1;
  result := '<label><input type="checkbox"'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
            ' value="true"'+
              switch(aValue,' checked','')+
            '/> '+aCaption+' </label>';
end;

// membuat masukan opsi
function inputOption(const options: TArrayOfString; const checked: integer = -1; 
                     const newLine: boolean = false): string;
var
  i: integer;
begin
  inputIndex := inputIndex+1;
  result := '';
  for i := 0 to high(options) do
  begin
    result += '<label>'+
              '<input type="radio"'+
              ' id="input_'+intToStr(inputIndex)+'"'+
              ' name="input_'+intToStr(inputIndex)+'"'+
              ' value="option_'+intToStr(i)+'"'+
                switch(i=checked,' checked','')+
              '/> '+options[i]+' </label>';
    if i < high(options) then 
      if newLine then
        result += BR+LE+'<span class="input"></span>'
      else
        result += LE+' <font color="lightgray"> │ </font>';
  end;
end;

// membuat masukan pilihan
function inputSelect(const items: TArrayOfString; const selected: integer = -1; 
                     const isMultiple: boolean = false): string;
var
  i: integer;
begin
  inputIndex := inputIndex+1;
  result := '<select'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
            switch(isMultiple,' multiple>','>')+LE;
  for i := 0 to high(items) do
    result += '<option value="item_'+intToStr(i)+'"'+
               switch(i=selected,' selected','')+'>'+
               items[i]+'</option>'+LE;
  result += '</select>';
end;

// membuat masukan memo
function inputMemo(const aValue: string = ''): string;
begin
  inputIndex := inputIndex+1;
  result := '<textarea'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'">'+
              aValue+'</textarea>';
end;

// membuat masukan tombol
function inputButton(const aCaption: string; const action: string = ''; const isReset: boolean = false): string;
begin
  inputIndex := inputIndex+1;
  result := '<button'+
            ' type="'+switch(isReset,'reset','submit')+'"'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
              switch(action='','',' formaction="'+action+'"')+
            ' value="clicked">'+aCaption+
            '</button>';
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

// gabungkan antarmuka masukan dan pembacaan data masukan [float]
procedure webRead(var float: double; const newLine: boolean = false);
var
  s: string;
begin
  // baca data masukan
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then float := strToFloat(s);
  // tampilan antarmuka masukan
  write(inputFloat(float));
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

procedure webReadLn(var float: double);
begin
  webRead(float,true);
end;

// membaca data masukan variabel html
procedure webReadVar(var aValue: string);
var
  s: string;
begin
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then aValue := s;
  writeln(inputVar(htmlEncode(httpDecode(aValue))));
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [memo]
procedure webReadMemo(var str: string; const newLine: boolean = true);
var
  s: string;
begin
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then str := s;
  write(inputMemo(htmlEncode(httpDecode(str))));
  if newLine then writeln(BR) else writeln;
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [radio]
procedure webReadOption(var checked: integer; const options: TArrayOfString; const newLine: boolean = true);
var
  s: string;
  p: integer;
begin
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then
  begin
    p := pos('_',s);
    if p > 0 then checked := strToInt(copy(s,p+1,length(s)));
  end;
  write(inputOption(options,checked,newLine));
  if newLine then writeln(BR) else writeln;
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [combo]
procedure webReadSelect(var selected: integer; const items: TArrayOfString; const newLine: boolean = true);
var
  s: string;
  p: integer;
begin
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  if s <> '' then
  begin
    p := pos('_',s);
    if p > 0 then selected := strToInt(copy(s,p+1,length(s)));
  end;
  write(inputSelect(items,selected));
  if newLine then writeln(BR) else writeln;
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [button]
procedure webReadButton(var clicked: boolean; const aCaption: string; const newLine: boolean = false;
                        const action: string = ''; const isReset: boolean = false);
begin
  clicked := (getValue('input_'+intToStr(inputIndex+1),allWebInput) = 'clicked');
  write(inputButton(aCaption,action,isReset));
  if newLine then writeln(BR) else writeln;
end;

(*** awalan dan akhiran unit ***)

initialization
  // memastikan berkas catatan tersedia
  if fileExists(LOG_FILE) then
  begin
    log := TEventLog.Create(nil);
    log.logType := ltFile;
    log.fileName := LOG_FILE;
    log.identification := ExtractFilename(ParamStr(0))+':';
    log.appendContent := true;
    log.active := true;
    log.debug('#'+{$I %LINE%}+': [webUtils.initialization] done.');
  end;

finalization
  if fileExists(LOG_FILE) then
  begin
    log.debug('#'+{$I %LINE%}+': [webUtils.finalization] done.');
    log.free;
  end;

end.