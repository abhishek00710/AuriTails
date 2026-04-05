import SwiftUI
import Foundation
import UIKit

private enum DecodedImageCache {
    private static let cache = NSCache<NSData, UIImage>()

    static func image(from data: Data) -> UIImage? {
        let key = data as NSData
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        guard let image = UIImage(data: data) else {
            return nil
        }

        cache.setObject(image, forKey: key)
        return image
    }
}

struct CachedDataImage<Placeholder: View>: View {
    let imageData: Data?
    @ViewBuilder let placeholder: () -> Placeholder

    var body: some View {
        if let imageData, let image = DecodedImageCache.image(from: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            placeholder()
        }
    }
}

extension ColorScheme {
    var topBarTitleColor: Color {
        self == .dark ? .white : Color.black.opacity(0.9)
    }

    var topBarButtonColor: Color {
        self == .dark ? Color.black.opacity(0.9) : .white
    }

    var topBarButtonBackground: Color {
        self == .dark ? Color.white.opacity(0.78) : Color.black.opacity(0.28)
    }

    var topBarButtonStroke: Color {
        self == .dark ? Color.white.opacity(0.16) : Color.white.opacity(0.10)
    }
}

extension PaletteTone {
    var primaryColor: Color {
        switch self {
        case .apricot: Color(red: 0.98, green: 0.63, blue: 0.49)
        case .meadow: Color(red: 0.39, green: 0.69, blue: 0.52)
        case .lagoon: Color(red: 0.30, green: 0.66, blue: 0.78)
        case .twilight: Color(red: 0.35, green: 0.39, blue: 0.68)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .apricot: Color(red: 0.99, green: 0.83, blue: 0.63)
        case .meadow: Color(red: 0.74, green: 0.88, blue: 0.67)
        case .lagoon: Color(red: 0.70, green: 0.90, blue: 0.93)
        case .twilight: Color(red: 0.67, green: 0.72, blue: 0.95)
        }
    }
}

extension InsightPriority {
    var tint: Color {
        switch self {
        case .steady: Color(red: 0.30, green: 0.66, blue: 0.78)
        case .watch: Color(red: 0.95, green: 0.58, blue: 0.42)
        case .celebrate: Color(red: 0.38, green: 0.75, blue: 0.52)
        }
    }

    var title: String {
        switch self {
        case .steady: L10n.tr("Steady", default: "Steady")
        case .watch: L10n.tr("Watch", default: "Watch")
        case .celebrate: L10n.tr("Celebrate", default: "Celebrate")
        }
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    var pressScale: CGFloat = 0.95
    var pressedBrightness: Double = 0.05

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressScale : 1)
            .brightness(configuration.isPressed ? pressedBrightness : 0)
            .animation(.bouncy(duration: 0.26, extraBounce: 0.22), value: configuration.isPressed)
    }
}

enum ProfilePhotoRole {
    case owner
    case pet
}

struct CircularProfilePhoto: View {
    let imageData: Data?
    let role: ProfilePhotoRole
    var size: CGFloat = 54

    var body: some View {
        CachedDataImage(imageData: imageData) {
                placeholder
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(.white.opacity(0.28), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.16), radius: 10, y: 5)
    }

    @ViewBuilder
    private var placeholder: some View {
        switch role {
        case .owner:
            TemporaryOwnerPortraitArtwork()
        case .pet:
            TemporaryPetPortraitArtwork()
        }
    }
}

struct RoundedProfilePhoto: View {
    let imageData: Data?
    let role: ProfilePhotoRole
    var height: CGFloat = 156
    var cornerRadius: CGFloat = 28
    var expandsHorizontally = false
    var maxWidth: CGFloat? = UIScreen.main.bounds.width / 2 - 32

    var body: some View {
        CachedDataImage(imageData: imageData) {
                placeholder
        }
        .frame(maxWidth: expandsHorizontally ? .infinity : maxWidth)
        .frame(height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
    }

    @ViewBuilder
    private var placeholder: some View {
        switch role {
        case .owner:
            TemporaryOwnerPortraitArtwork()
        case .pet:
            TemporaryPetPortraitArtwork()
        }
    }
}

struct BondHeroPhoto: View {
    let imageData: Data?
    var height: CGFloat = 250
    var cornerRadius: CGFloat = 30

