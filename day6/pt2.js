const readline = require('readline');

async function readLines() {
    const reader = readline.createInterface({ input: process.stdin });
    const lines = [];
    for await (const line of reader) {
        lines.push(line);
    }
    reader.close();
    return lines;
}

const trim = (line) => line.split(" ").filter(elem => elem.length > 0);

const toIntArray = (line) => line
    .filter(elem => elem !== " ")
    .map(Number)
    .filter(Number.isInteger);

function toInt(elems) {
    let result = 0;
    for (let i = elems.length - 1; i >= 0; i--) {
        result += elems[i] * Math.pow(10, elems.length - i - 1);
    }
    return result;
}

function parseNumberLines(lines) {
    if (lines.length === 0) return [];
    const rows = [[]];
    for (let i = 0; i < lines[0].length; i++) {
        const ns = toIntArray(lines.map(line => line[i]));
        if (ns.length === 0) {
            rows.push([]);
        } else {
            rows.at(-1).push(toInt(ns));
        }
    }
    return rows;
}

function calculate(elems, op) {
    switch (op) {
    case "+": return elems.reduce((acc, e) => acc + e, 0)
    case "*": return elems.reduce((acc, e) => acc * e, 1)
    default: console.error(`operation not found ${op}`)
    }
    return null;
}

readLines()
    .then(lines => {
        const opLines = trim(lines.pop());
        const result = parseNumberLines(lines)
            .map((elems, i) => calculate(elems, opLines[i]))
            .reduce((acc, res) => acc + res, 0);
        console.log(result);
    })
    .catch(error => console.error(`failed to read lines: ${error}`));
