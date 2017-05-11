program webTest;

uses 
  SysUtils, sharedMem, webUtils;
  
var
  webData: TSharedMem;

// menyisipkan javascript ke dokumen html
procedure writeScript(const aScript: string);
begin
  writeln('<script>',LE,aScript,'</script>',LE);
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

// mengubah isian masukan dgn kode javascript [boolean]
function jsFillValue(const aID: string; const aValue: boolean): string;
begin
  result := 'document.getElementById("'+aID+'").checked = '+
            lowerCase(boolToStr(aValue,true))+';'+LE;
end;

// mengubah isian masukan dgn kode javascript [memo]
function jsFillMemo(const aID: string; const aValue: string): string;
begin
  result := 'document.getElementById("'+aID+'").innerHTML = "'+aValue+'";'+LE;
end;

// membuat garis pemisah vertical
function spacer(const aClass: string = 'spacer'; const aID: string = ''): string;
begin
  result := '<span'+switch(aClass='','',' class="'+aClass+'"')+
                    switch(aID='','',' id="'+aID+'"')+'> │ </span>';
end;

// membuat masukan tombol
function inputButton(const aCaption: string; const action: string = ''; 
                     const isReset: boolean = false): string;
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

// gabungkan antarmuka masukan dan pembacaan data masukan [button]
procedure webReadButton(var clicked: boolean; const aCaption: string; const newLine: boolean = false;
                        const action: string = ''; const isReset: boolean = false);
var
  s: string;
begin
  s := getValue('input_'+intToStr(inputIndex+1),allWebInput);
  clicked := (s = 'clicked');  // baca klik dari nilai
  write(inputButton(aCaption,action,isReset));
  if newLine then writeln(BR) else writeln;
end;

// cek ketersediaan data tersimpan
function hasWebData: boolean;
var
  s: string;
begin
  memRead(webData,s);
  result := (s <> '');
end;

// simpan data ke memori
procedure saveWebData;
begin
  memWrite(webData,allWebInput);
end;

// baca data dari memori
function readWebData: string;
begin
  memRead(webData,result);
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
  log.debug('#'+{$I %LINE%}+': @showWebData saved = '+web);
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
procedure clearWebData;
begin
  memDestroy(webData);
  showWebData(true);
end;

// menulis isi laman
procedure writeContent;
var
  d: string  = '';
  s: string  = '';
  i: integer = -1;
  b: boolean = true;
  m: string  = '';
  btnSubmit, btnClear: boolean;
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
  write(spacer);   webReadButton(btnClear ,' CLEAR ');
  writeln(FORMc,Pc,HR);

  // tampilkan masukan, jika ada
  if webHasInput then
  begin
    if btnClear then clearWebData;
    if btnSubmit then saveWebData;
    if hasWebData then d := readWebData;    
    // tampilkan data tersedia
    writeln(Po,span('Available data:','bold'),BR);
    writeln('Input: ' ,switch(webInputs ='','[empty]',webInputs),BR);
    writeln('Query: ' ,switch(webQueries='','[empty]',webQueries),BR);
    writeln('Saved: ' ,switch(d='','[empty]',d),BR);
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
  writeHeader('Read Input','test.css');
  writeTitle('SAVE INPUT',3);
  allWebInput := readAllWebInput;
  writeContent;
  writeFooter;
end.