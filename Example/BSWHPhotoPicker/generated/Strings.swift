// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// ALL
  internal static var all: String { return L10n.tr("Localizable", "ALL", fallback: "ALL") }
  /// Background
  internal static var background: String { return L10n.tr("Localizable", "Background", fallback: "Background") }
  /// Cancel
  internal static var cancel: String { return L10n.tr("Localizable", "Cancel", fallback: "Cancel") }
  /// Choose A Template
  internal static var chooseATemplate: String { return L10n.tr("Localizable", "ChooseATemplate", fallback: "Choose A Template") }
  /// Christmas
  internal static var christmas: String { return L10n.tr("Localizable", "Christmas", fallback: "Christmas") }
  /// Crop
  internal static var crop: String { return L10n.tr("Localizable", "Crop", fallback: "Crop") }
  /// Done
  internal static var done: String { return L10n.tr("Localizable", "Done", fallback: "Done") }
  /// Duplicate
  internal static var duplicate: String { return L10n.tr("Localizable", "Duplicate", fallback: "Duplicate") }
  /// Flip H
  internal static var flipH: String { return L10n.tr("Localizable", "FlipH", fallback: "Flip H") }
  /// Flip V
  internal static var flipV: String { return L10n.tr("Localizable", "FlipV", fallback: "Flip V") }
  /// General
  internal static var general: String { return L10n.tr("Localizable", "General", fallback: "General") }
  /// Go to Settings
  internal static var gotoSettings: String { return L10n.tr("Localizable", "GotoSettings", fallback: "Go to Settings") }
  /// No Permission
  internal static var noPermission: String { return L10n.tr("Localizable", "NoPermission", fallback: "No Permission") }
  /// Please allow access to the photo library in Settings
  internal static var photoLibrarySettings: String { return L10n.tr("Localizable", "photoLibrarySettings", fallback: "Please allow access to the photo library in Settings") }
  /// Photos
  internal static var photos: String { return L10n.tr("Localizable", "Photos", fallback: "Photos") }
  /// Print
  internal static var print: String { return L10n.tr("Localizable", "Print", fallback: "Print") }
  /// Ratio
  internal static var ratio: String { return L10n.tr("Localizable", "Ratio", fallback: "Ratio") }
  /// Remove
  internal static var remove: String { return L10n.tr("Localizable", "Remove", fallback: "Remove") }
  /// Replace
  internal static var replace: String { return L10n.tr("Localizable", "Replace", fallback: "Replace") }
  /// save
  internal static var save: String { return L10n.tr("Localizable", "save", fallback: "save") }
  /// Social
  internal static var social: String { return L10n.tr("Localizable", "Social", fallback: "Social") }
  /// Stickers
  internal static var stickers: String { return L10n.tr("Localizable", "Stickers", fallback: "Stickers") }
  /// Text
  internal static var text: String { return L10n.tr("Localizable", "Text", fallback: "Text") }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Localize_Swift_bridge(forKey:table:fallbackValue:)(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
