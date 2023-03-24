
public protocol LineModifier: TextModifier {
    func modifyLines(_ lines: [Line]) -> [Line]
}

extension LineModifier {

    @TextBuilder
    public func body(content: Content) -> some Text {
        BuiltinText { environment in
            modifyLines(
                content.lines(environment: environment)
            )
        }
    }
}

extension Text {

    public func modifier(_ lineModifier: @escaping ([Line]) -> [Line]) -> some Text {
        modifier(AnyLineModifier(lineModifier: lineModifier))
    }

    public func modifier(_ lineModifier: @escaping (Line) -> Line) -> some Text {
        modifier(AnyLineModifier { $0.map(lineModifier) })
    }
}

private struct AnyLineModifier: LineModifier {
    let lineModifier: ([Line]) -> [Line]
    func modifyLines(_ lines: [Line]) -> [Line] {
        lineModifier(lines)
    }
}
