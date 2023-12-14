import XCTest
@testable import Components

final class WKSourceEditorTextFrameworkMediatorTests: XCTestCase {
    
    let mediator = {
        let viewModel = WKSourceEditorViewModel(configuration: .full, initialText: "", localizedStrings: WKSourceEditorLocalizedStrings.emptyTestStrings, isSyntaxHighlightingEnabled: true, textAlignment: .left)
        let mediator = WKSourceEditorTextFrameworkMediator(viewModel: viewModel)
        mediator.updateColorsAndFonts()
        return mediator
    }()

    func testBoldItalicsButtonSelectionState() throws {
        
        let text = "One\nTwo '''Three ''Four'' Five''' Six ''Seven'' Eight\nNine"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        // "One"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 0, length: 3))
        XCTAssertFalse(selectionStates1.isBold)
        XCTAssertFalse(selectionStates1.isItalics)
        
        // "Two"
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 4, length: 3))
        XCTAssertFalse(selectionStates2.isBold)
        XCTAssertFalse(selectionStates2.isItalics)
        
        // "Three"
        let selectionStates3 = mediator.selectionState(selectedDocumentRange: NSRange(location: 11, length: 5))
        XCTAssertTrue(selectionStates3.isBold)
        XCTAssertFalse(selectionStates3.isItalics)
        
        // "Four"
        let selectionStates4 = mediator.selectionState(selectedDocumentRange: NSRange(location: 19, length: 4))
        XCTAssertTrue(selectionStates4.isBold)
        XCTAssertTrue(selectionStates4.isItalics)
        
        // "Five"
        let selectionStates5 = mediator.selectionState(selectedDocumentRange: NSRange(location: 26, length: 4))
        XCTAssertTrue(selectionStates5.isBold)
        XCTAssertFalse(selectionStates5.isItalics)
        
        // "Six"
        let selectionStates6 = mediator.selectionState(selectedDocumentRange: NSRange(location: 34, length: 3))
        XCTAssertFalse(selectionStates6.isBold)
        XCTAssertFalse(selectionStates6.isItalics)
        
        // "Seven"
        let selectionStates7 = mediator.selectionState(selectedDocumentRange: NSRange(location: 40, length: 5))
        XCTAssertFalse(selectionStates7.isBold)
        XCTAssertTrue(selectionStates7.isItalics)
        
        // "Eight"
        let selectionStates8 = mediator.selectionState(selectedDocumentRange: NSRange(location: 48, length: 5))
        XCTAssertFalse(selectionStates8.isBold)
        XCTAssertFalse(selectionStates8.isItalics)
        
        // "Nine"
        let selectionStates9 = mediator.selectionState(selectedDocumentRange: NSRange(location: 54, length: 4))
        XCTAssertFalse(selectionStates9.isBold)
        XCTAssertFalse(selectionStates9.isItalics)
    }
    
    func testClosingBoldSelectionStateCursor() throws {
        let text = "One '''Two''' Three"
        mediator.textView.attributedText = NSAttributedString(string: text)

        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 10, length: 0))
        XCTAssertTrue(selectionStates.isBold)
    }
    
    func testClosingItalicsSelectionStateCursor() throws {
        let text = "One ''Two'' Three"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 9, length: 0))
        XCTAssertTrue(selectionStates.isItalics)
    }
    
    func testSelectionSpanningNonFormattedState1() throws {
        let text = "Testing '''bold with {{template}}''' selection that spans nonbold."
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        // "bold with {{template}}"
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 11, length: 22))
        XCTAssertTrue(selectionStates.isBold)
        XCTAssertFalse(selectionStates.isHorizontalTemplate)
    }
    
    func testSelectionSpanningNonFormattedState2() throws {
        let text = "Testing {{template | '''bold'''}} selection that spans nonbold."
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        // "template | '''bold'''"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 10, length: 21))
        XCTAssertFalse(selectionStates1.isBold)
        XCTAssertTrue(selectionStates1.isHorizontalTemplate)
    }
    
    func testHorizontalTemplateButtonSelectionStateCursor() throws {
        let text = "Testing simple {{Currentdate}} template example."
        mediator.textView.attributedText = NSAttributedString(string: text)

        // "Testing"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 4, length: 0))
        XCTAssertFalse(selectionStates1.isHorizontalTemplate)
        
        // "Currentdate"
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 20, length: 0))
        XCTAssertTrue(selectionStates2.isHorizontalTemplate)
        
        // "template"
        let selectionStates3 = mediator.selectionState(selectedDocumentRange: NSRange(location: 33, length: 0))
        XCTAssertFalse(selectionStates3.isHorizontalTemplate)
    }
    
    func testHorizontalTemplateButtonSelectionStateRange() throws {
        let text = "Testing simple {{Currentdate}} template example."
        mediator.textView.attributedText = NSAttributedString(string: text)

        // "Testing"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 4, length: 3))
        XCTAssertFalse(selectionStates1.isHorizontalTemplate)
        
        // "Currentdate"
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 20, length: 3))
        XCTAssertTrue(selectionStates2.isHorizontalTemplate)
        
        // "template"
        let selectionStates3 = mediator.selectionState(selectedDocumentRange: NSRange(location: 33, length: 3))
        XCTAssertFalse(selectionStates3.isHorizontalTemplate)
    }
    
    func testVerticalTemplateStartButtonSelectionStateCursor() throws {
        let text = "{{Infobox officeholder"
        mediator.textView.attributedText = NSAttributedString(string: text)

        // "Testing"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 4, length: 0))
        XCTAssertFalse(selectionStates1.isHorizontalTemplate)
    }
    
    func testVerticalTemplateParameterButtonSelectionStateCursor() throws {
        let text = "| genus = Felis"
        mediator.textView.attributedText = NSAttributedString(string: text)

        // "Testing"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 4, length: 0))
        XCTAssertFalse(selectionStates1.isHorizontalTemplate)
    }
    
    func testVerticalTemplateEndButtonSelectionStateCursor() throws {
        let text = "}}"
        mediator.textView.attributedText = NSAttributedString(string: text)

        // "Testing"
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 1, length: 0))
        XCTAssertFalse(selectionStates1.isHorizontalTemplate)
    }
    
    func testHorizontalTemplateButtonSelectionStateFormattedRange() throws {
        let text = "Testing inner formatted {{cite web | url=https://en.wikipedia.org | title = The '''Free''' Encyclopedia}} template example."
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        // "cite web | url=https://en.wikipedia.org | title = The '''Free''' Encyclopedia"
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 26, length: 77))
        XCTAssertTrue(selectionStates.isHorizontalTemplate)
    }
    
    func testHeadingSelectionState() throws {
        
        let text = "== Test =="
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 3, length: 4))
        XCTAssertTrue(selectionStates1.isHeading)
        XCTAssertFalse(selectionStates1.isSubheading1)
        XCTAssertFalse(selectionStates1.isSubheading2)
        XCTAssertFalse(selectionStates1.isSubheading3)
        XCTAssertFalse(selectionStates1.isSubheading4)
        
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 6, length: 0))
        XCTAssertTrue(selectionStates2.isHeading)
        XCTAssertFalse(selectionStates2.isSubheading1)
        XCTAssertFalse(selectionStates2.isSubheading2)
        XCTAssertFalse(selectionStates2.isSubheading3)
        XCTAssertFalse(selectionStates2.isSubheading4)
    }
    
    func testSubheading1SelectionState() throws {
        
        let text = "=== Test ==="
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 4, length: 4))
        XCTAssertFalse(selectionStates1.isHeading)
        XCTAssertTrue(selectionStates1.isSubheading1)
        XCTAssertFalse(selectionStates1.isSubheading2)
        XCTAssertFalse(selectionStates1.isSubheading3)
        XCTAssertFalse(selectionStates1.isSubheading4)
        
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 6, length: 0))
        XCTAssertFalse(selectionStates2.isHeading)
        XCTAssertTrue(selectionStates2.isSubheading1)
        XCTAssertFalse(selectionStates2.isSubheading2)
        XCTAssertFalse(selectionStates2.isSubheading3)
        XCTAssertFalse(selectionStates2.isSubheading4)
    }
    
    func testSubheading2SelectionState() throws {
        
        let text = "==== Test ===="
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 5, length: 4))
        XCTAssertFalse(selectionStates1.isHeading)
        XCTAssertFalse(selectionStates1.isSubheading1)
        XCTAssertTrue(selectionStates1.isSubheading2)
        XCTAssertFalse(selectionStates1.isSubheading3)
        XCTAssertFalse(selectionStates1.isSubheading4)
        
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 7, length: 0))
        XCTAssertFalse(selectionStates2.isHeading)
        XCTAssertFalse(selectionStates2.isSubheading1)
        XCTAssertTrue(selectionStates2.isSubheading2)
        XCTAssertFalse(selectionStates2.isSubheading3)
        XCTAssertFalse(selectionStates2.isSubheading4)
    }
    
    func testSubheading3SelectionState() throws {
        
        let text = "===== Test ====="
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 6, length: 4))
        XCTAssertFalse(selectionStates1.isHeading)
        XCTAssertFalse(selectionStates1.isSubheading1)
        XCTAssertFalse(selectionStates1.isSubheading2)
        XCTAssertTrue(selectionStates1.isSubheading3)
        XCTAssertFalse(selectionStates1.isSubheading4)
        
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 8, length: 0))
        XCTAssertFalse(selectionStates2.isHeading)
        XCTAssertFalse(selectionStates2.isSubheading1)
        XCTAssertFalse(selectionStates2.isSubheading2)
        XCTAssertTrue(selectionStates2.isSubheading3)
        XCTAssertFalse(selectionStates2.isSubheading4)
    }
    
    func testSubheading4SelectionState() throws {
        
        let text = "====== Test ======"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates1 = mediator.selectionState(selectedDocumentRange: NSRange(location: 7, length: 4))
        XCTAssertFalse(selectionStates1.isHeading)
        XCTAssertFalse(selectionStates1.isSubheading1)
        XCTAssertFalse(selectionStates1.isSubheading2)
        XCTAssertFalse(selectionStates1.isSubheading3)
        XCTAssertTrue(selectionStates1.isSubheading4)
        
        let selectionStates2 = mediator.selectionState(selectedDocumentRange: NSRange(location: 9, length: 0))
        XCTAssertFalse(selectionStates2.isHeading)
        XCTAssertFalse(selectionStates2.isSubheading1)
        XCTAssertFalse(selectionStates2.isSubheading2)
        XCTAssertFalse(selectionStates2.isSubheading3)
        XCTAssertTrue(selectionStates2.isSubheading4)
    }
    
    func testListBulletSingleSelectionState() throws {
        
        let text = "* Test"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 2, length: 4))
        XCTAssertTrue(selectionStates.isBulletSingleList)
        XCTAssertFalse(selectionStates.isBulletMultipleList)
        XCTAssertFalse(selectionStates.isNumberSingleList)
        XCTAssertFalse(selectionStates.isNumberMultipleList)
    }
    
    func testListBulletMultipleSelectionState() throws {
        
        let text = "** Test"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 3, length: 0))
        XCTAssertFalse(selectionStates.isBulletSingleList)
        XCTAssertTrue(selectionStates.isBulletMultipleList)
        XCTAssertFalse(selectionStates.isNumberSingleList)
        XCTAssertFalse(selectionStates.isNumberMultipleList)
    }
    
    func testListNumberSingleSelectionState() throws {
        
        let text = "# Test"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 2, length: 4))
        XCTAssertFalse(selectionStates.isBulletSingleList)
        XCTAssertFalse(selectionStates.isBulletMultipleList)
        XCTAssertTrue(selectionStates.isNumberSingleList)
        XCTAssertFalse(selectionStates.isNumberMultipleList)
    }
    
    func testListNumberMultipleSelectionState() throws {
        
        let text = "## Test"
        mediator.textView.attributedText = NSAttributedString(string: text)
        
        let selectionStates = mediator.selectionState(selectedDocumentRange: NSRange(location: 3, length: 0))
        XCTAssertFalse(selectionStates.isBulletSingleList)
        XCTAssertFalse(selectionStates.isBulletMultipleList)
        XCTAssertFalse(selectionStates.isNumberSingleList)
        XCTAssertTrue(selectionStates.isNumberMultipleList)
    }
}
