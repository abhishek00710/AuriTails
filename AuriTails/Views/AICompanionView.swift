import AVFoundation
import Charts
import Combine
import Speech
import SwiftUI

struct AICompanionView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var petSpeakMessage = ""
    @State private var petSpeakTone: PetSpeakTone = .affection
    @State private var petSpeakTranslation: PetSpeakTranslation?
    @StateObject private var petSpeakSpeechInput = PetSpeakSpeechInput()
    @StateObject private var petSpeakSpeaker = PetSpeakSpeaker()
    @FocusState private var isPetSpeakInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        GlassCard(tone: .lagoon) {
                            SectionHeader(
                                eyebrow: "Bond AI",
                                title: "Personalized tips from real rhythm patterns",
                                detail: "This stays intentionally gentle: no fake diagnosis, just thoughtful pattern-based guidance."
                            )

                            HStack(spacing: 12) {
                                StatChip(title: "Insights", value: "\(viewModel.insights.count)")
                                StatChip(title: "Bond score", value: "\(viewModel.bondScore)")
                            }
                        }

                        PetSpeakTranslatorCard(
                            petName: viewModel.displayPetName,
                            species: viewModel.pet.species,
                            message: $petSpeakMessage,
                            inputFocused: $isPetSpeakInputFocused,
                            selectedTone: $petSpeakTone,
                            translation: petSpeakTranslation,
                            isListening: petSpeakSpeechInput.isListening,
                            speechStatus: petSpeakSpeechInput.statusMessage ?? petSpeakSpeaker.statusMessage,
                            isSpeaking: petSpeakSpeaker.isSpeaking
                        ) {
                            isPetSpeakInputFocused = false
                            petSpeakTranslation = PetSpeakTranslator.translate(
                                message: petSpeakMessage,
                                tone: petSpeakTone,
                                petName: viewModel.displayPetName,
                                species: viewModel.pet.species
                            )
                        } listenAction: {
                            isPetSpeakInputFocused = false
                            petSpeakSpeechInput.toggleListening { transcript in
                                petSpeakMessage = transcript
                            }
                        } speakAction: {
                            guard let petSpeakTranslation else { return }
                            petSpeakSpeaker.speak(
                                petSpeakTranslation.phrase,
                                species: viewModel.pet.species,
                                tone: petSpeakTone
                            )
                        }

                        GlassCard {
                            Text("Behavior read")
                                .font(.system(size: 22, weight: .semibold, design: .serif))
                                .foregroundStyle(.white)

                            if viewModel.hasBehaviorData {
                                BehaviorSparkline(snapshots: viewModel.selectedPetBehaviorSnapshots)

                                Text("Energy peaks are healthy, but calmness dips later in the week hint that \(viewModel.displayPetName) does best when active rituals get a softer landing afterward.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.76))
                            } else {
                                Text("Bond AI is waiting for real signals")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("Once you log a few routines, food notes, vaccines, or daily check-ins, Bond AI will shift from setup guidance into real pattern-based insight.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.76))

                                Button {
                                    viewModel.openBehaviorCheckIn()
                                } label: {
                                    Label("Log daily check-in", systemImage: "plus.circle.fill")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.white, in: Capsule())
                                }
                                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
                            }
                        }

                        GlassCard(tone: .twilight) {
                            SectionHeader(
                                eyebrow: "Health trends",
                                title: "What the care pattern is doing over time",
                                detail: "This is where Bond AI reads movement across weight, weekly behavior, and symptom intensity instead of looking at isolated entries."
                            )

                            if viewModel.hasWeightData {
                                AITrendPanel(title: "Weight arc", subtitle: viewModel.weightTrendSummary) {
                                    WeightTrendChart(entries: viewModel.recentWeightEntries, unit: viewModel.preferredWeightUnit)

                                    if let latestWeightEntry = viewModel.latestWeightEntry {
                                        HStack(spacing: 12) {
                                            StatChip(title: "Latest", value: latestWeightEntry.valueLabel, fillsWidth: false)
                                            StatChip(title: "Logs", value: "\(viewModel.recentWeightEntries.count)", fillsWidth: false)
                                        }
                                    }

                                    LazyVStack(spacing: 10) {
                                        ForEach(viewModel.recentWeightEntries.suffix(3).reversed()) { entry in
                                            Button {
                                                viewModel.openWeightEntryEditor(entry.id)
                                            } label: {
                                                HStack(spacing: 12) {
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(entry.valueLabel)
                                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                                            .foregroundStyle(.white)
                                                        Text(entry.loggedLabel)
                                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                                            .foregroundStyle(.white.opacity(0.62))
                                                    }

                                                    Spacer(minLength: 12)

                                                    if !entry.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                        Text(entry.note)
                                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                                            .foregroundStyle(.white.opacity(0.70))
                                                            .multilineTextAlignment(.trailing)
                                                            .lineLimit(2)
                                                    }

                                                    Image(systemName: "pencil.circle.fill")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundStyle(.white.opacity(0.72))
                                                }
                                                .padding(12)
                                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            }
                                            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))
                                        }
                                    }
                                }
                            } else {
                                AIEmptyTrendPanel(
                                    title: "Weight arc",
                                    detail: "Add the first weigh-in and Bond AI will start watching whether the body picture is holding steady, drifting, or recovering.",
                                    buttonTitle: "Add weight",
                                    systemImage: "scalemass.fill"
                                ) {
                                    viewModel.openWeightEntryEditor()
                                }
                            }

                            if viewModel.hasBehaviorData {
                                AITrendPanel(
                                    title: "Behavior rhythm",
                                    subtitle: "Energy, calmness, appetite, and sleep become easier to compare once the week is visible as one shape."
                                ) {
                                    WeeklyBehaviorTrendChart(snapshots: viewModel.selectedPetBehaviorSnapshots)
                                }
                            } else {
                                AIEmptyTrendPanel(
                                    title: "Behavior rhythm",
                                    detail: "Log daily check-ins and this chart will start tracing calmness, appetite, sleep, and energy across the week.",
                                    buttonTitle: "Log check-in",
                                    systemImage: "waveform.path.ecg"
                                ) {
                                    viewModel.openBehaviorCheckIn()
                                }
                            }

                            if viewModel.hasSymptomData {
                                AITrendPanel(
                                    title: "Symptom intensity",
                                    subtitle: "Severity counts help Bond AI tell the difference between light noise and a week that deserves closer observation."
                                ) {
                                    SymptomSeverityChart(counts: viewModel.recentSymptomCounts)
                                }
                            } else {
                                AIEmptyTrendPanel(
                                    title: "Symptom intensity",
                                    detail: "Add symptom notes when something feels off and Bond AI will start showing whether the log is mostly mild or worth closer watch.",
                                    buttonTitle: "Add symptom",
                                    systemImage: "exclamationmark.triangle.fill"
                                ) {
                                    viewModel.openSymptomEditor()
                                }
                            }
                        }

                        ForEach(viewModel.insights) { insight in
                            GlassCard {
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: insight.systemImage)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(insight.priority.tint)
                                        .frame(width: 46, height: 46)
                                        .background(insight.priority.tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(insight.title)
                                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                                .foregroundStyle(.white)

                                            Spacer()

                                            Text(insight.priority.title)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.22))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(insight.priority.tint.opacity(0.95), in: Capsule())
                                        }

                                        Text(insight.detail)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.78))

                                        Text(insight.suggestedAction)
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        isPetSpeakInputFocused = false
                    }
                )
            }
            .navigationTitle("Bond AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        isPetSpeakInputFocused = false
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                }
            }
        }
    }
}

