import { load } from 'js-yaml'
import { readFileSync, writeFileSync } from 'fs'

const yaml = readFileSync('./data/languages.yml', 'utf8')
const data = load(yaml)

// Extract language names as a sorted array
const result = Object.keys(data).sort()

writeFileSync('./data/languages.json', JSON.stringify(result, null, 2))
console.log(`Generated languages.json with ${result.length} languages`)
