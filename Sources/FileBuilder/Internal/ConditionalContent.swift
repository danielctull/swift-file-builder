
public struct ConditionalContent<True: TextContent, False: TextContent> {

    private let generate: (EnvironmentValues) -> [Line]

    init(_ content: True) {
        generate = content.generate
    }

    init(_ content: False) {
        generate = content.generate
    }
}

// MARK: - Content

extension ConditionalContent: TextContent {

    public var body: some TextContent {
        BuiltinContent(generate: generate)
    }
}
