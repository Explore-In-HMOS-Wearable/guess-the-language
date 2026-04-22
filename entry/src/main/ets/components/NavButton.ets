@Component
export struct NavButton {
  @Prop text: ResourceStr = '';
  onAction?: () => void;

  build() {
    Button() {
      Text(this.text)
    }
    .onClick(() => {
      if (this.onAction) {
        this.onAction();
      }
    })
    .alignSelf(ItemAlign.Center)
    .fontColor(Color.White)
    .fontWeight(FontWeight.Bold)
    .width(80)
    .height(40)
    .borderRadius(200)
    .backgroundColor($r('app.color.color_primary'))
    .borderWidth(2)
    .borderColor($r('app.color.color_gold'))
    .shadow({
      offsetX: 1,
      offsetY: 1,
      color: Color.Black,
      radius: 10
    })
  }
}
