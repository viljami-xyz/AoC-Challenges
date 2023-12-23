
import readFile from "../utils/readFile";


interface CardGame {
    cards: number[];
    hand: number;
    bid: number;

}

const courtCards: { [key: string]: number } = {
    'A': 14,
    'K': 13,
    'Q': 12,
    'J': 1,
    'T': 10,
};

const getCards = (handString: string): number[] => {
    return handString.split('')
        .map((card) => courtCards[card] ?? Number(card));
}
const countOccurence = (arr: number[], target: number): number => {
    return arr.reduce((count, num) => (
        num === target ? count + 1 : count), 0);
};

const fullHouse = (cards: number[]): boolean => {
    const uniqueCards: number[] = [...new Set(cards)];
    if (uniqueCards.length != 2) {
        return false;
    }
    const firstCardCount: number = countOccurence(cards, uniqueCards[0]);
    const secondCardCount: number = countOccurence(cards, uniqueCards[1]);
    if (firstCardCount === 3 && secondCardCount === 2 ||
        firstCardCount === 2 && secondCardCount === 3) {
        return true;
    }

    return false
}

const twoPairs = (cards: number[]): boolean => {
    const uniqueCards: number[] = [...new Set(cards)];
    if (uniqueCards.length != 3) {
        return false;
    }
    const counts: number[] = [];
    for (let i = 0; i < uniqueCards.length; i++) {
        counts.push(countOccurence(cards, uniqueCards[i]));
    };
    if (countOccurence(counts, 2) === 2) {
        return true;
    }

    return false
}

const threeOfAKind = (cards: number[]): boolean => {
    const uniqueCards: number[] = [...new Set(cards)];
    if (uniqueCards.length != 3) {
        return false;
    }
    for (let i = 0; i < uniqueCards.length; i++) {
        const occurence = countOccurence(cards, uniqueCards[i]);
        if (occurence === 3) {
            return true;
        }
    }
    return false
}

const fourOfAKind = (cards: number[]): boolean => {
    const uniqueCards: number[] = [...new Set(cards)];
    for (let i = 0; i < uniqueCards.length; i++) {
        const occurence = countOccurence(cards, uniqueCards[i]);
        if (occurence === 4) {
            return true;
        }
    }
    return false
}


const getHand = (cards: number[]): number => {
    const uniqueCards: number[] = [...new Set(cards)];
    if (cards === uniqueCards) {
        return 1;
    }
    if (cards.length - 1 === uniqueCards.length) {
        return 2;
    }
    if (twoPairs(cards)) {
        return 3;
    }
    if (threeOfAKind(cards)) {
        return 4;
    }
    if (fullHouse(cards)) {
        return 5;
    }
    if (fourOfAKind(cards)) {
        return 6;
    }
    if (uniqueCards.length === 1) {
        return 7;
    }
    return 1;
}

const getHandWithJoker = (cards:number[]): number => {
    const uniqueCards: number[] = [...new Set(cards)];
    let hand: number = 1;
    if (cards.includes(1)) {
            uniqueCards.forEach((card) => {
                const jCards: number[] = cards.map((num) => (num === 1 ? card : num));
                const newHand: number = getHand(jCards);
                if (newHand > hand) {
                    hand = newHand;
                }
            })
    } else {
        hand = getHand(cards);
    }
    return hand;
};

const getHandWithBid = (data: string[]): CardGame[] => {
    const cardGames: CardGame[] = [];

    data.forEach((line) => {
        if (line.length < 2) {
            return;
        }
        const [hand, bid] = line.split(' ');
        const cardHand: number[] = getCards(hand);
        const handValue: number = getHandWithJoker(cardHand);
        const cardGame: CardGame = {
            cards: cardHand,
            bid: Number(bid),
            hand: handValue,
        }
        cardGames.push(cardGame);

    })
    return cardGames;

}

const sortTwoHands = (handOne: CardGame, handTwo: CardGame): boolean => {
    if (handOne.hand < handTwo.hand) {
        return false;
    }
    if (handOne.hand > handTwo.hand) {
        return true;
    }
    for (let i = 0; i < handOne.cards.length; i++) {
        const hOneCard = handOne.cards[i];
        const hTwoCard = handTwo.cards[i];
        if (hOneCard > hTwoCard) {
            return true;
        }
        if (hOneCard < hTwoCard) {
            return false;
        }
    }
    return false;

}


const main = async () => {
    const fileContent: string = await readFile('./d7/input.txt');
    const fileLines: string[] = fileContent.split(/\r?\n/);
    const cardGames: CardGame[] = getHandWithBid(fileLines);

    let sortedCards: CardGame[] = cardGames.slice().sort((a,b) =>
        sortTwoHands(a,b) ? 1 : -1);


    const winnings: number[] = [];
    for (let i=0;i<sortedCards.length;i++) {
        let w: number = i+1;
        winnings.push(sortedCards[i].bid*w);
    }
    console.log(winnings.reduce((a,b) => a+b));

}

main()
