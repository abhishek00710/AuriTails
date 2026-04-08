import PhotosUI
import SwiftUI

struct ProfileStudioView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var ownerDraft: OwnerProfile
    @State private var petDraft: PetProfile
    @State private var ownerPhotoData: Data?
    @State private var petPhotoData: Data?
    @State private var bondPhotoData: Data?
    @State private var ownerPickerItem: PhotosPickerItem?
    @State private var petPickerItem: PhotosPickerItem?
    @State private var bondPickerItem: PhotosPickerItem?
    
    private let photoCardWidth = (UIScreen.main.bounds.width - 94) / 2

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        _ownerDraft = State(initialValue: viewModel.owner)
        _petDraft = State(initialValue: viewModel.pet)
        _ownerPhotoData = State(initialValue: viewModel.ownerPhotoData)
        _petPhotoData = State(initialValue: viewModel.petPhotoData)
        _bondPhotoData = State(initialValue: viewModel.bondPhotoData)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        heroCard
                        bondPhotoSection
                        ownerSection
                        petSection
                        careCircleSection
                        saveCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Profile Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(colorScheme.topBarButtonColor)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme.topBarButtonColor)
                }
            }
        }
        .task(id: ownerPickerItem) {
            if let ownerPickerItem, let data = try? await ownerPickerItem.loadTransferable(type: Data.self) {
                ownerPhotoData = data
            }
        }
        .task(id: petPickerItem) {
            if let petPickerItem, let data = try? await petPickerItem.loadTransferable(type: Data.self) {
                petPhotoData = data
            }
        }
        .task(id: bondPickerItem) {
            if let bondPickerItem, let data = try? await bondPickerItem.loadTransferable(type: Data.self) {
                bondPhotoData = data
            }
        }
    }

    private var heroCard: some View {
        GlassCard(tone: .lagoon) {
            SectionHeader(
                eyebrow: "Profile",
                title: "Make the app feel like home",
                detail: "Add details, swap photos, and shape a profile that feels personal instead of placeholder."
            )

            HStack(spacing: 14) {
                EditablePhotoCard(
                    title: "Owner Photo",
                    subtitle: ownerDraft.name,
                    imageData: ownerPhotoData,
                    role: .owner,
                    photoWidth: photoCardWidth,
                    pickerItem: $ownerPickerItem,
                    removeAction: { ownerPhotoData = nil }
                )

                EditablePhotoCard(
                    title: "Pet Photo",
                    subtitle: petDraft.name,
                    imageData: petPhotoData,
                    role: .pet,
                    photoWidth: photoCardWidth,
                    pickerItem: $petPickerItem,
                    removeAction: { petPhotoData = nil }
                )
            }
        }
    }

    private var ownerSection: some View {
        GlassCard(tone: .apricot) {
            SectionHeader(
                eyebrow: "Owner",
                title: "Owner details",
                detail: "These details drive the tone of the dashboard, memories, and menu profile summary."
            )

            ProfileInputField(title: "Name", text: $ownerDraft.name, icon: "person.fill")
            ProfileInputField(title: "Headline", text: $ownerDraft.headline, icon: "sparkles")
            ProfileInputField(title: "Location", text: $ownerDraft.location, icon: "mappin.and.ellipse")
            ProfileInputEditor(title: "Notes", text: $ownerDraft.note, icon: "note.text", height: 110)
        }
    }

    private var bondPhotoSection: some View {
        GlassCard(tone: .twilight) {
            SectionHeader(
                eyebrow: "Together",
                title: "Shared owner + pet photo",
                detail: "This image shows on the home dashboard so the app can open with one real bond-centered moment."
            )

            WideBondPhotoCard(
                imageData: bondPhotoData,
                ownerName: ownerDraft.name,
                petName: petDraft.name,
                pickerItem: $bondPickerItem,
                removeAction: { bondPhotoData = nil }
            )
        }
    }

    private var petSection: some View {
        GlassCard(tone: .meadow) {
            SectionHeader(
                eyebrow: "Pet",
                title: "Pet details",
                detail: "Keep the profile rich enough for wellness, routines, and AI suggestions to feel tailored."
            )

            ProfileInputField(title: "Name", text: $petDraft.name, icon: "pawprint.fill")
            ProfileInputField(title: "Species", text: $petDraft.species, icon: "leaf.fill")
            ProfileInputField(title: "Breed", text: $petDraft.breed, icon: "dog.fill")

            HStack(spacing: 12) {
                ProfileInputField(title: "Age", text: $petDraft.ageDescription, icon: "birthday.cake.fill")
                ProfileInputField(title: "Weight", text: $petDraft.weightDescription, icon: "scalemass.fill")
            }

            ProfileInputField(title: "Favorite treat", text: $petDraft.favoriteTreat, icon: "carrot.fill")
            ProfileInputEditor(title: "Bond statement", text: $petDraft.bondStatement, icon: "heart.text.square.fill", height: 100)
            ProfileInputEditor(title: "Energy summary", text: $petDraft.energySummary, icon: "bolt.heart.fill", height: 100)
        }
    }

    private var saveCard: some View {
        GlassCard(tone: .twilight) {
            Text("The dashboard, menu profile, and wellness context will all use these updated details right away.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))

            Button(action: saveChanges) {
                HStack {
                    Spacer()
                    Label("Save Profile", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    Spacer()
                }
                .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96, pressedBrightness: 0.05))
        }
    }

    private var careCircleSection: some View {
        GlassCard(tone: .lagoon) {
            SectionHeader(
                eyebrow: "Sharing",
                title: "Care Circle",
                detail: "Invite trusted caregivers into one shared pet space so routines, meds, and memories never live with only one person."
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    CareCircleMetricPill(
                        title: "Active",
                        value: "\(viewModel.activeCareCircleMembers.count + 1)",
                        icon: "person.2.fill"
                    )
                    CareCircleMetricPill(
                        title: "Pending",
                        value: "\(viewModel.invitedCareCircleMembers.count)",
                        icon: "paperplane.fill"
                    )
                }

                Text(viewModel.careCircleSummary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    openCareCircle()
                } label: {
                    HStack {
                        Label("Open Care Circle", systemImage: "person.2.wave.2.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white, in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96, pressedBrightness: 0.04))
            }
        }
    }

    private func saveChanges() {
        viewModel.updateProfile(
            owner: ownerDraft,
            pet: petDraft,
            ownerPhotoData: ownerPhotoData,
            petPhotoData: petPhotoData,
            bondPhotoData: bondPhotoData
        )
        dismiss()
    }

    private func openCareCircle() {
        viewModel.updateProfile(
            owner: ownerDraft,
            pet: petDraft,
            ownerPhotoData: ownerPhotoData,
            petPhotoData: petPhotoData,
            bondPhotoData: bondPhotoData
        )
        dismiss()
        DispatchQueue.main.async {
            viewModel.activeSheet = .careCircle
        }
    }
}

struct CareCircleView: View {
    @ObservedObject var viewModel: AppViewModel
    @EnvironmentObject private var authController: AuthSessionController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var draftName = ""
    @State private var draftContact = ""
    @State private var draftRelationship = ""
    @State private var draftNote = ""
    @State private var isShowingCloudAccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        overviewCard
                        cloudCard
                        inviteCard
                        membersCard
                        activityCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Care Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(colorScheme.topBarButtonColor)
                }
            }
        }
        .sheet(isPresented: $isShowingCloudAccess) {
            CareCircleAuthView()
                .environmentObject(authController)
        }
    }

    private var overviewCard: some View {
        GlassCard(tone: .lagoon) {
            SectionHeader(
                eyebrow: "Shared Space",
                title: "\(viewModel.displayPetName)'s trusted circle",
                detail: "One source of truth for routines, wellness updates, meds, and memory-keeping, with clear attribution as family sharing grows."
            )

            HStack(spacing: 12) {
                CareCircleMetricPill(title: "Members", value: "\(viewModel.totalCareCircleCount)", icon: "person.3.fill")
                CareCircleMetricPill(title: "Pending", value: "\(viewModel.invitedCareCircleMembers.count)", icon: "envelope.badge.fill")
                CareCircleMetricPill(title: "Activity", value: "\(min(viewModel.careActivityEvents.count, 9))", icon: "waveform.path.ecg")
            }

            Text(viewModel.careCircleSummary)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var inviteCard: some View {
        GlassCard(tone: .apricot) {
            SectionHeader(
                eyebrow: "Invite",
                title: "Add a trusted caregiver",
                detail: "This first pass simulates the invite flow locally so you can shape the experience before we connect a real shared backend."
            )

            ProfileInputField(title: "Name", text: $draftName, icon: "person.fill")
            ProfileInputField(title: "Email or phone", text: $draftContact, icon: "paperplane.fill")
            ProfileInputField(title: "Relationship", text: $draftRelationship, icon: "heart.fill")
            ProfileInputEditor(title: "Support note", text: $draftNote, icon: "note.text", height: 90)

            Button(action: sendInvite) {
                HStack {
                    Label("Create invite", systemImage: "person.badge.plus")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white, in: Capsule())
            }
            .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96, pressedBrightness: 0.04))
        }
    }

    private var cloudCard: some View {
        GlassCard(tone: .twilight) {
            Text("CLOUD ACCESS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.56))

            Text(authController.isConfigured ? "Firebase cloud services are ready" : "Keep cloud sharing dormant until you're ready")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(authController.statusDetail)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                CareCircleMetricPill(
                    title: "Cloud quota",
                    value: "10 MB",
                    icon: "icloud.and.arrow.up.fill"
                )
                CareCircleMetricPill(
                    title: "Mode",
                    value: authController.isConfigured ? "Firebase" : "Local-first",
                    icon: authController.isConfigured ? "checkmark.circle.fill" : "internaldrive.fill"
                )
            }

            Button {
                isShowingCloudAccess = true
            } label: {
                HStack {
                    Label(authController.isConfigured ? "Open Firebase sign-in" : "Open Firebase setup", systemImage: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96, pressedBrightness: 0.04))
        }
    }

    private var membersCard: some View {
        GlassCard(tone: .meadow) {
            SectionHeader(
                eyebrow: "Members",
                title: "Who's helping right now",
                detail: "The owner is always primary. Caregivers can start as invited and later become active once they accept."
            )

            VStack(spacing: 12) {
                CareCircleMemberRow(
                    name: viewModel.displayOwnerName,
                    subtitle: [viewModel.owner.headline, viewModel.owner.location]
                        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        .joined(separator: " • "),
                    badge: CareCircleRole.owner.title,
                    status: L10n.tr("Primary", default: "Primary"),
                    tone: .lagoon,
                    primaryActionTitle: nil,
                    primaryAction: nil,
                    secondaryActionTitle: nil,
                    secondaryAction: nil
                )

                ForEach(viewModel.careCircleMembers) { member in
                    CareCircleMemberRow(
                        name: member.name,
                        subtitle: member.subtitle,
                        badge: member.role.title,
                        status: member.status.title,
                        tone: member.status == .active ? .meadow : .twilight,
                        primaryActionTitle: member.status == .invited ? "Mark accepted" : nil,
                        primaryAction: member.status == .invited ? { viewModel.markCaregiverInviteAccepted(member.id) } : nil,
                        secondaryActionTitle: "Remove",
                        secondaryAction: { viewModel.removeCareCircleMember(member.id) }
                    )
                }

                if viewModel.careCircleMembers.isEmpty {
                    Text("No caregivers yet. The moment you invite someone, AuriTails can start feeling like a real shared family hub.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }

    private var activityCard: some View {
        GlassCard(tone: .twilight) {
            SectionHeader(
                eyebrow: "Timeline",
                title: "Recent circle activity",
                detail: "Eventually this becomes your real family-care feed. For now, it helps shape the attribution and shared-space story."
            )

            VStack(spacing: 12) {
                ForEach(viewModel.careActivityEvents.prefix(6)) { event in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(event.tone.primaryColor.opacity(0.26))
                            Image(systemName: event.systemImage)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(event.tone.secondaryColor)
                        }
                        .frame(width: 42, height: 42)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(event.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(event.detail)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)

                            Text(event.createdLabel)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.44))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }

    private func sendInvite() {
        viewModel.inviteCaregiver(
            name: draftName,
            contact: draftContact,
            relationshipLabel: draftRelationship,
            note: draftNote
        )
        draftName = ""
        draftContact = ""
        draftRelationship = ""
        draftNote = ""
    }
}

private struct CareCircleMetricPill: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                    Text(value)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct CareCircleMemberRow: View {
    let name: String
    let subtitle: String
    let badge: String
    let status: String
    let tone: PaletteTone
    let primaryActionTitle: String?
    let primaryAction: (() -> Void)?
    let secondaryActionTitle: String?
    let secondaryAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    tone.primaryColor.opacity(0.95),
                                    tone.secondaryColor.opacity(0.9),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(badge)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.8), in: Capsule())
                    }

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(status)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if primaryActionTitle != nil || secondaryActionTitle != nil {
                HStack(spacing: 10) {
                    if let primaryActionTitle, let primaryAction {
                        Button(action: primaryAction) {
                            Text(primaryActionTitle)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white, in: Capsule())
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
                    }

                    if let secondaryActionTitle, let secondaryAction {
                        Button(action: secondaryAction) {
                            Text(secondaryActionTitle)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.12), in: Capsule())
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
                    }

                    Spacer(minLength: 0)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct EditablePhotoCard: View {
    let title: LocalizedStringKey
    let subtitle: String
    let imageData: Data?
    let role: ProfilePhotoRole
    let photoWidth: CGFloat
    @Binding var pickerItem: PhotosPickerItem?
    let removeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedProfilePhoto(imageData: imageData, role: role, height: 180, cornerRadius: 28, maxWidth: photoWidth)

            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))
                .lineLimit(1)

            if imageData != nil {
                resetButton
            } else {
                chooseButton
            }
        }
        .frame(width: photoWidth, alignment: .leading)
    }

    private var chooseButton: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Label("Choose", systemImage: "photo.badge.plus")
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.white, in: Capsule())
        }
        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
    }

    @ViewBuilder
    private var resetButton: some View {
        Button(action: removeAction) {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.10), in: Capsule())
        }
        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
    }
}

private struct WideBondPhotoCard: View {
    let imageData: Data?
    let ownerName: String
    let petName: String
    @Binding var pickerItem: PhotosPickerItem?
    let removeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BondHeroPhoto(imageData: imageData, height: 220, cornerRadius: 30)

            Text("\(ownerName) + \(petName)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text("Used as the main home image when you want one photo of both together.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            if imageData != nil {
                Button(action: removeAction) {
                    Label("Reset Together Photo", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.10), in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
            } else {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Choose Together Photo", systemImage: "photo.on.rectangle.angled")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
            }
        }
    }
}

private struct ProfileInputField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            TextField("", text: $text)
                .textInputAutocapitalization(.words)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private struct ProfileInputEditor: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let icon: String
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(height: height)
                .padding(12)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}
