program webTest;

uses 
  SysUtils, StrUtils, DateUtils, sharedMem, webUtils;

var
  userData : TSharedMem;
  browserID: string = '';
  userID   : string = '';

// read item at comma separated string; index is 1-based
function getItemAt(const aText: string; const aIndex: integer; aDelim: string = '|'): string;
var
  i,l,pa,pb: integer;
begin
  Result := '';
  //if aDelim <> csvSplitter then aDelim := csvSplitter;
  if (aText = '') or (aIndex < 1) or (aDelim = '') then Exit;

  i := 0; pa := 1;
  l := Length(aText);
  while pa > 0 do 
  begin
    i := i+1;
    pb := PosEx(aDelim,aText,pa); // found next delimiter after the last
    if pb = 0 then pb := l+1;     // no delimiter found at the end, include last char
    if pa = pb then pa := pa+1;   // found empty field, move to next char
    
    if i = aIndex then
    begin
      Result := Copy(aText,pa,pb-pa); // read field value as is (including spaces)
      if pb = l then Exit;            // a delimiter found at the end, stop it 
    end
    else
    begin
      pa := pb+1;                 // a delimiter found NOT at the index, get along
      if pa > l then pa := 0;     // iterator reaches the end of the text, stop it 
    end;
  end;
end;

// count items of comma separated string
function getItemCount(const aText: string; aDelim: string = '|'): integer;
var
  i,l,p: integer;
begin
  Result := 0;
  //if aDelim <> csvSplitter then aDelim := csvSplitter;
  if (aText = '') or (aDelim = '') then Exit;
  
  i := 0; p := 0;
  l := Length(aText);
  while p <= l do 
  begin
    i := i+1;                     // count delimiter found 
    p := PosEx(aDelim,aText,p+1); // search for delimiter along the text
    if p = 0 then p := l+1;       // no delimiter found at the end, stop it 
    if p = l then i := i-1;       // a delimiter found at the end, ignore it 
  end;
  Result := i;
end;

// mengambil kata kunci dari teks key=value
function getKey(const ofString: string; const delimiter: string = '='): string;
var
  p: integer;
begin
  p := pos(delimiter,ofString);
  if p > 0 then
    result := copy(ofString,1,p-1)
  else
    result := '';
end;

// mengubah atau menambah nilai pada deret teks
function setValue(const aKey, aValue, ofString: string; const delimiter: string = '&'; const equalizer: string = '='): string;
var
  pStart, pStop: integer;
  s,f: string;
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
    // ganti nilai lama dgn yg baru
    f := aKey+equalizer+copy(ofString,pStart,pStop-pStart);
    result := stringReplace(ofString,f,aKey+equalizer+aValue,[]);
  end
  // tak ditemukan kesamaan, tambah nilai baru
  else begin
    if ofString = '' then
      result := aKey+equalizer+aValue
    else
      result := ofString+delimiter+aKey+equalizer+aValue;
  end;
end;

// membuat masukan kata sandi
function inputPassword(const aValue: string = ''): string;
begin
  inputIndex := inputIndex+1;
  result := '<input type="password"'+
            ' id="input_'+intToStr(inputIndex)+'"'+
            ' name="input_'+intToStr(inputIndex)+'"'+
              switch(aValue='','',' value="'+aValue+'"')+
            '/>';
end;

// gabungkan antarmuka masukan dan pembacaan data masukan [password]
procedure webReadPassword(var str: string; const newLine: boolean = false);
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

// cek ketersediaan data tersimpan
function hasUserData: boolean;
var
  m,d: string;
begin
  memRead(userData,m);
  d := getValue(userID,m,'|',':');
  result := (d <> '');
end;

// simpan data ke memori
procedure saveUserData;
var
  m,d: string;
begin
  memRead(userData,m);
  // format data <user_id>:<data> dgn pemisah |
  d := getValue(userID,m,'|',':');
  // hapus data user yg sudah tersimpan
  m := stringReplace(m,userID+':'+d+'|','',[]);
  // catat waktu simpan
  d := allWebInput;
  d := setValue('session_id',browserID,d);
  d := setValue('last',floatToStr(now),d);
  // ganti data user dgn yg baru
  m += userID+':'+d+'|';
  memWrite(userData,m);
end;

// baca data dari memory
function readUserData: string;
var
  m: string;
begin
  memRead(userData,m);
  result := getValue(userID,m,'|',':');
end;

// mengisi form dengan data tersimpan
procedure showUserData(const isReset: boolean = false);
var
  i: integer = 0;
  d,s,web: string;

  function getInput: string;
  begin
    i += 1;
    result := getValue('input_'+intToStr(i),web);
  end;
  
begin
  web := readUserData;
  // baca dan tampilkan data masukan sesuai urutannya
  d := switch(isReset,'',htmlEncode(httpDecode(getInput)));
  s := jsFillValue('input_'+intToStr(i),d);
  d := switch(isReset,'',getInput);
  s += jsFillValue('input_'+intToStr(i),d);
  d := switch(isReset,'',getInput);
  s += jsFillValue('input_'+intToStr(i),d='true');
  d := switch(isReset,'',htmlEncode(httpDecode(getInput)));
  s += jsFillMemo('input_'+intToStr(i),d);
  writeScript(s);
