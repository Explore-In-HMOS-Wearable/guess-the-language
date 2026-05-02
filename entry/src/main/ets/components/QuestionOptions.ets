import { Option, Question } from '../model/Question';

@Component
export struct QuestionOptions {
  @Prop @Watch('currQuestion') currentQuestion: Question;
  @Link selectedIndex: number;
  @Prop isAnswered: boolean = false;
  @State optionSnapshot: Option[] = [];
  onAction?: () => void;

  @Builder
  OptionItem(item: Option | undefined, index: number) {
    if (!item) {
      Blank()
        .width('47%')
        .height(50)
    } else {
      Button() {
        Text(item.value)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Center)
      }
        .onClick(() => {
          if (this.isAnswered) {
            return;
          }
          this.selectedIndex = index
          if (this.onAction) {
            this.onAction();
          }
        })
        .fontColor(Color.Black)
        .borderWidth(2)
        .type(ButtonType.Normal)
        .borderRadius(16)
        .borderColor(this.selectedIndex === index ? $r('app.color.color_option_selected_border') : $r('app.color.color_option_border'))
        .width('47%')
        .height(50)
        .padding({ left: 6, right: 6, top: 4, bottom: 4 })
        .clickEffect({
          level: ClickEffectLevel.HEAVY
        })
        .opacity(this.isAnswered && this.selectedIndex !== index ? 0.5 : 1.0)
        .backgroundColor(this.selectedIndex === index ? $r('app.color.color_option_selected_bg') : $r('app.color.color_option_bg'));
    }
  }

  aboutToAppear(): void {
    this.optionSnapshot = [...this.currentQuestion.options];
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        this.OptionItem(this.optionSnapshot[0], 0)
        this.OptionItem(this.optionSnapshot[1], 1)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 10 }) {
        this.OptionItem(this.optionSnapshot[2], 2)
        this.OptionItem(this.optionSnapshot[3], 3)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  currQuestion(changedPropertyName: string) {
    this.optionSnapshot = [...this.currentQuestion.options];
    if (this.currentQuestion) {
      console.info(`Question loaded`)
    }
  }
}
