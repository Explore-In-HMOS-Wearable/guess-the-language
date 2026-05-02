import { Question } from '../model/Question';
import { shuffleList } from './ShuffleList';

// Typed interface matching the shape of questions.json
interface QuestionsFile {
  asia: Question[];
  europe: Question[];
  africa: Question[];
  america: Question[];
}

function decodeUtf8(bytes: Uint8Array): string {
  const textParts: string[] = [];
  let index = 0;

  while (index < bytes.length) {
    const firstByte = bytes[index];

    if (firstByte < 0x80) {
      textParts.push(String.fromCharCode(firstByte));
      index++;
      continue;
    }

    if ((firstByte & 0xE0) === 0xC0 && index + 1 < bytes.length) {
      const secondByte = bytes[index + 1];
      const codePoint = ((firstByte & 0x1F) << 6) | (secondByte & 0x3F);
      textParts.push(String.fromCharCode(codePoint));
      index += 2;
      continue;
    }

    if ((firstByte & 0xF0) === 0xE0 && index + 2 < bytes.length) {
      const secondByte = bytes[index + 1];
      const thirdByte = bytes[index + 2];
      const codePoint = ((firstByte & 0x0F) << 12) | ((secondByte & 0x3F) << 6) | (thirdByte & 0x3F);
      textParts.push(String.fromCharCode(codePoint));
      index += 3;
      continue;
    }

    if ((firstByte & 0xF8) === 0xF0 && index + 3 < bytes.length) {
      const secondByte = bytes[index + 1];
      const thirdByte = bytes[index + 2];
      const fourthByte = bytes[index + 3];
      const codePoint = ((firstByte & 0x07) << 18) | ((secondByte & 0x3F) << 12) |
        ((thirdByte & 0x3F) << 6) | (fourthByte & 0x3F);
      const adjustedCodePoint = codePoint - 0x10000;
      const highSurrogate = 0xD800 + (adjustedCodePoint >> 10);
      const lowSurrogate = 0xDC00 + (adjustedCodePoint & 0x3FF);
      textParts.push(String.fromCharCode(highSurrogate, lowSurrogate));
      index += 4;
      continue;
    }

    textParts.push('\uFFFD');
    index++;
  }

  return textParts.join('');
}

/**
 * Loads and returns a shuffled question list for the given continent from
 * rawfile/questions.json. Pass 'All' to combine all continents.
 */
export function loadContinentQuestions(context: Context, continent: string): Question[] {
  try {
    const raw: Uint8Array = context.resourceManager.getRawFileContentSync('questions.json');
    const text = decodeUtf8(raw);
    const parsedData = JSON.parse(text) as Record<string, Question[]>;
    const data: QuestionsFile = {
      asia: parsedData.Asia ?? [],
      europe: parsedData.Europe ?? [],
      africa: parsedData.Africa ?? [],
      america: parsedData.America ?? []
    };

    const continentMap: QuestionsFile = data;

    let list: Question[];
    if (continent === 'All') {
      list = [
        ...(continentMap.asia),
        ...(continentMap.europe),
        ...(continentMap.africa),
        ...(continentMap.america)
      ];
    } else {
      switch (continent) {
        case 'Asia':
          list = continentMap.asia;
          break;
        case 'Europe':
          list = continentMap.europe;
          break;
        case 'Africa':
          list = continentMap.africa;
          break;
        case 'America':
          list = continentMap.america;
          break;
        default:
          list = [];
          break;
      }
    }

    shuffleList(list);
    return list;
  } catch (e) {
    console.error(`QuestionLoader: failed to load "${continent}": ${e}`);
    return [];
  }
}
