import SwiftUI

private enum LegalSection: String, CaseIterable, Identifiable {
    case privacy
    case terms
    case launch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy:
            return L10n.tr("Privacy", default: "Privacy")
        case .terms:
            return L10n.tr("Terms", default: "Terms")
        case .launch:
            return L10n.tr("Launch Notes", default: "Launch Notes")
        }
    }
}

private enum LegalLinksConfiguration {
    static let privacyPolicyURL: URL? = nil
    static let termsURL: URL? = nil
    static let supportURL: URL? = nil
    static let websiteURL: URL? = nil
}

struct LegalCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection: LegalSection = .privacy

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        heroCard
                        selector
                        contentCard
                        linksCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle(L10n.tr("Privacy & Terms", default: "Privacy & Terms"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.tr("Done", default: "Done")) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var heroCard: some View {
        GlassCard(tone: .lagoon) {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.tr("Trust", default: "Trust").uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.55))

                Text(L10n.tr("Clear expectations for pet parents", default: "Clear expectations for pet parents"))
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.tr("AuriTails is designed to be warm and helpful, but also clear about what stays local, what may sync, and what should still go to a real veterinarian.", default: "AuriTails is designed to be warm and helpful, but also clear about what stays local, what may sync, and what should still go to a real veterinarian."))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var selector: some View {
        HStack(spacing: 10) {
            ForEach(LegalSection.allCases) { section in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        selection = section
                    }
                } label: {
                    Text(section.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(selection == section ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            Capsule()
                                .fill(selection == section ? Color.white : Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97, pressedBrightness: 0.03))
            }
        }
    }

    private var contentCard: some View {
        GlassCard(tone: cardTone) {
            ForEach(activeContent, id: \.title) { block in
                LegalContentBlock(block: block)
            }
        }
    }

    private var linksCard: some View {
        GlassCard(tone: .twilight) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.tr("Support & Links", default: "Support & Links").uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.55))

                    Text(L10n.tr("Publish the final public destinations", default: "Publish the final public destinations"))
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(L10n.tr("Add your public privacy, terms, support, and website links here before launch so users can reach the final published versions.", default: "Add your public privacy, terms, support, and website links here before launch so users can reach the final published versions."))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                if availableLinks.isEmpty {
                    LegalContentBlock(
                        block: LegalBlock(
                            title: L10n.tr("Launch checklist item", default: "Launch checklist item"),
                            body: L10n.tr("No public URLs are configured yet. Add your published Privacy Policy, Terms, support, and website URLs in LegalLinksConfiguration before release.", default: "No public URLs are configured yet. Add your published Privacy Policy, Terms, support, and website URLs in LegalLinksConfiguration before release.")
                        )
                    )
                } else {
                    ForEach(availableLinks) { item in
                        Link(destination: item.url) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(item.tone.opacity(0.22))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: item.icon)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(item.tone)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Text(item.url.absoluteString)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.68))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.82))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                                    }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var activeContent: [LegalBlock] {
        switch selection {
        case .privacy:
            return privacyBlocks
        case .terms:
            return termsBlocks
        case .launch:
            return launchBlocks
        }
    }

    private var cardTone: PaletteTone {
        switch selection {
        case .privacy: .lagoon
        case .terms: .twilight
        case .launch: .apricot
        }
    }

    private var availableLinks: [LegalLinkItem] {
        [
            LegalLinksConfiguration.privacyPolicyURL.map {
                LegalLinkItem(
                    title: L10n.tr("Privacy Policy URL", default: "Privacy Policy URL"),
                    url: $0,
                    icon: "hand.raised.fill",
                    tone: Color(red: 0.71, green: 0.87, blue: 0.98)
                )
            },
            LegalLinksConfiguration.termsURL.map {
                LegalLinkItem(
                    title: L10n.tr("Terms URL", default: "Terms URL"),
                    url: $0,
                    icon: "doc.text.fill",
                    tone: Color(red: 0.83, green: 0.76, blue: 0.98)
                )
            },
            LegalLinksConfiguration.supportURL.map {
                LegalLinkItem(
                    title: L10n.tr("Support", default: "Support"),
                    url: $0,
                    icon: "envelope.fill",
                    tone: Color(red: 0.98, green: 0.80, blue: 0.62)
                )
            },
            LegalLinksConfiguration.websiteURL.map {
                LegalLinkItem(
                    title: L10n.tr("Website", default: "Website"),
                    url: $0,
                    icon: "globe",
                    tone: Color(red: 0.66, green: 0.89, blue: 0.76)
                )
            }
        ]
        .compactMap { $0 }
    }
}

private struct LegalBlock {
    let title: String
    let body: String
}

private struct LegalLinkItem: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
    let icon: String
    let tone: Color
}

private struct LegalContentBlock: View {
    let block: LegalBlock

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(block.title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(block.body)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                }
        )
    }
}

