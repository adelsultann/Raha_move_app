import fs from 'node:fs/promises';
import path from 'node:path';
import { Workbook, SpreadsheetFile } from '@oai/artifact-tool';

const outDir = path.dirname(new URL(import.meta.url).pathname.replace(/^\/(?:[A-Za-z]:)/, m => m.slice(1)));
const index = JSON.parse(await fs.readFile(path.join(outDir, 'source_index.json'), 'utf8'));

// Each selection is source illustration ID, app name, complementary categories.
// The source rows provide equipment, original name, targets and media IDs.
const groups = [
  ['Chest', [
    ['0025','Barbell Bench Press','Shoulders, Triceps'],['0047','Barbell Incline Bench Press','Shoulders, Triceps'],
    ['0289','Dumbbell Bench Press','Shoulders, Triceps'],['0314','Dumbbell Incline Bench Press','Shoulders, Triceps'],
    ['0662','Push-up','Shoulders, Triceps, Core'],['0493','Incline Push-up','Shoulders, Triceps, Core'],
    ['0251','Chest Dip','Shoulders, Triceps'],['0308','Dumbbell Fly','Shoulders'],
    ['1030','Pec Deck Fly','Shoulders'],['3869','Cable Seated Chest Fly','Shoulders'],
  ]],
  ['Back', [
    ['0652','Pull-up','Biceps, Forearms'],['0017','Assisted Pull-up','Biceps, Forearms'],
    ['0027','Barbell Bent-over Row','Biceps, Forearms, Core'],['0292','Single-arm Dumbbell Row','Biceps, Forearms'],
    ['0180','Seated Cable Row','Biceps, Forearms'],['0499','Inverted Row','Biceps, Core'],
    ['0606','T-bar Row','Biceps, Forearms'],['0238','Straight-arm Cable Pulldown','Shoulders, Core'],
    ['0489','Back Extension','Glutes, Hamstrings'],['0032','Conventional Barbell Deadlift','Glutes, Hamstrings, Forearms'],
  ]],
  ['Shoulders', [
    ['0405','Seated Dumbbell Shoulder Press','Triceps'],['0765','Smith Machine Shoulder Press','Triceps'],
    ['0334','Dumbbell Lateral Raise',''],['0178','Cable Lateral Raise',''],
    ['0383','Dumbbell Reverse Fly','Back'],['0602','Reverse Pec Deck Fly','Back'],
    ['5609','Cable Face Pull','Back'],['3525','Single-arm Landmine Press','Triceps, Core'],
    ['0310','Dumbbell Front Raise','Chest'],['1107','Suspension Y Raise','Back'],
  ]],
  ['Biceps', [
    ['0031','Barbell Curl','Forearms'],['0447','EZ-bar Curl','Forearms'],
    ['0156','Cable Curl','Forearms'],['0318','Incline Dumbbell Curl','Forearms'],
    ['0313','Dumbbell Hammer Curl','Forearms'],['0070','Barbell Preacher Curl','Forearms'],
    ['0297','Dumbbell Concentration Curl','Forearms'],['0439','Dumbbell Zottman Curl','Forearms'],
    ['0165','Rope Hammer Curl','Forearms'],['0372','Dumbbell Preacher Curl','Forearms'],
  ]],
  ['Triceps', [
    ['0030','Close-grip Bench Press','Chest, Shoulders'],['0814','Parallel-bar Triceps Dip','Chest, Shoulders'],
    ['0241','Cable Triceps Pushdown',''],['0194','Rope Overhead Triceps Extension',''],
    ['0060','Barbell Skull Crusher',''],['0430','Standing Dumbbell Triceps Extension',''],
    ['0333','Dumbbell Triceps Kickback',''],['1104','Suspension Triceps Extension','Core'],
    ['0259','Close-grip Push-up','Chest, Shoulders, Core'],['1771','Kneeling Bodyweight Triceps Extension','Core'],
  ]],
  ['Forearms', [
    ['0126','Barbell Wrist Curl',''],['0082','Barbell Reverse Wrist Curl',''],
    ['0080','Barbell Reverse Curl','Biceps'],['0385','Dumbbell Reverse Wrist Curl',''],
    ['0397','Seated Neutral-grip Wrist Curl',''],['1044','Plate Pinch',''],
    ['2917','Dumbbell Farmer Carry','Core, Back'],['0859','Wrist Roller',''],
    ['10038','Dumbbell Wrist Supination',''],['0429','Dumbbell Reverse Curl','Biceps'],
  ]],
  ['Core', [
    ['0465','Front Plank','Shoulders, Glutes'],['0715','Side Plank','Shoulders, Glutes'],
    ['0276','Dead Bug','Glutes'],['0135','Bird Dog','Back, Glutes'],
    ['1202','Cable Pallof Press','Shoulders'],['0671','Reverse Crunch',''],
    ['9819','Hanging Knee Raise','Forearms'],['0857','Ab Wheel Rollout','Shoulders, Back'],
    ['0687','Russian Twist',''],['0175','Cable Kneeling Crunch',''],
  ]],
  ['Glutes & hips', [
    ['1060','Barbell Hip Thrust','Hamstrings, Core'],['2072','Bodyweight Hip Thrust','Hamstrings, Core'],
    ['2964','Barbell Glute Bridge','Hamstrings, Core'],['0710','Side-lying Hip Abduction',''],
    ['4421','Cable Glute Kickback','Hamstrings'],['0117','Sumo Barbell Deadlift','Quadriceps, Hamstrings, Back'],
    ['0802','Sumo Squat','Quadriceps'],['1477','Kneeling Straight-leg Kickback','Hamstrings'],
    ['0597','Seated Hip Abduction Machine',''],['0196','Cable Pull-through','Hamstrings, Back'],
  ]],
  ['Quadriceps', [
    ['0043','Barbell Back Squat','Glutes & hips, Hamstrings, Core'],['0042','Barbell Front Squat','Glutes & hips, Core'],
    ['0534','Kettlebell Goblet Squat','Glutes & hips, Core'],['0739','45-degree Leg Press','Glutes & hips'],
    ['0585','Leg Extension Machine',''],['3533','Bulgarian Split Squat','Glutes & hips'],
    ['0431','Dumbbell Step-up','Glutes & hips'],['0054','Barbell Lunge','Glutes & hips'],
    ['0732','Pistol Squat','Glutes & hips, Core'],['0781','Split Squat','Glutes & hips'],
  ]],
  ['Hamstrings', [
    ['0085','Barbell Romanian Deadlift','Glutes & hips, Back'],['1459','Dumbbell Romanian Deadlift','Glutes & hips, Back'],
    ['0586','Lying Leg Curl Machine',''],['0599','Seated Leg Curl Machine',''],
    ['7746','Nordic Hamstring Curl','Glutes & hips'],['0569','Stability-ball Leg Curl','Glutes & hips, Core'],
    ['3395','Sliding Towel Leg Curl','Glutes & hips, Core'],['0044','Barbell Good Morning','Glutes & hips, Back'],
    ['1757','Single-leg Dumbbell Deadlift','Glutes & hips, Back, Core'],['4456','Glute-ham Raise','Glutes & hips, Back'],
  ]],
  ['Calves', [
    ['1373','Bodyweight Standing Calf Raise',''],['0605','Standing Calf Raise Machine',''],
    ['0594','Seated Calf Raise Machine',''],['0409','Single-leg Dumbbell Calf Raise',''],
    ['0284','Donkey Calf Raise',''],['1391','Leg Press Calf Press',''],
    ['1490','Staircase Calf Raise',''],['1379','Seated Dumbbell Calf Raise',''],
    ['1375','Cable Standing Calf Raise',''],['9409','Standing Bent-knee Calf Raise',''],
  ]],
  ['Cardio', [
    ['0685','Running','Quadriceps, Hamstrings, Glutes & hips, Calves'],['2258','Walking','Quadriceps, Hamstrings, Glutes & hips, Calves'],
    ['0511','Jump Rope','Calves, Shoulders'],['1161','Rowing Machine','Back, Quadriceps, Core'],
    ['2192','Elliptical Trainer','Quadriceps, Glutes & hips, Calves'],['2279','Stationary Bike','Quadriceps, Glutes & hips'],
    ['1160','Burpee','Chest, Quadriceps, Core'],['0630','Mountain Climber','Core, Shoulders, Quadriceps'],
    ['0516','Jumping Jack','Calves, Shoulders'],['3893','Assault Bike','Quadriceps, Shoulders'],
  ]],
  ['Plyometrics', [
    ['0514','Jump Squat','Quadriceps, Glutes & hips, Calves'],['0564','Lateral Box Jump','Quadriceps, Glutes & hips, Calves'],
    ['3361','Skater Hop','Glutes & hips, Quadriceps, Calves'],['3582','Jumping Lunge','Quadriceps, Glutes & hips, Calves'],
    ['5460','Explosive Push-up','Chest, Triceps, Shoulders'],['9070','Two-foot Pogo Jump','Calves'],
    ['0515','Jump Step-up','Quadriceps, Glutes & hips, Calves'],['0797','Star Jump','Calves, Quadriceps, Shoulders'],
    ['10160','Box Drop with Two-foot Landing','Quadriceps, Glutes & hips, Calves'],['1354','Medicine-ball Overhead Slam','Core, Shoulders, Back'],
  ]],
  ['Stretching & mobility', [
    ['1053','Kneeling Hip-flexor Stretch','Glutes & hips, Quadriceps'],['1511','Hamstring Stretch','Hamstrings'],
    ['1059','Standing Quadriceps Stretch','Quadriceps'],['1377','Wall Calf Stretch','Calves'],
    ['7553','Doorway Chest Stretch','Chest, Shoulders'],['1980','Cross-body Shoulder Stretch','Shoulders'],
    ['0643','Overhead Triceps Stretch','Triceps, Shoulders'],['0711','Side Lunge Adductor Stretch','Glutes & hips, Hamstrings'],
    ['5055','Dead Hang Stretch','Back, Shoulders, Forearms'],['8052','Kneeling Thoracic Rotation','Back, Core'],
  ]],
  ['Neck', [
    ['5062','Lying Chin Tuck','Back'],['5063','Seated Chin Tuck','Back'],
    ['5061','Prone Cervical Extension Isometric Hold','Back'],['5145','Posterior Neck Isometric','Back'],
    ['0713','Side Neck Stretch','Shoulders'],['1831','Neck Rotation Stretch','Shoulders'],
    ['1838','Neck Extension and Rotation Stretch','Shoulders'],['0462','Front and Back Neck Stretch','Shoulders'],
    ['3441','Seated Neck Flexion and Extension','Shoulders'],['1836','Forward Neck Flexion Stretch','Shoulders'],
  ]],
  ['Weightlifting', [
    ['5190','Barbell Clean and Jerk','Quadriceps, Glutes & hips, Back, Shoulders'],['1533','Barbell Snatch','Quadriceps, Glutes & hips, Back, Shoulders'],
    ['5287','Barbell Full Clean','Quadriceps, Glutes & hips, Back'],['1530','Barbell Power Snatch','Quadriceps, Glutes & hips, Back, Shoulders'],
    ['1520','Barbell Hang Clean','Quadriceps, Glutes & hips, Back'],['1522','Barbell Hang Snatch','Quadriceps, Glutes & hips, Back, Shoulders'],
    ['1538','Barbell Split Jerk','Quadriceps, Glutes & hips, Shoulders, Triceps'],['1529','Barbell Power Jerk','Quadriceps, Glutes & hips, Shoulders, Triceps'],
    ['1517','Barbell Clean Pull','Quadriceps, Glutes & hips, Back'],['1200','Push Press','Quadriceps, Glutes & hips, Shoulders, Triceps'],
  ]],
  ['Yoga', [
    ['0945','Child Pose','Back, Glutes & hips'],['0949','Downward-facing Dog','Back, Shoulders, Hamstrings, Calves'],
    ['0963','Warrior II','Quadriceps, Glutes & hips, Shoulders'],['0964','Warrior I','Quadriceps, Glutes & hips, Shoulders'],
    ['0961','Tree Pose','Glutes & hips, Core, Calves'],['0962','Triangle Pose','Hamstrings, Glutes & hips, Core'],
    ['0951','Garland Pose','Glutes & hips, Quadriceps'],['0941','Bridge Pose','Glutes & hips, Hamstrings'],
    ['0942','Cat Pose','Back, Core'],['0959','Standing Forward Bend','Hamstrings, Back'],
  ]],
];

