
import readFileMatrix from '../utils/readFileMatrix';


const inputFile: string = './d3/input.txt';

enum Char {
    Number,
    Dot,
    NormGear,
    MultiGear,
};
const isRealChar = (char: string): Char => {
    return Char.Dot;
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


const getMultiplyMatrixes = (row:string[], y: number)=> {
    const multiplyIndexes: [number, number][] = [];
        for (let x = 0; x < row.length; x++) {
            if (row[y][x] == '*') {
                multiplyIndexes.push([y, x]);
            }
    }
    return multiplyIndexes;
};

const loopOverMatrix = (matrix: string[][]) => {
    let partIndexes: [number, number][][] = [];
    let multiplyIndexes: [number, number][] = [];
    for (let y = 0; y < matrix.length; y++) {
        const row = matrix[y];
        let rowParts: [number, number][] = getLinePartIndexes(row.join());
        multiplyIndexes = [...multiplyIndexes, 
            ...getMultiplyMatrixes(row,y)];
    }
};

const main = async () => {
    const matrix = readFileMatrix(inputFile);
    const xMatrix = matrix[0].length;
    const yMatrix = matrix.length;
    const indexes: [number, number][][] = [];
    for (let y = 0; y < yMatrix; y++) {
        if (matrix[y] === undefined) {
            indexes.push([]);
            continue
        }
        const joinedLine = matrix[y].join();
        const partIndexes = getLinePartIndexes(joinedLine);
        indexes.push(partIndexes);

    };
};

main();
