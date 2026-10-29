import AppKit
import CoreText
let out = URL(fileURLWithPath:CommandLine.arguments[1])
let data = NSMutableData()
var box = CGRect(x:0,y:0,width:22,height:16)
let context = CGContext(consumer:CGDataConsumer(data:data)!,mediaBox:&box,nil)!
context.beginPDFPage(nil)
let shape = CGMutablePath()
shape.addRoundedRect(in:box,cornerWidth:4,cornerHeight:4)
let font=NSFont.systemFont(ofSize:11,weight:.bold) as CTFont
let label=NSAttributedString(string:"HY",attributes:[NSAttributedString.Key(kCTFontAttributeName as String):font])
let line=CTLineCreateWithAttributedString(label)
let runs=CTLineGetGlyphRuns(line) as! [CTRun]
let width=CTLineGetTypographicBounds(line,nil,nil,nil)
let origin=CGPoint(x:(22-width)/2,y:(16-CTFontGetCapHeight(font))/2)
for run in runs {
    let count=CTRunGetGlyphCount(run)
    var glyphs=[CGGlyph](repeating:0,count:count)
    var positions=[CGPoint](repeating:.zero,count:count)
    CTRunGetGlyphs(run,CFRange(),&glyphs)
    CTRunGetPositions(run,CFRange(),&positions)
    for i in 0..<count {
        if let path=CTFontCreatePathForGlyph(font,glyphs[i],nil) {
            let transform=CGAffineTransform(translationX:origin.x+positions[i].x,y:origin.y+positions[i].y)
            shape.addPath(path,transform:transform)
        }
    }
}
context.addPath(shape)
context.setFillColor(NSColor.black.cgColor)
context.drawPath(using:.eoFill)
context.endPDFPage();context.closePDF()
try (data as Data).write(to:out)
print("Ստեղծվել է HY նշանը՝ 22 × 16 կետ չափով։")
