import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct RootView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var isShowingSplash = true
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
        .animation(.easeInOut(duration: 0.45), value: isShowingSplash)
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .ai:
                AICompanionView(viewModel: viewModel)
            case .profile:
                ProfileStudioView(viewModel: viewModel)
            case .notificationSettings:
                NotificationSettingsView(viewModel: viewModel)
            case let .behaviorCheckInEditor(day):
                BehaviorCheckInEditorView(viewModel: viewModel, day: day)
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
        .fileImporter(
            isPresented: $viewModel.isImportingBackup,
            allowedContentTypes: [.json]
        ) { result in
            viewModel.handleBackupImport(result: result)
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

                Text(viewModel.selectedTab.headerTitle(for: viewModel.pet.name))
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(colorScheme.topBarTitleColor)

                Text(viewModel.selectedTab.headerSubtitle(ownerName: viewModel.owner.name, petName: viewModel.pet.name))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(colorScheme.topBarTitleColor.opacity(0.72))
            }

            Spacer()

            Button {
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
