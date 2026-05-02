@Component
export struct CustomButton {
  @Prop text: ResourceStr = '';
  @Prop isEnabled: boolean = true;
  @Prop @Watch('buttonTy') type: boolean = false;
  @State pressed: boolean = false;
  onAction?: () => void;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height(36)
        .backgroundColor(this.isEnabled ? (this.type ? $r('app.color.color_correct_shadow') : $r('app.color.color_wrong_shadow')) : $r('app.color.color_disabled_shadow'))
        .borderRadius(16)

      Column()
        .width('100%')
        .height(36)
        .backgroundColor(this.isEnabled ? (this.type ? $r('app.color.color_correct') : $r('app.color.color_wrong')) : $r('app.color.color_disabled_bg'))
        .borderRadius(16)
        .offset({ x: 0, y: this.pressed ? 0 : -4 })
        .animation({ duration: 80 })

      Text(this.text)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isEnabled ? Color.White : $r('app.color.color_disabled_text'))
        .offset({ x: 0, y: this.pressed ? 0 : -4 })
        .animation({ duration: 80 })
    }
    .width('100%')
    .height(60)
    .onClick(() => {
      if (this.isEnabled && this.onAction) {
        this.onAction();
      }
    })
    .gesture(
      TapGesture()
        .onAction(() => {
          if (this.isEnabled) {
            this.pressed = true;
            setTimeout(() => {
              this.pressed = false;
            }, 150);
          }
        })
    )
    .onTouch((event: TouchEvent) => {
      if (!this.isEnabled) {
        return;
      }

      if (event.type === TouchType.Down) {
        this.pressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false;
      }
    })
  }

  buttonTy(changedPropertyName: string) {
    console.info(`Button type is ${changedPropertyName}`)
  }
}