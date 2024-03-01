import readFile from "../utils/readFile";

const getRaces = (fileData: string): [number, number][] => {
    const allValues = fileData
        .match(/\d+(\d+)?/g)?.map(Number) || [];

    const listOfRaces: [number, number][] = [];

    for (let i = 0; i < allValues.length / 2; i++) {
        const distance = i + allValues.length / 2;
        listOfRaces.push([allValues[i], allValues[distance]]);

    }
    return listOfRaces;


}

const countRaceDistance = (buttonTime:number, maxTime:number):number => {
    const travelTime: number = maxTime-buttonTime;
    return travelTime*buttonTime;

}

const countRaceWins = (race: [number,number]): number => {
    let wins: number = 0;
    const [time, distance]: [number,number] = race;
    for (let i = 0; i<time;i++) {
        if (countRaceDistance(i,time)>distance) {
            wins++;
        }

    }
    return wins;


}
const getWinsMultiplied = (races:[number,number][]): number => {
    const allWins: number[] = [];
    races.forEach((race) => {
        allWins.push(countRaceWins(race));

    })
    return allWins.reduce((a,b) => a*b);

}

const main = async () => {
    const fileContent: string = await readFile('./d6/input.txt');
    const races: [number, number][] = getRaces(fileContent);

    const result: number = getWinsMultiplied(races);

    console.log(result);
}

main()
