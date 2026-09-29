import fs from 'node:fs/promises';
import path from 'node:path';
import { FileBlob, SpreadsheetFile } from '@oai/artifact-tool';

const outDir = path.dirname(new URL(import.meta.url).pathname.replace(/^\/(?:[A-Za-z]:)/, m => m.slice(1)));
const workbookPath = path.join(outDir, 'Raha_Move_Stretching_Mobility_Top_10.xlsx');
const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));
const source = workbook.worksheets.getItem('Mobility picks');

const selected = [
  ['Neck', ['0462','0713','1831','5162','1844']],
  ['Shoulders', ['1980','1271','3130','4394','1990']],
  ['Upper back', ['6774','5135','1796','4601','1346']],
  ['Lower back', ['0690','1051','1364','1491','2116']],
  ['Hips', ['1053','1424','1847','1902','6705']],
  ['Knees', ['2773','2774','0692','0613','1377']],
  ['Full body', ['11095','2119','1847','3130','3630']],
];
const originalRows = source.getRange('A10:J79').values;
const key = id => String(id).padStart(4,'0');
const index = new Map(originalRows.map(row => [`${row[0]}|${key(row[7])}`,row]));
const rows = [];
for (const [area, ids] of selected) {
  if (ids.length !== 5) throw new Error(`${area}: expected five IDs`);
  for (let i=0;i<ids.length;i++) {
    const found = index.get(`${area}|${ids[i]}`);
    if (!found) throw new Error(`Missing ${area} / ${ids[i]} in source tab`);
    const copy = [...found];
    copy[1] = i+1;
    copy[7] = ids[i];
    rows.push(copy);
  }
}

// Repair one source identifier that Excel serialized numerically in the previous export.
source.getRange('H10').setNumberFormat('@');
source.getRange('H10').values = [['0462']];

const sheet = workbook.worksheets.add('Top 5 by area');
sheet.showGridLines = false;
sheet.tabColor = '#456B70';
sheet.getRange('A2').values = [['Raha Move | Top five mobility picks']];
sheet.getRange('A3').values = [['7 body areas · 5 picks each · drawn from the full mobility shortlist']];
sheet.getRange('A5').values = [['A compact set for short, beginner-friendly routines. Pick order reflects variety and daily usefulness, not clinical effectiveness.']];
sheet.getRange('A6').values = [['Full body reuses regional movements so a short routine can cover several areas. Review each demonstration before publishing.']];
sheet.getRange('A8:J8').values = [[
  'Body area','Pick','Movement name','Kind','Complementary areas','Support','Source name','Illustration ID','Animated GIF ID','Video ID'
]];
sheet.getRange('H9:J43').setNumberFormat('@');
sheet.getRange('A9:J43').values = rows;
sheet.getRange('A2:J43').format.font = {name:'Arial',size:10,color:'#23343A'};
sheet.getRange('A2').format.font = {name:'Arial',size:16,bold:true,color:'#274D53'};
sheet.getRange('A3').format.font = {name:'Arial',size:10,italic:true,color:'#5D7075'};
sheet.getRange('A5:A6').format.font = {name:'Arial',size:10,italic:true,color:'#5D7075'};
sheet.getRange('A8:J8').format = {fill:'#274D53',font:{name:'Arial',size:10,bold:true,color:'#FFFFFF'},rowHeight:29};
sheet.getRange('A9:J43').format.rowHeight = 23;
sheet.getRange('B9:B43').format.horizontalAlignment = 'center';
sheet.getRange('A9:J43').format.verticalAlignment = 'center';
const widths = {A:17,B:7,C:42,D:15,E:45,F:18,G:55,H:18,I:21,J:18};
for (const [col,width] of Object.entries(widths)) sheet.getRange(`${col}:${col}`).format.columnWidth = width;
for (let i=0;i<selected.length;i++) {
  const first = 9+i*5;
  const last = first+4;
  sheet.getRange(`A${first}:J${last}`).format.fill = i%2 ? '#FFFFFF' : '#F5F8F7';
  sheet.getRange(`A${first}:A${last}`).format.font = {name:'Arial',size:10,bold:true,color:'#274D53'};
  sheet.getRange(`A${first}:J${first}`).format.borders = {top:{style:'thin',color:'#BBCDCA'}};
}
sheet.freezePanes.freezeRows(8);
sheet.freezePanes.freezeColumns(3);
const table = sheet.tables.add('A8:J43',true,'MobilityTopFive');
table.showFilterButton = true;

workbook.recalculate();
const check = await workbook.inspect({kind:'table',range:'Top 5 by area!A8:J19',include:'values',tableMaxRows:12,tableMaxCols:10,maxChars:3500});
console.log(check.ndjson);
const errs = await workbook.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:20}});
console.log(errs.ndjson);
for (const [name,file] of [['Mobility picks','top_ten_after.png'],['Top 5 by area','top_five_preview.png']]) {
  const range = name === 'Mobility picks' ? 'A2:G20' : 'A2:G19';
  const preview = await workbook.render({sheetName:name,range,scale:1.2,format:'png'});
  await fs.writeFile(path.join(outDir,file),new Uint8Array(await preview.arrayBuffer()));
}
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(workbookPath);
console.log(JSON.stringify({sheetCount:2,topFiveRows:rows.length,output:workbookPath}));