private struct AITrendPanel<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private enum PetSpeakTone: String, CaseIterable, Identifiable {
    case affection
    case dinner
    case play
    case calm

    var id: String { rawValue }

    var title: String {
        switch self {
        case .affection: "Love"
        case .dinner: "Treat"
        case .play: "Play"
        case .calm: "Calm"
        }
    }

    var symbolName: String {
        switch self {
        case .affection: "heart.fill"
        case .dinner: "fork.knife"
        case .play: "tennisball.fill"
        case .calm: "moon.stars.fill"
        }
    }
}

private struct PetSpeakTranslation: Equatable {
    let phrase: String
    let bodyCue: String
    let ritual: String
}

private enum PetSpeakTranslator {
    static func translate(message: String, tone: PetSpeakTone, petName: String, species: String) -> PetSpeakTranslation {
        let cleanedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedMessage = cleanedMessage.isEmpty ? "I am thinking about you" : cleanedMessage
        let lowercasedSpecies = species.lowercased()
        let isCat = lowercasedSpecies.contains("cat") || lowercasedSpecies.contains("tabby") || lowercasedSpecies.contains("kitten")
        let syllables = soundTokens(for: resolvedMessage, tone: tone, isCat: isCat)
        let petVerb = isCat ? "slow blink" : "soft tail wag"
        let greeting = isCat ? "mrrp" : "wuff"
        let closing = isCat ? "prrr" : "boof"

        return PetSpeakTranslation(
            phrase: "\(greeting) \(syllables.joined(separator: " ")) \(closing)",
            bodyCue: "\(petName) may read this best with your voice, relaxed shoulders, and a \(petVerb).",
            ritual: ritual(for: tone, message: resolvedMessage, petName: petName, isCat: isCat)
        )
    }

