function resetShotId() { 
  if(cconfirm("Reset Data ?") != 'yes'){return;}

  var Sheet = SpreadsheetApp.getActiveSheet();
  var SP = SpreadsheetApp.getActiveSpreadsheet();
  var DatavalSheet = SP.getSheetByName('SHOTS');
  var datavalfirstcell = DatavalSheet.getRange('B4').getValue();
  var datavalcol = DatavalSheet.getRange('B2').getValue();
  var datavalrange = DatavalSheet.getRange(datavalfirstcell+":"+datavalcol);
  //SpreadsheetApp.getUi().alert(datavalfirstcell+":"+datavalcol);
  var datavalrule = SpreadsheetApp.newDataValidation().requireValueInRange(datavalrange).build();

  var skiprow = Sheet.getRange('B1').getValue()+1; // grouped rows (for matrix sheet)
  var firstrow = Sheet.getRange('B3').getValue(); // 31
  var lastidrow = Sheet.getRange('B9').getValue(); // max row of token and id -> max row 
  var lastnoterow = Sheet.getRange('D2').getValue(); // max row for notes column
  var mergecolstartindex = Sheet.getRange('D5').getValue(); // col B (index-> 2)
  var lastallrow = Sheet.getLastRow() ; // max row
  var mergekeeprow = Sheet.getRange('D8').getValue();
  var maxiddata = lastidrow-firstrow+1 ; // = num of data row (data only)
  var maxnotedata = lastnoterow-firstrow+1; // = num of notes row (notes only)
  var maxalldata = lastallrow-firstrow+1; // = num of data+notes row

  var idcol = Sheet.getRange('B4').getValue(); // c
  var tokencol = Sheet.getRange('B7').getValue(); // 
  var notecolstart = Sheet.getRange('B10').getValue();
  var notecolstartindex = Sheet.getRange('D10').getValue();
  var notecolendindex = Sheet.getRange('D11').getValue();

  var notecolend = Sheet.getRange('B15').getValue();
  var notecolnum = Sheet.getRange('D1').getValue();
  var mergecolnum = Sheet.getRange('D7').getValue();
  
  if(maxiddata>0){
    var idarr = new Array(maxiddata);
    for (i=0;i<maxiddata;i++){
      idarr[i]= new Array(1);
      idarr[i][0] = "" ;
    }
    var idrange = idcol+firstrow+":"+idcol+lastidrow;
    var idcells = Sheet.getRange(idrange);
    idcells.setValues(idarr);
  }

  if(maxnotedata>0){
    var notearr = new Array(maxnotedata);
    for (i=0;i<maxnotedata;i++){
      notearr[i]= new Array(notecolnum);
      for (j=0;j<notecolnum;j++){
        notearr[i][j] = "" ;
      }
    }
    var noterange = notecolstart+firstrow+":"+notecolend+lastnoterow;
    var notecells = Sheet.getRange(noterange); 
    notecells.setValues(notearr) ;
  }

  // set data validation
  var idallrange = idcol+firstrow+":"+idcol+lastallrow;
  var idallcells = Sheet.getRange(idallrange);  
  idallcells.setDataValidation(datavalrule) ;

  // merge cells
  if(skiprow >1){
    for (i=0;i<Math.floor(maxalldata/skiprow) ;i++){
      Sheet.getRange(firstrow+(i*skiprow),mergecolstartindex,skiprow-mergekeeprow, mergecolnum).mergeVertically(); //data 
      Sheet.getRange(firstrow+(i*skiprow),notecolstartindex,skiprow-mergekeeprow, notecolendindex - notecolstartindex +1).mergeVertically(); //note
    }
  }
  
}


