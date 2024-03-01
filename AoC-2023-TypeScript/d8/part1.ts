import readFile from "../utils/readFile";

type Node = { [key: string]: [string, string] };

const getInstructionsAsList = (instructions: string): number[] => {
    return instructions.split('')
        .map((char) => (char === 'L' ? 0 : 1))

}

const getNodesInStructs = (nodes: string[]): Node => {
    const nodesStruct: Node = {};
    nodes.forEach((node) => {
        const key: string = node.slice(0, 3);
        const left: string = node.slice(7, 10);
        const right: string = node.slice(12, 15);
        nodesStruct[key] = [left, right];



    });

    return nodesStruct;
}

const mapNewNode = (guide: number[], nodes: Node): number => {
    let steps: number = 0;
    let index: number = 0;
    let continueLoop: boolean = true;
    let selectNode: [string, string] = nodes['AAA'];

    while (continueLoop) {
        const currentGuide: number = guide[index % guide.length];
        const newLocation: string = selectNode[currentGuide];
        steps++
        if (newLocation === 'ZZZ') {
            continueLoop = false;
        }
        selectNode = nodes[newLocation];
        console.log(`${newLocation}->${selectNode[guide[
            currentGuide+1 % guide.length]]}`);
        index++

    };
    return steps;

};

const main = async () => {
    const fileContent: string = await readFile('./d8/input.txt');
    const fileLines: string[] = fileContent.split(/\r?\n/);

    const instructions: string = fileLines[0];
    const nodes: string[] = fileLines.slice(2);

    const numGuide: number[] = getInstructionsAsList(instructions);
    const nodesMap: Node = getNodesInStructs(nodes);

    const steps:number = mapNewNode(numGuide,nodesMap);

    console.log(steps);

}


main()
