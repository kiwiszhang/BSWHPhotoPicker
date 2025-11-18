// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length line_length implicit_return

// MARK: - Files

// swiftlint:disable explicit_type_interface identifier_name
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Files {
  internal enum Gif {
    /// first_page_gif.gif
    internal static let firstPageGifGif = File(name: "first_page_gif", ext: "gif", relativePath: "", mimeType: "image/gif")
    /// retrieve_earth.gif
    internal static let retrieveEarthGif = File(name: "retrieve_earth", ext: "gif", relativePath: "", mimeType: "image/gif")
  }
  internal enum Videos {
    /// new-guid-0.mp4
    internal static let newGuid0Mp4 = File(name: "new-guid-0", ext: "mp4", relativePath: "", mimeType: "video/mp4")
    /// new-guid-1.mp4
    internal static let newGuid1Mp4 = File(name: "new-guid-1", ext: "mp4", relativePath: "", mimeType: "video/mp4")
    /// new-guid-2.mp4
    internal static let newGuid2Mp4 = File(name: "new-guid-2", ext: "mp4", relativePath: "", mimeType: "video/mp4")
    /// new-guid-3.mp4
    internal static let newGuid3Mp4 = File(name: "new-guid-3", ext: "mp4", relativePath: "", mimeType: "video/mp4")
    /// new-guid-4.mp4
    internal static let newGuid4Mp4 = File(name: "new-guid-4", ext: "mp4", relativePath: "", mimeType: "video/mp4")
    /// setting_animation.mp4
    internal static let settingAnimationMp4 = File(name: "setting_animation", ext: "mp4", relativePath: "", mimeType: "video/mp4")
  }
}
// swiftlint:enable explicit_type_interface identifier_name
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

internal struct File {
  internal let name: String
  internal let ext: String?
  internal let relativePath: String
  internal let mimeType: String

  internal var url: URL {
    return url(locale: nil)
  }

  internal func url(locale: Locale?) -> URL {
    let bundle = BundleToken.bundle
    let url = bundle.url(
      forResource: name,
      withExtension: ext,
      subdirectory: relativePath,
      localization: locale?.identifier
    )
    guard let result = url else {
      let file = name + (ext.flatMap { ".\($0)" } ?? "")
      fatalError("Could not locate file named \(file)")
    }
    return result
  }

  internal var path: String {
    return path(locale: nil)
  }

  internal func path(locale: Locale?) -> String {
    return url(locale: locale).path
  }
}

// swiftlint:disable convenience_type explicit_type_interface
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type explicit_type_interface
