import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct Site: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case gathers
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://scorer.com")!
    var name = "Scorer"
    var description = "Scorer is a fun app for friends"
    var language: Language { .english }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
try Site().publish(withTheme: .foundation)
