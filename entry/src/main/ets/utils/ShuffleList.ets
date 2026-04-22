import { Question } from '../model/Question';
import { secureRandomNumber } from './SecureRandom';

// Fisher-Yates shuffle algorithm.
export function shuffleList(questionList: Question[]): void {
  for (let i = 0; i < questionList.length; i++) {
    try {
      const randomIndex = i + Math.floor(secureRandomNumber() * (questionList.length - i));
      const tmp = questionList[randomIndex];
      questionList[randomIndex] = questionList[i];
      questionList[i] = tmp;
    } catch (error) {
      console.error(`Shuffle error at index ${i}: ${error}`);
    }
  }
}
