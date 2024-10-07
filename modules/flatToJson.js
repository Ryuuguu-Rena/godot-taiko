const fs = require('node:fs');
let input = process.argv[2];
let output = input.slice(0, input.indexOf('.')) + '.map.test'
let bitmap;

try {
  const jsonstr = fs.readFileSync(input, 'utf8');
  bitmap = JSON.parse(jsonstr);
  bitmap = bitmap.map((item, i) => {
    return {
      id: i,
      //delay: +(item.end - item.start).toFixed(3),
      delay: item.delay,
      //type: 0
      type: item.type
    }
  })
  fs.writeFileSync(output, JSON.stringify(bitmap, null, '\t'))
} 
catch (err) {
  console.error(err)
}
