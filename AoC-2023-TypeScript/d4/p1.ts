import readFile from '../utils/readFile';

const cards: { [key: number]: number } = {};

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

const countWins = (winCards: number[], myCards: number[]):
    [number, number] => {
    const commonNumber: number[] = myCards.filter(
        (num) => winCards.includes(num));
    const matches = commonNumber.length;
    if (matches != 0) {
        return [2 ** (matches - 1), matches];
    }
    return [0, 0];

};

const createCopies = (
    currentCard: number,
    copyAmount: number,
    maxCards: number = 199) => {
    for (let i = 0;
        i < copyAmount; i++) {
        if (currentCard + i > maxCards) {
            return;
        }
        const thisCard = currentCard + i + 1;
        if (thisCard in cards) {
            cards[thisCard] += 1;
        } else {
            cards[thisCard] = 1;
        }
    }
};


const main = async () => {
    const fileContents = await readFile('./d4/input.txt');
    const lines = fileContents.split(/\r?\n/);

    for (let i = 1; i < 200; i++) {
        cards[i] = 1;
    }
    const winPoints: number[] = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const currentCard = i + 1;
        if (!line.startsWith('Card')) {
            continue
        }
        const [winCards, myCards] = getCardsInTuple(line);
        const [matches, copies] = countWins(winCards, myCards);
        if (copies > 0) {
            for (let y = 0;
                y < cards[currentCard]; y++) {
                createCopies(currentCard, copies);
            }
            winPoints.push(matches);
        }

    };
    console.log(winPoints.reduce((acc, num) => acc + num, 0));
    let allCards: number = 0;
    for (let key in cards) {
        allCards += cards[key];
    };
    console.log(allCards);

};

main()
