import readFile from '../utils/readFile';

const filterCards = (cardString: string): number[] => {
    return cardString.trim().replace(/\s+/g, ' ')
        .split(' ').map((strNum) => parseInt(strNum, 10));
};

const getCardsInTuple = (line: string): [number[], number[]] => {

    const indexStart = line.indexOf(': ');
    const allCards = line.substring(indexStart + 1);
    const [winCards, myCards] = allCards.split('|');

    const winCardsList = filterCards(winCards);
    const myCardsList = filterCards(myCards);
    return [winCardsList, myCardsList];

};

const countWins = (winCards: number[], myCards: number[]): number => {
    const commonNumber: number[] = myCards.filter(
        (num) => winCards.includes(num));
    if (commonNumber.length != 0) {
        return 2 ** (commonNumber.length - 1);
    }
    return 0;

};

const main = async () => {
    const fileContents = await readFile('./d4/input.txt');
    const lines = fileContents.split(/\r?\n/);

    const winPoints: number[] = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (!line.startsWith('Card')) {
            continue
        }
        const [winCards, myCards] = getCardsInTuple(line);
        winPoints.push(countWins(winCards, myCards));

        
    };
    console.log(winPoints.reduce((acc, num) => acc + num, 0));

};

main()