    private static func soundTokens(for message: String, tone: PetSpeakTone, isCat: Bool) -> [String] {
        let words = message
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
        let fallback = toneSeed(tone: tone, isCat: isCat)
        let source = words.isEmpty ? fallback : words
        let bank = soundBank(tone: tone, isCat: isCat)

        return source.prefix(6).enumerated().map { index, word in
            let value = word.unicodeScalars.reduce(index + tone.rawValue.count) { $0 + Int($1.value) }
            return bank[value % bank.count]
        }
    }

    private static func toneSeed(tone: PetSpeakTone, isCat: Bool) -> [String] {
        switch tone {
        case .affection: ["love", "near", "safe"]
        case .dinner: ["snack", "bowl", "yum"]
        case .play: ["run", "jump", "chase"]
        case .calm: isCat ? ["soft", "blink", "nest"] : ["settle", "easy", "snuggle"]
        }
    }

    private static func soundBank(tone: PetSpeakTone, isCat: Bool) -> [String] {
        if isCat {
            switch tone {
            case .affection: ["mrr", "prrp", "mee", "nya", "rrup"]
            case .dinner: ["mya", "mrrp", "nyam", "mee-ow", "prr"]
            case .play: ["brrt", "mip", "nyaa", "chirp", "rrup"]
            case .calm: ["prrr", "mm", "mew", "sloow", "mrmm"]
            }
        } else {
            switch tone {
            case .affection: ["woof", "ruff", "mmf", "boof", "wuff"]
            case .dinner: ["arf", "nom", "ruff", "wum", "boof"]
            case .play: ["ruff!", "bark", "aroo", "wuff", "yip"]
            case .calm: ["huff", "mmf", "woof", "snoof", "boof"]
            }
        }
    }

    private static func ritual(for tone: PetSpeakTone, message: String, petName: String, isCat: Bool) -> String {
        switch tone {
        case .affection:
            return isCat
                ? "Say it once, offer one slow blink, then let \(petName) choose whether to come closer."
                : "Say it warmly, pause, then reward eye contact with a gentle scratch or tiny treat."
        case .dinner:
            return "Pair the phrase with the same bowl cue each time so \(petName) learns the rhythm, not just the words."
        case .play:
            return isCat
                ? "Say it before wand time or a short chase burst, then stop while \(petName) still wants more."
                : "Say it before toy time, then make the first move small so excitement stays easy to read."
        case .calm:
            return "Use a softer voice than usual. The real translation is your calm pace, not the exact sound."
        }
    }
}

@MainActor
private final class PetSpeakSpeechInput: ObservableObject {
    @Published var isListening = false
    @Published var statusMessage: String?

    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func toggleListening(update: @escaping (String) -> Void) {
        if isListening {
            stopListening()
            return
        }

        requestPermissions { [weak self] isAllowed in
            guard let self else { return }
            if isAllowed {
                self.startListening(update: update)
            } else {
                self.statusMessage = "Voice input needs Microphone and Speech Recognition permission."
            }
        }
    }

    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { speechStatus in
            let handleMicrophonePermission: (Bool) -> Void = { microphoneAllowed in
                Task { @MainActor in completion(speechStatus == .authorized && microphoneAllowed) }
            }

            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission(completionHandler: handleMicrophonePermission)
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission(handleMicrophonePermission)
            }
        }
    }

    private func startListening(update: @escaping (String) -> Void) {
        guard let recognizer, recognizer.isAvailable else {
            statusMessage = "Voice input is not available right now."
            return
        }

        stopListening(shouldClearStatus: false)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
                request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            statusMessage = "Listening... say the phrase for Pet Speak."

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let transcript = result?.bestTranscription.formattedString, !transcript.isEmpty {
                        update(transcript)
                    }

                    if result?.isFinal == true {
                        self.stopListening()
                    } else if let error {
                        self.statusMessage = error.localizedDescription
                        self.stopListening(shouldClearStatus: false)
                    }
                }
            }
        } catch {
            statusMessage = "Could not start voice input: \(error.localizedDescription)"
            stopListening(shouldClearStatus: false)
        }
    }

    private func stopListening(shouldClearStatus: Bool = true) {
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        if shouldClearStatus {
            statusMessage = nil
        }
    }
}

