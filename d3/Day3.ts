import readFile from '../utils/readFile';


const inputFile: string = './d3/input.txt';

const getRealPartChar = (char: string): boolean => {
    if (char === undefined) {
        return false
    }
    if (isNaN(Number(char)) && char != '.') {
        return true
    }
    return false
};

const gatherHorizontalAdjacents = (
    row: string[], part: [number, number]): boolean => {
    if (getRealPartChar(row[part[0] - 1])) {
        return true
    }
    //console.log(`${row.slice(part[0], part[1]).join('')}: ${row[part[0] - 1]} - ${row[part[1]]}`);
    if (getRealPartChar(row[part[1]])) {
        return true
    }

    return false
};

const gatherVerticalAdjacents =
    (row: string[], part: [number, number]) => {

        for (const char of row.slice(part[0], part[1])) {
            if (getRealPartChar(char)) {
                return true
            }
        }
        return gatherHorizontalAdjacents(row, part);
    };

const checkPartNumber =
    (rows: [any, any, any],
        part: [number, number]): boolean => {
        const lastRow: string[] = rows[0].split('');
        const thisRow: string[] = rows[1].split('');
        const nextRow: string[] = rows[2].split('');

        if (gatherVerticalAdjacents(lastRow, part)) {
            return true
        }
        if (gatherHorizontalAdjacents(thisRow, part)) {
            return true
        }
        if (gatherVerticalAdjacents(nextRow, part)) {
            return true
        }
        return false
    };

const getLinePartIndexes = (line: string) => {
    const indexList: [number, number][] = [];
    const regex: RegExp = /\d+/g;
    let match;

    while ((match = regex.exec(line)) !== null) {
        const number = match[0];
        const index = match.index;
        indexList.push([index,
            index + String(number).split('').length]);
    }
    return indexList;
}

const getRequiredLines = (lines: string[], currentRow: number): [string, string, string] => {
    if (currentRow === 0) {
        return ["", lines[currentRow], lines[currentRow + 1]];
    }
    else if (currentRow === lines.length) {
        return [lines[currentRow - 1], lines[currentRow], ""];
    }
    else {
        return [lines[currentRow - 1], lines[currentRow], lines[currentRow + 1]];
    }
};

const countRowParts = (partIndexes: [number, number][],
    rows: [string, string, string]): number[] => {
    const rowParts: number[] = [];
    partIndexes.forEach(part => {
        if (checkPartNumber(rows, part)) {
            const partNumber = Number(rows[1].slice(part[0], part[1]));
            rowParts.push(partNumber);
        }
    })
    return rowParts
};

const main = async () => {
    const fileData: string = await readFile(inputFile);
    const lines: string[] = fileData.split(/\r?\n/);
    let partNumbers: number[] = [];
    for (let y = 0; y < lines.length; y++) {
        const line: string = lines[y];
        const partIndexes: [number, number][] = getLinePartIndexes(line);
        const adjacentRows: [string, string, string] = getRequiredLines(lines, y);
        const rowParts: number[] = countRowParts(partIndexes, adjacentRows);
        partNumbers = [...partNumbers, ...rowParts];
    }
    console.log(partNumbers);
    const sumOfParts = partNumbers.reduce((sum, num) => sum + num, 0);
    console.log(sumOfParts);
};
main()