    var body: some View {
        CachedDataImage(imageData: imageData) {
                BondPortraitArtwork()
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.16), radius: 18, y: 10)
    }
}

extension RootTab {
    var selectionColors: [Color] {
        switch self {
        case .dashboard:
            [
                Color(red: 0.99, green: 0.86, blue: 0.66),
                Color(red: 0.48, green: 0.83, blue: 0.84),
            ]
        case .wellness:
            [
                Color(red: 0.79, green: 0.94, blue: 0.72),
                Color(red: 0.48, green: 0.79, blue: 0.58),
            ]
        case .routines:
            [
                Color(red: 1.00, green: 0.79, blue: 0.58),
                Color(red: 0.98, green: 0.60, blue: 0.40),
            ]
        case .memories:
            [
                Color(red: 0.81, green: 0.82, blue: 0.98),
                Color(red: 0.63, green: 0.70, blue: 0.95),
            ]
        }
    }

    var selectionGlowColor: Color {
        selectionColors.last ?? .white
    }

    var selectionForegroundColor: Color {
        Color(red: 0.10, green: 0.13, blue: 0.22)
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.17, blue: 0.23),
                    Color(red: 0.08, green: 0.31, blue: 0.39),
                    Color(red: 0.16, green: 0.23, blue: 0.39),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 1.00, green: 0.71, blue: 0.48).opacity(0.50))
                .frame(width: 350)
                .blur(radius: 68)
                .offset(x: -150, y: -314)

            Circle()
                .fill(Color(red: 0.43, green: 0.84, blue: 0.88).opacity(0.40))
                .frame(width: 300)
                .blur(radius: 76)
                .offset(x: 178, y: -108)

            Circle()
                .fill(Color(red: 0.58, green: 0.91, blue: 0.76).opacity(0.28))
                .frame(width: 376)
                .blur(radius: 88)
                .offset(x: 94, y: 326)

            Ellipse()
                .fill(Color(red: 0.99, green: 0.84, blue: 0.62).opacity(0.12))
                .frame(width: 420, height: 170)
                .blur(radius: 40)
                .offset(x: 44, y: 382)
        }
    }
}

struct TabBarSeparationLayer: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.34))
                .frame(height: 92)
                .blur(radius: 28)
                .offset(y: 22)

            Ellipse()
                .fill(Color.white.opacity(0.08))
                .frame(height: 72)
                .blur(radius: 24)
                .offset(y: -4)

            LinearGradient(
                colors: [
                    Color.white.opacity(0.10),
                    Color.white.opacity(0.03),
                    .clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .blur(radius: 10)
        }
        .allowsHitTesting(false)
    }
}

struct GlassCard<Content: View>: View {
    let tone: PaletteTone?
    @ViewBuilder var content: Content

    init(tone: PaletteTone? = nil, @ViewBuilder content: () -> Content) {
        self.tone = tone
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 22, y: 14)
    }

    private var gradientColors: [Color] {
        guard let tone else {
            return [
                Color.white.opacity(0.12),
                Color.white.opacity(0.07),
            ]
        }

        return [
            tone.primaryColor.opacity(0.28),
            tone.secondaryColor.opacity(0.12),
            Color.white.opacity(0.06),
        ]
    }
}

struct SectionHeader: View {
    let eyebrow: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.tr(eyebrow, default: eyebrow).uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.55))

            Text(title)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text(detail)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
    }
}

