import SwiftUI

struct CareCircleAuthView: View {
    @EnvironmentObject private var authController: AuthSessionController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var email = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        introCard
                        if authController.isConfigured {
                            emailCard
                        } else {
                            setupCard
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Cloud Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(colorScheme.topBarButtonColor)
                }
            }
        }
    }

    private var introCard: some View {
        GlassCard(tone: .lagoon) {
            Text("FIREBASE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.56))

            Text(authController.statusTitle)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(authController.statusDetail)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            if let email = authController.signedInEmail {
                HStack {
                    Label(email, systemImage: "checkmark.shield.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private var emailCard: some View {
        GlassCard(tone: .apricot) {
            SectionHeader(
                eyebrow: "Magic Link",
                title: "Use one email sign-in for Care Circle",
                detail: "Send a real Firebase email link to this device so Care Circle can move from local preview mode into live shared membership."
            )

            CloudEmailInput(text: $email)

            Button {
                Task {
                    await authController.sendMagicLink(to: email)
                }
            } label: {
                HStack {
                    Label("Send email link", systemImage: "paperplane.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96, pressedBrightness: 0.04))

            #if DEBUG
            Button {
                authController.markSignedIn(email: email.isEmpty ? "developer@auritails.local" : email)
            } label: {
                HStack {
                    Label("Simulate signed-in state", systemImage: "wrench.and.screwdriver.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.12), in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
            #endif

            if case let .linkSent(sentEmail) = authController.phase {
                Text("A real Firebase email link was sent for \(sentEmail). Open it on this device and come back through the app callback to finish sign-in.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var setupCard: some View {
        GlassCard(tone: .twilight) {
            SectionHeader(
                eyebrow: "Configuration",
                title: "Add Firebase config when you're ready",
                detail: "The auth shell is installed, but live sign-in stays dormant until you add GoogleService-Info.plist and the required email-link URL. That keeps today's local-first app behavior unchanged."
            )

            VStack(alignment: .leading, spacing: 10) {
                CloudKeyRow(label: "GoogleService-Info.plist")
                CloudKeyRow(label: "FIREBASE_EMAIL_LINK_URL")
                CloudKeyRow(label: "Firebase Auth email-link enabled")
            }
        }
    }
}

private struct CloudKeyRow: View {
    let label: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct CloudEmailInput: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))

            HStack(spacing: 10) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.62))

                TextField("name@example.com", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}
