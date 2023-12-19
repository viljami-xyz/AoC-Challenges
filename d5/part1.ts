import readFile from '../utils/readFile';


interface SeedSet {
    destination: number,
    source: number,
    range: number,
}

type mapObject = SeedSet[];
const mapObjectList: mapObject[] = [];

const inputFile = './d5/input.txt';

const getDataMap = (data: string): mapObject => {

    const splittedData: string[] = data.split(/\r?\n/);

    const dataMap: mapObject = [];
    for (let i = 1; i < splittedData.length; i++) {
        const line = splittedData[i];
        if (line == '') {
            continue
        }
        const [dst, src, len] = line.split(' ');

        const setOfSeed: SeedSet = {
            destination: Number(dst),
            source: Number(src),
            range: Number(len),
        };
        dataMap.push(setOfSeed);

    };
    return dataMap;
};

const getPlace = (seedMap: SeedSet, seed: number): number => {
    const lowerRange: number = seedMap.source;
    const upperRange: number = seedMap.source + seedMap.range;
    const locationIndex: number = seed - seedMap.source;
    if (seed >= lowerRange && seed <= upperRange) {
        return seedMap.destination + locationIndex;
    }
    return seed;

};

const mapNewSeedLocation = (seedMaps: SeedSet[], seeds:number[]): number[] => {
    const newLocations: number[] = [];

    outerLoop: for (let x = 0; x < seeds.length; x++) {
        const seed = seeds[x];
        for (let i = 0; i < seedMaps.length; i++) {
            const seedMap = seedMaps[i];
            const seedPlace = getPlace(seedMap, seed);
            if (seed != seedPlace) {
                newLocations.push(seedPlace);
                continue outerLoop;
            }

        }
        newLocations.push(seed);
    }
    return newLocations;


}
const countSeedMaps = (seeds: number[], seedMaps: mapObject[]): number => {

    for (let i = 0; i < seedMaps.length; i++) {
        const locations: number[] = [];

        seeds = mapNewSeedLocation(
            seedMaps[i], seeds);

    }
    const lowestNumber: number = seeds.sort((a,b)=> a-b)[0];

    return lowestNumber;
}

const main = async () => {
    const fileContent: string = await readFile(inputFile);

    const splittedMaps: string[] = fileContent.split(/\n\n/);

    const seeds: number[] = splittedMaps[0]
        .match(/\d+(\d+)?/g)?.map(Number) || [];

    splittedMaps.slice(1).forEach((set) => {
        const dataMap: mapObject = getDataMap(set);
        mapObjectList.push(dataMap);

    })

    const lowestSeed: number = countSeedMaps(seeds, mapObjectList);

    console.log(lowestSeed);

}
main()
