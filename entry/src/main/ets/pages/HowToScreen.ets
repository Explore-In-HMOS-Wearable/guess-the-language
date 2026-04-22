import { CustomText } from '../components/CustomText';
import { NavButton } from '../components/NavButton';

@Component
export default struct HowToScreen {
  @Consume('pages') pages: NavPathStack;
  build() {
    NavDestination() {
      Column() {
        CustomText({text: $r('app.string.how_to_step1')})
        CustomText({text: $r('app.string.how_to_step2')})
        CustomText({text: $r('app.string.how_to_step3')})
        CustomText({text: $r('app.string.how_to_step4')})
        CustomText({text: $r('app.string.how_to_step5')})

        NavButton({
          text: $r('app.string.btn_back'),
          onAction: () => {
            this.pages.clear();
            this.pages.pushPathByName('MainScreen', 0)
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
