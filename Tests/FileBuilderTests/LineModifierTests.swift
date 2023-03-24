
import FileBuilder
import XCTest

final class LineModifierTests: XCTestCase {

    func testLineModifier() throws {

        struct Suffix: LineModifier {
            let text: String
            func modifyLines(_ lines: [Line]) -> [Line] {
                lines.map { $0.suffix(text) }
            }
        }

        try AssertText {
            Group {
                "Hello"
                "World"
            }
            .modifier(Suffix(text: "!"))
        } is: {
            """
            Hello!
            World!
            """
        }
    }

    func testLinesClosureModifier() throws {
        try AssertText {
            Group {
                "Hello"
                "World"
            }
            .modifier { $0.filter { String($0).hasPrefix("H") } }
        } is: {
            "Hello"
        }
    }

    func testLineClosureModifier() throws {
        try AssertText {
            "Hello".modifier { _ in Line.empty }
        } is: {
            ""
        }
    }
}
