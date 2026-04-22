import { getLast7Days } from '../utils/ScoreStorage';
import { NavButton } from '../components/NavButton';

// Canvas API only accepts string colors, not $r() resource references
const CHART_ACCENT_COLOR: string = '#DD6031';
const CHART_GRID_COLOR: string = '#EABE7C';
const CHART_AXIS_COLOR: string = '#4f351c';
const CHART_POINT_COLOR: string = '#713105';

@Component
export default struct StatsScreen {
  @Consume('pages') pages: NavPathStack;
  @State scoreData: number[] = [0, 0, 0, 0, 0, 0, 0];
  @State percentData: number[] = [0, 0, 0, 0, 0, 0, 0];
  private dataLoaded: boolean = false;
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private context2: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ctx: CanvasRenderingContext2D | null = null;
  private ctx2: CanvasRenderingContext2D | null = null;

  private async loadData(): Promise<void> {
    this.scoreData = await getLast7Days(this.getUIContext().getHostContext() as Context, 'score');
    this.percentData = await getLast7Days(this.getUIContext().getHostContext() as Context, 'percent');
    this.dataLoaded = true;
  }

  private getAverage(data: number[]): number {
    if (data.length === 0) {
      return 0;
    }

    let total = 0;
    data.forEach((value: number) => {
      total += value;
    });
    return total / data.length;
  }

  private tryDrawCharts(): void {
    if (!this.dataLoaded) {
      return;
    }
    if (this.ctx) {
      this.drawGraph(this.ctx, this.context, this.scoreData);
    }
    if (this.ctx2) {
      this.drawGraph(this.ctx2, this.context2, this.percentData);
    }
  }

  private drawGraph(cts: CanvasRenderingContext2D | null, takenContext: CanvasRenderingContext2D, takenData: number[]) {
    if (!cts) {
      return;
    }
    const w: number = cts.width;
    const h: number = cts.height;
    takenContext.clearRect(0, 0, w, h);

    // Scale data
    const maxVal: number = Math.max(...takenData);
    const stepX: number = (w - 65) / (takenData.length - 1);

    // Draw axes + labels
    for (let i = 0; i < 4; i++) {
      if (i === 0) {
        takenContext.strokeStyle = CHART_ACCENT_COLOR;
      } else {
        takenContext.strokeStyle = CHART_GRID_COLOR;
      }

      const y = h - 30 - i * 20;

      // draw line
      takenContext.beginPath();
      takenContext.moveTo(15, y); // start a bit to the right (leave room for labels)
      takenContext.lineTo(w - 15, y);
      takenContext.stroke();

      // compute value for this line (relative to maxVal)
      const value = Math.round((i / 3) * maxVal);

      // draw text
      takenContext.fillStyle = CHART_AXIS_COLOR;
      takenContext.font = '12px sans-serif';
      takenContext.textAlign = 'right';
      takenContext.textBaseline = 'middle';
      takenContext.fillText(value.toString(), 15, y);
    }

    // Plot line
    takenContext.strokeStyle = CHART_AXIS_COLOR;
    takenContext.lineWidth = 2;
    takenContext.beginPath();
    takenData.forEach((v: number, i: number) => {
      const x = 25 + i * stepX;
      const y = maxVal > 0 ? h - 30 - (v / maxVal) * (h - 60) : h - 30;

      if (i === 0) {
        takenContext.moveTo(x, y);
      } else {
        takenContext.lineTo(x, y);
      }
    });
    takenContext.stroke();

    // Points
    takenContext.fillStyle = CHART_POINT_COLOR;
    takenData.forEach((v: number, i: number) => {
      const x = 25 + i * stepX;
      const y = maxVal > 0 ? h - 30 - (v / maxVal) * (h - 60) : h - 30;
      takenContext.beginPath();
      takenContext.arc(x, y, 3, 0, Math.PI * 2);
      takenContext.fill();
    });
  }

  async aboutToAppear() {
    await this.loadData();
    this.tryDrawCharts();
  }

  build() {
    NavDestination() {
      Column() {
        Swiper() {
          Column() {
            Column() {
              Text(this.getAverage(this.percentData).toFixed(1))
                .fontSize(20)
                .fontColor($r('app.color.color_primary'))
              Text($r('app.string.stats_avg_percent'))
                .fontSize(20)
                .fontColor($r('app.color.color_primary'))
            }
            .height('30%')
            .justifyContent(FlexAlign.Center)
            Canvas(this.context2)
              .width('90%')
              .height('51%')
              .onAppear(() => {
                this.ctx2 = this.context2
                this.tryDrawCharts();
              })
          }

          Column() {
            Column() {
              Text(this.getAverage(this.scoreData).toFixed(1))
                .fontSize(20)
                .fontColor($r('app.color.color_primary'))
              Text($r('app.string.stats_avg_score'))
                .fontSize(20)
                .fontColor($r('app.color.color_primary'))
            }
            .height('30%')
            .justifyContent(FlexAlign.Center)
            Canvas(this.context)
              .width('90%')
              .height('51%')
              .onAppear(() => {
                this.ctx = this.context
                this.tryDrawCharts();
              })
          }
        }
        .indicator(new DotIndicator()
          .color($r('app.color.color_accent'))
          .selectedColor($r('app.color.color_accent')))
        .loop(true)
        NavButton({
          text: $r('app.string.btn_back'),
          onAction: () => {
            this.pages.clear();
            this.pages.pushPathByName('MainScreen', 0)
          }
        })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(8)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.color_background'))
    .hideBackButton(true)
  }
}
