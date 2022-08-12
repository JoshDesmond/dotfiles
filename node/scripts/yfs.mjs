import * as readline from 'node:readline';
import { stdin as input, stdout as output } from 'node:process';

function getRandomInt(max) {
	return Math.floor(Math.random() * max);
}

let range = 35;
let start = 1990;

function getRandomYear() {
	return start + getRandomInt(range);
}

let e2e = (x) => {
	x = x % 100;
	if (x % 2 == 1) { x += 11; }
	x /= 2;
	if (x % 2 == 1) { x += 11; }
	return x;
}

let cfs = (x) => {
	x = x - (x % 100);
	x = x % 400;
	switch (x) {
		case 100:
			return 0;
			break;
		case 200:
			return 2;
			break;
		case 300:
			return 4;
		case 0:
			return 5;
	}
}

let yfs = (x) => {
	return (e2e(x) + cfs(x)) % 7;
}

/**
 * Lists years in 1900 and 2000 with a given YFS
 */
function listXYears(x) {
	if (x < 0 || x > 6) {
		throw new RangeError();
	}

	const list = [];
	for (let i = 1960; i < 2030; i++) {
		if (yfs(i) == x) {
			list.push(i);
		}
	}
	return list;
}

console.log("Reference Years:");
const yearMap = new Map();
for (let x = 0; x <= 6; x++) {
	yearMap.set(x, listXYears(x));
}
console.log(yearMap);

console.log("YFS Practice");
console.log("Enter 'exit' to quit");

const rl = readline.createInterface({ input, output });
let running = true;

while (running) {
	let year = getRandomYear();
	let userResponse = await new Promise(resolve => {
		rl.question(`What is yfs(${year})?\n`, resolve);
	});

	if (userResponse.includes('x')) {
		running = false;
		break;
	}

	if (parseInt(userResponse) !== yfs(year)) {
		console.log(`No! Answer: ${yfs(year)}`);
	}
}

rl.close();

