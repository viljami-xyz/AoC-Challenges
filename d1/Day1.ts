import readFile from '../utils/readFile';

const filePath = './d1/input.txt';


const getNumber = (row: string[]): string => {

    for (const char of row)  {
        if (!isNaN(Number(char))) {
            return String(char);
        }
    };
    return "0"; 
}


const main = async () => {

    const fileContents = await readFile(filePath);

    const lines: string[] = fileContents.split(/\r?\n/);

    const listOfNumber: number[]= [];
    lines.forEach((line, _) => {
        const listed: string[] = line.split('');
        const firstNum: string =getNumber(listed);
        const lastNum: string = getNumber(listed.reverse());
        listOfNumber.push(Number(firstNum + lastNum));
    });
    console.log(listOfNumber.reduce((acc, num) => acc + num, 0));

}


main()
