import Testing
@testable import Velari

@Suite("Text Processing")
struct TextProcessingTests {
    @Test func plainTextPassesThrough() {
        let text = "This is plain text with no tags."
        #expect(text.strippedOfCiteTags == text)
    }

    @Test func removesSingleCiteTag() {
        let text = "Some text <cite>reference</cite> more text"
        #expect(text.strippedOfCiteTags == "Some text reference more text")
    }

    @Test func removesCiteTagWithAttributes() {
        let text = "Text <cite data-source=\"1\" class=\"ref\">source</cite> end"
        #expect(text.strippedOfCiteTags == "Text source end")
    }

    @Test func removesMultipleCiteTags() {
        let text = "<cite>A</cite> and <cite>B</cite> and <cite>C</cite>"
        #expect(text.strippedOfCiteTags == "A and B and C")
    }

    @Test func emptyStringReturnsEmpty() {
        #expect("".strippedOfCiteTags == "")
    }

    @Test func textWithoutCiteTagsUnchanged() {
        let text = "<b>Bold</b> and <i>italic</i>"
        #expect(text.strippedOfCiteTags == text)
    }
}
