import preferences from '@ohos.data.preferences';

const SCORE_PREFERENCE_NAME = 'score_storage';
const COUNT_PREFERENCE_NAME = 'count_storage';
const PERCENT_PREFERENCE_NAME = 'percent_storage';
let scorePref: preferences.Preferences | null = null;
let countPref: preferences.Preferences | null = null;
let percentPref: preferences.Preferences | null = null;

async function getScorePreferences(context: Context): Promise<preferences.Preferences | null> {
  if (!scorePref) {
    try {
      scorePref = await preferences.getPreferences(context, SCORE_PREFERENCE_NAME);
    } catch (error) {
      console.error(`Failed to get score preferences: ${error}`);
      return null;
    }
  }
  return scorePref;
}

async function getCountPreferences(context: Context): Promise<preferences.Preferences | null> {
  if (!countPref) {
    try {
      countPref = await preferences.getPreferences(context, COUNT_PREFERENCE_NAME);
    } catch (error) {
      console.error(`Failed to get count preferences: ${error}`);
      return null;
    }
  }
  return countPref;
}

async function getPercentPreferences(context: Context): Promise<preferences.Preferences | null> {
  if (!percentPref) {
    try {
      percentPref = await preferences.getPreferences(context, PERCENT_PREFERENCE_NAME);
    } catch (error) {
      console.error(`Failed to get percent preferences: ${error}`);
      return null;
    }
  }
  return percentPref;
}

function getDateKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

function buildRecentDateKeys(today: Date): string[] {
  const keys: string[] = [];
  const cursor = new Date(today);
  cursor.setDate(today.getDate() - 6);

  for (let i = 0; i < 7; i++) {
    keys.push(getDateKey(cursor));
    cursor.setDate(cursor.getDate() + 1);
  }

  return keys;
}

export async function getLast7Days(context: Context, desiredData: string): Promise<number[]> {
  const scorePreferences = await getScorePreferences(context);
  const countPreferences = await getCountPreferences(context);
  const percentPreferences = await getPercentPreferences(context);
  const today = new Date();
  const result: number[] = [];
  const dateKeys = buildRecentDateKeys(today);

  if (desiredData === 'score') {
    for (const key of dateKeys) {
      try {
        if (!scorePreferences || !countPreferences) {
          result.push(0);
          continue;
        }
        const score = await scorePreferences.get(key, 0);
        const count = await countPreferences.get(key, 0);
        const avg = (count !== 0) ? (score as number) / (count as number) : 0;
        result.push(avg as number);
      } catch (error) {
        console.error(`Failed to read score for ${key}: ${error}`);
        result.push(0);
      }
    }
  } else {
    for (const key of dateKeys) {
      try {
        if (!percentPreferences || !countPreferences) {
          result.push(0);
          continue;
        }
        const percent = await percentPreferences.get(key, 0);
        const count = await countPreferences.get(key, 0);
        const avg = (count !== 0) ? (percent as number) / (count as number) : 0;
        result.push(avg as number);
      } catch (error) {
        console.error(`Failed to read percent for ${key}: ${error}`);
        result.push(0);
      }
    }
  }

  return result;
}

export async function storeScore(context: Context, quizScore: number, quizPercent: number): Promise<void> {
  try {
    const scorePreferences = await getScorePreferences(context);
    const countPreferences = await getCountPreferences(context);
    const percentPreferences = await getPercentPreferences(context);
    if (!scorePreferences || !countPreferences || !percentPreferences) {
      console.error('Failed to store score: preferences unavailable');
      return;
    }
    const todayKey = getDateKey(new Date());

    const currentScore = await scorePreferences.get(todayKey, 0);
    const currentCount = await countPreferences.get(todayKey, 0);
    const currentPercent = await percentPreferences.get(todayKey, 0);
    const newScore = (currentScore as number) + quizScore;
    const newPercent = (currentPercent as number) + quizPercent;
    const newCount = (currentCount as number) + 1;

    await scorePreferences.put(todayKey, newScore);
    await countPreferences.put(todayKey, newCount);
    await percentPreferences.put(todayKey, newPercent);
    await scorePreferences.flush();
    await countPreferences.flush();
    await percentPreferences.flush();
  } catch (error) {
    console.error(`Failed to store score: ${error}`);
  }
}

// Reset today's data for testing.
export async function resetToday(context: Context): Promise<void> {
  try {
    const scorePreferences = await getScorePreferences(context);
    const countPreferences = await getCountPreferences(context);
    const percentPreferences = await getPercentPreferences(context);
    if (!scorePreferences || !countPreferences || !percentPreferences) {
      console.error('Failed to reset: preferences unavailable');
      return;
    }
    const todayKey = getDateKey(new Date());

    await scorePreferences.put(todayKey, 0);
    await countPreferences.put(todayKey, 0);
    await percentPreferences.put(todayKey, 0);
    await scorePreferences.flush();
    await countPreferences.flush();
    await percentPreferences.flush();
  } catch (error) {
    console.error(`Failed to reset today's data: ${error}`);
  }
}
