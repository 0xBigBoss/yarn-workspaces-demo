import { version, name } from "../package.json";

/**
 * Gets the current version of the shared-utils package
 */
export function getVersion(): string {
  return version;
}

/**
 * Gets detailed package info including name and version
 */
export function getPackageInfo(): { name: string; version: string } {
  return {
    name,
    version,
  };
}

/**
 * Formats a string by capitalizing the first letter
 */
export function capitalize(str: string): string {
  if (!str) return "";
  return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Adds two numbers together
 */
export function add(a: number, b: number): number {
  return a + b;
}

/**
 * Multiplies two numbers
 */
export function multiply(a: number, b: number): number {
  return a * b;
}

/**
 * Generates a greeting message
 */
export function greet(name: string): string {
  return `Hello, ${capitalize(name)}!`;
}

/**
 * Utility to format dates
 */
export function formatDate(date: Date): string {
  return date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}
