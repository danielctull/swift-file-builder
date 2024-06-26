
import Foundation

public struct TextFile<Content: Text>: File {

    @Environment(\.stringEncoding) private var encoding: String.Encoding
    private let name: FileName
    private let text: Content

    public init(
        _ name: FileName,
        @TextBuilder text: () -> Content
    ) {
        self.name = name
        self.text = text()
    }

    public var file: some File {
        BuiltinFile { directory, environment in
            let string = String(text, environment: environment)
            guard let data = string.data(using: encoding) else {
                throw TextFileFailure(name: name)
            }
            let url = directory.appending(name)
            try data.write(to: url)
        }
    }
}

struct TextFileFailure: Error {
    let name: FileName
}
