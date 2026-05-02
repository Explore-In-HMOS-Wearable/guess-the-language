import { Score } from '../model/Score';
import ContinentChooseScreen from './ContinentChooseScreen';
import HowToScreen from './HowToScreen';
import MainScreen from './MainScreen';
import QuizScreen from './QuizScreen';
import ScoreScreen from './ScoreScreen';
import StatsScreen from './StatsScreen';

@Entry
@Component
struct Index {
  @Provide('pages') pages: NavPathStack = new NavPathStack();
  @Provide('totalXp') totalXp: number = 0;
  @Provide('scoreInfo') scoreInfo: Score = {
    score: 0,
    percent: 0
  };

  @Builder
  PagesMap(name: string) {
    if (name === 'MainScreen') {
      MainScreen()
    } else if (name === 'ContinentChooseScreen') {
      ContinentChooseScreen()
    } else if (name === 'QuizScreen') {
      QuizScreen()
    } else if (name === 'ScoreScreen') {
      ScoreScreen()
    }
    else if (name === 'StatsScreen'){
      StatsScreen()
    }
    else if (name === 'HowToScreen') {
      HowToScreen()
    }
  }

  aboutToAppear(): void {
    if (this.pages === undefined) {
      this.pages = new NavPathStack();
    }

    this.pages.pushPathByName('MainScreen',0)

  }

  build() {
    Navigation(this.pages) {
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
  }
}