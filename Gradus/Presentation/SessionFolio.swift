import Foundation
import PDFKit
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Local PDF of sealed session notes. Nothing is uploaded.
enum SessionFolio {
    static func document(notes: [SessionNote], names: [UUID: String]) -> Data {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let raw = renderer.pdfData { context in
            if notes.isEmpty {
                context.beginPage()
                draw("No sealed sessions yet.", at: CGPoint(x: 48, y: 72))
                return
            }
            for note in notes {
                context.beginPage()
                var y: CGFloat = 64
                let name = names[note.coacheeID] ?? "Coachee"
                y = draw(name, at: CGPoint(x: 48, y: y), size: 22) + 8
                let titles = SessionNote.sectionTitles
                let bodies = note.sectionBodies
                for index in titles.indices {
                    y = draw(titles[index], at: CGPoint(x: 48, y: y), size: 14) + 4
                    let body = index < bodies.count ? bodies[index] : ""
                    y = draw(body.isEmpty ? " " : body, at: CGPoint(x: 48, y: y), size: 12) + 16
                }
                let readiness = "Readiness \(Figures.whole(note.readiness)) of \(Figures.whole(5))"
                _ = draw(readiness, at: CGPoint(x: 48, y: y), size: 14)
            }
        }
        return PDFDocument(data: raw)?.dataRepresentation() ?? raw
    }

    @discardableResult
    private static func draw(_ text: String, at origin: CGPoint, size: CGFloat = 16) -> CGFloat {
        let font = UIFont(name: DesignTokens.fontFamily, size: size) ?? UIFont.systemFont(ofSize: size)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]
        let bounds = CGRect(x: origin.x, y: origin.y, width: 516, height: 400)
        let used = (text as NSString).boundingRect(
            with: CGSize(width: 516, height: 400),
            options: [.usesLineFragmentOrigin],
            attributes: attributes,
            context: nil
        )
        (text as NSString).draw(in: bounds, withAttributes: attributes)
        return origin.y + max(used.height, size)
    }
}

struct FolioFile: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
