import * as fs from 'fs';

const readFile = (filePath: string): Promise<string> => {

    return new Promise((resolve, reject) => {
        fs.readFile(filePath, 'utf8', (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        });
    });
}



const filePath = './d1/input.txt';

readFile(filePath)
    .then((fileContents) => {
        console.log('File contents: ', fileContents);
    })
    .catch((error) => {
        console.error('Error reading file:', error);
    });
