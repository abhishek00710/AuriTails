import SwiftUI

struct OnboardingFlowView: View {
    @ObservedObject var viewModel: AppViewModel

    @State private var step = 0
    @State private var ownerDraft: OwnerProfile
    @State private var petDraft: PetProfile
    @State private var focus: OnboardingFocus

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        _ownerDraft = State(initialValue: viewModel.owner)
        _petDraft = State(initialValue: viewModel.pet)
        _focus = State(initialValue: viewModel.onboardingFocus)
    }

    var body: some View {
        ZStack {
            AppBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                progressHeader

                currentStep
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                footer
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .interactiveDismissDisabled()
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Welcome to AuriTails")
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Spacer()

                Text("Step \(step + 1) of 3")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.08), in: Capsule())
            }

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index <= step ? .white : .white.opacity(0.18))
                        .frame(height: 8)
                }
            }
        }
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 0:
            welcomeStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case 1:
            detailStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        default:
            focusStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }

    private var welcomeStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                GlassCard(tone: .apricot) {
                    SectionHeader(
                        eyebrow: "Bond-first",
                        title: "One place for care, routines, memories, and gentle AI",
                        detail: "Most pet apps separate the admin from the love. AuriTails keeps both in one cinematic home."
                    )

                    GeometryReader { proxy in
                        let cardWidth = max(0, (proxy.size.width - 14) / 2)

                        HStack(spacing: 14) {
                            RoundedProfilePhoto(
                                imageData: viewModel.ownerPhotoData,
                                role: .owner,
                                height: 190,
                                cornerRadius: 30
                            )
                            .frame(width: cardWidth)

                            RoundedProfilePhoto(
                                imageData: viewModel.petPhotoData,
                                role: .pet,
                                height: 190,
                                cornerRadius: 30
                            )
                            .frame(width: cardWidth)
                        }
                    }
                    .frame(height: 190)
                }

                GlassCard(tone: .lagoon) {
                    onboardingBullet(
                        title: "Care that stays readable",
                        detail: "Vaccines, vet notes, and food cues live in a calm wellness passport."
                    )
                    onboardingBullet(
                        title: "Routines that can breathe",
                        detail: "Add a week plan, shift it, and keep your rhythm without rigid reminder fatigue."
                    )
                    onboardingBullet(
                        title: "Memories that feel alive",
                        detail: "Birthdays and milestones become part of the story instead of floating alone in a gallery."
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    private var detailStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                GlassCard(tone: .lagoon) {
                    SectionHeader(
                        eyebrow: "Quick setup",
                        title: "Make it feel like your own",
                        detail: "You can edit everything later, but these details make the dashboard personal right away."
                    )

                    OnboardingField(title: "Your name", text: $ownerDraft.name, icon: "person.fill")
                    OnboardingField(title: "Location", text: $ownerDraft.location, icon: "mappin.and.ellipse")
                    OnboardingField(title: "Pet name", text: $petDraft.name, icon: "pawprint.fill")
                    OnboardingField(title: "Breed", text: $petDraft.breed, icon: "dog.fill")

                    HStack(spacing: 12) {
                        OnboardingField(title: "Age", text: $petDraft.ageDescription, icon: "birthday.cake.fill")
                        OnboardingField(title: "Favorite treat", text: $petDraft.favoriteTreat, icon: "carrot.fill")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    private var focusStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                GlassCard(tone: .twilight) {
                    SectionHeader(
                        eyebrow: "Start here",
                        title: "Choose the home rhythm you care about most",
                        detail: "This just shapes the first landing experience. The full app stays available either way."
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(OnboardingFocus.allCases) { option in
                            Button {
                                focus = option
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: option.systemImage)
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(option.title)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Text(option.detail)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle((focus == option ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white).opacity(0.78))
                                }
                                .foregroundStyle(focus == option ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white)
                                .frame(maxWidth: .infinity, minHeight: 148, alignment: .topLeading)
                                .padding(16)
                                .background(
                                    focus == option
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.96),
                                                Color.white.opacity(0.82),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(.white.opacity(0.08)),
                                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                                )
                            }
                            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
                        }
                    }
                }

                GlassCard(tone: .meadow) {
                    OwnerPetRow(
                        owner: resolvedOwner,
                        pet: resolvedPet,
                        ownerPhotoData: viewModel.ownerPhotoData,
                        petPhotoData: viewModel.petPhotoData,
                        supportingText: "You can add real photos and richer details from Profile Studio next."
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if step > 0 {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        step -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white.opacity(0.08), in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
            }

            Button {
                advance()
            } label: {
                Label(step == 2 ? "Open AuriTails" : "Continue", systemImage: step == 2 ? "arrow.right.circle.fill" : "arrow.right")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
        }
    }

    private var resolvedOwner: OwnerProfile {
        var owner = ownerDraft
        if owner.name.trimmedOrNil == nil {
            owner.name = viewModel.owner.name
        }
        if owner.location.trimmedOrNil == nil {
            owner.location = viewModel.owner.location
        }
        if owner.headline.trimmedOrNil == nil {
            owner.headline = viewModel.owner.headline
        }
        if owner.note.trimmedOrNil == nil {
            owner.note = viewModel.owner.note
        }
        return owner
    }

    private var resolvedPet: PetProfile {
        var pet = petDraft
        if pet.name.trimmedOrNil == nil {
            pet.name = viewModel.pet.name
        }
        if pet.breed.trimmedOrNil == nil {
            pet.breed = viewModel.pet.breed
        }
        if pet.ageDescription.trimmedOrNil == nil {
            pet.ageDescription = viewModel.pet.ageDescription
        }
        if pet.favoriteTreat.trimmedOrNil == nil {
            pet.favoriteTreat = viewModel.pet.favoriteTreat
        }
        if pet.species.trimmedOrNil == nil {
            pet.species = viewModel.pet.species
        }
        if pet.weightDescription.trimmedOrNil == nil {
            pet.weightDescription = viewModel.pet.weightDescription
        }
        if pet.bondStatement.trimmedOrNil == nil {
            pet.bondStatement = viewModel.pet.bondStatement
        }
        if pet.energySummary.trimmedOrNil == nil {
            pet.energySummary = viewModel.pet.energySummary
        }
        return pet
    }

    private func advance() {
        if step < 2 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                step += 1
            }
        } else {
            viewModel.completeOnboarding(owner: resolvedOwner, pet: resolvedPet, focus: focus)
        }
    }

    private func onboardingBullet(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.99, green: 0.84, blue: 0.67))
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
            }

            Spacer()
        }
    }
}

private struct OnboardingField: View {
    let title: String
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

private extension String {
    var trimmedOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
