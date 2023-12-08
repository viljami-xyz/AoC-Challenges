import readFile from '../utils/readFile';

const main = async () => {
    const input: string = await readFile("./d2/input.txt")

    console.log(input);

}
main()
