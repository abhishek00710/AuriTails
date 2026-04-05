import SwiftUI
import UIKit

struct VetVisitPackBuilder {
    struct DocumentPayload {
        let url: URL
        let title: String
    }

    func makeDocument(
        owner: OwnerProfile,
        pet: PetProfile,
        vaccinations: [VaccineRecord],
        medicalHistory: [MedicalEntry],
        foodPreferences: [FoodPreference],
        routines: [RoutineItem],
        bondPhotoData: Data?
    ) throws -> DocumentPayload {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let title = "AuriTails-Vet-Visit-Pack-\(pet.name.replacingOccurrences(of: " ", with: "-"))"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(title)
            .appendingPathExtension("pdf")

        let sortedVaccinations = vaccinations.sorted { $0.nextDue < $1.nextDue }
        let sortedMedical = medicalHistory.sorted { $0.date > $1.date }
        let sortedRoutines = routines.sorted { lhs, rhs in
            if lhs.day.rawValue != rhs.day.rawValue {
                return lhs.day.rawValue < rhs.day.rawValue
            }
            return lhs.time < rhs.time
        }

        try renderer.writePDF(to: url) { context in
            var pageNumber = 1
            var yOffset: CGFloat = 44

            func beginPageIfNeeded(for requiredHeight: CGFloat) {
                if yOffset + requiredHeight < pageBounds.height - 48 { return }
                context.beginPage()
                pageNumber += 1
                yOffset = 44
                drawPageFooter(pageNumber: pageNumber, bounds: pageBounds)
            }

            context.beginPage()
            drawPageFooter(pageNumber: pageNumber, bounds: pageBounds)

            drawHeader(
                title: "Vet Visit Pack",
                subtitle: "Prepared by AuriTails for \(pet.name)",
                owner: owner,
                pet: pet,
                bondPhotoData: bondPhotoData,
                in: pageBounds,
                yOffset: &yOffset
            )

            yOffset += 20
            drawSection(
                title: "Care Snapshot",
                rows: [
                    ("Owner", owner.name),
                    ("Pet", pet.name),
                    ("Breed", pet.breed),
                    ("Age", pet.ageDescription),
                    ("Weight", pet.weightDescription),
                    ("Favorite treat", pet.favoriteTreat),
                ],
                bounds: pageBounds,
                yOffset: &yOffset
            )

            yOffset += 18
            beginPageIfNeeded(for: max(180, CGFloat(sortedVaccinations.count) * 74 + 80))
            drawVaccines(sortedVaccinations, bounds: pageBounds, yOffset: &yOffset)

            yOffset += 18
            beginPageIfNeeded(for: max(180, CGFloat(sortedMedical.count) * 88 + 80))
            drawMedicalHistory(sortedMedical, bounds: pageBounds, yOffset: &yOffset)

            yOffset += 18
            beginPageIfNeeded(for: max(160, CGFloat(foodPreferences.count) * 58 + 80))
            drawSection(
                title: "Food Notes",
                rows: foodPreferences.map { ($0.title, $0.detail) },
                bounds: pageBounds,
                yOffset: &yOffset
            )

            yOffset += 18
            beginPageIfNeeded(for: max(180, CGFloat(sortedRoutines.count) * 60 + 80))
            drawSection(
                title: "Weekly Routines",
                rows: sortedRoutines.map { ("\($0.day.title) • \($0.time.label)", "\($0.title) — \($0.subtitle)") },
                bounds: pageBounds,
                yOffset: &yOffset
            )
        }

        return DocumentPayload(url: url, title: title)
    }

    private func drawHeader(
        title: String,
        subtitle: String,
        owner: OwnerProfile,
        pet: PetProfile,
        bondPhotoData: Data?,
        in bounds: CGRect,
        yOffset: inout CGFloat
    ) {
        let cardFrame = CGRect(x: 36, y: yOffset, width: bounds.width - 72, height: 172)
        let path = UIBezierPath(roundedRect: cardFrame, cornerRadius: 28)
        UIColor(red: 0.17, green: 0.42, blue: 0.55, alpha: 1).setFill()
        path.fill()

        if let bondPhotoData, let image = UIImage(data: bondPhotoData) {
            image.draw(in: cardFrame, blendMode: .normal, alpha: 0.18)
        }

        UIColor.white.withAlphaComponent(0.18).setStroke()
        path.lineWidth = 1
        path.stroke()

        let titleAttrs = attributed(fontSize: 28, weight: .bold, color: .white, fontDesign: .serif)
        let subtitleAttrs = attributed(fontSize: 14, weight: .medium, color: UIColor.white.withAlphaComponent(0.82))
        let bodyAttrs = attributed(fontSize: 13, weight: .medium, color: UIColor.white.withAlphaComponent(0.74))

        NSString(string: title).draw(in: CGRect(x: 60, y: yOffset + 24, width: cardFrame.width - 48, height: 34), withAttributes: titleAttrs)
        NSString(string: subtitle).draw(in: CGRect(x: 60, y: yOffset + 60, width: cardFrame.width - 48, height: 20), withAttributes: subtitleAttrs)

        let summary = "\(owner.name) • \(owner.location)\n\(pet.name) • \(pet.breed) • \(pet.ageDescription) • \(pet.weightDescription)"
        NSString(string: summary).draw(
            in: CGRect(x: 60, y: yOffset + 98, width: cardFrame.width - 48, height: 50),
            withAttributes: bodyAttrs
        )

        yOffset = cardFrame.maxY
    }