@MainActor
private final class PetSpeakSpeaker: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isSpeaking = false
    @Published var statusMessage: String?

    private var audioPlayer: AVAudioPlayer?
    private let engine = AVAudioEngine()
    private let fallbackPlayer = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100

    func speak(_ phrase: String, species: String, tone: PetSpeakTone) {
        let spokenPhrase = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spokenPhrase.isEmpty else { return }

        stop()

        if let clipURL = bundledClipURL(species: species, tone: tone) {
            configureAudioSession()
            if playBundledClip(at: clipURL) {
                return
            }
        } else {
            reportMissingClip(species: species, tone: tone)
        }

        configureAudioSession()
        playProceduralFallback(seed: spokenPhrase, species: species)
    }

    private func stop() {
        audioPlayer?.stop()
        audioPlayer = nil

        if fallbackPlayer.isPlaying {
            fallbackPlayer.stop()
        }

        isSpeaking = false
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Pet Speak audio session failed: \(error.localizedDescription)")
        }
    }

    private func playBundledClip(at clipURL: URL) -> Bool {
        do {
            let player = try AVAudioPlayer(contentsOf: clipURL)
            player.delegate = self
            player.prepareToPlay()
            audioPlayer = player
            statusMessage = nil
            isSpeaking = true
            player.play()
            return true
        } catch {
            print("Pet Speak bundled audio failed: \(error.localizedDescription)")
            return false
        }
    }

    private func bundledClipURL(species: String, tone: PetSpeakTone) -> URL? {
        let baseName = clipName(species: species, tone: tone)
        let supportedExtensions = ["caf", "wav", "mp3", "m4a"]

        for fileExtension in supportedExtensions {
            if let url = Bundle.main.url(
                forResource: baseName,
                withExtension: fileExtension,
                subdirectory: "PetSpeakAudio"
            ) {
                return url
            }

            if let url = Bundle.main.url(forResource: baseName, withExtension: fileExtension) {
                return url
            }
        }

        return nil
    }

    private func clipName(species: String, tone: PetSpeakTone) -> String {
        let prefix = isCatSpecies(species) ? "cat" : "dog"

        switch tone {
        case .affection:
            return "\(prefix)_love"
        case .dinner:
            return "\(prefix)_treat"
        case .play:
            return "\(prefix)_play"
        case .calm:
            return "\(prefix)_calm"
        }
    }

    private func reportMissingClip(species: String, tone: PetSpeakTone) {
        let baseName = clipName(species: species, tone: tone)
        #if DEBUG
        statusMessage = "Missing real pet sound: add \(baseName).wav, .m4a, .mp3, or .caf in PetSpeakAudio."
        print("Pet Speak missing bundled audio clip: \(baseName)")
        #else
        statusMessage = nil
        #endif
    }

    private func playProceduralFallback(seed: String, species: String) {
        let buffer = isCatSpecies(species)
            ? makeCatBuffer(seed: seed)
            : makeDogBuffer(seed: seed)

        isSpeaking = true
        prepareEngineIfNeeded()

        fallbackPlayer.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
            let speaker = self
            Task { @MainActor in
                speaker?.finishPlayback()
            }
        }

        fallbackPlayer.play()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            finishPlayback()
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            finishPlayback()
        }
    }

    private func finishPlayback() {
        isSpeaking = false
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func prepareEngineIfNeeded() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        if fallbackPlayer.engine == nil {
            engine.attach(fallbackPlayer)
            engine.connect(fallbackPlayer, to: engine.mainMixerNode, format: format)
        }

        guard !engine.isRunning else { return }

        do {
            try engine.start()
        } catch {
            print("Pet Speak audio engine failed: \(error.localizedDescription)")
        }
    }

    private func isCatSpecies(_ species: String) -> Bool {
        let lowercasedSpecies = species.lowercased()
        return lowercasedSpecies.contains("cat")
            || lowercasedSpecies.contains("tabby")
            || lowercasedSpecies.contains("kitten")
    }

    private func makeDogBuffer(seed: String) -> AVAudioPCMBuffer {
        let barkCount = max(2, min(5, seed.split(separator: " ").count))
        let totalDuration = Double(barkCount) * 0.22 + 0.10
        return makeBuffer(duration: totalDuration) { time in
            let barkIndex = Int(time / 0.22)
            let localTime = time - (Double(barkIndex) * 0.22)
            guard barkIndex < barkCount, localTime < 0.145 else { return 0 }

            let envelope = exp(-localTime * 18) * min(localTime * 35, 1)
            let base = 145 + Double((stableSeed(seed) + barkIndex * 37) % 46)
            let growl = sin(2 * .pi * base * time)
            let chest = 0.58 * sin(2 * .pi * (base * 0.52) * time)
            let rasp = 0.18 * sin(2 * .pi * (base * 2.4) * time + sin(time * 90))
            return Float((growl + chest + rasp) * envelope * 0.55)
        }
    }

    private func makeCatBuffer(seed: String) -> AVAudioPCMBuffer {
        let chirpCount = max(2, min(4, seed.split(separator: " ").count))
        let totalDuration = Double(chirpCount) * 0.34 + 0.16
        return makeBuffer(duration: totalDuration) { time in
            let chirpIndex = Int(time / 0.34)
            let localTime = time - (Double(chirpIndex) * 0.34)
            guard chirpIndex < chirpCount, localTime < 0.25 else { return 0 }

            let envelope = sin(.pi * min(localTime / 0.25, 1))
            let start = 520 + Double((stableSeed(seed) + chirpIndex * 53) % 170)
            let end = start * 1.55
            let progress = min(localTime / 0.25, 1)
            let frequency = start + ((end - start) * progress)
            let mew = sin(2 * .pi * frequency * time)
            let purr = 0.20 * sin(2 * .pi * 72 * time)
            return Float((mew + purr) * envelope * 0.34)
        }
    }

    private func makeBuffer(duration: Double, sample: (Double) -> Float) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let channel = buffer.floatChannelData?[0] else { return buffer }

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            channel[frame] = max(-1, min(1, sample(time)))
        }

        return buffer
    }

    private func stableSeed(_ string: String) -> Int {
        string.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
    }
}

