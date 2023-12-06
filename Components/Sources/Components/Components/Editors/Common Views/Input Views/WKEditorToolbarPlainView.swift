import Foundation

class WKEditorToolbarPlainView: WKEditorToolbarView {
    
    // MARK: Properties
    
    @IBOutlet private weak var boldButton: WKEditorToolbarButton!
    @IBOutlet private weak var italicsButton: WKEditorToolbarButton!
    @IBOutlet private weak var citationButton: WKEditorToolbarButton!
    @IBOutlet private weak var linkButton: WKEditorToolbarButton!
    @IBOutlet private weak var templateButton: WKEditorToolbarButton!
    @IBOutlet private weak var commentButton: WKEditorToolbarButton!
    
    weak var delegate: WKEditorInputViewDelegate?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        boldButton.setImage(WKSFSymbolIcon.for(symbol: .bold), for: .normal)
        boldButton.addTarget(self, action: #selector(tappedBold), for: .touchUpInside)
        boldButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current?.accessibilityLabelButtonBold

        italicsButton.setImage(WKSFSymbolIcon.for(symbol: .italic), for: .normal)
        italicsButton.addTarget(self, action: #selector(tappedItalics), for: .touchUpInside)
        italicsButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current?.accessibilityLabelButtonItalics

        citationButton.setImage(WKSFSymbolIcon.for(symbol: .quoteOpening), for: .normal)
        citationButton.addTarget(self, action: #selector(tappedCitation), for: .touchUpInside)
        citationButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current?.accessibilityLabelButtonCitation

        linkButton.setImage(WKIcon.link, for: .normal)
        linkButton.addTarget(self, action: #selector(tappedLink), for: .touchUpInside)
        linkButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current?.accessibilityLabelButtonLink

        templateButton.setImage(WKSFSymbolIcon.for(symbol: .curlybraces), for: .normal)
        templateButton.addTarget(self, action: #selector(tappedTemplate), for: .touchUpInside)
        templateButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current?.accessibilityLabelButtonTemplate

        commentButton.setImage(WKIcon.exclamationPointCircle, for: .normal)
        commentButton.addTarget(self, action: #selector(tappedComment), for: .touchUpInside)
        commentButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current?.accessibilityLabelButtonComment
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonSelectionState(_:)), name: Notification.WKSourceEditorSelectionState, object: nil)
    }
    
    // MARK: - Notifications
    
    @objc private func updateButtonSelectionState(_ notification: NSNotification) {
        guard let selectionState = notification.userInfo?[Notification.WKSourceEditorSelectionStateKey] as? WKSourceEditorSelectionState else {
            return
        }
        
        boldButton.isSelected = selectionState.isBold
        italicsButton.isSelected = selectionState.isItalics
        templateButton.isSelected = selectionState.isHorizontalTemplate
    }
    
    // MARK: Button Actions
    
    @objc private func tappedBold() {
        delegate?.didTapBold(isSelected: boldButton.isSelected)
    }

    @objc private func tappedItalics() {
        delegate?.didTapItalics(isSelected: italicsButton.isSelected)
    }

    @objc private func tappedCitation() {
    }

    @objc private func tappedTemplate() {
        delegate?.didTapTemplate(isSelected: templateButton.isSelected)
    }

    @objc private func tappedComment() {
    }

    @objc private func tappedLink() {
    }
}
