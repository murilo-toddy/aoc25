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

const trimToInt = (line) => trim(line).map(Number).filter(Number.isInteger);

function transpose(lines) {
    const rows = lines.length;
    if (rows === 0) {
        return [];
    }
    const cols = lines[0].length;
    const transposed = new Array(cols);
    for (let i = 0; i < cols; i++) {
        transposed[i] = Array(rows);
    }
    for (let row = 0; row < rows; row++) {
        for (let col = 0; col < cols; col++) {
            transposed[col][row] = lines[row][col];
        }
    }
    return transposed;
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
        const parsedLines = lines.map(line => trimToInt(line))
        const result = transpose(parsedLines)
            .map((elems, i) => calculate(elems, opLines[i]))
            .reduce((acc, res) => acc + res, 0);
        console.log(result);
    })
    .catch(error => console.error(`failed to read lines: ${error}`));
