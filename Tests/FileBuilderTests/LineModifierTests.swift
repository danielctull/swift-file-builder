
import FileBuilder
import XCTest

final class LineModifierTests: XCTestCase {

    func testLineModifier() throws {

        struct Suffix<C: Content>: LineModifier {
            let text: String
            func modifyLines(_ lines: [Line]) -> [Line] {
                lines.map { $0.suffix(text) }
            }
        }

        try AssertContent {
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
}
