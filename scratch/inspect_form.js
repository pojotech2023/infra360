const fs = require('fs');

let html = fs.readFileSync('scratch/sand_form.html', 'utf8');
let forms = [...html.matchAll(/<form([^>]*)>([\s\S]*?)<\/form>/g)];
console.log('Number of forms:', forms.length);
forms.forEach((f, i) => {
    console.log('Form', i, f[1]);
    let names = [...f[2].matchAll(/name=["']([^"']+)["']/g)].map(m => m[1]);
    console.log('   names:', [...new Set(names)]);
});