    private func drawVaccines(_ vaccinations: [VaccineRecord], bounds: CGRect, yOffset: inout CGFloat) {
        drawSectionTitle("Vaccination Summary", y: yOffset, width: bounds.width - 72)
        yOffset += 36

        for vaccine in vaccinations {
            let frame = CGRect(x: 36, y: yOffset, width: bounds.width - 72, height: 64)
            fillRow(frame: frame)
            let titleAttrs = attributed(fontSize: 15, weight: .bold, color: UIColor(red: 0.10, green: 0.13, blue: 0.22, alpha: 1))
            let detailAttrs = attributed(fontSize: 12, weight: .medium, color: UIColor(red: 0.33, green: 0.39, blue: 0.47, alpha: 1))
            let badgeAttrs = attributed(fontSize: 11, weight: .bold, color: UIColor(red: 0.10, green: 0.13, blue: 0.22, alpha: 1))

            NSString(string: vaccine.title).draw(in: CGRect(x: 52, y: yOffset + 12, width: 230, height: 18), withAttributes: titleAttrs)
            NSString(string: "Last given • \(vaccine.lastGivenLabel)\nNext due • \(vaccine.nextDueLabel)").draw(
                in: CGRect(x: 52, y: yOffset + 32, width: 260, height: 26),
                withAttributes: detailAttrs
            )

            let badgeText = vaccine.status.title as NSString
            let badgeSize = badgeText.size(withAttributes: badgeAttrs)
            let badgeRect = CGRect(x: bounds.width - 36 - badgeSize.width - 26, y: yOffset + 18, width: badgeSize.width + 18, height: 24)
            UIColor.white.withAlphaComponent(0.94).setFill()
            UIBezierPath(roundedRect: badgeRect, cornerRadius: 12).fill()
            badgeText.draw(in: CGRect(x: badgeRect.minX + 9, y: badgeRect.minY + 6, width: badgeSize.width, height: 14), withAttributes: badgeAttrs)

            yOffset += 74
        }
    }

    private func drawMedicalHistory(_ entries: [MedicalEntry], bounds: CGRect, yOffset: inout CGFloat) {
        drawSectionTitle("Medical History", y: yOffset, width: bounds.width - 72)
        yOffset += 36

        for entry in entries {
            let frame = CGRect(x: 36, y: yOffset, width: bounds.width - 72, height: 78)
            fillRow(frame: frame)
            NSString(string: entry.title).draw(
                in: CGRect(x: 52, y: yOffset + 12, width: frame.width - 32, height: 18),
                withAttributes: attributed(fontSize: 15, weight: .bold, color: UIColor(red: 0.10, green: 0.13, blue: 0.22, alpha: 1))
            )
            NSString(string: "\(entry.dateLabel) • \(entry.clinician)").draw(
                in: CGRect(x: 52, y: yOffset + 32, width: frame.width - 32, height: 14),
                withAttributes: attributed(fontSize: 12, weight: .medium, color: UIColor(red: 0.33, green: 0.39, blue: 0.47, alpha: 1))
            )
            NSString(string: entry.summary).draw(
                in: CGRect(x: 52, y: yOffset + 48, width: frame.width - 32, height: 22),
                withAttributes: attributed(fontSize: 12, weight: .medium, color: UIColor(red: 0.22, green: 0.27, blue: 0.34, alpha: 1))
            )
            yOffset += 88
        }
    }

    private func drawSection(
        title: String,
        rows: [(String, String)],
        bounds: CGRect,
        yOffset: inout CGFloat
    ) {
        drawSectionTitle(title, y: yOffset, width: bounds.width - 72)
        yOffset += 36

        for row in rows {
            let frame = CGRect(x: 36, y: yOffset, width: bounds.width - 72, height: 48)
            fillRow(frame: frame)
            NSString(string: row.0).draw(
                in: CGRect(x: 52, y: yOffset + 10, width: 170, height: 16),
                withAttributes: attributed(fontSize: 13, weight: .bold, color: UIColor(red: 0.10, green: 0.13, blue: 0.22, alpha: 1))
            )
            NSString(string: row.1).draw(
                in: CGRect(x: 224, y: yOffset + 10, width: frame.width - 188, height: 28),
                withAttributes: attributed(fontSize: 13, weight: .medium, color: UIColor(red: 0.22, green: 0.27, blue: 0.34, alpha: 1))
            )
            yOffset += 58
        }
    }

    private func drawSectionTitle(_ title: String, y: CGFloat, width: CGFloat) {
        NSString(string: title).draw(
            in: CGRect(x: 36, y: y, width: width, height: 24),
            withAttributes: attributed(fontSize: 20, weight: .bold, color: UIColor(red: 0.10, green: 0.13, blue: 0.22, alpha: 1), fontDesign: .serif)
        )
    }

    private func fillRow(frame: CGRect) {
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 22)
        UIColor(red: 0.93, green: 0.96, blue: 0.98, alpha: 1).setFill()
        path.fill()
        UIColor(red: 0.80, green: 0.86, blue: 0.90, alpha: 1).setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    private func drawPageFooter(pageNumber: Int, bounds: CGRect) {
        NSString(string: "AuriTails Vet Visit Pack • Page \(pageNumber)").draw(
            in: CGRect(x: 36, y: bounds.height - 28, width: bounds.width - 72, height: 14),
            withAttributes: attributed(fontSize: 11, weight: .medium, color: UIColor(red: 0.40, green: 0.45, blue: 0.52, alpha: 1))
        )
    }

    private func attributed(
        fontSize: CGFloat,
        weight: UIFont.Weight,
        color: UIColor,
        fontDesign: UIFontDescriptor.SystemDesign? = nil
    ) -> [NSAttributedString.Key: Any] {
        var font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        if let fontDesign, let descriptor = font.fontDescriptor.withDesign(fontDesign) {
            font = UIFont(descriptor: descriptor, size: fontSize)
        }
        return [
            .font: font,
            .foregroundColor: color,
        ]
    }
}