end;

// hapus data tersimpan
procedure clearUserData;
var
  m,d: string;
begin
  memRead(userData,m);
  d := getValue(userID,m,'|',':');
  m := stringReplace(m,userID+':'+d+'|','',[]);
  memWrite(userData,m);
  showUserData(true);
end;

// kosongkan data tersimpan
procedure destroyUserData;
begin
  memDestroy(userData);
  showUserData(true);
end;

procedure pageContent; forward;

// laman masuk
procedure pageLogin;
var
  i: integer = 0;
  web: string = '';
  u_name: string = '';
  passwd: string = '';
  btnLogin: boolean;

  function getInput: string;
  begin
    i += 1;
    result := getValue('input_'+intToStr(i),web);
  end;
  
  function passValid(const aPass: string): boolean;
  begin
    result := (aPass <> '') and (aPass = 'admin');
  end;

begin
  u_name := getInput;
  passwd := getInput;
  btnLogin := (getInput = 'clicked');

  if (not btnLogin) or (not passValid(passwd)) then
  begin
    passwd := '';
    // tampilkan antarmuka masukan
    writeHeader('Pascal Web App','test.css');
    writeTitle('LOGIN PAGE',3);
    writeln(Po,formOpen(ExtractFilename(ParamStr(0)),true));
    write(putLabel('Username: ')); webReadln(u_name);
    write(putLabel('Password: ')); webReadPassword(passwd);
    writeln(separator);
    write(putSpace); webReadButton(btnLogin ,' LOGIN ');
    writeln(putVar('page','login'));
    writeln(FORMc,Pc,HR);
    writeFooter;
  end else
  begin
    memCreate(userData,1024);
    userID := u_name;
    browserID := generateGUID;
    writeln(createCookie('browser_id',browserID));
    allWebInput := '';
    
    // simpan data kosong utk user baru
    saveUserData;
    pageContent;
  end;
end;

// menulis isi laman
procedure pageContent;
var
  d: string  = '';
  s: string  = '';
  i: integer = -1;
  b: boolean = true;
  m: string  = '';
  btnSubmit, btnClear, btnDestroy: boolean;
begin
  writeHeader('Pascal Web App','test.css');
  writeTitle('CONTENT PAGE',3);
  // tampilkan antarmuka masukan
  writeln(Po,formOpen(ExtractFilename(ParamStr(0)),true));
  write(putLabel('String: '));      webReadln(s);
  write(putLabel('Number: '));      webReadln(i);
  write(putLabel('Boolean: ',''));  webReadln(b,'Yes, I agree');
  write(putLabel('Memo: '));        webReadMemo(m);
  writeln(separator);
  write(putSpace); webReadButton(btnSubmit ,' SUBMIT ');
  write(spacer);   webReadButton(btnClear  ,' CLEAR ');
  write(spacer);   webReadButton(btnDestroy,' CLEAR ALL ');
  writeln(putVar('page','content'));
  writeln(FORMc,Pc,HR);

  // tampilkan masukan, jika ada
  if webHasInput then
  begin
    if btnClear then clearUserData;
    if btnSubmit then saveUserData;
    if btnDestroy then destroyUserData;
    {if hasUserData then} memRead(userData,d);    
    // tampilkan data tersedia
    writeln(Po,span('Available data:','bold'),BR);
    writeln('Input: ' ,switch(webInputs ='','[empty]',webInputs),BR);
    writeln('Query: ' ,switch(webQueries='','[empty]',webQueries),BR);
    writeln('Cookie: ',switch(webCookies='','[empty]',webCookies),BR);
    writeln('Saved: ' ,BR,switch(d='','[empty]'+BR,stringReplace(d,'|',BR,[rfReplaceAll])));
    // info waktu perbaruanuserData
    d := getValue('last',readUserData);
    if d <> '' then d := formatDateTime('dd-mm-yyyy hh:nn:ss',strToFloat(d));
    writeln('Last updated: ',switch(d='','-',d));
    writeln(Pc,HR);
  end
  // tampilkan data tersimpan
  else begin
    if hasUserData then showUserData;
  end;

  writeFooter;
  log.debug('#'+{$I %LINE%}+': [main.writeContent] done.');
end;

// pilih laman yg muncul
procedure setupPage;
var
  i,c: integer;
  s,d: string;
begin
  if not webHasInput then
    pageLogin
  else begin
    memCreate(userData,1024);
    browserID := getValue('browser_id',webCookies);
    // baca data tersimpan
    memRead(userData,d);
    userID := '';
    c := getItemCount(d);
    for i := 0 to c do
    begin
      s := getItemAt(d,i);
      if pos(browserID,s) > 0 then userID := getKey(s,':');
    end;
    pageContent;
  end;
end;

(*** program utama ***)
begin
  allWebInput := readAllWebInput(true);
  setupPage;
end.