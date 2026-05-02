@Component
export struct CustomText {
  @Prop text: ResourceStr = '';

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.text)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.color_primary'))
        .margin({ bottom: 6 })
    }
  }
}