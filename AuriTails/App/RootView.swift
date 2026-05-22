import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct RootView: View {
    @ObservedObject var viewModel: AppViewModel
    @EnvironmentObject private var authController: AuthSessionController
    @State private var isShowingSplash = true
    @State private var isPetSwitcherPresented = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .trailing) {
            AppBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                currentScreen
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    TabBarSeparationLayer()
                        .padding(.horizontal, 10)
                        .padding(.bottom, 2)

                    FloatingTabBar(selectedTab: viewModel.selectedTab) { tab in
                        viewModel.selectTab(tab)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
            }
            .opacity(isShowingSplash ? 0.72 : 1)
            .scaleEffect(isShowingSplash ? 1.02 : 1)
            .blur(radius: contentBlurRadius)
            .allowsHitTesting(!viewModel.isMenuPresented && !isShowingSplash)

            if viewModel.isMenuPresented {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        viewModel.closeMenu()
                    }
            }

            if isPetSwitcherPresented {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                            isPetSwitcherPresented = false
                        }
                    }
            }

            if isPetSwitcherPresented {
                GeometryReader { _ in
                    VStack {
                        HStack {
                            petSwitcherPanel
                            Spacer()
                        }
                        .padding(.top, 78)
                        .padding(.leading, 20)

                        Spacer()
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(4)
            }

            if viewModel.isMenuPresented {
                GeometryReader { proxy in
                    HStack {
                        Spacer()

                        ScrollView(showsIndicators: false) {
                            SlideMenuPanel(viewModel: viewModel)
                        }
                        .frame(width: 336)
                        .frame(maxHeight: max(200, proxy.size.height - 92))
                        .padding(.top, 74)
                        .padding(.trailing, 14)
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            if isShowingSplash {
                OpeningSplashView(ownerName: viewModel.owner.name, petName: viewModel.pet.name) {
                    isShowingSplash = false
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: viewModel.isMenuPresented)
        .animation(.spring(response: 0.34, dampingFraction: 0.9), value: isPetSwitcherPresented)
        .animation(.easeInOut(duration: 0.45), value: isShowingSplash)
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .ai:
                AICompanionView(viewModel: viewModel)
            case .profile:
                ProfileStudioView(viewModel: viewModel)
            case .careCircle:
                CareCircleView(viewModel: viewModel)
            case .notificationSettings:
                NotificationSettingsView(viewModel: viewModel)
            case .legalCenter:
                LegalCenterView()
            case let .behaviorCheckInEditor(day):
                BehaviorCheckInEditorView(viewModel: viewModel, day: day)
            case let .weightEntryEditor(entryID):
                WeightEntryEditorView(viewModel: viewModel, entryID: entryID)
            case let .medicationEditor(medicationID):
                MedicationEditorView(viewModel: viewModel, medicationID: medicationID)
            case let .symptomEditor(symptomID):
                SymptomEditorView(viewModel: viewModel, symptomID: symptomID)
            case let .routineEditor(routineID):
                RoutineEditorView(viewModel: viewModel, routineID: routineID)
            case let .memoryEditor(memoryID):
                MemoryEditorView(viewModel: viewModel, memoryID: memoryID)
            case let .vaccineEditor(vaccineID):
                VaccineEditorView(viewModel: viewModel, vaccineID: vaccineID, initialDraft: viewModel.vaccineEditorSeed)
            case let .medicalEntryEditor(entryID):
                MedicalEntryEditorView(viewModel: viewModel, entryID: entryID)
            case let .foodPreferenceEditor(preferenceID):
                FoodPreferenceEditorView(viewModel: viewModel, preferenceID: preferenceID)
            }
        }
        .fileExporter(
            isPresented: $viewModel.isExportingBackup,
            document: viewModel.exportBackupDocument,
            contentType: .json,
            defaultFilename: viewModel.backupFilename
        ) { result in
            viewModel.handleBackupExport(result: result)
        }
        .sheet(isPresented: $viewModel.isImportingBackup) {
            BackupDocumentPicker { result in
                viewModel.handleBackupImport(result: result)
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImportingVaccineDocument,
            allowedContentTypes: [.pdf, .image]
        ) { result in
            viewModel.handleVaccineDocumentImport(result: result)
        }
        .alert(item: $viewModel.backupNotice) { notice in
            Alert(
                title: Text(notice.title),
                message: Text(notice.message),
                dismissButton: .default(Text("OK")) {
                    viewModel.clearBackupNotice()
                }
            )
        }
        .sheet(item: $viewModel.sharePayload) { payload in
            ActivityView(activityItems: payload.items)
        }
        .fullScreenCover(isPresented: $viewModel.isShowingVaccineScanner) {
            VaccineDocumentScannerView(
                onCancel: { viewModel.cancelVaccineScanner() },
                onScan: { pages in viewModel.handleScannedVaccinePages(pages) }
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingFlowView(viewModel: viewModel)
        }
        .task {
            viewModel.handleAuthPhase(authController.phase)
        }
        .onChange(of: authController.phase) { _, phase in
            viewModel.handleAuthPhase(phase)
        }
    }

    private var contentBlurRadius: CGFloat {
        if viewModel.isMenuPresented {
            10
        } else if isShowingSplash {
            8
        } else {
            0
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !viewModel.hasCompletedOnboarding && !isShowingSplash },
            set: { _ in }
        )
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("AuriTails")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(colorScheme.topBarTitleColor.opacity(0.78))

                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                        isPetSwitcherPresented.toggle()
                        viewModel.closeMenu()
                    }
                } label: {
                    HStack(spacing: 8) {
                        CircularProfilePhoto(imageData: viewModel.petPhotoData, role: .pet, size: 30)

                        Text(viewModel.displayPetName)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(colorScheme.topBarTitleColor)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(colorScheme.topBarTitleColor.opacity(0.78))
                            .rotationEffect(.degrees(isPetSwitcherPresented ? 180 : 0))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: colorScheme == .dark
                                            ? [
                                                Color.white.opacity(0.18),
                                                Color.white.opacity(0.08),
                                                Color.black.opacity(0.10)
                                            ]
                                            : [
                                                Color.white.opacity(0.48),
                                                Color.white.opacity(0.24),
                                                Color.black.opacity(0.06)
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
                                colorScheme == .dark
                                ? Color.white.opacity(0.20)
                                : Color.white.opacity(0.34),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.94, pressedBrightness: 0.04))

                Text(viewModel.selectedTab.headerTitle(for: viewModel.pet.name))
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(colorScheme.topBarTitleColor)

                Text(viewModel.selectedTab.headerSubtitle(ownerName: viewModel.owner.name, petName: viewModel.pet.name))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(colorScheme.topBarTitleColor.opacity(0.72))
            }

            Spacer()

            Button {
                isPetSwitcherPresented = false
                viewModel.toggleMenu()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(colorScheme.topBarButtonColor)
                    .frame(width: 48, height: 48)
                    .background(colorScheme.topBarButtonBackground, in: Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(colorScheme.topBarButtonStroke, lineWidth: 1)
                    }
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.88, pressedBrightness: 0.08))
            .accessibilityLabel("Open menu")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var petSwitcherPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Switch Pet")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))

            ForEach(viewModel.activePets) { pet in
                Button {
                    viewModel.selectPet(pet.id)
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                        isPetSwitcherPresented = false
                    }
                } label: {
                    HStack(spacing: 10) {
                        CircularProfilePhoto(imageData: pet.photoData, role: .pet, size: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(pet.name.trimmedOrNil ?? "New pet")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(pet.breed.trimmedOrNil ?? pet.species.trimmedOrNil ?? "Profile ready")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.62))
                        }

                        Spacer(minLength: 0)

                        if pet.id == viewModel.selectedPetID {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(pet.id == viewModel.selectedPetID ? Color.white.opacity(0.12) : Color.white.opacity(0.06))
                    )
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97, pressedBrightness: 0.03))
            }

            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                    isPetSwitcherPresented = false
                }
                viewModel.addPet()
                viewModel.openProfile()
            } label: {
                Label("Add Pet", systemImage: "plus")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96, pressedBrightness: 0.04))
        }
        .padding(16)
        .frame(width: 250)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.16),
                                    Color.white.opacity(0.08),
                                    Color.black.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 20, y: 10)
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch viewModel.selectedTab {
        case .dashboard:
            DashboardView(viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .leading)))
        case .wellness:
            WellnessView(viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .routines:
            RoutinesView(viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .memories:
            MemoriesView(viewModel: viewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct BackupDocumentPicker: UIViewControllerRepresentable {
    let onComplete: (Result<URL, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json, .data], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onComplete: (Result<URL, Error>) -> Void

        init(onComplete: @escaping (Result<URL, Error>) -> Void) {
            self.onComplete = onComplete
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                onComplete(.failure(CocoaError(.fileNoSuchFile)))
                return
            }

            onComplete(.success(url))
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onComplete(.failure(CocoaError(.userCancelled)))
        }
    }
}
