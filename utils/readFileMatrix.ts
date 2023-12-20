import * as fs from 'fs';

function readFileMatrix(filePath: string): string[][] {

    const fileContent: string = fs.readFileSync(filePath, 'utf-8');

    const lines: string[] = fileContent.split(/\r?\n/);

    const matrix: string[][] = lines.map(line => 
        line.split(''))

    return matrix;
};

export default readFileMatrix;
