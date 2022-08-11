import * as readline from 'node:readline';
import { stdin as input, stdout as output } from 'node:process';

function getRandomInt(max) {
	return Math.floor(Math.random() * max);
}

console.log("Modulo 7 Practice");
console.log("Enter 'exit' to quit");

const rl = readline.createInterface({ input, output });
let running = true;

while (running) {
	let x = getRandomInt(80) + 10;
	let userResponse = await new Promise(resolve => {
		rl.question(`What is ${x} % 7\n`, resolve);
	});
	if (userResponse.includes('x')) {
		running = false;
		break;
	}

	if ((parseInt(userResponse) + 7) % 7 !== x % 7) {
		console.log(`No! Answer: ${x % 7}`);
	}
}

rl.close();