const seen = new Map();
const rows = [];
for (const [category, picks] of groups) {
  if (picks.length !== 10) throw new Error(`${category} has ${picks.length} picks`);
  for (let i = 0; i < picks.length; i++) {
    const [id, display, secondary] = picks[i];
    const source = index[id];
    if (!source) throw new Error(`Missing source illustration ${id}`);
    if (seen.has(id)) throw new Error(`Duplicate source ID ${id}: ${seen.get(id)} and ${category}`);
    seen.set(id, category);
    rows.push([category, i + 1, display, secondary || '—', source.equipment || '—', source.name, id,
      source['Animated GIFs']?.id || '—', source.Videos?.id || '—', source.bodypart || '—', source.target || '—']);
  }
}

const wb = Workbook.create();
const sheet = wb.worksheets.add('Top 10 by category');
sheet.showGridLines = false;
sheet.tabColor = '#17324D';
sheet.getRange('A2').values = [['Gym visual exercise shortlist']];
sheet.getRange('A3').values = [[`${groups.length} categories · 10 exercises each · ${rows.length} selections`]];
sheet.getRange('A5').values = [['Primary category reflects the main training use. Complementary categories show meaningful overlap.']];
sheet.getRange('A6').values = [['Rank is an editorial shortlist order, not a measured effectiveness score. Use the IDs to locate each visual in the source workbook.']];
sheet.getRange('A7').values = [['Source BodyPart and Source Target are copied as provided; some source labels are inconsistent with the exercise name.']];
sheet.getRange('A8:K8').values = [[
  'Primary category','Pick','Exercise name','Complementary categories','Equipment','Source name','Illustration ID','Animated GIF ID','Video ID','Source BodyPart','Source Target'
]];
sheet.getRange(`A9:K${8+rows.length}`).values = rows;
sheet.getRange(`A2:K${8+rows.length}`).format.font = {name:'Arial',size:10,color:'#202A35'};
sheet.getRange('A2').format.font = {name:'Arial',size:16,bold:true,color:'#17324D'};
sheet.getRange('A3').format.font = {name:'Arial',size:10,italic:true,color:'#526373'};
sheet.getRange('A5:A7').format.font = {name:'Arial',size:10,italic:true,color:'#526373'};
sheet.getRange('A8:K8').format = {fill:'#17324D',font:{name:'Arial',size:10,bold:true,color:'#FFFFFF'},rowHeight:30};
sheet.getRange(`A9:K${8+rows.length}`).format.rowHeight = 22;
sheet.getRange(`A9:K${8+rows.length}`).format.verticalAlignment = 'center';
sheet.getRange(`B9:B${8+rows.length}`).format.horizontalAlignment = 'center';
const widths = {A:20,B:7,C:40,D:40,E:22,F:48,G:17,H:18,I:16,J:21,K:50};
for (const [col, width] of Object.entries(widths)) sheet.getRange(`${col}:${col}`).format.columnWidth = width;
let start = 9;
for (let gi=0;gi<groups.length;gi++) {
  const fill = gi%2===0 ? '#F4F7FA' : '#FFFFFF';
  sheet.getRange(`A${start}:K${start+9}`).format.fill = fill;
  sheet.getRange(`A${start}:A${start+9}`).format.font = {name:'Arial',size:10,bold:true,color:'#17324D'};
  sheet.getRange(`A${start}:K${start}`).format.borders = {top:{style:'thin',color:'#A9B9C8'}};
  start += 10;
}
sheet.freezePanes.freezeRows(8);
sheet.freezePanes.freezeColumns(3);
const table = sheet.tables.add(`A8:K${8+rows.length}`, true, 'ExercisePicks');
table.showFilterButton = true;

wb.recalculate();
const check = await wb.inspect({kind:'table',range:'Top 10 by category!A8:K20',include:'values',tableMaxRows:13,tableMaxCols:11,maxChars:5000});
console.log(check.ndjson);
const errorCheck = await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:20},summary:'final error scan'});
console.log(errorCheck.ndjson);
const preview = await wb.render({sheetName:'Top 10 by category',range:'A2:F20',scale:1.4,format:'png'});
await fs.writeFile(path.join(outDir,'preview.png'),new Uint8Array(await preview.arrayBuffer()));
const xlsx = await SpreadsheetFile.exportXlsx(wb);
await xlsx.save(path.join(outDir,'Gym_Visual_Top_10_by_Category.xlsx'));
console.log(JSON.stringify({categories:groups.length,rows:rows.length,output:path.join(outDir,'Gym_Visual_Top_10_by_Category.xlsx')}));