private struct PetSpeakTranslatorCard: View {
    let petName: String
    let species: String
    @Binding var message: String
    var inputFocused: FocusState<Bool>.Binding
    @Binding var selectedTone: PetSpeakTone
    let translation: PetSpeakTranslation?
    let isListening: Bool
    let speechStatus: String?
    let isSpeaking: Bool
    let translateAction: () -> Void
    let listenAction: () -> Void
    let speakAction: () -> Void

    var body: some View {
        GlassCard(tone: .apricot) {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(
                    eyebrow: "Pet speak",
                    title: "Turn a human phrase into a playful \(petKind) cue",
                    detail: "For bonding and fun only. This is not a real animal-language translator or behavior diagnosis."
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Human phrase")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))
                        .textCase(.uppercase)
                        .tracking(1.2)

                    HStack(alignment: .center, spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Try: I love you, dinner time, want to play?")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.34))
                                    .padding(.top, 17)
                                    .padding(.leading, 16)
                                    .allowsHitTesting(false)
                            }

                            TextEditor(text: $message)
                                .focused(inputFocused)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                                .frame(minHeight: 74, maxHeight: 112)
                        }
                        .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)

                        Button(action: listenAction) {
                            Image(systemName: isListening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(isListening ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white)
                                .frame(width: 46, height: 46)
                                .background(isListening ? Color.white : Color.white.opacity(0.12), in: Circle())
                                .overlay {
                                    Circle()
                                        .strokeBorder(.white.opacity(0.16), lineWidth: 1)
                                }
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                        .accessibilityLabel(isListening ? "Stop voice input" : "Start voice input")
                    }
                    .padding(2)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(inputFocused.wrappedValue ? Color.white.opacity(0.34) : Color.white.opacity(0.13), lineWidth: 1)
                    }

                    if let speechStatus {
                        Text(speechStatus)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.66))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 10)], spacing: 10) {
                    ForEach(PetSpeakTone.allCases) { tone in
                        Button {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.86)) {
                                selectedTone = tone
                            }
                        } label: {
                            Label(tone.title, systemImage: tone.symbolName)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(selectedTone == tone ? Color(red: 0.10, green: 0.13, blue: 0.22) : .white.opacity(0.76))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTone == tone ? Color.white : Color.white.opacity(0.08), in: Capsule())
                        }
                        .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.96))
                    }
                }

                Button(action: translateAction) {
                    Label("Translate for \(petName)", systemImage: "sparkles")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.97))

                if let translation {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Text(translation.phrase)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: speakAction) {
                                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                                    .frame(width: 46, height: 46)
                                    .background(Color.white, in: Circle())
                            }
                            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.92))
                            .accessibilityLabel("Play pet speak audio")
                        }

                        Text(translation.bodyCue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))

                        Text(translation.ritual)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.70))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private var petKind: String {
        let lowercasedSpecies = species.lowercased()
        if lowercasedSpecies.contains("cat") || lowercasedSpecies.contains("tabby") || lowercasedSpecies.contains("kitten") {
            return "cat"
        }
        if lowercasedSpecies.contains("dog") || lowercasedSpecies.contains("retriever") || lowercasedSpecies.contains("puppy") {
            return "dog"
        }
        return "pet"
    }
}