struct FloatingTabBar: View {
    let selectedTab: RootTab
    let onSelect: (RootTab) -> Void
    @Namespace private var selectionAnimation

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RootTab.allCases) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: tab.symbolName)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(selectedTab == tab ? tab.selectionForegroundColor : Color.white.opacity(0.58))
                    .scaleEffect(selectedTab == tab ? 1.02 : 1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        ZStack {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                tab.selectionColors[0].opacity(0.98),
                                                tab.selectionColors[1].opacity(0.88),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .matchedGeometryEffect(id: "tab-selection", in: selectionAnimation)
                                    .overlay {
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.34),
                                                        Color.white.opacity(0.12),
                                                        .clear,
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                    }
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [
                                                        .white.opacity(0.45),
                                                        .white.opacity(0.12),
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                ),
                                                lineWidth: 1
                                            )
                                    }
                                    .shadow(color: tab.selectionGlowColor.opacity(0.42), radius: 18, y: 10)
                                    .shadow(color: Color.white.opacity(0.16), radius: 6, y: -2)
                            }
                        }
                    }
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.93, pressedBrightness: 0.08))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background {
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.16),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.10),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .overlay {
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.34),
                            .white.opacity(0.08),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        }
        .background {
            ZStack {
                Capsule()
                    .fill(Color.black.opacity(0.22))
                    .blur(radius: 28)
                    .padding(.horizontal, 10)
                    .offset(y: 16)

                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .blur(radius: 18)
                    .padding(.horizontal, 24)
                    .offset(y: -8)
            }
        }
        .shadow(color: .black.opacity(0.24), radius: 28, y: 14)
    }
}

struct StatChip: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))

            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct WeekdayPicker: View {
    @Binding var selection: Weekday

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Weekday.allCases) { day in
                Button {
                    selection = day
                } label: {
                    VStack(spacing: 6) {
                        Text(day.shortTitle)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Circle()
                            .fill(selection == day ? .white : .white.opacity(0.35))
                            .frame(width: 6, height: 6)
                    }
                    .foregroundStyle(selection == day ? Color(red: 0.12, green: 0.15, blue: 0.22) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        Capsule()
                            .fill(selection == day ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.08)))
                    }
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.94))
            }
        }
    }
}

struct SlideMenuPanel: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Menu")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Quick access for your companion space")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.66))
                }

                Spacer()

                Button {
                    viewModel.closeMenu()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.10), in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        }
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.9))
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("ACCOUNT")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.46))

                Button {
                    viewModel.openProfile()
                } label: {
                    MenuProfileCard(
                        owner: viewModel.owner,
                        pet: viewModel.pet,
                        ownerPhotoData: viewModel.ownerPhotoData,
                        petPhotoData: viewModel.petPhotoData
                    )
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.98, pressedBrightness: 0.02))
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("TOOLS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.46))

                SocialMenuActionRow(
                    icon: "bell.badge.fill",
                    iconTint: .apricot,
                    title: "Notifications",
                    subtitle: "Control reminder timing and which moments should ping you."
                ) {
                    viewModel.openNotificationSettings()
                }

                BackupActionsRow(
                    exportAction: viewModel.exportBackup,
                    restoreAction: viewModel.importBackup
                )

                SocialMenuActionRow(
                    icon: "square.and.arrow.up.fill",
                    iconTint: .twilight,
                    title: "Share AuriTails",
                    subtitle: "Invite someone else into the bond-first pet care experience."
                ) {
                    viewModel.openAppShare()
                }

                SocialMenuActionRow(
                    icon: "sparkles",
                    iconTint: .lagoon,
                    title: "Bond Pulse",
                    subtitle: "\(viewModel.insights.count) relationship signals ready for \(viewModel.pet.name)."
                ) {
                    viewModel.openAI()
                }
            }

            #if DEBUG
            VStack(alignment: .leading, spacing: 12) {
                Text("DEVELOPMENT")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.46))

                SocialMenuActionRow(
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    iconTint: .meadow,
                    title: "Switch app mode",
                    subtitle: "Re-open onboarding so you can jump back into demo mode or start fresh."
                ) {
                    viewModel.reopenOnboardingForDevelopment()
                }
            }
            #endif

            Text("Designed to feel more like a companion hub than a settings drawer.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.52))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.14),
                                    Color.white.opacity(0.07),
                                    Color.black.opacity(0.08),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.22), radius: 28, y: 16)
    }
}

