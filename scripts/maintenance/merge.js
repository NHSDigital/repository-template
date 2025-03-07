/*******************************************************************************
 * Script to merge all added lines from source to target.
 * Modified lines will be left intact.
 *
 * This is intended for updating config files like .tool-versions and .gitignore
 * where the first token on the line remains the same
 *
 * Usage:
 *   $ node merge.js <target> <source>
 *
 * Output:
 *   Outputs the merged file to stdout
 *
 *******************************************************************************/

const fs = require("fs");

// Read files
const [file1, file2] = process.argv.slice(2);
const lines1 = fs.readFileSync(file1).toString().split('\n');
const lines2 = fs.readFileSync(file2).toString().split('\n');

// Tokenize lines in file1 for later comparison
const tokenize = line => {
  if (line === '') {
    return [];
  }
  return line.split(/\s+/).filter(x => x !== '#').slice(0, 1);
};
const lines1Tokens = lines1.flatMap(tokenize);

// Step through the files
let pos1 = 0, pos2 = 0;
while (pos1 < lines1.length || pos2 < lines2.length) {

  const l1 = pos1 < lines1.length && lines1[pos1] || '';
  const l2 = pos2 < lines2.length && lines2[pos2] || '';

  // If the lines match, print l1 and skip l2
  if (l1 !== '' && l1 === l2) {
    process.stdout.write(`${l1}\n`);
    pos1++;
    pos2++;
    continue;
  }

  if (pos2 < lines2.length) {
    // If l2 is empty, skip l2
    if (l2 === '') {
      pos2++;
      continue;
    }

    const [l2token] = tokenize(l2);

    // If l2 token matches l1 token, print l1
    if (pos1 < lines1.length && lines1Tokens[pos1] === l2token) {
      process.stdout.write(`${l1}\n`);
      pos1++;
      pos2++;
      continue;
    }

    // If l2 doesn't match any lines in file1, print l2
    if (l2token && !lines1Tokens.includes(l2token)) {
      process.stdout.write(`${l2}\n`);
    }
    pos2++
    continue;
  }

  // If we're not at the end of file1, print l1
  if (pos1 < lines1.length) {
    if (pos1 === lines1.length - 1 && l1 === '') {
      // Don't print tailing newline
    } else {
      process.stdout.write(`${l1}\n`);
    }
    pos1++;
  }
}
