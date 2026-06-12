import XCTest

enum JSONSnapshotTesting {
    static var isRecording: Bool {
        ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
    }

    static func assertSnapshot<T: Encodable>(
        _ value: T,
        named name: String? = nil,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        do {
            let actualData = try makeJSONData(from: value)
            let snapshotURL = snapshotURL(
                sourceFilePath: file,
                testName: testName,
                named: name
            )

            if isRecording || !FileManager.default.fileExists(atPath: snapshotURL.path) {
                try FileManager.default.createDirectory(
                    at: snapshotURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try actualData.write(to: snapshotURL, options: .atomic)

                if isRecording {
                    return
                }

                XCTFail(
                    "Missing snapshot at \(snapshotURL.path). Re-run with RECORD_SNAPSHOTS=1 to record it.",
                    file: file,
                    line: line
                )
                return
            }

            let expectedData = try Data(contentsOf: snapshotURL)
            guard actualData != expectedData else { return }

            let actualJSON = String(data: actualData, encoding: .utf8) ?? "<invalid utf8>"
            let expectedJSON = String(data: expectedData, encoding: .utf8) ?? "<invalid utf8>"
            XCTFail(
                """
                Snapshot mismatch at \(snapshotURL.path)

                Expected:
                \(expectedJSON)

                Actual:
                \(actualJSON)
                """,
                file: file,
                line: line
            )
        } catch {
            XCTFail("Failed to compare JSON snapshot: \(error)", file: file, line: line)
        }
    }

    private static func makeJSONData<T: Encodable>(from value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(value)
    }

    private static func snapshotURL(
        sourceFilePath: StaticString,
        testName: String,
        named name: String?
    ) -> URL {
        let sourceURL = URL(fileURLWithPath: "\(sourceFilePath)")
        let testClassName = sourceURL.deletingPathExtension().lastPathComponent
        let sanitizedTestName = testName.hasSuffix("()")
            ? String(testName.dropLast(2))
            : testName
        let snapshotName = [sanitizedTestName, name].compactMap { $0 }.joined(separator: ".")
        return sourceURL
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(testClassName)
            .appendingPathComponent("\(snapshotName).json")
    }
}