private struct MenuProfileCard: View {
    let owner: OwnerProfile
    let pet: PetProfile
    let ownerPhotoData: Data?
    let petPhotoData: Data?

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: -10) {
                CircularProfilePhoto(imageData: ownerPhotoData, role: .owner, size: 56)
                CircularProfilePhoto(imageData: petPhotoData, role: .pet, size: 56)
            }
            .padding(.trailing, 4)

            VStack(alignment: .leading, spacing: 5) {
                Text("\(owner.name) & \(pet.name)")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("View profile studio")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(pet.breed) • \(owner.location)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.48))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.42))
        }
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

private struct SocialMenuActionRow: View {
    let icon: String
    let iconTint: PaletteTone
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SocialMenuActionRowLabel(
                icon: icon,
                iconTint: iconTint,
                title: title,
                subtitle: subtitle
            )
        }
        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.98, pressedBrightness: 0.02))
    }
}

private struct SocialMenuActionRowLabel: View {
    let icon: String
    let iconTint: PaletteTone
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(iconTint.primaryColor.opacity(0.22))

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconTint.secondaryColor)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.40))
        }
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

struct MemoryPostcard: View {
    let memory: MemoryMoment
    var onShare: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                Label(memory.dateLabel, systemImage: memory.systemImage)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.65), in: Capsule())

                Spacer()

                if let onShare {
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.65), in: Capsule())
                    }
                    .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                }

                if let days = memory.daysUntilNextCelebration {
                    Text("\(days)d")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.65), in: Capsule())
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text(memory.title)
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text(memory.caption)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                Text(memory.detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            ZStack {
                if memory.photoData != nil {
                    CachedDataImage(imageData: memory.photoData) {
                        EmptyView()
                    }
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.16),
                                Color.black.opacity(0.08),
                                memory.tone.primaryColor.opacity(0.18),
                                Color.black.opacity(0.46),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [memory.tone.primaryColor, memory.tone.secondaryColor, Color.black.opacity(0.26)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        }
    }
}

private struct BackupActionsRow: View {
    let exportAction: () -> Void
    let restoreAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PaletteTone.meadow.primaryColor.opacity(0.22))

                    Image(systemName: "externaldrive.badge.icloud")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(PaletteTone.meadow.secondaryColor)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Backup")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Export or restore your full pet journey from one safe file.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.66))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                BackupActionButton(
                    icon: "square.and.arrow.up.fill",
                    title: "Export",
                    tone: .meadow,
                    action: exportAction
                )

                BackupActionButton(
                    icon: "square.and.arrow.down.fill",
                    title: "Restore",
                    tone: .apricot,
                    action: restoreAction
                )
            }
        }
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

private struct BackupActionButton: View {
    let icon: String
    let title: LocalizedStringKey
    let tone: PaletteTone
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tone.primaryColor.opacity(0.24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(tone.secondaryColor.opacity(0.32), lineWidth: 1)
                    }
            )
        }
        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97, pressedBrightness: 0.02))
    }
}

struct OwnerPetRow: View {
    let owner: OwnerProfile
    let pet: PetProfile
    var ownerPhotoData: Data? = nil
    var petPhotoData: Data? = nil
    var supportingText: String? = nil
    var showsChevron = false

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: -12) {
                CircularProfilePhoto(imageData: ownerPhotoData, role: .owner, size: 52)
                CircularProfilePhoto(imageData: petPhotoData, role: .pet, size: 52)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(owner.name) + \(pet.name)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(supportingText ?? "\(pet.breed) • \(owner.location)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct AvatarBadge: View {
    let label: String
    let tone: PaletteTone

    var body: some View {
        Text(label)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
            .frame(width: 42, height: 42)
            .background(tone.secondaryColor, in: Circle())
            .overlay {
                Circle().strokeBorder(.white.opacity(0.24), lineWidth: 1)
            }
    }
}

struct MenuActionRow: View {
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let tone: PaletteTone
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tone.secondaryColor)
                    .frame(width: 44, height: 44)
                    .background(tone.primaryColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(detail)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(LiquidGlassButtonStyle())
    }
}

