import readFile from '../utils/readFile';

const filePath = './d1/input.txt';


const getNumber = (row: string[]): string => {

    for (const char of row) {
        if (!isNaN(Number(char))) {
            return String(char);
        }
    };
    return "0";
}

const wordToNumber: { [key: string]: number } = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,

}

const getAllIndexesOfSubstring = (row: string, substr: string): number[] => {
    const indexes: number[] = [];
    let currentIndex = row.indexOf(substr);

    while (currentIndex !== -1) {
        indexes.push(currentIndex);
        currentIndex = row.indexOf(substr, currentIndex + 1);

    }

    return indexes;
};

const reindexList = (row: string): number => {
    const indexValues: { [key: number]: number } = {};
    let firstValueIndex: number | undefined = undefined;
    let lastValueIndex: number | undefined = undefined;
    for (const key in wordToNumber) {
        const value = wordToNumber[key];
        const str_indexes = getAllIndexesOfSubstring(row, key);
        const int_indexes = getAllIndexesOfSubstring(row, String(value));
        str_indexes.forEach(item => {
            indexValues[item] = value;
            if (firstValueIndex === undefined || firstValueIndex >= item) {
                firstValueIndex = item;
            }
            if (lastValueIndex === undefined || lastValueIndex <= item) {
                lastValueIndex = item;
            }
        });

        int_indexes.forEach(item => {
            indexValues[item] = value
            if (firstValueIndex === undefined || firstValueIndex >= item) {
                firstValueIndex = item;
            }
            if (lastValueIndex === undefined || lastValueIndex <= item) {
                lastValueIndex = item;
            }
        });
    }

    if (firstValueIndex === undefined || lastValueIndex === undefined) {
        return 0
    }
    return Number(String(indexValues[firstValueIndex]) 
                  + String(indexValues[lastValueIndex]))


}
const main = async () => {

    let fileContents = await readFile(filePath);

    const lines: string[] = fileContents.split(/\r?\n/);


    const listOfNumber: number[] = [];
    lines.forEach((line, _) => {
        const concNum: number = reindexList(line);
        listOfNumber.push(concNum);
    });
    console.log(listOfNumber.reduce((acc, num) => acc + num, 0));

}


main()
