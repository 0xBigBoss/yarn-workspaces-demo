import { greet, add, multiply, formatDate, capitalize, getVersion, getPackageInfo } from '@yarn-workspaces-demo/shared-utils';

console.log('=== My App Demo ===\n');

// Display package version information
const packageInfo = getPackageInfo();
console.log(`Using ${packageInfo.name} v${packageInfo.version}`);
console.log(`(Direct version check: v${getVersion()})\n`);

// Use the shared utilities
console.log(greet('world'));
console.log(greet('yarn workspaces'));

console.log('\n--- Math Operations ---');
console.log(`5 + 3 = ${add(5, 3)}`);
console.log(`4 × 7 = ${multiply(4, 7)}`);

console.log('\n--- String Operations ---');
console.log(`Capitalize 'hello' = ${capitalize('hello')}`);
console.log(`Capitalize 'typescript' = ${capitalize('typescript')}`);

console.log('\n--- Date Formatting ---');
console.log(`Today's date: ${formatDate(new Date())}`);

console.log('\n=== Demo Complete ===');
