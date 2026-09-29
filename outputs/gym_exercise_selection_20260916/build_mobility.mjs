import fs from 'node:fs/promises';
import path from 'node:path';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';

const outDir = path.dirname(new URL(import.meta.url).pathname.replace(/^\/(?:[A-Za-z]:)/, m => m.slice(1)));
const source = JSON.parse(await fs.readFile(path.join(outDir, 'source_index.json'), 'utf8'));

// Source ID, reviewed English display name, movement kind, complementary body areas, support.
// All selected source records must be Stretching + Body weight and have all three media IDs.
const categories = [
  ['Neck', [
    ['0462','Front and Back Neck Stretch','Stretch','Shoulders','None'],
    ['0713','Side Neck Stretch','Stretch','Shoulders','None'],
    ['1831','Neck Rotation Stretch','Mobility','Shoulders','None'],
    ['1836','Forward Neck Flexion Stretch','Stretch','Upper back','None'],
    ['1838','Neck Extension and Rotation Stretch','Mobility','Upper back, Shoulders','None'],
    ['1840','Neck Flexion and Rotation Stretch','Mobility','Shoulders','None'],
    ['1844','Neck Extension and Side Tilt Stretch','Mobility','Shoulders','None'],
    ['5162','Seated Neck Stretch','Stretch','Shoulders','Chair optional'],
    ['5195','Seated Side Neck Stretch','Stretch','Shoulders','Chair optional'],
    ['7306','Standing Side Neck Stretch','Stretch','Shoulders','None'],
  ]],
  ['Shoulders', [
    ['0669','Rear Shoulder Stretch','Stretch','Upper back','None'],
    ['1271','Chest and Front Shoulder Stretch','Stretch','Upper back','None'],
    ['1488','Behind-the-Back Shoulder Stretch','Stretch','Upper back','None'],
    ['1970','Standing Upright Shoulder Stretch','Stretch','Neck, Upper back','None'],
    ['1980','Cross-body Shoulder Stretch','Stretch','Upper back','None'],
    ['1982','Shoulder Rotation Stretch','Mobility','Upper back','None'],
    ['1990','External Shoulder Rotation Stretch','Mobility','Upper back','None'],
    ['1991','Internal Shoulder Rotation Stretch','Mobility','Upper back','None'],
    ['3130','Shoulder Blade Elevation and Depression','Mobility','Neck, Upper back','None'],
    ['4394','Shoulder Flexion Against Wall','Mobility','Upper back','Wall'],
  ]],
  ['Upper back', [
    ['0626','Middle Back Stretch','Stretch','Shoulders','None'],
    ['1346','Kneeling Lat Stretch','Stretch','Shoulders, Lower back','None'],
    ['1796','Standing Reach and Back Rotation','Mobility','Shoulders, Lower back','None'],
    ['1802','Side Lat Stretch','Stretch','Shoulders','None'],
    ['1806','Seated Side Reach Stretch','Stretch','Shoulders, Lower back','Chair optional'],
    ['1812','Kneeling Back Rotation Stretch','Mobility','Shoulders, Lower back','None'],
    ['4601','Open Book Stretch','Mobility','Shoulders, Lower back','None'],
    ['5135','Seated Rotation Stretch','Mobility','Lower back','Chair optional'],
    ['6774','Seated Rhomboid Stretch','Stretch','Shoulders','Chair optional'],
    ['6614','Seated Shoulder Blade Squeeze','Mobility','Shoulders, Neck','Chair optional'],
  ]],
  ['Lower back', [
    ['0690','Seated Lower Back Stretch','Stretch','Hips','Chair optional'],
    ['1051','Cat Stretch','Mobility','Upper back, Hips','None'],
    ['1362','Sphinx Stretch','Stretch','Hips','None'],
    ['1363','Spine Stretch','Stretch','Upper back, Hips','None'],
    ['1364','Standing Pelvic Tilt','Mobility','Hips','None'],
    ['1805','Seated Forward Back Stretch','Stretch','Upper back, Hips','Chair optional'],
    ['1491','Supine Spinal Twist','Stretch','Hips','None'],
    ['2116','Lying Knee Roll-over Stretch','Mobility','Hips','None'],
    ['3242','Lying Bent-knee Lower Back Stretch','Stretch','Hips','None'],
    ['7294','Lying Pelvic Tilt','Mobility','Hips','None'],
  ]],
  ['Hips', [
    ['1053','Kneeling Hip Flexor Stretch','Stretch','Lower back, Knees','None'],
    ['1424','Seated Glute Stretch','Stretch','Lower back','Chair optional'],
    ['1847','Hip Circles','Mobility','Lower back, Knees','None'],
    ['1895','Standing Hip Rotation Stretch','Mobility','Lower back, Knees','None'],
    ['1902','Seated Wide-leg Adductor Stretch','Stretch','Knees','None'],
    ['1936','Lying Cross-over Knee Stretch','Stretch','Lower back','None'],
    ['1899','Side Lunge Adductor Stretch','Stretch','Knees','None'],
    ['6705','Supine Windshield Wipers','Mobility','Lower back','None'],
    ['6560','90/90 Hip Stretch','Stretch','Lower back, Knees','None'],
    ['1056','Lying Glute Stretch','Stretch','Lower back','None'],
  ]],
  ['Knees', [
    ['0257','Gentle Knee Circles','Mobility','Hips','None'],
    ['2773','Knee Extension Mobility','Mobility','Hips','None'],
    ['2774','Knee Flexion Mobility','Mobility','Hips','None'],
    ['0692','Seated Single-leg Hamstring Stretch','Stretch','Hips, Lower back','None'],
    ['0613','Side-lying Quadriceps Stretch','Stretch','Hips','None'],
    ['1059','Standing Quadriceps Stretch','Stretch','Hips','Support optional'],
    ['1406','Lying Hamstring Stretch','Stretch','Hips, Lower back','None'],
    ['1377','Wall Calf Stretch','Stretch','None','Wall'],
    ['11649','Bent-knee Calf Stretch','Stretch','None','None'],
    ['10547','Standing Single-leg Calf Rock','Mobility','Hips','Support optional'],
  ]],
  // Full body is a routine area in the brief: this set intentionally reuses
  // suitable movements from regional categories to cover the whole body.
  ['Full body', [
    ['11095','Seated Cat-Cow Stretch','Mobility','Upper back, Lower back, Hips','Chair'],
    ['2119','Standing Side Stretch','Stretch','Shoulders, Upper back, Lower back','None'],
    ['3630','Standing Hamstring and Back Stretch','Stretch','Lower back, Hips, Knees','None'],
    ['5251','Downward-facing Dog','Stretch','Shoulders, Upper back, Hips, Knees','None'],
    ['2110','Standing Trunk Rotation Stretch','Mobility','Upper back, Lower back, Hips','None'],
    ['1796','Standing Reach and Back Rotation','Mobility','Shoulders, Upper back, Lower back','None'],
    ['1847','Hip Circles','Mobility','Hips, Lower back, Knees','None'],
    ['3130','Shoulder Blade Elevation and Depression','Mobility','Neck, Shoulders, Upper back','None'],
    ['0257','Gentle Knee Circles','Mobility','Hips, Knees','None'],
    ['1831','Neck Rotation Stretch','Mobility','Neck, Shoulders','None'],
  ]],
];

