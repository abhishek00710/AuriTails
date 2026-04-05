import Foundation
import PDFKit
import UIKit
import Vision

struct VaccineDocumentImportService {
    func importFromScannedPages(_ pages: [UIImage]) async -> VaccineRecord? {
        guard let firstPage = pages.first else { return nil }
        let text = await recognizeText(in: pages)
        return makeDraft(from: text, certificateData: firstPage.jpegData(compressionQuality: 0.88))
    }

    func importFromFile(url: URL) async -> VaccineRecord? {
        let ext = url.pathExtension.lowercased()

        if ext == "pdf", let document = PDFDocument(url: url) {
            let text = document.string ?? ""
            let firstPage = document.page(at: 0)?.thumbnail(of: CGSize(width: 1400, height: 1800), for: .cropBox)
            return makeDraft(from: text, certificateData: firstPage?.jpegData(compressionQuality: 0.88))
        }

        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return nil }

        let text = await recognizeText(in: [image])
        return makeDraft(from: text, certificateData: data)
    }

    private func recognizeText(in images: [UIImage]) async -> String {
        await withTaskGroup(of: String.self) { group in
            for image in images {
                group.addTask {
                    await recognizeText(in: image)
                }
            }

            var combined = ""
            for await chunk in group {
                if !combined.isEmpty, !chunk.isEmpty {
                    combined += "\n"
                }
                combined += chunk
            }
            return combined
        }
    }

    private func recognizeText(in image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let text = (request.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n") ?? ""
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: "")
            }
        }
    }

    private func makeDraft(from rawText: String, certificateData: Data?) -> VaccineRecord {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let vaccineTitle = inferVaccineTitle(from: text)
        let dates = extractDates(from: text)
        let lastGiven = inferLastGiven(from: dates)
        let nextDue = inferNextDue(from: dates, after: lastGiven)
        let note = makeNote(from: text)

        return VaccineRecord(
            title: vaccineTitle,
            lastGiven: lastGiven,
            nextDue: nextDue,
            status: nextDue < Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now ? .watch : .onTrack,
            note: note,
            certificateData: certificateData
        )
    }

    private func inferVaccineTitle(from text: String) -> String {
        let lower = text.lowercased()
        let knownTitles = [
            "rabies": "Rabies",
            "dhpp": "DHPP",
            "distemper": "DHPP",
            "bordetella": "Bordetella",
            "leptospirosis": "Leptospirosis",
            "lepto": "Leptospirosis",
            "influenza": "Canine Influenza",
            "parvo": "DHPP"
        ]

        for (key, title) in knownTitles where lower.contains(key) {
            return title
        }

        return "Imported Vaccine Record"
    }

    private func extractDates(from text: String) -> [Date] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let nsText = text as NSString
        let results = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length)) ?? []
        return results.compactMap(\.date).sorted()
    }

    private func inferLastGiven(from dates: [Date]) -> Date {
        let now = Date()
        return dates.last(where: { $0 <= now }) ?? now
    }

    private func inferNextDue(from dates: [Date], after lastGiven: Date) -> Date {
        if let future = dates.first(where: { $0 > Date() }) {
            return future
        }
        if let later = dates.first(where: { $0 > lastGiven }) {
            return later
        }
        return Calendar.current.date(byAdding: .year, value: 1, to: lastGiven) ?? lastGiven
    }

    private func makeNote(from text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.isEmpty {
            return "Imported from vaccine certificate."
        }

        return String(cleaned.prefix(180))
    }
}