function assignShotId() { 
  var SP = SpreadsheetApp.getActiveSpreadsheet();
  var Sheettemp = SP.getSheetByName('HELPER_SHOTID');
  var datanum = Sheettemp.getRange('B5').getValue();
  //SpreadsheetApp.getUi().alert(datanum);

  if(datanum==0) {
    SpreadsheetApp.getUi().alert("No new data.");
    return;}

  if(cconfirm("Add "+datanum+" new data ?") != 'yes'){return;}
  var Sheet = SpreadsheetApp.getActiveSheet();

  
  var tempfirstrow = Sheettemp.getRange('B2').getValue();
  var templastrow = Sheettemp.getRange('B3').getValue();
  var tempcol = Sheettemp.getRange('B4').getValue();


  var idcol = Sheet.getRange('B4').getValue();
  var skiprow = Sheet.getRange('B1').getValue();
  var firstrow = Sheet.getRange('B9').getValue()+1;
  
  tempmaxdata = templastrow - tempfirstrow + 1;
  tempmaxdata += skiprow ; // additional row for token
  templastrow += skiprow ; // additional row for token
  var lastrow = firstrow + tempmaxdata -1 ;

  var shotarr = new Array(tempmaxdata);
  for (i=0;i<tempmaxdata;i++){
    shotarr[i]= new Array(1);
    shotarr[i][0] = "" ;
  }

  shotarr = Sheettemp.getRange(tempcol+tempfirstrow+":"+tempcol+templastrow).getValues();
  Sheet.getRange(idcol+firstrow+":"+idcol+lastrow).setValues(shotarr);
  SpreadsheetApp.getUi().alert("Assign "+datanum+" items.");
}



function getSheetUrl() {
  var SS = SpreadsheetApp.getActiveSpreadsheet();
  var ss = SS.getActiveSheet();
  var url = '';
  url += SS.getUrl();
  url += '#gid=';
  url += ss.getSheetId(); 
  return url;
}

function setState() {
  var Sheet = SpreadsheetApp.getActiveSheet();
  var skipmode = Sheet.getRange('G16').getValue();
  ask = (skipmode) ? "Skip All Shots" : "Select All Shots";
  var confirm = Browser.msgBox(ask, Browser.Buttons.YES_NO); 
  if (confirm!= 'yes'){ return; }

  var firstrow = Sheet.getRange('B3').getValue();
  var lastrow =  Sheet.getRange('D16').getValue();
  var maxdata = (lastrow - firstrow) +1;
  var skipcol = Sheet.getRange('G3').getValue();

  var skiparr = new Array(maxdata);
  for (i=0;i< maxdata;i++){
    skiparr[i]= new Array(1);
    skiparr[i][0] = (skipmode) ? 1 : 0 ;
  }
  Sheet.getRange(skipcol+firstrow+":"+skipcol+lastrow).setValues(skiparr);
}

function clearMarks() {
  if(cconfirm("Clear All Search Marks ?") != 'yes'){return;}
  var Sheet = SpreadsheetApp.getActiveSheet();
  var firstrow = Sheet.getRange('B3').getValue();
  var lastrow =  Sheet.getRange('D16').getValue();
  var maxdata = (lastrow - firstrow) +1;
  var markcol = Sheet.getRange('G2').getValue(); 
  var markarr = new Array(maxdata);

  for (i=0;i<maxdata;i++){
    markarr[i]= new Array(1);
    markarr[i][0] = "" ;
  }
  Sheet.getRange(markcol+firstrow+":"+markcol+lastrow).setValues(markarr);
}



