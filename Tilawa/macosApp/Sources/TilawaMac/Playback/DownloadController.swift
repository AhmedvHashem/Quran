import Combine
import Foundation

struct DownloadKey: Hashable {
    let editionId: Int32
    let chapterId: Int32
}

struct DownloadResult {
    let file: URL
    let response: URLResponse
}

/// One background URLSession for the app; completed files are moved before delegate return.
@MainActor
final class DownloadController: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published private(set) var progress: [DownloadKey: Double] = [:]

    private struct Pending {
        let key: DownloadKey
        let stagingFile: URL
        let continuation: CheckedContinuation<DownloadResult, Error>
    }

    private var pending: [Int: Pending] = [:]
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.hashem.tilawa.downloads")
        configuration.isDiscretionary = false
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()

    func download(from remoteURL: URL, to stagingFile: URL, key: DownloadKey) async throws -> DownloadResult {
        try await withCheckedThrowingContinuation { continuation in
            let task = session.downloadTask(with: remoteURL)
            task.taskDescription = "\(key.editionId):\(key.chapterId)"
            pending[task.taskIdentifier] = Pending(key: key, stagingFile: stagingFile, continuation: continuation)
            progress[key] = 0
            task.resume()
        }
    }

    func progress(for key: DownloadKey) -> Double? { progress[key] }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        Task { @MainActor in
            guard let job = pending[downloadTask.taskIdentifier] else { return }
            progress[job.key] = min(max(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite), 0), 1)
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        Task { @MainActor in
            guard let job = pending.removeValue(forKey: downloadTask.taskIdentifier) else { return }
            guard let response = downloadTask.response else {
                progress[job.key] = nil
                job.continuation.resume(throwing: URLError(.badServerResponse))
                return
            }
            do {
                let files = FileManager.default
                if files.fileExists(atPath: job.stagingFile.path) {
                    try files.removeItem(at: job.stagingFile)
                }
                try files.moveItem(at: location, to: job.stagingFile)
                progress[job.key] = nil
                job.continuation.resume(returning: DownloadResult(file: job.stagingFile, response: response))
            } catch {
                progress[job.key] = nil
                job.continuation.resume(throwing: error)
            }
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let error else { return }
        Task { @MainActor in
            guard let job = pending.removeValue(forKey: task.taskIdentifier) else { return }
            progress[job.key] = nil
            job.continuation.resume(throwing: error)
        }
    }
}
