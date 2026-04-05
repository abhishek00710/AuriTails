import Foundation

enum L10n {
    static func tr(_ key: String, default defaultValue: String) -> String {
        NSLocalizedString(key, bundle: .main, value: defaultValue, comment: "")
    }

    static func format(_ key: String, default defaultValue: String, _ arguments: CVarArg...) -> String {
        String(
            format: tr(key, default: defaultValue),
            locale: Locale.autoupdatingCurrent,
            arguments: arguments
        )
    }
}