const rows = [];
for (const [area, picks] of categories) {
  if (picks.length !== 10) throw new Error(`${area}: ${picks.length} selections`);
  for (let i=0;i<picks.length;i++) {
    const [id, name, kind, complementary, support] = picks[i];
    const s = source[id];
    if (!s) throw new Error(`Missing source ID ${id}`);
    if (s.type !== 'Stretching' || s.equipment !== 'Body weight') throw new Error(`${id} is ${s.type}/${s.equipment}`);
    if (!s['Animated GIFs']?.id || !s.Videos?.id) throw new Error(`${id} lacks visual formats`);
    rows.push([area,i+1,name,kind,complementary,support,s.name,id,s['Animated GIFs'].id,s.Videos.id]);
  }
}
const unique = new Set(rows.map(r=>r[7]));

const wb = Workbook.create();
const sheet = wb.worksheets.add('Mobility picks');
sheet.showGridLines = false;
sheet.tabColor = '#456B70';
sheet.getRange('A2').values = [['Raha Move | Stretching and mobility shortlist']];
sheet.getRange('A3').values = [[`${categories.length} body areas · 10 picks each · ${unique.size} distinct movements`]];
sheet.getRange('A5').values = [['Selected for the everyday mobility focus in the product brief. Every source row is labeled Stretching and Body weight.']];
sheet.getRange('A6').values = [['Full body reuses regional movements as building blocks for a balanced routine. Complementary areas show where a movement may also fit.']];
sheet.getRange('A7').values = [['Names, movement type, and support are editorial suggestions; review each demonstration and suitability before publishing in the app.']];
sheet.getRange('A9:J9').values = [[
  'Body area','Pick','Movement name','Kind','Complementary areas','Support','Source name','Illustration ID','Animated GIF ID','Video ID'
]];
sheet.getRange(`A10:J${9+rows.length}`).values = rows;
sheet.getRange(`A2:J${9+rows.length}`).format.font = {name:'Arial',size:10,color:'#23343A'};
sheet.getRange('A2').format.font = {name:'Arial',size:16,bold:true,color:'#274D53'};
sheet.getRange('A3').format.font = {name:'Arial',size:10,italic:true,color:'#5D7075'};
sheet.getRange('A5:A7').format.font = {name:'Arial',size:10,italic:true,color:'#5D7075'};
sheet.getRange('A9:J9').format = {fill:'#274D53',font:{name:'Arial',size:10,bold:true,color:'#FFFFFF'},rowHeight:29};
sheet.getRange(`A10:J${9+rows.length}`).format.rowHeight = 23;
sheet.getRange(`B10:B${9+rows.length}`).format.horizontalAlignment = 'center';
sheet.getRange(`A10:J${9+rows.length}`).format.verticalAlignment = 'center';
const widths = {A:17,B:7,C:42,D:15,E:45,F:18,G:55,H:18,I:21,J:18};
for (const [col,width] of Object.entries(widths)) sheet.getRange(`${col}:${col}`).format.columnWidth = width;
for (let i=0;i<categories.length;i++) {
  const first = 10+i*10;
  const last = first+9;
  sheet.getRange(`A${first}:J${last}`).format.fill = i%2 ? '#FFFFFF' : '#F5F8F7';
  sheet.getRange(`A${first}:A${last}`).format.font = {name:'Arial',size:10,bold:true,color:'#274D53'};
  sheet.getRange(`A${first}:J${first}`).format.borders = {top:{style:'thin',color:'#BBCDCA'}};
}
sheet.freezePanes.freezeRows(9);
sheet.freezePanes.freezeColumns(3);
const table = sheet.tables.add(`A9:J${9+rows.length}`,true,'MobilityPicks');
table.showFilterButton = true;
wb.recalculate();
const check = await wb.inspect({kind:'table',range:'Mobility picks!A9:J20',include:'values',tableMaxRows:12,tableMaxCols:10,maxChars:3500});
console.log(check.ndjson);
const errs = await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:20}});
console.log(errs.ndjson);
const preview = await wb.render({sheetName:'Mobility picks',range:'A2:G20',scale:1.3,format:'png'});
await fs.writeFile(path.join(outDir,'mobility_preview.png'),new Uint8Array(await preview.arrayBuffer()));
const output = await SpreadsheetFile.exportXlsx(wb);
const outputPath = path.join(outDir,'Raha_Move_Stretching_Mobility_Top_10.xlsx');
await output.save(outputPath);
console.log(JSON.stringify({areas:categories.length,selections:rows.length,uniqueMovements:unique.size,output:outputPath}));
