export interface Question {
  question: string;
  languageException: string | boolean;
  options: Option[];
}

export interface Option {
  value: string;
  isCorrect: boolean;
}