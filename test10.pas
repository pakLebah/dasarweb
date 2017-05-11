program webTest;

uses 
  SysUtils, DateUtils, sharedMem, webUtils;

const
  SPACE = '&nbsp;';

var
  webData: TSharedMem;
  browserID: string = '';

// membuat guid
function generateGUID: string;
var
  guid: TGUID;
begin
  repeat sleep(1) until createGUID(guid) = 0;
  result := guidToString(guid);
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

// cek ketersediaan data tersimpan
function hasWebData: boolean;
var
  m,d: string;
begin
  memRead(webData,m);
  d := getValue(browserID,m,'|',':');
  result := (d <> '');
end;

// simpan data ke memori
procedure saveWebData;
var
  m,d,t: string;
begin
  memRead(webData,m);
  // format sesi <id>:<data> dgn pemisah |
  d := getValue(browserID,m,'|',':');
  // hapus data sesi yg sudah tersimpan
  m := stringReplace(m,browserID+':'+d+'|','',[]);
  // catat waktu simpan
  t := '&last='+floatToStr(now);
  // ganti data sesi dgn yg baru
  m += browserID+':'+allWebInput+t+'|';
  memWrite(webData,m);
  log.debug('#'+{$I %LINE%}+': @saveWebData saved = '+m);
end;

// baca data dari memori
function readWebData: string;
var
  m: string;
begin
  memRead(webData,m);
  result := getValue(browserID,m,'|',':');
end;

// mengisi form dengan data tersimpan
procedure showWebData(const isReset: boolean = false);
var
  i: integer = 0;
  d,s,web: string;

  function getInput: string;
  begin
    i += 1;
    result := getValue('input_'+intToStr(i),web);
  end;
  
begin
  web := readWebData;
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
procedure deleteWebData;
var
  m,d: string;
begin
  memRead(webData,m);
  d := getValue(browserID,m,'|',':');
  m := stringReplace(m,browserID+':'+d+'|','',[]);
  memWrite(webData,m);
  showWebData(true);
end;

// kosongkan memori bersama
procedure clearWebData;
begin
  memDestroy(webData);
  showWebData(true);
end;

// baca kue http
procedure setupCookies;
begin
  webCookies := readWebCookie;
  if webCookies = '' then
  begin
    // simpan kue baru
    browserID := generateGUID;
    writeln(createCookie('browser_id',browserID));
  end
  else
    // baca kue tersimpan
    browserID := getValue('browser_id',webCookies);
end;

// menulis isi laman
procedure writeContent;
var
  d: string  = '';
  s: string  = '';
  i: integer = -1;
  b: boolean = true;
  m: string  = '';
  btnSubmit, btnDelete, btnClear: boolean;
begin
  // buat penyimpan data dgn kapasitas 1 kb
  memCreate(webData,1024);
  
  // tampilkan antarmuka masukan
  writeln(Po,formOpen(ExtractFilename(ParamStr(0)),true));
  write(putLabel('String: '));      webReadln(s);
  write(putLabel('Number: '));      webReadln(i);
  write(putLabel('Boolean: ',''));  webReadln(b,'Yes, I agree');
  write(putLabel('Memo: '));        webReadMemo(m);
  writeln(separator);
  write(putSpace); webReadButton(btnSubmit,' SUBMIT ');
  write(spacer);   webReadButton(btnDelete,' DELETE ');
  write(SPACE);    webReadButton(btnClear ,' CLEAR ');
  writeln(FORMc,Pc,HR);

  // tampilkan masukan, jika ada
  if webHasInput then
  begin
    if btnSubmit then saveWebData;
    if btnDelete then deleteWebData;
    if btnClear  then clearWebData;
    memRead(webData,d);
    
    // tampilkan data tersedia
    writeln(Po,span('Available data:','bold'),BR);
    writeln('Input: ' ,switch(webInputs ='','[empty]',webInputs),BR);
    writeln('Query: ' ,switch(webQueries='','[empty]',webQueries),BR);
    writeln('Cookie: ',switch(webCookies='','[empty]',webCookies),BR);
    writeln('Saved: ' ,BR,switch(d='','[empty]'+BR,stringReplace(d,'|',BR,[rfReplaceAll])));
    
    // info waktu perbaruan
    d := getValue('last',readWebData);
    if d <> '' then d := formatDateTime('dd-mm-yyyy hh:nn:ss',strToFloat(d));
    writeln('Last updated: ',switch(d='','-',d));
    writeln(Pc,HR);
  end
  // tampilkan data tersimpan
  else begin
    if hasWebData then showWebData;
  end;

  log.debug('#'+{$I %LINE%}+': [main.writeContent] done.');
end;

(*** program utama ***)
begin
  setupCookies;
  writeHeader('Read Input','test.css');
  writeTitle('DATA & COOKIE',3);
  allWebInput := readAllWebInput;
  writeContent;
  writeFooter;
end.