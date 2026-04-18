import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics
import Foundation

enum FirebaseTelemetry {
    static func logEvent(_ name: String, parameters: [String: Any?] = [:]) {
        guard FirebaseApp.app() != nil else { return }

        let sanitized = sanitizeParameters(parameters)
        Analytics.logEvent(name, parameters: sanitized.isEmpty ? nil : sanitized)
    }

    static func setUserProperties(authPhase: String, firebaseConfigured: Bool) {
        guard FirebaseApp.app() != nil else { return }

        Analytics.setUserProperty(authPhase, forName: "care_circle_auth_phase")
        Analytics.setUserProperty(firebaseConfigured ? "true" : "false", forName: "firebase_configured")
    }

    static func recordError(
        domain: String,
        code: Int,
        context: String,
        extras: [String: Any?] = [:]
    ) {
        guard FirebaseApp.app() != nil else { return }

        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCustomValue(context, forKey: "telemetry_context")
        crashlytics.setCustomValue(domain, forKey: "telemetry_error_domain")
        crashlytics.setCustomValue(code, forKey: "telemetry_error_code")

        let sanitizedExtras = sanitizeParameters(extras)
        for (key, value) in sanitizedExtras {
            crashlytics.setCustomValue(value, forKey: key)
        }

        let sanitizedError = NSError(
            domain: domain,
            code: code,
            userInfo: [NSLocalizedDescriptionKey: "\(context) failed"]
        )
        crashlytics.record(error: sanitizedError)
    }

    static func record(error: Error, context: String, extras: [String: Any?] = [:]) {
        let nsError = error as NSError
        recordError(
            domain: nsError.domain,
            code: nsError.code,
            context: context,
            extras: extras
        )
    }

    private static func sanitizeParameters(_ parameters: [String: Any?]) -> [String: Any] {
        parameters.reduce(into: [String: Any]()) { result, entry in
            let key = normalizedKey(entry.key)
            guard let value = sanitizeValue(entry.value) else { return }
            result[key] = value
        }
    }

    private static func normalizedKey(_ key: String) -> String {
        let allowed = key.lowercased().map { character -> Character in
            character.isLetter || character.isNumber || character == "_" ? character : "_"
        }
        return String(allowed.prefix(40))
    }

    private static func sanitizeValue(_ value: Any?) -> Any? {
        switch value {
        case let int as Int:
            return int
        case let double as Double:
            return double
        case let bool as Bool:
            return bool ? 1 : 0
        case let string as String:
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }

            if trimmed.contains("@") {
                return "redacted_email"
            }

            if trimmed.count > 64 {
                return String(trimmed.prefix(64))
            }

            return trimmed
        default:
            return nil
        }
    }
}