private struct AIEmptyTrendPanel: View {
    let title: String
    let detail: String
    let buttonTitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Text(detail)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            Button(action: action) {
                Label(buttonTitle, systemImage: systemImage)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.22))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(LiquidGlassButtonStyle(pressScale: 0.95))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct WeightTrendChart: View {
    let entries: [WeightEntry]
    let unit: WeightUnit

    var body: some View {
        Chart(entries) { entry in
            LineMark(
                x: .value("Date", entry.loggedAt),
                y: .value("Weight", entry.displayValue(in: unit))
            )
            .foregroundStyle(Color.white)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

            AreaMark(
                x: .value("Date", entry.loggedAt),
                y: .value("Weight", entry.displayValue(in: unit))
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.white.opacity(0.34), Color.white.opacity(0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            PointMark(
                x: .value("Date", entry.loggedAt),
                y: .value("Weight", entry.displayValue(in: unit))
            )
            .foregroundStyle(Color.white)
            .symbolSize(36)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: min(max(entries.count, 2), 4))) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated).day())
                    }
                }
                .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text("\(amount.formatted(.number.precision(.fractionLength(1)))) \(unit.shortLabel)")
                    }
                }
                .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(height: 210)
    }
}

private struct WeeklyBehaviorTrendChart: View {
    let snapshots: [BehaviorSnapshot]

    var body: some View {
        Chart {
            ForEach(snapshots) { snapshot in
                LineMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Energy", snapshot.energy * 100)
                )
                .foregroundStyle(PaletteTone.apricot.primaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                LineMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Calmness", snapshot.calmness * 100)
                )
                .foregroundStyle(PaletteTone.lagoon.secondaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                LineMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Appetite", snapshot.appetite * 100)
                )
                .foregroundStyle(PaletteTone.meadow.secondaryColor)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                BarMark(
                    x: .value("Day", snapshot.day.shortTitle),
                    y: .value("Sleep", min(max((snapshot.sleepHours / 14) * 100, 0), 100))
                )
                .foregroundStyle(PaletteTone.twilight.secondaryColor.opacity(0.40))
                .cornerRadius(8)
            }
        }
        .chartLegend(position: .bottom, alignment: .leading) {
            HStack(spacing: 12) {
                TrendLegend(color: PaletteTone.apricot.primaryColor, title: "Energy")
                TrendLegend(color: PaletteTone.lagoon.secondaryColor, title: "Calm")
                TrendLegend(color: PaletteTone.meadow.secondaryColor, title: "Appetite")
                TrendLegend(color: PaletteTone.twilight.secondaryColor, title: "Sleep score")
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(height: 240)
    }
}

private struct SymptomSeverityChart: View {
    let counts: [(severity: SymptomSeverity, count: Int)]

    var body: some View {
        Chart(counts, id: \.severity.id) { item in
            BarMark(
                x: .value("Severity", item.severity.title),
                y: .value("Count", item.count)
            )
            .foregroundStyle(color(for: item.severity))
            .cornerRadius(12)
            .annotation(position: .top) {
                Text("\(item.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.white.opacity(0.08))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .chartPlotStyle { plot in
            plot
                .background(.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(height: 180)
    }

    private func color(for severity: SymptomSeverity) -> Color {
        switch severity {
        case .mild: return PaletteTone.meadow.secondaryColor
        case .moderate: return PaletteTone.apricot.primaryColor
        case .urgent: return Color(red: 0.95, green: 0.52, blue: 0.45)
        }
    }
}

private struct TrendLegend: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
    }
}