function selectMatchShots() {
  var Sheet = SpreadsheetApp.getActiveSheet();
  var operation = Sheet.getRange('G10').getValue();  
  if (operation!="mark only"){
    var confirm = Browser.msgBox("Mark (Select/Skip) ?", Browser.Buttons.YES_NO); 
    if (confirm!= 'yes'){ return; }
  }

  var vfxcol = Sheet.getRange('D13').getValue();
  var markcol = Sheet.getRange('G2').getValue();  
  var skipcol = Sheet.getRange('G3').getValue();
  var keyword = Sheet.getRange('G4').getValue();  
  var firstrow = Sheet.getRange('B3').getValue();
  var type = Sheet.getRange('G8').getValue();
  var mode = Sheet.getRange('G9').getValue();
  var exactword = Sheet.getRange('G11').getValue(); 

  var maxdata = Sheet.getRange('B6').getValue();
  var lastrow = firstrow+maxdata-1;
  var keywords = keyword.split(",").join("|");
  var items = 0;
  var markarr = new Array(maxdata);
  var textarr = new Array(maxdata);

  var skiparr = new Array(maxdata);
  for(i=0;i<maxdata;i++){
    skiparr[i] = new Array(1);   
  } 

  for (i=0;i<maxdata;i++){
    textarr[i]= new Array(1);
  }
  textarr =  Sheet.getRange(vfxcol+firstrow+":"+vfxcol+lastrow).getValues();
  skiparr = Sheet.getRange(skipcol+firstrow+":"+skipcol+lastrow).getValues();

  //if (operation!="mark only"){
  //  var skiparr = new Array(maxdata);
  //  for(i=0;i<maxdata;i++){
  //   skiparr[i] = new Array(1);   
  //  } 
  //  skiparr = Sheet.getRange(skipcol+firstrow+":"+skipcol+lastrow).getValues();
  //}

  if (exactword) {
    var regex = (mode === 'match') ? new RegExp("\\b"+keywords+"\\b","i") : new RegExp(`^((?!\\b${keywords}\\b).)*$`, 'i') ;
  } else {
    var regex = (mode === 'match') ? new RegExp(keywords,"i") : new RegExp(`^((?!${keywords}).)*$`, 'i') ;
  }

  

  for(i=firstrow; i<=lastrow; i++ ) {
    idx = i - firstrow;
    markarr[idx] = new Array(1);
    markarr[idx][0] = "";
 
    if (type!="All"){
      if (type=="Selected") {
        if(skiparr[idx][0]) {continue;}
      } else {
        if(!skiparr[idx][0]) {continue;}
      }
    }

   
    textarr[idx][0] = textarr[idx][0].replace(/\n/g,"");
    match = textarr[idx][0].match(regex);

    if (match) {
      markarr[idx][0] = 1;
      if (operation!="mark only"){
        if (operation == "select"){
          skiparr[idx][0] = 0;
        } else {
          skiparr[idx][0] = 1;
        }
      }
      items += 1;
    } 
  }

  //write to table
  Sheet.getRange(markcol+firstrow+":"+markcol+lastrow).setValues(markarr);
  if (operation!="mark only"){
    Sheet.getRange(skipcol+firstrow+":"+skipcol+lastrow).setValues(skiparr);
  }
  SpreadsheetApp.getUi().alert("Match : "+items);  
}

function fillSelectMarks() {
  var confirm = Browser.msgBox("Fill the Flag/Partial data of Selected Marked Shots ?", Browser.Buttons.YES_NO); 
  if (confirm!= 'yes'){ return; }

  var Sheet = SpreadsheetApp.getActiveSheet();
  var flagcol = Sheet.getRange('G5').getValue();
  var partialcol = Sheet.getRange('G12').getValue();
  var fillmode = Sheet.getRange('G13').getValue();
  var maxdata = Sheet.getRange('B6').getValue();
  var firstrow = Sheet.getRange('B3').getValue();
  var lastrow = firstrow+maxdata-1;
  var markcol = Sheet.getRange('G2').getValue();  
  var text = Sheet.getRange('G14').getValue();  
  var overwrite = Sheet.getRange('G15').getValue();  
  var markarr = new Array(maxdata);
  linebreak = '\n';
  for (i=0;i<maxdata;i++){
    markarr[i]= new Array(1);
  }
  markarr = Sheet.getRange(markcol+firstrow+":"+markcol+lastrow).getValues();


  if (fillmode == 'flag') {
    var flagarr = new Array(maxdata);
    for (i=0;i<maxdata;i++){
      flagarr[i]= new Array(1);
    }
    flagarr = Sheet.getRange(flagcol+firstrow+":"+flagcol+lastrow).getValues();
  } else {
    var partialarr = new Array(maxdata);
    for (i=0;i<maxdata;i++){
      partialarr[i]= new Array(1);
    }
    partialarr = Sheet.getRange(partialcol+firstrow+":"+partialcol+lastrow).getValues();
  }

  for(i=firstrow; i<=lastrow; i++ ) {
    idx = i - firstrow;
    if (markarr[idx][0] == 1){
      if (fillmode == "flag") {
        if (overwrite) {flagarr[idx][0] = text; } else { flagarr[idx][0] += ((flagarr[idx][0] !=="") ? linebreak : "" ) + text ;} 
      } else {
        if (overwrite) {partialarr[idx][0] = text } else { partialarr[idx][0] += ((partialarr[idx][0] !=="") ? linebreak : "" ) + text ;}
      }
    }
  }

  //write to table
  if (fillmode == "flag") {
    Sheet.getRange(flagcol+firstrow+":"+flagcol+lastrow).setValues(flagarr);
  } else {
    Sheet.getRange(partialcol+firstrow+":"+partialcol+lastrow).setValues(partialarr);
  }
}


