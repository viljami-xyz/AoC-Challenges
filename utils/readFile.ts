
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

export default readFile;

