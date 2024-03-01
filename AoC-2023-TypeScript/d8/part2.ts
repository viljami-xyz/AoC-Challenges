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


const getStartingNodes = (nodes: Node): [string, string][] => {
    const startNodes: [string, string][] = [];

    Object.keys(nodes).forEach((key) => {
        if (key[2] === 'A') {
            startNodes.push(nodes[key]);
        }
    });

    return startNodes;


};

function gcdCalc(): {

};

function lcmCalc(): {};

function countSteps(numGuide:number[],nodesMap:Node,startNodes:[string,string][]): number  {


};

const main = async () => {
    const fileContent: string = await readFile('./d8/input.txt');
    const fileLines: string[] = fileContent.split(/\r?\n/);

    const instructions: string = fileLines[0];
    const nodes: string[] = fileLines.slice(2);


    const numGuide: number[] = getInstructionsAsList(instructions);
    const nodesMap: Node = getNodesInStructs(nodes);

    const startNodes: [string, string][] = getStartingNodes(nodesMap);

    const steps: number = countSteps(numGuide, nodesMap, startNodes);

    console.log(steps);

}


main()