private let privacyBlocks: [LegalBlock] = [
    LegalBlock(
        title: L10n.tr("Local-first by default", default: "Local-first by default"),
        body: L10n.tr("AuriTails is designed to keep core pet profiles, routines, wellness records, memories, and most media on the device by default. If the app is deleted, local-only data may also be deleted unless you created a backup.", default: "AuriTails is designed to keep core pet profiles, routines, wellness records, memories, and most media on the device by default. If the app is deleted, local-only data may also be deleted unless you created a backup.")
    ),
    LegalBlock(
        title: L10n.tr("Data you provide", default: "Data you provide"),
        body: L10n.tr("You may enter owner details, pet details, routines, behavior check-ins, medications, symptoms, vaccine records, food notes, memories, and optional photos or scanned documents.", default: "You may enter owner details, pet details, routines, behavior check-ins, medications, symptoms, vaccine records, food notes, memories, and optional photos or scanned documents.")
    ),
    LegalBlock(
        title: L10n.tr("Permissions", default: "Permissions"),
        body: L10n.tr("The app may ask for Photos, Camera, Location, and Notifications depending on which features you use. Each one supports a specific pet-care feature such as document scanning, memory photos, nearby vet lookup, or reminders.", default: "The app may ask for Photos, Camera, Location, and Notifications depending on which features you use. Each one supports a specific pet-care feature such as document scanning, memory photos, nearby vet lookup, or reminders.")
    ),
    LegalBlock(
        title: L10n.tr("Cloud services when enabled", default: "Cloud services when enabled"),
        body: L10n.tr("If Care Circle or other cloud features are enabled, AuriTails may use Firebase Authentication, Firestore, Storage, Analytics, and Crashlytics. Those services are optional and should be disclosed clearly in the shipping build.", default: "If Care Circle or other cloud features are enabled, AuriTails may use Firebase Authentication, Firestore, Storage, Analytics, and Crashlytics. Those services are optional and should be disclosed clearly in the shipping build.")
    ),
    LegalBlock(
        title: L10n.tr("Sharing", default: "Sharing"),
        body: L10n.tr("Your data is not public by default. Information is shared only when you explicitly share content, invite a trusted caregiver into Care Circle, or enable a cloud-backed shared feature.", default: "Your data is not public by default. Information is shared only when you explicitly share content, invite a trusted caregiver into Care Circle, or enable a cloud-backed shared feature.")
    )
]

private let termsBlocks: [LegalBlock] = [
    LegalBlock(
        title: L10n.tr("Not veterinary advice", default: "Not veterinary advice"),
        body: L10n.tr("AuriTails helps organize care information and generate summaries, but it does not diagnose, treat, or replace a licensed veterinarian. If your pet may be in danger, contact a real vet or emergency clinic immediately.", default: "AuriTails helps organize care information and generate summaries, but it does not diagnose, treat, or replace a licensed veterinarian. If your pet may be in danger, contact a real vet or emergency clinic immediately.")
    ),
    LegalBlock(
        title: L10n.tr("Your responsibility", default: "Your responsibility"),
        body: L10n.tr("You are responsible for the accuracy of records you enter, the caregivers you invite, and the decisions you make from reminders, logs, and trend summaries.", default: "You are responsible for the accuracy of records you enter, the caregivers you invite, and the decisions you make from reminders, logs, and trend summaries.")
    ),
    LegalBlock(
        title: L10n.tr("Local data and backups", default: "Local data and backups"),
        body: L10n.tr("Because AuriTails is local-first, you should use backup/export features if you want extra protection against reinstall or device loss. Cloud sync may cover only some data or some media in later versions.", default: "Because AuriTails is local-first, you should use backup/export features if you want extra protection against reinstall or device loss. Cloud sync may cover only some data or some media in later versions.")
    ),
    LegalBlock(
        title: L10n.tr("Third-party services", default: "Third-party services"),
        body: L10n.tr("Some features may rely on Apple system services or Google Firebase services. Those providers operate under their own terms and privacy policies.", default: "Some features may rely on Apple system services or Google Firebase services. Those providers operate under their own terms and privacy policies.")
    ),
    LegalBlock(
        title: L10n.tr("Availability", default: "Availability"),
        body: L10n.tr("Features such as reminders, scanning, auth links, cloud sharing, and exports depend on device support and service availability. They should be treated as supportive tools rather than guarantees.", default: "Features such as reminders, scanning, auth links, cloud sharing, and exports depend on device support and service availability. They should be treated as supportive tools rather than guarantees.")
    )
]

private let launchBlocks: [LegalBlock] = [
    LegalBlock(
        title: L10n.tr("Before App Store release", default: "Before App Store release"),
        body: L10n.tr("Publish a real public Privacy Policy URL, Terms or usage terms URL, support URL, and ideally a lightweight website or product page for AuriTails.", default: "Publish a real public Privacy Policy URL, Terms or usage terms URL, support URL, and ideally a lightweight website or product page for AuriTails.")
    ),
    LegalBlock(
        title: L10n.tr("Privacy nutrition answers", default: "Privacy nutrition answers"),
        body: L10n.tr("Review whether the release build actually uses contact info, diagnostics, analytics identifiers, location, user content, or cloud-backed shared data. Only disclose what the shipping build truly collects or processes.", default: "Review whether the release build actually uses contact info, diagnostics, analytics identifiers, location, user content, or cloud-backed shared data. Only disclose what the shipping build truly collects or processes.")
    ),
    LegalBlock(
        title: L10n.tr("Firebase decisions", default: "Firebase decisions"),
        body: L10n.tr("Before launch, lock whether Care Circle is truly live in V1, whether Analytics and Crashlytics are enabled in production, and which media types are eligible for cloud sync.", default: "Before launch, lock whether Care Circle is truly live in V1, whether Analytics and Crashlytics are enabled in production, and which media types are eligible for cloud sync.")
    ),
    LegalBlock(
        title: L10n.tr("Trust copy inside the app", default: "Trust copy inside the app"),
        body: L10n.tr("Explain what stays local, what may sync to cloud, what shared caregivers can see, and what happens when the app is deleted. That clarity matters as much as the legal documents themselves.", default: "Explain what stays local, what may sync to cloud, what shared caregivers can see, and what happens when the app is deleted. That clarity matters as much as the legal documents themselves.")
    )
]
