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
