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

const getPlace = (data: string) => { };
const mapNextPlace = (source: number, target: number) => { };

const countSeedMaps = (seeds: number[], seedMaps: mapObjectList): number => {

    for (let i = 0; i<seedMaps.length; i++) {
        const locations: number[] = [];


    }
    return 0
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
