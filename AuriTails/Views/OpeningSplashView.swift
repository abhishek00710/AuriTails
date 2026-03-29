import SwiftUI

struct OpeningSplashView: View {
    let ownerName: String
    let petName: String
    let onFinish: () -> Void

    @State private var didStartSequence = false
    @State private var haloBreathing = false
    @State private var artworkLifted = false
    @State private var copyVisible = false
    @State private var loaderAnimating = false
    @State private var isExiting = false

    var body: some View {
        ZStack {
            AppBackground()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    .clear,
                    Color.black.opacity(0.22),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            decorativeGlow

            VStack(spacing: 30) {
                Spacer(minLength: 56)

                splashArtwork

                splashCopy

                loadingFooter

                Spacer(minLength: 56)
            }
            .padding(.horizontal, 28)
        }
        .opacity(isExiting ? 0 : 1)
        .scaleEffect(isExiting ? 1.04 : 1)
        .blur(radius: isExiting ? 8 : 0)
        .onAppear(perform: startSequence)
    }

    private var decorativeGlow: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.99, green: 0.79, blue: 0.56).opacity(0.20))
                .frame(width: 340, height: 340)
                .blur(radius: 24)
                .scaleEffect(haloBreathing ? 1.08 : 0.92)
                .offset(x: -124, y: -302)

            Circle()
                .fill(Color(red: 0.45, green: 0.83, blue: 0.85).opacity(0.18))
                .frame(width: 310, height: 310)
                .blur(radius: 28)
                .scaleEffect(haloBreathing ? 0.94 : 1.10)
                .offset(x: 154, y: -178)

            Ellipse()
                .fill(Color.white.opacity(0.08))
                .frame(width: 420, height: 130)
                .blur(radius: 24)
                .offset(y: 232)
        }
        .animation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true), value: haloBreathing)
        .allowsHitTesting(false)
    }

    private var splashArtwork: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.09))
                .frame(width: 300, height: 300)
                .blur(radius: 18)
                .scaleEffect(haloBreathing ? 1.06 : 0.94)

            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.34),
                                    Color.white.opacity(0.10),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.24), radius: 28, y: 22)

            VStack(spacing: 14) {
                ZStack(alignment: .topLeading) {
                    Image("SplashScene")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 292)
                        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        }

                    Label("Opening \(petName)'s world", systemImage: "sparkles")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.76), in: Capsule())
                        .padding(16)
                }

                HStack(spacing: 10) {
                    SplashPill(title: "Care", value: "Live")
                    SplashPill(title: "Routines", value: "Saved")
                    SplashPill(title: "Memories", value: "Ready")
                }
            }
            .padding(18)
        }
        .frame(maxWidth: 380)
        .frame(height: 410)
        .scaleEffect(artworkLifted ? 1 : 0.90)
        .offset(y: artworkLifted ? 0 : 28)
        .rotationEffect(.degrees(artworkLifted ? 0 : -4))
        .shadow(color: Color(red: 0.47, green: 0.82, blue: 0.84).opacity(0.16), radius: 24, y: 12)
    }

    private var splashCopy: some View {
        VStack(spacing: 12) {
            Text("AuriTails")
                .font(.system(size: 40, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text("A luminous home for \(ownerName) and \(petName).")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)

            Text("Loading rituals, wellness notes, memories, and gentle Bond AI cues.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.70))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
        .opacity(copyVisible ? 1 : 0)
        .offset(y: copyVisible ? 0 : 18)
    }

    private var loadingFooter: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.96),
                                    Color(red: 0.99, green: 0.83, blue: 0.65),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 30, height: 10)
                        .scaleEffect(x: loaderAnimating ? 1 : 0.56, y: loaderAnimating ? 1 : 0.56)
                        .opacity(loaderAnimating ? 1 : 0.34)
                        .animation(
                            .easeInOut(duration: 0.84)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.14),
                            value: loaderAnimating
                        )
                }
            }

            Text("Preparing a softer start...")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.62))
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private func startSequence() {
        guard !didStartSequence else { return }
        didStartSequence = true

        haloBreathing = true
        loaderAnimating = true

        withAnimation(.spring(response: 0.82, dampingFraction: 0.84)) {
            artworkLifted = true
        }

        withAnimation(.easeOut(duration: 0.52).delay(0.18)) {
            copyVisible = true
        }

        Task {
            try? await Task.sleep(for: .milliseconds(2200))

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.42)) {
                    isExiting = true
                }
            }

            try? await Task.sleep(for: .milliseconds(360))
            await MainActor.run {
                onFinish()
            }
        }
    }
}

private struct SplashPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.56))
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
