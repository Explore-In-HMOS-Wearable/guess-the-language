import { NavButton } from '../components/NavButton';

@Component
export default struct MainScreen {
  @Consume('pages') pages: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.app_title'))
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_primary'))
          .margin({ bottom: 6 })

        NavButton({
          text: $r('app.string.btn_play'),
          onAction: () => {
            this.pages.pushPathByName('ContinentChooseScreen', 0)
          }
        })

        NavButton({
          text: $r('app.string.btn_stats'),
          onAction: () => {
            this.pages.pushPathByName('StatsScreen', 0)
          }
        })

        NavButton({
          text: $r('app.string.btn_how_to_play'),
          onAction: () => {
            this.pages.pushPathByName('HowToScreen', 0)
          }
        })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
      .padding(15)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.color_background'))
    .hideBackButton(true)
  }
}
