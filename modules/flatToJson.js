const fs = require('node:fs');

try {
  const input = fs.readFileSync(process.argv[2], 'utf8');
  console.log(input)
} 
catch (err) {
  console.error(err)
}
