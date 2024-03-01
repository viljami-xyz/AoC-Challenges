import readFile from '../utils/readFile';
import * as fs from 'fs';

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

const mapNewSeedLocation = (seedMaps: SeedSet[], seed: number): number => {

    for (let i = 0; i < seedMaps.length; i++) {
        const seedMap = seedMaps[i];
        const seedPlace = getPlace(seedMap, seed);
        if (seed != seedPlace) {
            return seedPlace
        }

    }
    return seed


}
const countSeedMaps = (seed: number, seedMaps: mapObject[]): number => {

    for (let i = 0; i < seedMaps.length; i++) {

        seed = mapNewSeedLocation(
            seedMaps[i], seed);

    }

    return seed;
}
const getLargerSetOfSeeds = (seeds: number[], seedMaps: mapObject[]): number => {

    let lowestSeed = 99999999999;
    for (let i = 0; i < seeds.length; i += 2) {
        console.log(i);
        let start = seeds[i];
        let end = seeds[i] + seeds[i + 1];
        for (start; start < end; start++) {
            const newSeed: number = countSeedMaps(start, seedMaps);
            for (let y = 0; y < seeds.length; y += 2) {
                let starty: number = seeds[y];
                let endy: number = seeds[y] + seeds[y + 1];
                if (starty >= newSeed
                    && newSeed <= endy && newSeed < lowestSeed) {
                    lowestSeed = newSeed;
                }
            }
        }
        console.log(lowestSeed);

    }
    return lowestSeed

};

const main = async () => {
    const fileContent: string = await readFile(inputFile);

    const splittedMaps: string[] = fileContent.split(/\n\n/);

    const seeds: number[] = splittedMaps[0]
        .match(/\d+(\d+)?/g)?.map(Number) || [];

    splittedMaps.slice(1).forEach((set) => {
        const dataMap: mapObject = getDataMap(set);
        mapObjectList.push(dataMap);

    })
    const newSeed: number = getLargerSetOfSeeds(seeds, mapObjectList);

    console.log(newSeed);
    fs.writeFile('./output.txt', String(newSeed), (err) => {
        if (err) {
            console.error("fuck", err);
        } else {
            console.log("writted");
        }
    });



}
main()
