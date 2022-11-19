import UIKit

class UnderlinedBackGroundView: UIView {
  var lineHeight: CGFloat = 29
  
  override func draw(_ rect: CGRect) {
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.setStrokeColor(UIColor.idorm_gray_200.cgColor)
    let numberOfLines = Int(rect.height / lineHeight)
    
    for i in 1...numberOfLines {
      let y = CGFloat(i) * lineHeight
      let line = CGMutablePath()
      line.move(to: CGPoint(x: 0, y: y))
      line.addLine(to: CGPoint(x: rect.width, y: y))
      ctx?.addPath(line)
    }
    ctx?.strokePath()
    super.draw(rect)
  }
}
