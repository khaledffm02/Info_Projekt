export function randomString(length: number): string {
  let result = Math.random().toString(36).substring(2);
  while (result.length < length) {
    result += Math.random().toString(36).substring(2);
  }
  return result.substring(0, length);
}