struct TemporaryOwnerPortraitArtwork: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.66, blue: 0.51),
                    Color(red: 0.98, green: 0.83, blue: 0.70),
                    Color(red: 0.44, green: 0.76, blue: 0.86),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.24))
                .frame(width: 132, height: 132)
                .offset(x: 56, y: -66)

            Circle()
                .fill(Color.black.opacity(0.16))
                .frame(width: 84, height: 84)
                .offset(y: -8)

            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .frame(width: 132, height: 150)
                .offset(y: 88)

            Capsule()
                .fill(Color.white.opacity(0.14))
                .frame(width: 76, height: 28)
                .offset(y: 72)

            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: 170, height: 34)
                .offset(y: 142)
        }
    }
}

struct TemporaryPetPortraitArtwork: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.37, green: 0.70, blue: 0.82),
                    Color(red: 0.63, green: 0.86, blue: 0.92),
                    Color(red: 0.99, green: 0.82, blue: 0.62),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.20))
                .frame(width: 116, height: 116)
                .offset(x: 64, y: -70)

            Ellipse()
                .fill(Color.black.opacity(0.16))
                .frame(width: 156, height: 108)
                .offset(y: 70)

            Circle()
                .fill(Color.black.opacity(0.18))
                .frame(width: 88, height: 88)
                .offset(y: 6)

            Triangle()
                .fill(Color.black.opacity(0.18))
                .frame(width: 34, height: 34)
                .offset(x: -28, y: -44)

            Triangle()
                .fill(Color.black.opacity(0.18))
                .frame(width: 34, height: 34)
                .offset(x: 28, y: -44)

            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.black.opacity(0.16))
                .frame(width: 138, height: 126)
                .offset(y: 96)

            Capsule()
                .fill(Color.white.opacity(0.12))
                .frame(width: 64, height: 26)
                .offset(y: 86)

            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: 182, height: 30)
                .offset(y: 146)
        }
    }
}

struct BondPortraitArtwork: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.99, green: 0.72, blue: 0.48),
                            Color(red: 0.99, green: 0.84, blue: 0.67),
                            Color(red: 0.49, green: 0.72, blue: 0.76),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 120, height: 120)
                .offset(x: 108, y: -68)

            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 220, height: 26)
                .offset(y: 92)

            Group {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.black.opacity(0.22))
                    .frame(width: 96, height: 134)
                    .offset(x: -30, y: 20)

                Circle()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 72, height: 72)
                    .offset(x: -30, y: -42)

                Capsule()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 18, height: 88)
                    .offset(x: -56, y: 72)
                    .rotationEffect(.degrees(7))

                Capsule()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 18, height: 82)
                    .offset(x: -6, y: 72)
                    .rotationEffect(.degrees(-5))

                Ellipse()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 116, height: 70)
                    .offset(x: 60, y: 38)

                Circle()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: 50, height: 50)
                    .offset(x: 96, y: 6)

                Triangle()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: 22, height: 22)
                    .offset(x: 82, y: -16)

                Triangle()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: 22, height: 22)
                    .offset(x: 112, y: -16)

                Capsule()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 12, height: 48)
                    .offset(x: 38, y: 82)

                Capsule()
                    .fill(Color.black.opacity(0.24))
                    .frame(width: 12, height: 48)
                    .offset(x: 80, y: 82)

                Capsule()
                    .fill(Color.black.opacity(0.22))
                    .frame(width: 52, height: 10)
                    .offset(x: 126, y: 40)
                    .rotationEffect(.degrees(24))
            }
        }
        .frame(height: 250)
    }
}

struct BehaviorSparkline: View {
    let snapshots: [BehaviorSnapshot]

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(snapshots) { snapshot in
                VStack(spacing: 8) {
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.08))
                            .frame(width: 28, height: 124)

                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.42, green: 0.82, blue: 0.68),
                                        Color(red: 0.99, green: 0.70, blue: 0.51),
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 28, height: max(28, 124 * snapshot.energy))

                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                            .offset(y: CGFloat(-110 * snapshot.calmness))
                    }

                    Text(snapshot.day.shortTitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
