import readFile from '../utils/readFile';

type Colors = { [key: string]: number };
const colorCountLimit: Colors = {
    "green": 13,
    "blue": 14,
    "red": 12,
}
const getGameId = (title: string) => {
    const gameId: string | undefined = title.split(' ').pop();
    return Number(gameId)
};


const getColorCount = (pair: string): [string, number] => {
    const countAndColor: string[] = pair
        .trim().split(' ');
    const colorAndCount: [string, number] = [countAndColor[1],
    Number(countAndColor[0])];
    return colorAndCount
};
const getSetOfGameP1 = (gameSet: string) => {
    const setColorCount: Colors = {
        "green": 0,
        "blue": 0,
        "red": 0,
    };
    gameSet = gameSet.trim();
    const colorAndCount: string[] | undefined = gameSet.split(',');
    colorAndCount.forEach(pair => {
        const [color, value] = getColorCount(pair);
        setColorCount[color] += value;
    });
    for (const key in setColorCount) {
        if (setColorCount[key] > colorCountLimit[key]) {
            return false
        }
    };
    return true;
};


const getPlausibleGameP1 = (row: string) => {

    const gameIdAndValues: string[] = row.split(':');
    const gameId: number = getGameId(gameIdAndValues[0]
    );
    const sets: string[] = gameIdAndValues[1].split(';');
    for (const gameSet of sets) {
        if (!getSetOfGameP1(gameSet)) {
            return 0
        }
    };
    return gameId;

};

const getSetOfGameP2 = (gameSet: string) => {
    const setColorCount: Colors = {
        "green": 0,
        "blue": 0,
        "red": 0,
    };
    gameSet = gameSet.trim();
    const colorAndCount: string[] | undefined = gameSet.split(',');
    colorAndCount.forEach(pair => {
        const [color, value] = getColorCount(pair);
        setColorCount[color] += value;
    });
    return setColorCount;
};


const getPlausibleGameP2 = (row: string) => {

    const gameIdAndValues: string[] = row.split(':');
    const sets: string[] = gameIdAndValues[1].split(';');
    const minCubeCount: Colors = {
        "green": 0,
        "blue": 0,
        "red": 0,
    };
    for (const gameSet of sets) {
        const cubeCount = getSetOfGameP2(gameSet);
        for (const key in minCubeCount) {
            if (minCubeCount[key] < cubeCount[key]) {
                minCubeCount[key] = cubeCount[key];
            };
        }
    }
    let multiplied: number = 1;
    for (const key in minCubeCount) {
        if (minCubeCount[key] != 0) {
            multiplied = multiplied * minCubeCount[key];
        }
    };
    return multiplied;
};


const main = async () => {
    const input: string = await readFile("./d2/input.txt")
    const games: string[] = input.split(/\r?\n/);
    const plausiblesP1: number[] = [];
    const plausiblesP2: number[] = [];

    games.forEach(game => {
        if (game.includes(":")) {
            plausiblesP1.push(getPlausibleGameP1(game));
            const p2Game: number = getPlausibleGameP2(game);
            plausiblesP2.push(p2Game);
        }
    })


    const sumOfIdsP1: number = plausiblesP1.reduce((acc, num) => acc + num, 0);
    const sumOfIdsP2: number = plausiblesP2.reduce((acc, num) => acc + num, 0);
    console.log(`Part 1 answe: ${sumOfIdsP1}`);
    console.log(`Part 2 answe: ${sumOfIdsP2}`);
}
main();
